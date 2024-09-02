CREATE DEFINER=`root`@`localhost` PROCEDURE `assentament_crea`(IN `data` TEXT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	/*
		{"assentament_cab": "", "compte": "", "contra": "", "concepte": "", "deure": "", "haver": ""}
		{"assentament_cab": "3577", "compte": "100", "contra": "200", "concepte": "test", "deure": "123", "haver": "123"}
	*/
	
	/* parametros de entrada. */
	DECLARE _assentament_cab INT DEFAULT common_schema.extract_json_value(data, '/assentament_cab');
	DECLARE _compte VARCHAR(12) DEFAULT common_schema.extract_json_value(data, '/compte');
	DECLARE _compte_contra VARCHAR(12) DEFAULT common_schema.extract_json_value(data, '/contra');
	DECLARE _concepte VARCHAR(50) DEFAULT common_schema.extract_json_value(data, '/concepte');
	DECLARE _import_deure DECIMAL(13,2) DEFAULT common_schema.extract_json_value(data, '/deure');
	DECLARE _import_haver DECIMAL(13,2) DEFAULT common_schema.extract_json_value(data, '/haver');
	
	/* variables */
	DECLARE _cab_assentament_id, _cab_centre_id, _cab_centre_exercici_id, _cab_ano, _cab_mes, _cab_dia, _cab_num_ass, _inserted_id INT;
	DECLARE _cab_data_assentament DATE;
	DECLARE _compte_id, _compte_compte INT;
	DECLARE _compte_contra_id, _compte_contra_compte INT;
	DECLARE _compte_titol, _compte_contra_titol VARCHAR(50);
	DECLARE _assentament_cab_total_deure, _assentament_cab_total_haver DECIMAL(13,2);
	
	/* recupera la información de cabecera del asentamiento */
	SELECT id, centre_id, centre_exercici_id, ano, mes, dia, data_assentament, num_ass
	INTO _cab_assentament_id, _cab_centre_id, _cab_centre_exercici_id, _cab_ano, _cab_mes, _cab_dia, _cab_data_assentament, _cab_num_ass
	FROM assentament_cab WHERE id = _assentament_cab LIMIT 1;

	/* recupera la información de la cuenta */
	SELECT compte.`id`, compte.`compte`, compte.`titol`
	INTO _compte_id, _compte_compte, _compte_titol
	FROM compte WHERE compte.`compte` = _compte AND compte.centre_id = _cab_centre_id AND compte.centre_exercici_id = _cab_centre_exercici_id LIMIT 1;

	/* si compte_contra = VARIOS */
	IF _compte_contra = 'VARIOS' THEN
		SET _compte_contra_id = NULL;
		SET _compte_contra_titol = NULL;
	ELSE
		/* recupera la información de la cuenta contra */
		SELECT compte.`id`, compte.`compte`, compte.`titol`
		INTO _compte_contra_id, _compte_contra_compte, _compte_contra_titol
		FROM compte WHERE compte.`compte` = _compte_contra AND compte.centre_id = _cab_centre_id AND compte.centre_exercici_id = _cab_centre_exercici_id LIMIT 1;
	END IF;
	
	/* guarda el asiento */
	INSERT INTO assentament SET 
		assentament_id = _cab_assentament_id,
		centre_id = _cab_centre_id,
		centre_exercici_id = _cab_centre_exercici_id,
		ano = _cab_ano,
		mes = _cab_mes,
		dia = _cab_dia,
		data_assentament = _cab_data_assentament,
		compte_id = _compte_id,
		`compte` = _compte,
		num_ass = _cab_num_ass,
		concepte = _concepte,
		import_deure = _import_deure,
		import_haver = _import_haver,
		compte_contra = _compte_contra,
		compte_contra_id = _compte_contra_id,
		compte_titol = _compte_titol,
		contra_titol = _compte_contra_titol;
	
	SET _inserted_id = LAST_INSERT_ID();

	/* calcula suma de deure/haver del assentament_cab */
	SELECT SUM(import_deure), SUM(import_haver)
	INTO _assentament_cab_total_deure, _assentament_cab_total_haver
	FROM assentament WHERE assentament_id = _cab_assentament_id;
	
	/* actualiza assentament_cab */
	UPDATE assentament_cab SET 
		import_deure = _assentament_cab_total_deure,
		import_haver = _assentament_cab_total_haver
	WHERE id = _cab_assentament_id LIMIT 1;
	
	CALL compte_upd_saldos_crea_ind(_cab_centre_id, _cab_centre_exercici_id, _compte_id, _cab_mes, _import_deure , _import_haver);
	
	SELECT 'ok' as result, _inserted_id as id;
	
END