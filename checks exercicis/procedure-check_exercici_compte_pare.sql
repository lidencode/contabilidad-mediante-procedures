CREATE DEFINER=`root`@`localhost` PROCEDURE `check_exercici_compte_pare`(IN `_centre_id` INT, IN `_centre_exercici_id` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* declara las variables */
	DECLARE result VARCHAR(10);
	DECLARE mes, _compte, _compte_pare, _check_id INT;
	
	DECLARE _saldo_inid_pare, _saldo_inih_pare, _saldo_inicial_pare, _saldo_final_pare, _saldo_inicial_diferencia_pare, _saldo_final_diferencia_pare DECIMAL(13,2);
	DECLARE _sumd01_pare, _sumh01_pare, _sumd02_pare, _sumh02_pare, _sumd03_pare, _sumh03_pare, _sumd04_pare, _sumh04_pare DECIMAL(13,2);
	DECLARE _sumd05_pare, _sumh05_pare, _sumd06_pare, _sumh06_pare, _sumd07_pare, _sumh07_pare, _sumd08_pare, _sumh08_pare DECIMAL(13,2);
	DECLARE _sumd09_pare, _sumh09_pare, _sumd10_pare, _sumh10_pare, _sumd11_pare, _sumh11_pare, _sumd12_pare, _sumh12_pare DECIMAL(13,2);
	
	DECLARE _saldo_inid_suma, _saldo_inih_suma, _saldo_inicial_suma, _saldo_final_suma, _saldo_inicial_diferencia_suma, _saldo_final_diferencia_suma DECIMAL(13,2);
	DECLARE _sumd01_suma, _sumh01_suma, _sumd02_suma, _sumh02_suma, _sumd03_suma, _sumh03_suma, _sumd04_suma, _sumh04_suma DECIMAL(13,2);
	DECLARE _sumd05_suma, _sumh05_suma, _sumd06_suma, _sumh06_suma, _sumd07_suma, _sumh07_suma, _sumd08_suma, _sumh08_suma DECIMAL(13,2);
	DECLARE _sumd09_suma, _sumh09_suma, _sumd10_suma, _sumh10_suma, _sumd11_suma, _sumh11_suma, _sumd12_suma, _sumh12_suma DECIMAL(13,2);
	
	DECLARE _saldo_inid_diferencia, _saldo_inih_diferencia, _saldo_inicial_diferencia, _saldo_final_diferencia, _saldo_inicial_diferencia_diferencia, _saldo_final_diferencia_diferencia DECIMAL(13,2);
	DECLARE _sumd01_diferencia, _sumh01_diferencia, _sumd02_diferencia, _sumh02_diferencia, _sumd03_diferencia, _sumh03_diferencia, _sumd04_diferencia, _sumh04_diferencia DECIMAL(13,2);
	DECLARE _sumd05_diferencia, _sumh05_diferencia, _sumd06_diferencia, _sumh06_diferencia, _sumd07_diferencia, _sumh07_diferencia, _sumd08_diferencia, _sumh08_diferencia DECIMAL(13,2);
	DECLARE _sumd09_diferencia, _sumh09_diferencia, _sumd10_diferencia, _sumh10_diferencia, _sumd11_diferencia, _sumh11_diferencia, _sumd12_diferencia, _sumh12_diferencia DECIMAL(13,2);
	
	DECLARE cursor_compte_eof INTEGER DEFAULT 0;
	DECLARE cursor_compte CURSOR FOR SELECT DISTINCT compte.compte FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte.compte_pare IS NULL ORDER BY compte ASC;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_compte_eof = 1;
   
   SET result = 'OK';
   
   /* Calcula el CHECK_ID único que se usará para identificar estas operaciones en la tabla */
   SELECT check_id INTO _check_id FROM check_exercici_compte_pare ORDER BY check_id DESC LIMIT 1;
   IF _check_id IS NULL THEN
		SET _check_id = 1;
	ELSE 
		SET _check_id = _check_id + 1;
	END IF;
   
	/* Bucle sobre los números de cuenta que usa el ejercicio */
   SET cursor_compte_eof = 0;
   OPEN cursor_compte;
   
   get_compte: LOOP
   
   	FETCH cursor_compte INTO _compte_pare;
   	
   	IF cursor_compte_eof = 1 THEN
			LEAVE get_compte;
		END IF;
   	
   	/* carga los saldos de la cuenta padre */
		SELECT saldo_inid, saldo_inih, saldo_inicial, saldo_final, sumd01, sumd02, sumd03, sumd04, sumd05, sumd06, sumd07, sumd08, sumd09, sumd10, sumd11, sumd12,
			sumh01, sumh02, sumh03, sumh04, sumh05, sumh06, sumh07, sumh08, sumh09, sumh10, sumh11, sumh12
		INTO _saldo_inid_pare, _saldo_inih_pare, _saldo_inicial_pare, _saldo_final_pare,
			_sumd01_pare, _sumh01_pare, _sumd02_pare, _sumh02_pare, _sumd03_pare, _sumh03_pare, _sumd04_pare, _sumh04_pare,
			_sumd05_pare, _sumh05_pare, _sumd06_pare, _sumh06_pare, _sumd07_pare, _sumh07_pare, _sumd08_pare, _sumh08_pare,
			_sumd09_pare, _sumh09_pare, _sumd10_pare, _sumh10_pare, _sumd11_pare, _sumh11_pare, _sumd12_pare, _sumh12_pare
		FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte = _compte_pare LIMIT 1;
		
		/* carga los saldos de la cuenta */
		SELECT IFNULL(SUM(saldo_inid), 0), IFNULL(SUM(saldo_inih), 0), IFNULL(SUM(saldo_inicial), 0), IFNULL(SUM(saldo_final), 0), IFNULL(SUM(sumd01), 0), IFNULL(SUM(sumd02), 0), IFNULL(SUM(sumd03), 0), IFNULL(SUM(sumd04), 0), IFNULL(SUM(sumd05), 0), IFNULL(SUM(sumd06), 0),
			IFNULL(SUM(sumd07), 0), IFNULL(SUM(sumd08), 0), IFNULL(SUM(sumd09), 0), IFNULL(SUM(sumd10), 0), IFNULL(SUM(sumd11), 0), IFNULL(SUM(sumd12), 0),
			IFNULL(SUM(sumh01), 0), IFNULL(SUM(sumh02), 0), IFNULL(SUM(sumh03), 0), IFNULL(SUM(sumh04), 0), IFNULL(SUM(sumh05), 0), IFNULL(SUM(sumh06), 0),
			IFNULL(SUM(sumh07), 0), IFNULL(SUM(sumh08), 0), IFNULL(SUM(sumh09), 0), IFNULL(SUM(sumh10), 0), IFNULL(SUM(sumh11), 0), IFNULL(SUM(sumh12), 0)
		INTO _saldo_inid_suma, _saldo_inih_suma, _saldo_inicial_suma, _saldo_final_suma,
			_sumd01_suma, _sumh01_suma, _sumd02_suma, _sumh02_suma, _sumd03_suma, _sumh03_suma, _sumd04_suma, _sumh04_suma,
			_sumd05_suma, _sumh05_suma, _sumd06_suma, _sumh06_suma, _sumd07_suma, _sumh07_suma, _sumd08_suma, _sumh08_suma,
			_sumd09_suma, _sumh09_suma, _sumd10_suma, _sumh10_suma, _sumd11_suma, _sumh11_suma, _sumd12_suma, _sumh12_suma
		FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte_pare = _compte_pare;		

		/* hace calculo diferencia entre saldo cuenta padre y saldo cuenta */
		SET _saldo_inid_diferencia = _saldo_inid_pare - _saldo_inid_suma;
		SET _saldo_inih_pare = _saldo_inih_pare - _saldo_inih_suma;
		SET _saldo_inicial_diferencia = _saldo_inicial_pare - _saldo_inicial_suma;
		SET _saldo_final_diferencia = _saldo_final_pare - _saldo_final_suma;		
		SET _sumd01_diferencia = _sumd01_pare - _sumd01_suma;
		SET _sumd02_diferencia = _sumd02_pare - _sumd02_suma;
		SET _sumd03_diferencia = _sumd03_pare - _sumd03_suma;
		SET _sumd04_diferencia = _sumd04_pare - _sumd04_suma;
		SET _sumd05_diferencia = _sumd05_pare - _sumd05_suma;
		SET _sumd06_diferencia = _sumd06_pare - _sumd06_suma;
		SET _sumd07_diferencia = _sumd07_pare - _sumd07_suma;
		SET _sumd08_diferencia = _sumd08_pare - _sumd08_suma;
		SET _sumd09_diferencia = _sumd09_pare - _sumd09_suma;
		SET _sumd10_diferencia = _sumd10_pare - _sumd10_suma;
		SET _sumd11_diferencia = _sumd11_pare - _sumd11_suma;
		SET _sumd12_diferencia = _sumd12_pare - _sumd12_suma;
		SET _sumh01_diferencia = _sumh01_pare - _sumh01_suma;
		SET _sumh02_diferencia = _sumh02_pare - _sumh02_suma;
		SET _sumh03_diferencia = _sumh03_pare - _sumh03_suma;
		SET _sumh04_diferencia = _sumh04_pare - _sumh04_suma;
		SET _sumh05_diferencia = _sumh05_pare - _sumh05_suma;
		SET _sumh06_diferencia = _sumh06_pare - _sumh06_suma;
		SET _sumh07_diferencia = _sumh07_pare - _sumh07_suma;
		SET _sumh08_diferencia = _sumh08_pare - _sumh08_suma;
		SET _sumh09_diferencia = _sumh09_pare - _sumh09_suma;
		SET _sumh10_diferencia = _sumh10_pare - _sumh10_suma;
		SET _sumh11_diferencia = _sumh11_pare - _sumh11_suma;
		SET _sumh12_diferencia = _sumh12_pare - _sumh12_suma;
		
		/* si existe alguna diferencia ... */
		IF _saldo_inid_diferencia <> 0 OR _saldo_inih_pare <> 0 OR _saldo_inicial_diferencia <> 0 OR _saldo_final_diferencia <> 0 OR 
			_sumd01_diferencia <> 0 OR _sumd02_diferencia <> 0 OR _sumd03_diferencia <> 0 OR _sumd04_diferencia <> 0 OR _sumd05_diferencia <> 0 OR _sumd06_diferencia <> 0 OR
			_sumd07_diferencia <> 0 OR _sumd08_diferencia <> 0 OR _sumd09_diferencia <> 0 OR _sumd10_diferencia <> 0 OR _sumd11_diferencia <> 0 OR _sumd12_diferencia <> 0 OR
			_sumh01_diferencia <> 0 OR _sumh02_diferencia <> 0 OR _sumh03_diferencia <> 0 OR _sumh04_diferencia <> 0 OR _sumh05_diferencia <> 0 OR _sumh06_diferencia <> 0 OR
			_sumh07_diferencia <> 0 OR _sumh08_diferencia <> 0 OR _sumh09_diferencia <> 0 OR _sumh10_diferencia <> 0 OR _sumh11_diferencia <> 0 OR _sumh12_diferencia <> 0
		THEN
			/* si existe alguna diferencia inserta el error en la tabla */
			SET result = 'FAIL';
			INSERT INTO check_exercici_compte_pare (check_id, centre_id, centre_exercici_id, `compte`, diferencia_saldo_inid, diferencia_saldo_inih, diferencia_saldo_inicial, diferencia_saldo_final,
				diferencia_sumd01, diferencia_sumd02, diferencia_sumd03, diferencia_sumd04, diferencia_sumd05, diferencia_sumd06,
				diferencia_sumd07, diferencia_sumd08, diferencia_sumd09, diferencia_sumd10, diferencia_sumd11, diferencia_sumd12,
				diferencia_sumh01, diferencia_sumh02, diferencia_sumh03, diferencia_sumh04, diferencia_sumh05, diferencia_sumh06,
				diferencia_sumh07, diferencia_sumh08, diferencia_sumh09, diferencia_sumh10, diferencia_sumh11, diferencia_sumh12)
			VALUES (_check_id, _centre_id, _centre_exercici_id, _compte_pare, _saldo_inid_diferencia, _saldo_inih_pare, _saldo_inicial_diferencia, _saldo_final_diferencia,
				_sumd01_diferencia, _sumd02_diferencia, _sumd03_diferencia, _sumd04_diferencia, _sumd05_diferencia, _sumd06_diferencia,
				_sumd07_diferencia, _sumd08_diferencia, _sumd09_diferencia, _sumd10_diferencia, _sumd11_diferencia, _sumd12_diferencia,
				_sumh01_diferencia, _sumh02_diferencia, _sumh03_diferencia, _sumh04_diferencia, _sumh05_diferencia, _sumh06_diferencia,
				_sumh07_diferencia, _sumh08_diferencia, _sumh09_diferencia, _sumh10_diferencia, _sumh11_diferencia, _sumh12_diferencia);
		END IF;
		
	END LOOP get_compte;
 
	CLOSE cursor_compte;
	
	/* devuelve el resultado */
	SELECT _check_id as `check_id`, result as `result`;
END