CREATE DEFINER=`root`@`localhost` PROCEDURE `inventari_prepara_compara`(IN `_centre_id` INT, IN `_centre_exercici_id` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	/* variables */
	DECLARE _compte INT;
	DECLARE _suma_assentament_deure, _suma_assentament_haver, _suma_inventari_compra, _suma_inventari_acumulat DECIMAL(13,2);
	DECLARE _import_error, _amortitza_error INT DEFAULT 0;
	
	/* declara el cursor para inv_comptes */
	DECLARE cursor_eof INTEGER DEFAULT 0;
	DECLARE cursor_compte_inv CURSOR FOR SELECT DISTINCT compte_codi FROM inv_comptes WHERE centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id ORDER BY compte_codi ASC;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_eof = 1;
	
	/* borrar los datos de la tabla tmp_inventari_compara de este ejercicio */
	DELETE FROM tmp_inventari_compara WHERE centre_id = _centre_id AND _centre_exercici_id = _centre_exercici_id;
	
	/* recorre la tabla inv_comptes */
	SET cursor_eof = 0;
	OPEN cursor_compte_inv;
	get_compte_inv: LOOP
	
		FETCH cursor_compte_inv INTO _compte;
	
		IF cursor_eof = 1 THEN
			LEAVE get_compte_inv;
		END IF;
		
		/* recupera los dos pares de sumas de assentament/inventari */
		SELECT SUM(import_deure), SUM(import_haver) INTO _suma_assentament_deure, _suma_assentament_haver FROM assentament 
		 WHERE LEFT(assentament.compte, LENGTH(_compte)) = _compte AND centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id;

		SELECT SUM(import_compra), SUM(import_acumulat) INTO _suma_inventari_compra, _suma_inventari_acumulat FROM inventari 
		 WHERE LEFT(compte_compra, LENGTH(_compte)) = _compte AND centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id;
		
		/* si son null los establece como 0 para que no de error en la comparación */
		IF ISNULL(_suma_assentament_deure) = TRUE THEN
			SET _suma_assentament_deure = 0;
		END IF;

		IF ISNULL(_suma_assentament_haver) = TRUE THEN
			SET _suma_assentament_haver = 0;
		END IF;
		
		IF ISNULL(_suma_inventari_compra) = TRUE THEN
			SET _suma_inventari_compra = 0;
		END IF;
		
		IF ISNULL(_suma_inventari_acumulat) = TRUE THEN
			SET _suma_inventari_acumulat = 0;
		END IF;
				
		/* hace las comparaciones */
		SET _import_error = 0;
		SET _amortitza_error = 0;
		
		IF _suma_assentament_deure <> _suma_inventari_compra THEN
			SET _import_error = 1;
		END IF;

		IF _suma_assentament_haver <> _suma_inventari_acumulat THEN
			SET _amortitza_error = 1;
		END IF;
		
		/* inserta el registro */		
		INSERT INTO tmp_inventari_compara SET
			centre_id = _centre_id,
			centre_exercici_id = _centre_exercici_id,
			compte = _compte,
			import_error = _import_error,
			import_compta = _suma_assentament_deure,
			import_inventari = _suma_inventari_compra,
			amortitza_error = _amortitza_error,
			amortitza_compta = _suma_assentament_haver,
			amortiza_inventari = _suma_inventari_acumulat;

	END LOOP get_compte_inv;
	CLOSE cursor_compte_inv;
	
	/* devuelve el result */
	SELECT 'ok' as result;
END