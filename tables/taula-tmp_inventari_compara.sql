CREATE TABLE `tmp_inventari_compara` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'identificador únic del assentament',
  `centre_id` int(11) DEFAULT NULL,
  `centre_exercici_id` int(11) DEFAULT NULL,
  `compte` varchar(12) DEFAULT NULL,
  `compte_id` int(11) DEFAULT NULL,
  `import_error` int(1) DEFAULT NULL,
  `import_compta` decimal(13,2) DEFAULT '0.00',
  `import_inventari` decimal(13,2) DEFAULT '0.00',
  `amortitza_error` int(1) DEFAULT NULL,
  `amortitza_compta` decimal(13,2) DEFAULT NULL,
  `amortiza_inventari` decimal(13,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
