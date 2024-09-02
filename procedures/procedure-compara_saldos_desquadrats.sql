CREATE DEFINER=`root`@`localhost` PROCEDURE `compara_saldos_desquadrats`(IN `_centre_id` INT, IN `_centre_exercici_id` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* borra los datos obsoletos */
	DELETE FROM tmp_comptes_saldos_desquadrats WHERE centre_id = _centre_id AND centre_exercici_id = _centre_exercici_id;
	
	/* inserta los datos nuevos */
	INSERT INTO tmp_comptes_saldos_desquadrats (`centre_id`,`centre_exercici_id`,`compte`,`exercici_anterior`,`saldo_final`,`exercici_actual`,`saldo_inicial`)
	SELECT c.centre_id, c.centre_exercici_id, c.compte, ea.any_exercici, ca.saldo_final, e.any_exercici, c.saldo_inicial FROM compte c
	  LEFT JOIN centre_exercici e ON e.id = c.centre_exercici_id
	  LEFT JOIN (SELECT id, centre_id, any_exercici FROM centre_exercici ORDER BY any_exercici) ea ON ea.any_exercici = e.any_exercici - 1 AND ea.centre_id = c.centre_id 
	  LEFT JOIN compte ca ON ca.centre_exercici_id = ea.id AND ca.compte = c.compte
	WHERE c.centre_id = _centre_id AND c.centre_exercici_id = _centre_exercici_id AND c.saldo_inicial <> ca.saldo_final
	GROUP BY c.compte;
	
END