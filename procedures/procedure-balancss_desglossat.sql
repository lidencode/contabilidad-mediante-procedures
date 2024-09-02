CREATE DEFINER=`root`@`localhost` PROCEDURE `balancss_desglossat`(IN `_centre_id` INT, IN `_centre_exercici_id` INT, IN `_tipus_compte` VARCHAR(1), IN `_any_mes` VARCHAR(6))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* declarar variables */
	DECLARE result VARCHAR(10) DEFAULT 'OK';
	DECLARE _any VARCHAR(4);
	DECLARE _mes VARCHAR(2);
	DECLARE _mes_inici, _exercici_any, _compte_existeix INT;
	DECLARE _exercici_iniejer VARCHAR(10);
	DECLARE _compte, _balancss_compte_compte, _balancss_compte VARCHAR(12);
	DECLARE _suma_tram1_deure, _suma_tram1_haver DECIMAL(13,2);
	DECLARE _suma_tram2_deure, _suma_tram2_haver DECIMAL(13,2);
	DECLARE _suma_total_deure, _suma_total_haver DECIMAL(13,2);
	DECLARE _compte_titol VARCHAR(50);
	DECLARE _resta_haver_deure, _total_acreedor, _total_deudor DECIMAL(13,2);
	DECLARE _balancss_compte_titol, _balancss_titol VARCHAR(50);
	DECLARE _balancss_compte_sumd, _balancss_compte_sumh DECIMAL(13,2);
	
	DECLARE _sumd01, _sumd02, _sumd03, _sumd04, _sumd05, _sumd06,
	_sumd07, _sumd08, _sumd09, _sumd10, _sumd11, _sumd12,
	_sumh01, _sumh02, _sumh03, _sumh04, _sumh05, _sumh06,
	_sumh07, _sumh08, _sumh09, _sumh10, _sumh11, _sumh12 DECIMAL(13,2);
	
	/* declara cursores */
	DECLARE cursor_eof INTEGER DEFAULT 0;	
	DECLARE cursor_compte CURSOR FOR SELECT DISTINCT compte.compte FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id ORDER BY compte ASC;
	DECLARE cursor_balancss CURSOR FOR SELECT balancss_desglos.compte, balancss_desglos.titol FROM balancss_desglos
		WHERE balancss_desglos.centre_id = _centre_id AND balancss_desglos.centre_exercici_id = _centre_exercici_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_eof = 1;
	
	/* establece año y mes por separado */
	SET _any = LEFT(_any_mes, 4);
	SET _mes = RIGHT(_any_mes, 2);
	
	/* establece mes de inicio */
	SELECT iniejer INTO _exercici_iniejer FROM centre_exercici WHERE centre_exercici.centre_id = _centre_id AND centre_exercici.id = _centre_exercici_id;
	SET _mes_inici = RIGHT(LEFT(_exercici_iniejer, 7), 2);
	
	/* borrar datos de la DB */
	DELETE FROM tmp_balancss WHERE tmp_balancss.centre_id = _centre_id AND tmp_balancss.centre_exercici_id = _centre_exercici_id AND tmp_balancss.tipus_compte = _tipus_compte;
	
	/* bucle sobre comptes */
	SET cursor_eof = 0;
	OPEN cursor_compte;
	get_compte: LOOP
	
		FETCH cursor_compte INTO _compte;
		IF cursor_eof = 1 THEN
			LEAVE get_compte;
		END IF;

		/* acciones sobre _compte actual */
		
		SELECT titol INTO _compte_titol FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte.compte = _compte;
		
		/* guarda sumas de los meses en una tabla temporal */
		SELECT SUM(sumd01), SUM(sumd02), SUM(sumd03), SUM(sumd04), SUM(sumd05), SUM(sumd06), SUM(sumd07), SUM(sumd08), SUM(sumd09), SUM(sumd10), SUM(sumd11), SUM(sumd12),
			SUM(sumh01), SUM(sumh02), SUM(sumh03), SUM(sumh04), SUM(sumh05), SUM(sumh06), SUM(sumh07), SUM(sumh08), SUM(sumh09), SUM(sumh10), SUM(sumh11), SUM(sumh12)
		INTO _sumd01, _sumd02, _sumd03, _sumd04, _sumd05, _sumd06, _sumd07, _sumd08, _sumd09, _sumd10, _sumd11, _sumd12,
			_sumh01, _sumh02, _sumh03, _sumh04, _sumh05, _sumh06, _sumh07, _sumh08, _sumh09, _sumh10, _sumh11, _sumh12
		FROM compte WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id AND compte.compte = _compte;

		DROP TEMPORARY TABLE IF EXISTS tmp_suma_mesos;
		CREATE TEMPORARY TABLE tmp_suma_mesos (
		  tipus VARCHAR(1),
		  mes INT unsigned,
		  suma DECIMAL(13, 2)
		) ENGINE=memory;
		
		INSERT INTO tmp_suma_mesos VALUES
			('D', 1, _sumd01), ('D', 2, _sumd02), ('D', 3, _sumd03), ('D', 4, _sumd04), ('D', 5, _sumd05), ('D', 6, _sumd06),
			('D', 7, _sumd07), ('D', 8, _sumd08), ('D', 9, _sumd09), ('D', 10, _sumd10), ('D', 11, _sumd11), ('D', 12, _sumd12),
			('H', 1, _sumh01), ('H', 2, _sumh02), ('H', 3, _sumh03), ('H', 4, _sumh04), ('H', 5, _sumh05), ('H', 6, _sumh06),
			('H', 7, _sumh07), ('H', 8, _sumh08), ('H', 9, _sumh09), ('H', 10, _sumh10), ('H', 11, _sumh11), ('H', 12, _sumh12);

		/* suma deure y haver según mes inicio/final */
		IF _mes_inici = 1 THEN
			SELECT SUM(suma) INTO _suma_total_deure FROM tmp_suma_mesos WHERE tipus='D' AND mes <= _mes;
			SELECT SUM(suma) INTO _suma_total_haver FROM tmp_suma_mesos WHERE tipus='H' AND mes <= _mes;
		ELSE 
			IF _mes >= 9 THEN

				/* Si el mes dado está entre Septiembre y Diciembre calcula los meses desde septiembre hasta el mes escogido */
				SELECT IFNULL(SUM(suma), 0) INTO _suma_total_deure FROM tmp_suma_mesos WHERE tipus='D' AND (mes <= _mes AND mes >= 9);			
				SELECT IFNULL(SUM(suma), 0) INTO _suma_total_haver FROM tmp_suma_mesos WHERE tipus='H' AND (mes <= _mes AND mes >= 9);		
			ELSE

				/* Si el mes dado es anterior a Septiembre calcula de enero al mes dado y de septiembre a diciembre */
				SELECT IFNULL(SUM(suma), 0) INTO _suma_total_deure FROM tmp_suma_mesos WHERE tipus='D' AND (mes <= _mes OR mes >= 9);			
				SELECT IFNULL(SUM(suma), 0) INTO _suma_total_haver FROM tmp_suma_mesos WHERE tipus='H' AND (mes <= _mes OR mes >= 9);					
			END IF;		
		END IF;
		
		/* calcula acreedor y deudor */
			SET _resta_haver_deure = _suma_total_deure - _suma_total_haver;
			IF _resta_haver_deure < 0 THEN
				SET _total_acreedor = 0;
				SET _total_deudor = ABS(_resta_haver_deure);
			ELSE
				SET _total_acreedor = ABS(_resta_haver_deure);
				SET _total_deudor = 0;
			END IF;
		
		/* INSERTA EL REGISTRO */
		IF _compte_titol <> '' AND (_suma_total_deure <> 0 OR _suma_total_haver <> 0 OR _total_acreedor <> 0 OR _total_deudor <> 0) THEN
			INSERT INTO tmp_balancss (centre_id, centre_exercici_id, mes, anymes, numcompte, titol, deure, haver, acreedor, deudor, tipus_compte)
			VALUES (_centre_id, _centre_exercici_id, _mes, _any_mes, _compte, _compte_titol, _suma_total_deure, _suma_total_haver, _total_acreedor, _total_deudor, _tipus_compte);
		END IF;
		
	END LOOP get_compte;
	CLOSE cursor_compte;

	/* Bucle balancss_desglos */
	SET cursor_eof = 0;	
	OPEN cursor_balancss;
	get_balancss: LOOP
		
		SET cursor_eof = 0;
		FETCH cursor_balancss INTO _balancss_compte, _balancss_titol;

		IF cursor_eof = 1 THEN
			LEAVE get_balancss;
		END IF;	
	
		/* selecciona las sumas de la cuenta del cursor_balancss */
		SELECT LEFT(c.compte, LENGTH(_balancss_compte)), b.titol,
			SUM(sumd01), SUM(sumd02), SUM(sumd03), SUM(sumd04), SUM(sumd05), SUM(sumd06), SUM(sumd07), SUM(sumd08), SUM(sumd09), SUM(sumd10), SUM(sumd11), SUM(sumd12),
			SUM(sumh01), SUM(sumh02), SUM(sumh03), SUM(sumh04), SUM(sumh05), SUM(sumh06), SUM(sumh07), SUM(sumh08), SUM(sumh09), SUM(sumh10), SUM(sumh11), SUM(sumh12)
		INTO _balancss_compte_compte, _balancss_compte_titol,
			_sumd01, _sumd02, _sumd03, _sumd04, _sumd05, _sumd06, _sumd07, _sumd08, _sumd09, _sumd10, _sumd11, _sumd12,
			_sumh01, _sumh02, _sumh03, _sumh04, _sumh05, _sumh06, _sumh07, _sumh08, _sumh09, _sumh10, _sumh11, _sumh12
		FROM compte AS c INNER JOIN balancss_desglos AS b ON b.compte = _balancss_compte
		WHERE c.centre_id = _centre_id AND c.centre_exercici_id = _centre_exercici_id AND c.tipus_compte = 'A' AND LEFT(c.compte, LENGTH(_balancss_compte)) = b.compte
		GROUP BY LEFT(c.compte, LENGTH(_balancss_compte));

		/* crea una tabla temporal para guardar los valores sumados */
		DROP TEMPORARY TABLE IF EXISTS tmp_suma_mesos;
		CREATE TEMPORARY TABLE tmp_suma_mesos (
		  tipus VARCHAR(1),
		  mes INT unsigned,
		  suma DECIMAL(13, 2)
		) ENGINE=memory;
		
		INSERT INTO tmp_suma_mesos VALUES
			('D', 1, _sumd01), ('D', 2, _sumd02), ('D', 3, _sumd03), ('D', 4, _sumd04), ('D', 5, _sumd05), ('D', 6, _sumd06),
			('D', 7, _sumd07), ('D', 8, _sumd08), ('D', 9, _sumd09), ('D', 10, _sumd10), ('D', 11, _sumd11), ('D', 12, _sumd12),
			('H', 1, _sumh01), ('H', 2, _sumh02), ('H', 3, _sumh03), ('H', 4, _sumh04), ('H', 5, _sumh05), ('H', 6, _sumh06),
			('H', 7, _sumh07), ('H', 8, _sumh08), ('H', 9, _sumh09), ('H', 10, _sumh10), ('H', 11, _sumh11), ('H', 12, _sumh12);
		
		/* suma deure y haver según mes inicio/final */
		IF _mes_inici = 1 THEN
			SELECT SUM(suma) INTO _balancss_compte_sumd FROM tmp_suma_mesos WHERE tipus='D' AND mes <= _mes;
			SELECT SUM(suma) INTO _balancss_compte_sumh FROM tmp_suma_mesos WHERE tipus='H' AND mes <= _mes;
		ELSE 
			IF _mes >= 9 THEN
				/* Si el mes dado está entre Septiembre y Diciembre calcula los meses desde septiembre hasta el mes escogido */
				SELECT IFNULL(SUM(suma), 0) INTO _balancss_compte_sumd FROM tmp_suma_mesos WHERE tipus='D' AND (mes <= _mes AND mes >= 9);			
				SELECT IFNULL(SUM(suma), 0) INTO _balancss_compte_sumh FROM tmp_suma_mesos WHERE tipus='H' AND (mes <= _mes AND mes >= 9);		
			ELSE
				/* Si el mes dado es anterior a Septiembre calcula de enero al mes dado y de septiembre a diciembre */
				SELECT IFNULL(SUM(suma), 0) INTO _balancss_compte_sumd FROM tmp_suma_mesos WHERE tipus='D' AND (mes <= _mes OR mes >= 9);			
				SELECT IFNULL(SUM(suma), 0) INTO _balancss_compte_sumh FROM tmp_suma_mesos WHERE tipus='H' AND (mes <= _mes OR mes >= 9);					
			END IF;		
		END IF;		

		/* calcula acreedor y deudor */
		SET _resta_haver_deure = _balancss_compte_sumd - _balancss_compte_sumh;
		IF _resta_haver_deure < 0 THEN
			SET _total_acreedor = 0;
			SET _total_deudor = ABS(_resta_haver_deure);
		ELSE
			SET _total_acreedor = ABS(_resta_haver_deure);
			SET _total_deudor = 0;
		END IF;
				
		SET _compte_existeix = 0;
		SELECT count(*) INTO _compte_existeix FROM tmp_balancss WHERE centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id AND mes = _mes AND anymes = _any_mes AND numcompte = _balancss_compte_compte;
		
		IF _compte_existeix = 0 AND (_balancss_compte_sumd <> 0 OR _balancss_compte_sumh <> 0 OR _total_acreedor <> 0 OR _total_deudor <> 0) THEN
			INSERT INTO tmp_balancss (centre_id, centre_exercici_id, mes, anymes, numcompte, titol, deure, haver, acreedor, deudor, tipus_compte)
			VALUES (_centre_id, _centre_exercici_id, _mes, _any_mes, _balancss_compte_compte, _balancss_compte_titol, _balancss_compte_sumd, _balancss_compte_sumh, _total_acreedor, _total_deudor, _tipus_compte);
		END IF;
				
	END LOOP get_balancss;
	CLOSE cursor_balancss;

	/* devuelve el result */
	SELECT result as `result`;

END