CREATE DEFINER=`abac`@`%` PROCEDURE `traspas_moviments`(IN `$centre_id` INT, IN `$centre_exercici_id` INT, IN `$compte_origen` VARCHAR(12), IN `$compte_desti` VARCHAR(12), IN `$tipus_traspas` INT, IN `$data_traspas` VARCHAR(6), IN `$asentaments_predefinits` VARCHAR(1))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'creat oscar@nextware.es'
BEGIN
	/* variables */
	DECLARE $compte_origen_id, $compte_desti_id INT DEFAULT 0;
	DECLARE $compte_origen_titol VARCHAR(50);
	DECLARE $data_mes_inici, $data_mes_final, $data_any INT;
	DECLARE $data_inici, $data_final DATETIME;
	
	/* calcular fecha inicio-fin */
	SET $data_any = LEFT($data_traspas, 4);
	SET $data_mes_inici = RIGHT($data_traspas, 2);
	
	IF $data_mes_inici = 99 THEN
		SET $data_mes_inici = 1;
		SET $data_mes_final = 12;
		SET $data_inici = CONCAT($data_any, '-01-01');
		SET $data_final = CONCAT($data_any, '-12-31');
	ELSE
		SET $data_mes_final = $data_mes_inici;
		SET $data_inici = CONCAT($data_any, '-', $data_mes_inici, '-01');
		SET $data_final = LAST_DAY($data_inici);
	END IF;

	/* calculos ids de cuentas */
	SELECT id INTO $compte_origen_id FROM compte WHERE compte.`compte` = $compte_origen AND centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;
	SELECT id INTO $compte_desti_id FROM compte WHERE compte.`compte` = $compte_desti AND centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;

	/* 1. asientos predefinidos */
	IF $asentaments_predefinits = 1 THEN
		UPDATE pred_det SET
			pred_det.compte_id = $compte_desti_id,
			pred_det.`compte` = $compte_desti 
		WHERE pred_det.centre_id =  $centre_id AND pred_det.centre_exercici_id = $centre_exercici_id AND pred_det.compte_id = $compte_origen_id AND pred_det.`compte` = $compte_origen;
	END IF;
	
	/* 2. traspasar movimientos */
	UPDATE assentament SET
		assentament.compte_id = $compte_desti_id,
		assentament.`compte` = $compte_desti 
	WHERE assentament.centre_id =  $centre_id AND assentament.centre_exercici_id = $centre_exercici_id AND assentament.compte_id = $compte_origen_id AND assentament.`compte` = $compte_origen
		AND assentament.ano = $data_any AND assentament.mes >= $data_mes_inici AND assentament.mes <= $data_mes_final;
	
	/* 3. traspasar facturas */
	UPDATE fra_det
	LEFT JOIN fra_cab ON (fra_det.fra_cab_id = fra_cab.id)
	SET fra_det.compte_id = $compte_desti_id,
		fra_det.`compte` = $compte_desti 
	WHERE fra_cab.centre_id =  $centre_id AND fra_cab.centre_exercici_id = $centre_exercici_id AND fra_cab.compte_id = $compte_origen_id AND fra_cab.`compte` = $compte_origen
		AND data_fra >= $data_inici AND data_fra <= $data_final;	
	
	UPDATE fra_cab SET
		fra_cab.compte_id = $compte_desti_id,
		fra_cab.`compte` = $compte_desti 
	WHERE fra_cab.centre_id =  $centre_id AND fra_cab.centre_exercici_id = $centre_exercici_id AND fra_cab.compte_id = $compte_origen_id AND fra_cab.`compte` = $compte_origen
		AND data_fra >= $data_inici AND data_fra <= $data_final;	

	UPDATE minutes_det
	LEFT JOIN minutes_cab ON (minutes_det.minutes_cab_id = minutes_cab.id)
	SET minutes_det.compte_id = $compte_desti_id,
		minutes_det.`compte` = $compte_desti
	WHERE minutes_cab.centre_id =  $centre_id AND minutes_cab.centre_exercici_id = $centre_exercici_id AND minutes_cab.compte_id = $compte_origen_id AND minutes_cab.compte_codi = $compte_origen
		AND minutes_cab.ano = $data_any AND minutes_cab.mes >= $data_mes_inici AND minutes_cab.mes <= $data_mes_final;

	UPDATE minutes_cab SET
		minutes_cab.compte_id = $compte_desti_id,
		minutes_cab.compte_codi = $compte_desti 
	WHERE minutes_cab.centre_id =  $centre_id AND minutes_cab.centre_exercici_id = $centre_exercici_id AND minutes_cab.compte_id = $compte_origen_id AND minutes_cab.compte_codi = $compte_origen
		AND minutes_cab.ano = $data_any AND minutes_cab.mes >= $data_mes_inici AND minutes_cab.mes <= $data_mes_final;
	
	/* traspasar inventari */
	IF $tipus_traspas = 4 THEN
		/* se traspasan todos */
		UPDATE inventari SET
			compte_compra_id = $compte_desti_id,
			compte_compra = $compte_desti
		WHERE inventari.centre_id = $centre_id AND inventari.compte_compra_id = $compte_origen_id AND inventari.compte_compra = $compte_origen;
	ELSE
		/* se traspasan solo los del ejercicio */
		UPDATE inventari SET
			compte_compra_id = $compte_desti_id,
			compte_compra = $compte_desti
		WHERE inventari.centre_id = $centre_id AND inventari.centre_exercici_id = $centre_exercici_id AND inventari.compte_compra_id = $compte_origen_id AND inventari.compte_compra = $compte_origen;	
	END IF;
	
	/* traspasar apertura_presupost */
	IF $tipus_traspas = 4 THEN
		UPDATE pressupost SET
			pressupost.compte_id = $compte_desti_id,
			pressupost.`compte` = $compte_desti 
		WHERE pressupost.centre_id =  $centre_id AND pressupost.centre_exercici_id = $centre_exercici_id AND pressupost.compte_id = $compte_origen_id AND pressupost.`compte` = $compte_origen;
	END IF;
	
	/* traspasar título de cuenta */
	IF $tipus_traspas = 2 OR $tipus_traspas = 4 THEN
		SELECT compte.titol INTO $compte_origen_titol FROM compte WHERE compte.id = $compte_origen_id;
		UPDATE compte SET compte.titol = $compte_origen_titol WHERE compte.id = $compte_desti_id;
	END IF;
	
	/* suprimir cuenta origen */
	IF $tipus_traspas = 3 THEN
		/* ... si saldo_inicial = 0 */
		DELETE FROM compte WHERE compte.id = $compte_origen_id AND IFNULL(compte.saldo_inicial, 0) = 0;
	END IF;
	
	IF $tipus_traspas = 4 THEN
		/* ... siempre */
		DELETE FROM compte WHERE compte.id = $compte_origen_id;
	END IF;
	
	/* actualiza cuenta inicial */
	CALL update_compte($centre_id, $centre_exercici_id, $compte_origen);
	
	/* actualiza cuenta destino */
	CALL update_compte($centre_id, $centre_exercici_id, $compte_desti);
END