CREATE TABLE `tmp_saldos_subcomptes` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`centre_id` INT(11) NULL DEFAULT NULL,
	`centre_exercici_id` INT(11) NULL DEFAULT NULL,
	`compte` VARCHAR(12) NULL DEFAULT NULL,
	`titol` VARCHAR(50) NULL DEFAULT NULL,
	`saldo_final` DECIMAL(13,2) NULL DEFAULT NULL,
	`tipus_error` VARCHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
ENGINE=InnoDB;
