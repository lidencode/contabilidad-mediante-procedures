CREATE TABLE `tmp_subcomptes_saldos_moviments` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`centre_id` INT(11) NOT NULL DEFAULT '0',
	`centre_exercici_id` INT(11) NOT NULL DEFAULT '0',
	`compte` VARCHAR(12) NOT NULL DEFAULT '0',
	`titol` VARCHAR(50) NOT NULL DEFAULT '0',
	`exercici_anterior` VARCHAR(2) NOT NULL DEFAULT '0',
	`saldo_final_anterior` DECIMAL(13,2) NOT NULL DEFAULT '0.00',
	`exercici_actual` VARCHAR(2) NOT NULL DEFAULT '0',
	`saldo_final_actual` DECIMAL(13,2) NOT NULL DEFAULT '0.00',
	PRIMARY KEY (`id`)
)
ENGINE=InnoDB;
