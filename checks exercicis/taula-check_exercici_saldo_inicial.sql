CREATE TABLE `check_exercici_saldo_inicial` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`check_id` INT(11) NOT NULL DEFAULT '0',
	`centre_id` INT(11) NOT NULL DEFAULT '0',
	`centre_exercici_id` INT(11) NOT NULL DEFAULT '0',
	`compte` INT(11) NOT NULL DEFAULT '0',
	`timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`saldo_inih` DECIMAL(13,2) NOT NULL,
	`saldo_inid` DECIMAL(13,2) NOT NULL,
	`saldo_inicial` DECIMAL(13,2) NOT NULL,
	`saldo_final` DECIMAL(13,2) NOT NULL,
	`saldo_inicial_diferencia` DECIMAL(13,2) NOT NULL,
	`saldo_final_diferencia` DECIMAL(13,2) NOT NULL,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;