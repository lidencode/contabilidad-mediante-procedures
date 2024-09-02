CREATE TABLE `balancss_desglos` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`centre_id` INT(11) NULL DEFAULT NULL,
	`centre_exercici_id` INT(11) NULL DEFAULT NULL,
	`compte` VARCHAR(12) NULL DEFAULT NULL,
	`titol` VARCHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
COMMENT='Titols de nivell desglos balanç sumes i saldos'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;
