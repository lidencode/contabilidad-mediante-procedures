CREATE DEFINER=`abac`@`%` PROCEDURE `amortitzacions_genera_massiu`(IN `_centre_id` INT, IN `_centre_exercici_id` INT, IN `_tipus` VARCHAR(1), IN `_any_mes` VARCHAR(6))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'creat oscar@nextware.es'
BEGIN
	/* variables */
	DECLARE result VARCHAR(10) DEFAULT 'ok';
	DECLARE _inventari_id, _amortitza_codi, _contrapartida_codi INT;
	DECLARE _any_mes_ultim_dia, _inventari_data_ini_amor, _inventari_data_ult_amor DATE;
	DECLARE _inventari_bucle_fi BOOL;
	DECLARE _inventari_bucle_data_actual, _amortitzacio_data_venda, _amortitzacio_data_baixa DATE;
	DECLARE _inventari_bucle_data_diferencia, _ano, _mes INT DEFAULT 0;
	DECLARE _amortitzacio_valor_dia_origen, _amortitzacio_valor_dia, _amortitzacio_valor_total, _inventari_data_import_pendent, _inventari_data_import_compra, _inventari_data_import_acumulat DECIMAL(13,6);
	DECLARE _inventari_data_percentatge, _inventari_ultim_percentatge DECIMAL (5,2);
	DECLARE _dies_total_any INT DEFAULT 365;
	DECLARE _assentament_id, _assentament_amortitza_id, _assentament_amortitza_codi, _assentament_contrapartida_id, _assentament_contrapartida_codi INT;
	DECLARE _assentament_original_compte_id, _assentament_original_contra_id, _assentament_original_mes INT;
	DECLARE _assentament_original_deure, _assentament_original_haver DECIMAL(13, 2);
	DECLARE _assentament_import DECIMAL(13,2);
	DECLARE _assentament_D_H VARCHAR(1);
	
	/* declara el cursor para inventario */
	DECLARE cursor_eof INTEGER DEFAULT 0;
	DECLARE cursor_inventari CURSOR FOR SELECT id, data_ini_amor, data_ult_amor, import_compra, pctge,(import_pendent - IFNULL(valor_residual, 0)),
	  		import_acumulat, (((import_compra - IFNULL(valor_residual, 0)) * pctge) / 100), data_venda, data_baixa, amortitza_codi, contrapartida_codi
		FROM inventari WHERE inventari.centre_id = _centre_id AND inventari.centre_exercici_id = _centre_exercici_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_eof = 1;

	/* bucle sobre el cursor comptes */
	SET cursor_eof = 0;
	OPEN cursor_inventari;
	get_inventari: LOOP
	
		SET cursor_eof = 0;
		
		FETCH cursor_inventari INTO _inventari_id, _inventari_data_ini_amor, _inventari_data_ult_amor, _inventari_data_import_compra, _inventari_data_percentatge, _inventari_data_import_pendent,
			_inventari_data_import_acumulat, _amortitzacio_valor_dia_origen, _amortitzacio_data_venda, _amortitzacio_data_baixa, _amortitza_codi, _contrapartida_codi;

		IF cursor_eof = 1 THEN
			LEAVE get_inventari;
		END IF;

		/* si existe alguna linea en el inventari_hist, recupera la última para asignarle ese mismo % */
		SET _inventari_ultim_percentatge = 0;
		SELECT pctge INTO _inventari_ultim_percentatge FROM inventari_hist WHERE inventari_id = _inventari_id ORDER BY id DESC LIMIT 1;
		
		IF _inventari_ultim_percentatge > 0 THEN
			SET _inventari_data_percentatge = _inventari_ultim_percentatge;
			SET _amortitzacio_valor_dia_origen = _inventari_data_import_compra * _inventari_ultim_percentatge / 100;
		END IF;
		
		/* si no hay fecha ultima amortización se establece que es igual a fecha inicio amortización */
		IF ISNULL(_inventari_data_ult_amor) THEN
			SET _inventari_data_ult_amor = _inventari_data_ini_amor;
		END IF;
		
		/* establece fecha fin del calculo de la amortización según si el tipo de operación es A o M */
		IF _tipus = 'A' THEN
			SET _any_mes_ultim_dia = CONCAT(LEFT(_any_mes, 4), '-12-31');
		ELSE
			SET _any_mes_ultim_dia = LAST_DAY(CONCAT(LEFT(_any_mes, 4), '-', RIGHT(_any_mes, 2), '-01'));
		END IF;
	
		/* recorre los meses/años hasta _any_mes_ultim_dia */
		SET _inventari_bucle_fi = FALSE;
		SET _inventari_bucle_data_actual = NULL;

		inventari_lapse: LOOP
		
			IF _tipus = 'A' THEN
			/* si se calcula año a año ... hasta llegar a _any_mes_ultim_dia */
				/* suma un año o la diferencia hasta final de año si no estaba a final de año */
				IF ISNULL(_inventari_bucle_data_actual) THEN
					IF _inventari_data_ult_amor = CONCAT(LEFT(_inventari_data_ult_amor, 4), '-12-31') THEN
						/* suma un año */
						SET _inventari_bucle_data_actual = LAST_DAY(DATE_ADD(_inventari_data_ult_amor, INTERVAL 365 DAY));
					ELSE
						/* suma hasta final del año actual  */
						SET _inventari_bucle_data_actual = CONCAT(LEFT(_inventari_data_ult_amor, 4), '-12-31');
					END IF;
				ELSE
					/* suma un año */
					SET _inventari_bucle_data_actual = LAST_DAY(DATE_ADD(_inventari_data_ult_amor, INTERVAL 365 DAY));
				END IF;
			ELSE
			/* si se calcula mes a mes ... hasta llegar a _any_mes_ultim_dia */
				/* suma un més o la diferencia hasta final de més si no estaba a final de més */
				IF ISNULL(_inventari_bucle_data_actual) THEN
					IF _inventari_data_ult_amor = LAST_DAY(_inventari_data_ult_amor) THEN
						/* suma un mes */
						SET _inventari_bucle_data_actual = LAST_DAY(DATE_ADD(_inventari_data_ult_amor, INTERVAL 1 DAY));
					ELSE
						/* suma hasta final del mes actual */
						SET _inventari_bucle_data_actual = LAST_DAY(_inventari_data_ult_amor);
					END IF;
				ELSE
					/* suma un mes */
					SET _inventari_bucle_data_actual = LAST_DAY(DATE_ADD(LAST_DAY(_inventari_data_ult_amor), INTERVAL 1 DAY));
				END IF;
			END IF;			
	
			/* calcula si el año es bisiesto */
			SET _ano = LEFT(_inventari_bucle_data_actual, 4);
			IF MOD(_ano, 4)=0 THEN
			  SET _dies_total_any = 366;
			ELSE
			  SET _dies_total_any = 365;
			END IF;
		
			/* calcula el valor por dia de la amortización */
			SET _amortitzacio_valor_dia = _amortitzacio_valor_dia_origen / _dies_total_any;
			
			/* Calcula si se tiene que salir del bucle */
			
			/* ... si se ha vendido o dado de baja el inventari */
			IF _amortitzacio_data_venda <> NULL OR _amortitzacio_data_baixa <> NULL THEN
				SET _inventari_bucle_fi = TRUE;
			END IF;
			
			/* ... si la fecha del bucle ha sobrepasado el parametro _any_mes => _any_mes_ultim_dia */
			IF _inventari_bucle_data_actual > _any_mes_ultim_dia THEN
				SET _inventari_bucle_fi = TRUE;
			END IF;
			
			IF _inventari_bucle_fi = TRUE THEN
				LEAVE inventari_lapse;
			ELSE
				/* calcula la diferencia de dias entre última amortización y la que se va a hacer ahora */
				SET _inventari_bucle_data_diferencia = DATEDIFF(_inventari_bucle_data_actual, _inventari_data_ult_amor);
				SET _inventari_data_ult_amor = _inventari_bucle_data_actual;
				
				/* calcula el valor total de esta amortización */
				SET _amortitzacio_valor_total = _inventari_bucle_data_diferencia * _amortitzacio_valor_dia;
				
				/* esta cifra no puede superar el total pendiente */
				IF _amortitzacio_valor_total >= _inventari_data_import_pendent THEN
					SET _amortitzacio_valor_total = _inventari_data_import_pendent;
					SET _inventari_bucle_fi = TRUE;
				END IF;
				
				/* redondea */
				SET _amortitzacio_valor_total = ROUND(_amortitzacio_valor_total + 0.001, 2);
				
				/* actualiza restante */
				SET _inventari_data_import_pendent = _inventari_data_import_pendent - _amortitzacio_valor_total;
				SET _inventari_data_import_acumulat = _inventari_data_import_acumulat + _amortitzacio_valor_total;
				
				/* inserta el movimiento en invetari_hist */ /* ¿no deberia de existir este registro no? */
				INSERT INTO inventari_hist SET
					inventari_id = _inventari_id,
					centre_id = _centre_id,
					centre_exercici_id = _centre_exercici_id,
					data_amortitzacio = _inventari_bucle_data_actual,
					pctge = _inventari_data_percentatge,
					import = _amortitzacio_valor_total,
					amortitzacio_acum = _inventari_data_import_acumulat,
					valor_net = _inventari_data_import_pendent,
					assentament_id = 0;
					
				/* crea los asientos */	
				SELECT SUM(h.import), i.D_H
				 INTO _assentament_import, _assentament_D_H
				 FROM inventari i JOIN inventari_hist h ON h.inventari_id = i.id  AND h.data_amortitzacio = _inventari_bucle_data_actual
				 WHERE i.centre_id = _centre_id AND i.centre_exercici_id = _centre_exercici_id AND i.id = _inventari_id
				 GROUP BY data_ult_amor, D_H;

				/* localiza el asiento con el inventari_id correspondiente */
				SET _assentament_id = 0;
				SELECT assentament_id INTO _assentament_id FROM assentament WHERE centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id AND inventari_id = _inventari_id;
				
				/* si no existe, crea una cabecera y lo actualiza en el inventario */
				IF _assentament_id = 0 THEN
					SET _assentament_id = assentament_cab_crea(_centre_id, _centre_exercici_id, 'A', _inventari_bucle_data_actual);
					UPDATE assentament SET assentament_id = _assentament_id WHERE inventari_id = _inventari_id AND centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id;
				END IF;

				/* actualiza la linea de inventari_hist con el num. assentament_id */				
				UPDATE inventari_hist SET assentament_id = _assentament_id
				 WHERE inventari_id = _inventari_id AND centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id;
				
				/* si existen los asientos los borra */
				SET _assentament_original_compte_id = 0;
				
				SELECT compte_id, compte_contra_id, mes, import_deure, import_haver
				 INTO _assentament_original_compte_id, _assentament_original_contra_id, _assentament_original_mes, _assentament_original_deure, _assentament_original_haver
				 FROM assentament
			    WHERE centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id AND assentament_id = _assentament_id LIMIT 1;
				
				IF _assentament_original_compte_id > 0 THEN
					DELETE FROM assentament WHERE centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id AND assentament_id = _assentament_id;
					CALL compte_upd_saldos_elimina_ind(_centre_id, _centre_exercici_id, _assentament_original_compte_id,  _assentament_original_mes, _assentament_original_deure, _assentament_original_haver);
					CALL compte_upd_saldos_elimina_ind(_centre_id, _centre_exercici_id, _assentament_original_contra_id,  _assentament_original_mes, _assentament_original_haver, _assentament_original_deure);
				END IF;
				
				/* crea los asientos dependiendo del campo D_H. compte_upd_saldos_crea_ind() se ejecuta dentro de assentament_crea() */
				IF _assentament_D_H = 'D' THEN		
					CALL assentament_crea(CONCAT('{
						"assentament_cab": "',_assentament_id,'",
						"compte": "',_amortitza_codi,'",
						"contra": "',_contrapartida_codi,'",
						"concepte": "AMORTITZACIO ',_inventari_data_ult_amor,'",
						"deure": "0",
						"haver": "',_amortitzacio_valor_total,'"
					}'));
										
					CALL assentament_crea(CONCAT('{
						"assentament_cab": "',_assentament_id,'",
						"compte": "',_contrapartida_codi,'",
						"contra": "',_amortitza_codi,'",
						"concepte": "AMORTITZACIO ',_inventari_data_ult_amor,'",
						"deure": "',_amortitzacio_valor_total,'",
						"haver": "0"
					}'));
				ELSE
					CALL assentament_crea(CONCAT('{
						"assentament_cab": "',_assentament_id,'",
						"compte": "',_contrapartida_codi,'",
						"contra": "',_amortitza_codi,'",
						"concepte": "AMORTITZACIO ',_inventari_data_ult_amor,'",
						"deure": "',_amortitzacio_valor_total,'",
						"haver": "0"
					}'));
					
					CALL assentament_crea(CONCAT('{
						"assentament_cab": "',_assentament_id,'",
						"compte": "',_amortitza_codi,'",
						"contra": "',_contrapartida_codi,'",
						"concepte": "AMORTITZACIO ',_inventari_data_ult_amor,'",
						"deure": "0",
						"haver": "',_amortitzacio_valor_total,'"
					}'));				
				END IF;
			END IF;
			
		END LOOP inventari_lapse;

		/* actualiza inventario */
		UPDATE inventari SET
			data_ult_amor = _inventari_data_ult_amor,
			import_acumulat = _inventari_data_import_acumulat,
			import_pendent = _inventari_data_import_pendent
		WHERE id = _inventari_id;
		
	END LOOP get_inventari;
	CLOSE cursor_inventari;

	SELECT _any_mes_ultim_dia;
	SELECT _inventari_id, _inventari_data_ini_amor, _inventari_data_ult_amor;
	
	SELECT result as result;
END