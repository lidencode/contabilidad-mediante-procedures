CREATE TABLE `check_exercici_compte_mes` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`check_id` INT(11) NOT NULL DEFAULT '0',
	`centre_id` INT(11) NOT NULL DEFAULT '0',
	`centre_exercici_id` INT(11) NOT NULL DEFAULT '0',
	`compte` INT(11) NOT NULL DEFAULT '0',
	`mes` INT(11) NOT NULL DEFAULT '0',
	`diferencia_deure` DECIMAL(13,2) NOT NULL DEFAULT '0.00',
	`diferencia_haver` DECIMAL(13,2) NOT NULL DEFAULT '0.00',
	`timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;
