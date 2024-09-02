CREATE TABLE `check_exercici_compte_pare` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`check_id` INT(11) NOT NULL DEFAULT '0',
	`centre_id` INT(11) NOT NULL DEFAULT '0',
	`centre_exercici_id` INT(11) NOT NULL DEFAULT '0',
	`compte` INT(11) NOT NULL DEFAULT '0',
	`diferencia_saldo_inid` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_saldo_inih` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_saldo_inicial` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_saldo_final` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd01` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd02` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd03` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd04` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd05` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd06` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd07` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd08` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd09` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd10` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd11` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumd12` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh01` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh02` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh03` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh04` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh05` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh06` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh07` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh08` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh09` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh10` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh11` DECIMAL(13,2) NULL DEFAULT NULL,
	`diferencia_sumh12` DECIMAL(13,2) NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;
