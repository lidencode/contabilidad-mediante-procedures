CREATE DEFINER=`abac`@`%` PROCEDURE `genera_assentaments_no_comptables`(IN `$centre_id` VARCHAR(12), IN `$centre_exercici_id` VARCHAR(12), IN `$id_ass_no_comptable` INT, IN `$adata` DATE, IN `$concepte` VARCHAR(50))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'creat oscar@nextware.es'
BEGIN
	/* variables */
	DECLARE $assentament_cab_id INT;
	DECLARE $assentament_deure, $assentament_haver DECIMAL(13,2);
	DECLARE $compte_codi1, $compte_codi2, $compte_codi3, $compte_codi4, $compte_codi5, $compte_codi6, $compte_codi7, $compte_codi8, $compte_codi9 INT;
	DECLARE $signe1, $signe2, $signe3, $signe4, $signe5, $signe6, $signe7, $signe8, $signe9 VARCHAR(1);
	DECLARE $import1, $import2, $import3, $import4, $import5, $import6, $import7, $import8, $import9 DECIMAL(13,2);
	
	/* declara cursores */
	DECLARE $EOF INTEGER DEFAULT 0;
	DECLARE $cursor_taula CURSOR FOR SELECT compte_codi1, signe1, import1, compte_codi2, signe2, import2, compte_codi3, signe3, import3, compte_codi4, signe4, import4, compte_codi5, signe5, import5,
			compte_codi6, signe6, import6, compte_codi7, signe7, import7, compte_codi8, signe8, import8, compte_codi9, signe9, import9
		FROM tmp_ass_no_compables_pantalla
		WHERE centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET $EOF = 1;
	
	/* crea assentament_cab */
	SET $assentament_cab_id = assentament_cab_crea($centre_id, $centre_exercici_id, null, $adata);
	
	/* recorre la tabla comptes */
	OPEN $cursor_taula;
	loop_taula: LOOP
	
		/* resetea variables clave */
		SET $EOF = 0;
		SET $compte_codi1 = 0;
		SET $compte_codi2 = 0;
		SET $compte_codi3 = 0;
		SET $compte_codi4 = 0;
		SET $compte_codi5 = 0;
		SET $compte_codi6 = 0;
		SET $compte_codi7 = 0;
		SET $compte_codi8 = 0;
		SET $compte_codi9 = 0;
		
		FETCH $cursor_taula INTO $compte_codi1, $signe1, $import1, $compte_codi2, $signe2, $import2, $compte_codi3, $signe3, $import3, $compte_codi4, $signe4, $import4, $compte_codi5, $signe5, $import5,
			$compte_codi6, $signe6, $import6, $compte_codi7, $signe7, $import7, $compte_codi8, $signe8, $import8, $compte_codi9, $signe9, $import9;
		IF $EOF = 1 THEN LEAVE loop_taula; END IF;
		
		/* crea registros solo de los datos que tengan cuenta válida */
		IF $compte_codi1 > 0 AND $import1 <> 0 THEN
			IF $signe1 = 'D' THEN
				SET $assentament_deure = $import1;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import1;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi1,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 1 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;

		IF $compte_codi2 > 0 AND $import2 <> 0 THEN
			IF $signe2 = 'D' THEN
				SET $assentament_deure = $import2;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import2;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi2,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 2 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;			
		
		IF $compte_codi3 > 0 AND $import3 <> 0 THEN
			IF $signe3 = 'D' THEN
				SET $assentament_deure = $import3;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import3;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi3,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 3 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;
		
		IF $compte_codi4 > 0 AND $import4 <> 0 THEN
			IF $signe4 = 'D' THEN
				SET $assentament_deure = $import4;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import4;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi4,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 4 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;
			
			
		IF $compte_codi5 > 0 AND $import5 <> 0 THEN
			IF $signe5 = 'D' THEN
				SET $assentament_deure = $import5;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import5;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi5,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 5 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;
		
		IF $compte_codi6 > 0 AND $import6 <> 0 THEN
			IF $signe6 = 'D' THEN
				SET $assentament_deure = $import6;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import6;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi6,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 6 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;
		
		IF $compte_codi7 > 0 AND $import7 <> 0 THEN
			IF $signe7 = 'D' THEN
				SET $assentament_deure = $import7;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import7;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi7,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 7 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;
		
		IF $compte_codi8 > 0 AND $import8 <> 0 THEN
			IF $signe8 = 'D' THEN
				SET $assentament_deure = $import8;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import8;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi8,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 8 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;
		
		IF $compte_codi9 > 0 AND $import9 <> 0 THEN
			IF $signe9 = 'D' THEN
				SET $assentament_deure = $import9;
				SET $assentament_haver = 0;
			ELSE
				SET $assentament_deure = 0;
				SET $assentament_haver = $import9;
			END IF;
			
			CALL assentament_crea(CONCAT('{"
				assentament_cab": "',$assentament_cab_id,'",
				"compte": "',$compte_codi9,'",
				"contra": "VARIOS",
				"concepte": "',CONCAT($concepte, ' 9 ', LEFT($adata, 7)),'",
				"deure": "',$assentament_deure,'",
				"haver": "',$assentament_haver,'"}'
			));
		END IF;
	
	END LOOP loop_taula;
	CLOSE $cursor_taula;
	
	SELECT 'ok' as result;
END