CREATE DEFINER=`root`@`localhost` PROCEDURE `check_exercici_saldo_inicial`(IN `_centre_id` INT, IN `_centre_exercici_id` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* declara variables */
	DECLARE _compte, _check_id, _error INT;
	DECLARE result VARCHAR(10);
	
	DECLARE _saldo_inid, _saldo_inih, _saldo_inicial, _saldo_final, _saldo_inicial_diferencia, _saldo_final_diferencia DECIMAL(13,2);
	DECLARE _sumd01, _sumh01, _sumd02, _sumh02, _sumd03, _sumh03, _sumd04, _sumh04 DECIMAL(13,2);
	DECLARE _sumd05, _sumh05, _sumd06, _sumh06, _sumd07, _sumh07, _sumd08, _sumh08 DECIMAL(13,2);
	DECLARE _sumd09, _sumh09, _sumd10, _sumh10, _sumd11, _sumh11, _sumd12, _sumh12 DECIMAL(13,2);

	DECLARE cursor_compte_eof INTEGER DEFAULT 0;
	DECLARE cursor_compte CURSOR FOR SELECT DISTINCT compte.compte FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id ORDER BY compte ASC;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_compte_eof = 1;

	SET result = 'OK';
	
	/* calcula el CHECK_ID que identificará estas operaciones en la tabla */	
	SELECT check_id INTO _check_id FROM check_exercici_saldo_inicial ORDER BY check_id DESC LIMIT 1;
	IF _check_id IS NULL THEN
		SET _check_id = 1;
	ELSE 
		SET _check_id = _check_id + 1;
	END IF;
	
	/* Bucle sobre los números de cuenta usados en el ejercicio */
	SET cursor_compte_eof = 0;
	OPEN cursor_compte;
	
	get_compte: LOOP
	
		FETCH cursor_compte INTO _compte;
	
		IF cursor_compte_eof = 1 THEN
			LEAVE get_compte;
		END IF;
		
		/* recupera la suma de saldos haber/deber del ejercicio */
		SELECT saldo_inid, saldo_inih, saldo_inicial, saldo_final, sumd01, sumd02, sumd03, sumd04, sumd05, sumd06, sumd07, sumd08, sumd09, sumd10, sumd11, sumd12,
				sumh01, sumh02, sumh03, sumh04, sumh05, sumh06, sumh07, sumh08, sumh09, sumh10, sumh11, sumh12
			INTO _saldo_inid, _saldo_inih, _saldo_inicial, _saldo_final, _sumd01, _sumd02, _sumd03, _sumd04, _sumd05, _sumd06, _sumd07, _sumd08, _sumd09, _sumd10, _sumd11, _sumd12,
				_sumh01, _sumh02, _sumh03, _sumh04, _sumh05, _sumh06, _sumh07, _sumh08, _sumh09, _sumh10, _sumh11, _sumh12
			FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte.compte = _compte LIMIT 1;
			
		SET _error = 0;
		
		/* si hay diferencia entre el saldo inicial haber y deber establece que hay un error */
		SET _saldo_inicial_diferencia = (_saldo_inid - _saldo_inih) - _saldo_inicial;
		if _saldo_inicial_diferencia <> 0 THEN
			SET _error = 1;
		END IF;

		/* si hay una diferencia entre la suma de saldo inicial + suma de saldos de cada mes con el saldo final, establece que hay un error */
		SET _saldo_final_diferencia = (_saldo_inicial + _sumd01 + _sumd02 + _sumd03 + _sumd04 + _sumd05 + _sumd06 + _sumd07 + _sumd08 + _sumd09 + _sumd10 + _sumd11 + _sumd12 -
			_sumh01 - _sumh02 - _sumh03 - _sumh04 - _sumh05 - _sumh06 - _sumh07 - _sumh08 - _sumh09 - _sumh10 - _sumh11 - _sumh12) - _saldo_final;
		if _saldo_final_diferencia <> 0 THEN
			SET _error = 1;
		END IF;
		
		/* si ha habido un error, lo introduce en la tabla */
		if _error = 1 THEN
			INSERT INTO check_exercici_saldo_inicial (`check_id`, `centre_id`, `centre_exercici_id`, `compte`, `saldo_inih`, `saldo_inid`, `saldo_inicial`, `saldo_inicial_diferencia`, `saldo_final`, `saldo_final_diferencia`)
			VALUES (_check_id, _centre_id, _centre_exercici_id, _compte, _saldo_inih, _saldo_inid, _saldo_inicial, _saldo_inicial_diferencia, _saldo_final, _saldo_final_diferencia);
			SET result = 'FAIL';
		END IF;

	END LOOP get_compte;

	CLOSE cursor_compte;
	
	/* devuelve los resultados */
	SELECT _check_id as `check_id`, result as `result`;

END