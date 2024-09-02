CREATE DEFINER=`root`@`localhost` PROCEDURE `check_exercici_compte_mes`(IN `_centre_id` INT, IN `_centre_exercici_id` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* declarar variables */
	DECLARE result VARCHAR(10);
	DECLARE mes, _compte, _check_id INT;
	DECLARE _import_deure, _import_haver, diferencia DECIMAL(13,2);
	
	DECLARE _sumd01, _sumh01, _sumd02, _sumh02, _sumd03, _sumh03, _sumd04, _sumh04 DECIMAL(13,2);
	DECLARE _sumd05, _sumh05, _sumd06, _sumh06, _sumd07, _sumh07, _sumd08, _sumh08 DECIMAL(13,2);
	DECLARE _sumd09, _sumh09, _sumd10, _sumh10, _sumd11, _sumh11, _sumd12, _sumh12 DECIMAL(13,2);
	
	DECLARE cursor_compte_eof INTEGER DEFAULT 0;
	DECLARE cursor_compte CURSOR FOR SELECT DISTINCT compte.compte FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id ORDER BY compte ASC;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_compte_eof = 1;
   
   SET result = 'OK';
   
   /* Calcular un CHECK_ID que identificará los resultados de este proceso único en la tabla */
   SELECT check_id INTO _check_id FROM check_exercici_compte_mes ORDER BY check_id DESC LIMIT 1;
   IF _check_id IS NULL THEN
		SET _check_id = 1;
	ELSE 
		SET _check_id = _check_id + 1;
	END IF;
   
   /* Bucle que devuelve los números de cuenta usados en el ejercicio */
   SET cursor_compte_eof = 0;
   OPEN cursor_compte;
   
   get_compte: LOOP
   
   	FETCH cursor_compte INTO _compte;
   	
   	IF cursor_compte_eof = 1 THEN
			LEAVE get_compte;
		END IF;
   	
   	/* asigna valores "deber" de la cuenta */
		SELECT sumd01, sumd02, sumd03, sumd04, sumd05, sumd06, sumd07, sumd08, sumd09, sumd10, sumd11, sumd12
			INTO _sumd01, _sumd02, _sumd03, _sumd04, _sumd05, _sumd06, _sumd07, _sumd08, _sumd09, _sumd10, _sumd11, _sumd12
			FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte.compte = _compte;

   	/* asigna valores "haber" de la cuenta */
		SELECT sumh01, sumh02, sumh03, sumh04, sumh05, sumh06, sumh07, sumh08, sumh09, sumh10, sumh11, sumh12
			INTO _sumh01, _sumh02, _sumh03, _sumh04, _sumh05, _sumh06, _sumh07, _sumh08, _sumh09, _sumh10, _sumh11, _sumh12
			FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte.compte = _compte;
			
		/* Bucle sobre los 12 meses del año */
		SET mes = 0;
		
		WHILE mes < 12 DO
			SET mes = mes + 1;
			SELECT SUM(assentament.import_deure), SUM(assentament.import_haver) INTO _import_deure, _import_haver FROM assentament WHERE assentament.centre_id = _centre_id AND assentament.centre_exercici_id = _centre_exercici_id AND assentament.compte = _compte AND assentament.mes = mes;
	
			/* check deure */
			SET diferencia = 0;
			
			CASE mes
				WHEN 1 THEN	SET diferencia = _import_deure - _sumd01;
				WHEN 2 THEN	SET diferencia = _import_deure - _sumd02;
				WHEN 3 THEN	SET diferencia = _import_deure - _sumd03;
				WHEN 4 THEN	SET diferencia = _import_deure - _sumd04;
				WHEN 5 THEN	SET diferencia = _import_deure - _sumd05;
				WHEN 6 THEN	SET diferencia = _import_deure - _sumd06;
				WHEN 7 THEN	SET diferencia = _import_deure - _sumd07;
				WHEN 8 THEN	SET diferencia = _import_deure - _sumd08;
				WHEN 9 THEN	SET diferencia = _import_deure - _sumd09;
				WHEN 10 THEN SET diferencia = _import_deure - _sumd10;
				WHEN 11 THEN SET diferencia = _import_deure - _sumd11;
				WHEN 12 THEN SET diferencia = _import_deure - _sumd12;
			END CASE;
			
			IF diferencia <> 0 THEN
				INSERT INTO `check_exercici_compte_mes` (`check_id`, `centre_id`, `centre_exercici_id`, `compte`, `mes`, `diferencia_deure`, `diferencia_haver`)
					VALUES (_check_id, _centre_id, _centre_exercici_id, _compte, mes, diferencia, 0);
				SET result = 'FAIL';
			END IF;
			
			/* check haver */
			SET diferencia = 0;
			
			CASE mes
				WHEN 1 THEN	SET diferencia = _import_haver - _sumh01;
				WHEN 2 THEN	SET diferencia = _import_haver - _sumh02;
				WHEN 3 THEN	SET diferencia = _import_haver - _sumh03;
				WHEN 4 THEN	SET diferencia = _import_haver - _sumh04;
				WHEN 5 THEN	SET diferencia = _import_haver - _sumh05;
				WHEN 6 THEN	SET diferencia = _import_haver - _sumh06;
				WHEN 7 THEN	SET diferencia = _import_haver - _sumh07;
				WHEN 8 THEN	SET diferencia = _import_haver - _sumh08;
				WHEN 9 THEN	SET diferencia = _import_haver - _sumh09;
				WHEN 10 THEN SET diferencia = _import_haver - _sumh10;
				WHEN 11 THEN SET diferencia = _import_haver - _sumh11;
				WHEN 12 THEN SET diferencia = _import_haver - _sumh12;
			END CASE;
			
			/* compara la diferencia */
			IF diferencia <> 0 THEN
				/* si tiene valor es que este mes no cuadra */
				INSERT INTO `check_exercici_compte_mes` (`check_id`, `centre_id`, `centre_exercici_id`, `compte`, `mes`, `diferencia_deure`, `diferencia_haver`)
					VALUES (_check_id, _centre_id, _centre_exercici_id, _compte, mes, 0, diferencia);
				SET result = 'FAIL';
			END IF;
		
		END WHILE;
	
	END LOOP get_compte;
 
	CLOSE cursor_compte;
	
	/* devuelve el resultado */
	SELECT _check_id as `check_id`, result as `result`;

END