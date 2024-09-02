CREATE DEFINER=`abac`@`%` PROCEDURE `arregla_inventari_hist_errors`(IN `$centre_id` VARCHAR(12), IN `$centre_exercici_id` VARCHAR(12))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'creat oscar@nextware.es'
BEGIN
	/* actualiza las lineas de inventari_hist con el acumulado y el valor_neto que deberian de tener */
	UPDATE inventari_hist
	LEFT JOIN check_inventari_hist_errors ON (inventari_hist.id = check_inventari_hist_errors.id)
	SET inventari_hist.amortitzacio_acum = check_inventari_hist_errors.import_acumulat, inventari_hist.valor_net = check_inventari_hist_errors.import_compra - check_inventari_hist_errors.import_acumulat
	WHERE check_inventari_hist_errors.centre_id = $centre_id AND check_inventari_hist_errors.centre_exercici_id = $centre_exercici_id;
	
	/* recalcula las lineas de inventari con los valores correctos */
	UPDATE inventari
	LEFT JOIN
		(SELECT inventari_hist.inventari_id as id, IFNULL(inventari.import_compra, 0) as import_compra, SUM(inventari_hist.import) as import_acumulat, (IFNULL(inventari.import_compra, 0) - SUM(inventari_hist.import)) as import_pendent
		FROM inventari_hist
		LEFT JOIN inventari ON (inventari.id = inventari_hist.inventari_id)
		WHERE inventari_hist.centre_id = $centre_id AND inventari_hist.centre_exercici_id = $centre_exercici_id
		GROUP BY inventari_hist.inventari_id) src ON (inventari.id = src.id)
	SET inventari.import_acumulat = src.import_acumulat, inventari.import_pendent = src.import_pendent
	WHERE inventari.centre_id = $centre_id AND inventari.centre_exercici_id = $centre_exercici_id;

END