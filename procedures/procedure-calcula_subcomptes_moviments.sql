CREATE DEFINER=`root`@`localhost` PROCEDURE `calcula_subcomptes_moviments`(IN `$centre_id` VARCHAR(12), IN `$centre_exercici_id` VARCHAR(12))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* calcula_subcomptes_moviments */
	/* inserta en la tabla tmp_subcomptes_saldos_moviments un extracto de las cuentas con los si tuvieron o no ejercicio anterior y actual, y sus saldos finales en caso que los tuviesen */
	
	/* variables */
	DECLARE $centre_exercici_anterior, $centre_exercici_actual INT;
	DECLARE $compte_compte VARCHAR(12);
	DECLARE $centre_exercici_any VARCHAR(10);
	DECLARE $compte_titol VARCHAR(50);
	DECLARE $saldo_anterior, $saldo_actual DECIMAL(13,2) DEFAULT 0;
	DECLARE $existeix_anterior, $existeix_actual VARCHAR(2) DEFAULT "No";
		
	/* declara cursores */
	DECLARE $EOF INTEGER DEFAULT 0;
	DECLARE $cursor_compte CURSOR FOR SELECT `compte`, `titol` FROM compte WHERE centre_id = $centre_id GROUP BY `compte`;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET $EOF = 1;

	/* borra los datos de la tabla destino */
	DELETE FROM `tmp_subcomptes_saldos_moviments` WHERE centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;

	/* recupera los ejercicios que se van a usar  */
	SELECT any_exercici INTO $centre_exercici_any FROM centre_exercici WHERE id = $centre_exercici_id;
	SELECT IFNULL(id, 0) INTO $centre_exercici_anterior FROM centre_exercici WHERE centre_id = $centre_id AND any_exercici = $centre_exercici_any - 1;
	SELECT IFNULL(id, 0) INTO $centre_exercici_actual FROM centre_exercici WHERE centre_id = $centre_id AND any_exercici = YEAR(NOW());
	
	/* recorre la tabla comptes */
	OPEN $cursor_compte;
	loop_compte: LOOP
	
		SET $EOF = 0;
		FETCH $cursor_compte INTO $compte_compte, $compte_titol;
		IF $EOF = 1 THEN LEAVE loop_compte; END IF;
		
		/* recupera datos del ejercicio anterior y actual */
		SELECT IFNULL(saldo_final, 0) INTO $saldo_anterior FROM compte WHERE compte = $compte_compte AND centre_id = $centre_id AND centre_exercici_id = $centre_exercici_anterior;
		SELECT IFNULL(saldo_final, 0) INTO $saldo_actual FROM compte WHERE compte = $compte_compte AND centre_id = $centre_id AND centre_exercici_id = $centre_exercici_actual;
		
		/* formatea variable de si existen los ejercicios o no */
		SET $existeix_anterior = "No";
		SET $existeix_actual = "No";
		
		IF $centre_exercici_anterior > 0 THEN SET $existeix_anterior = "Si"; END IF;
		IF $centre_exercici_actual > 0 THEN SET $existeix_actual = "Si"; END IF;
		
		/* inserta los datos en la tabla destino */
		INSERT INTO `tmp_subcomptes_saldos_moviments` (`centre_id`,`centre_exercici_id`,`compte`,`titol`,`exercici_anterior`,`saldo_final_anterior`,`exercici_actual`,`saldo_final_actual`)
		VALUES ($centre_id, $centre_exercici_id, $compte_compte, $compte_titol, $existeix_anterior, $saldo_anterior, $existeix_actual, $saldo_actual);
		
	END LOOP loop_compte;
	CLOSE $cursor_compte;
	
	SELECT 'ok' as result;
END