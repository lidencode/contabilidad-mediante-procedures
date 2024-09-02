CREATE DEFINER=`root`@`localhost` FUNCTION `assentament_cab_crea`(`_centre_id` INT, `_centre_exercici_id` INT, `_diari` VARCHAR(5), `_data` DATE)
	RETURNS int(11)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	
	/* variables */
	DECLARE _data_ano, _data_mes, _data_dia INT;
	DECLARE _num_ass, _predefinit INT;
	
	/* calcula la fecha */
	SET _data_ano = EXTRACT(YEAR FROM _data);
	SET _data_mes = EXTRACT(MONTH FROM _data);
	SET _data_dia = EXTRACT(DAY FROM _data);
	
	/* calcula el num_ass */
	set _num_ass =  nextval_compta('ass', _centre_id, _centre_exercici_id);
	
	/* crea la cabecera */
	INSERT INTO assentament_cab SET
		centre_id = _centre_id,
		centre_exercici_id = _centre_exercici_id,
		diari = _diari,
		ano = _data_ano,
		mes = _data_mes,
		dia = _data_dia,
		data_assentament = _data,
		num_ass = _num_ass,
		import_deure = 0,
		import_haver = 0;		

	RETURN LAST_INSERT_ID();
	
END