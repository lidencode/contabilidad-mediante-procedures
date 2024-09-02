CREATE TABLE `tmp_comptes_saldos_desquadrats` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`centre_id` INT(11) NULL DEFAULT NULL,
	`centre_exercici_id` INT(11) NULL DEFAULT NULL,
	`compte` VARCHAR(12) NULL DEFAULT NULL,
	`exercici_anterior` VARCHAR(10) NULL DEFAULT NULL,
	`saldo_final` DECIMAL(13,2) NULL DEFAULT '0.00',
	`exercici_actual` VARCHAR(10) NULL DEFAULT NULL,
	`saldo_inicial` DECIMAL(13,2) NULL DEFAULT '0.00',
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;
