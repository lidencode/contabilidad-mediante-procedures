ALTER TABLE `compte` ADD COLUMN `id_ant` INT NULL DEFAULT NULL AFTER `COMPTE_RESERVA`;
ALTER TABLE `tipus_iva` ADD COLUMN `id_ant` INT NULL DEFAULT NULL AFTER `P_C`;
ALTER TABLE `centre_constants` ADD COLUMN `id_ant` INT NULL DEFAULT NULL AFTER `tipus_amortitzacio`;
ALTER TABLE `assentament_cab` ADD COLUMN `id_ant` INT NULL DEFAULT NULL AFTER `origen_importacio`;
ALTER TABLE `assentament` ADD COLUMN `id_ant` INT(11) NULL DEFAULT NULL AFTER `inventari_id`;
ALTER TABLE `inventari` ADD COLUMN `id_ant` INT NULL DEFAULT NULL AFTER `numero`;
ALTER TABLE `inventari_hist` ADD COLUMN `id_ant` INT(11) NULL DEFAULT NULL AFTER `num_amortitza`;
ALTER TABLE `fra_cab` ADD COLUMN `id_ant` INT NULL DEFAULT NULL AFTER `num_recepcio`;
ALTER TABLE `fra_det` ADD COLUMN `id_ant` INT(11) NULL DEFAULT NULL AFTER `cc`;
ALTER TABLE `tercers` ADD COLUMN `id_ant` INT(11) NULL DEFAULT NULL AFTER `iva_codi`;
ALTER TABLE `minutes_cab` ADD COLUMN `id_ant` INT(11) NULL DEFAULT NULL AFTER `nrr`;
ALTER TABLE `minutes_det`ADD COLUMN `id_ant` INT NULL DEFAULT NULL AFTER `compte_titol`;

CREATE DEFINER=`root`@`localhost` PROCEDURE `consolidacio`(IN `$params` TEXT, IN `$entitats` TEXT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* parametros de entrada */
	DECLARE $params TEXT DEFAULT '{"centre_anterior": "1", "centre_nou": "10", "centre_exercici_anterior": "2", "centre_exercici_nou": "20"}';
	DECLARE $entitats TEXT DEFAULT '{"compte": "1", "tipus_iva": "0", "centre_constants": "0", "tercers": "0", "assentament": "0", "inventari": "0", "factures": "0", "minutes": "0"}';
	
	/* parametros. */
	DECLARE $centre_anterior INT DEFAULT common_schema.extract_json_value($params, '/centre_anterior');
	DECLARE $centre_nou INT DEFAULT common_schema.extract_json_value($params, '/centre_nou');
	DECLARE $centre_exercici_anterior INT DEFAULT common_schema.extract_json_value($params, '/centre_exercici_anterior');
	DECLARE $centre_exercici_nou INT DEFAULT common_schema.extract_json_value($params, '/centre_exercici_nou');
	
	DECLARE $entitat_compte INT DEFAULT common_schema.extract_json_value($entitats, '/compte');
	DECLARE $entitat_tipus_iva INT DEFAULT common_schema.extract_json_value($entitats, '/tipus_iva');
	DECLARE $entitat_centre_constants INT DEFAULT common_schema.extract_json_value($entitats, '/centre_constants');
	DECLARE $entitat_tercers INT DEFAULT common_schema.extract_json_value($entitats, '/tercers');
	DECLARE $entitat_assentament INT DEFAULT common_schema.extract_json_value($entitats, '/assentament');
	DECLARE $entitat_factures INT DEFAULT common_schema.extract_json_value($entitats, '/factures');
	DECLARE $entitat_inventari INT DEFAULT common_schema.extract_json_value($entitats, '/inventari');
	DECLARE $entitat_minutes INT DEFAULT common_schema.extract_json_value($entitats, '/minutes');	
	
	/* variables */
	
	/* ENTITAT: COMPTE */
	IF $entitat_compte = 1 THEN	
		INSERT INTO compte
		SELECT null, compte.tipus_pla, $centre_nou, $centre_exercici_nou, compte.comptabilitat_id, compte.compte, compte.compte_pare, compte.compte_pare_id, compte.titol, compte.balanc, compte.resultado,
			compte.A_P, compte.tipus_compte, compte.tipus_auxiliar, compte.criteri_imputacio, compte.bloqueig_entrada_directa, compte.bloquejada, compte.D_H, compte.saldo_cd, compte.tipus_reg, compte.cc_id, compte.cc,
			compte.tercer, compte.saldo_inid, compte.saldo_inih, compte.sumd01, compte.sumh01, compte.sumd02, compte.sumh02, compte.sumd03, compte.sumh03, compte.sumd04, compte.sumh04, compte.sumd05, compte.sumh05,
			compte.sumd06, compte.sumh06, compte.sumd07, compte.sumh07, compte.sumd08, compte.sumh08, compte.sumd09, compte.sumh09, compte.sumd10, compte.sumh10, compte.sumd11, compte.sumh11, compte.sumd12,
			compte.sumh12, compte.sumd13, compte.sumh13, compte.sumd14, compte.sumh14, compte.sumd15, compte.sumh15, compte.sumd16, compte.sumh16, compte.sumd17, compte.sumh17, compte.sumd18, compte.sumh18,
			compte.sumd19, compte.sumh19, compte.sumd20, compte.sumh20, compte.sumd21, compte.sumh21, compte.sumd22, compte.sumh22, compte.sumd23, compte.sumh23, compte.sumd24, compte.sumh24, compte.signo,
			compte.saldo, compte.signe, compte.errsct, compte.datacreacio, compte.PGC, compte.id_usuari_creacio, compte.data_modificacio, compte.id_usuari_modificacio, compte.prog_modificacio, compte.proces_generador,
			compte.TITOL50, compte.root, compte.lft, compte.rgt, compte.level, compte.saldo_inicial, compte.saldo_final, compte.pressupost, compte.realitzat, compte.per_realitzar, compte.pctge_per_realitzar,
			compte.COMPTE_RESERVA, compte.id
		FROM compte WHERE compte NOT IN (SELECT compte FROM compte WHERE centre_exercici_id = $centre_exercici_nou) AND compte.centre_id = $centre_anterior AND compte.centre_exercici_id = $centre_exercici_anterior; 
	END IF;
	
	/* ENTITAT: TIPUS_IVA */
	IF $entitat_tipus_iva = 1 THEN
		INSERT INTO tipus_iva
		SELECT null, $centre_nou, $centre_exercici_nou, tipus_iva.descripcio, tipus_iva.tipus, tipus_iva.codi_iva, tipus_iva.pctge_iva, tipus_iva.pctge_rec, tipus_iva.subcompte_iva,
			compte_iva_id.id, tipus_iva.subcompte_rec, compte_rec_id.id, tipus_iva.subjecte, tipus_iva.exent, tipus_iva.ja_repercutit, tipus_iva.rec_equiv, tipus_iva.agrari, tipus_iva.deduible,
			tipus_iva.operacio, tipus_iva.data_creacio, tipus_iva.usuari_creacio_id, tipus_iva.data_modificacio, tipus_iva.usuari_modificacio_id, tipus_iva.prog_modificacio, tipus_iva.proces_generador,
			tipus_iva.P_C, tipus_iva.id
		FROM tipus_iva 
		LEFT JOIN compte as compte_iva_id ON (compte_iva_id.id_ant = tipus_iva.compte_iva_id AND compte_iva_id.centre_id = $centre_nou AND compte_iva_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as compte_rec_id ON (compte_rec_id.id_ant = tipus_iva.compte_rec_id AND compte_rec_id.centre_id = $centre_nou AND compte_rec_id.centre_exercici_id = $centre_exercici_nou)
		WHERE tipus_iva.centre_id = $centre_anterior AND tipus_iva.centre_exercici_id = $centre_exercici_anterior; 	
	END IF;
	
	/* ENTITAT: CENTRE_CONSTANTS */
	IF $entitat_centre_constants = 1 THEN
		INSERT INTO centre_constants
		SELECT null, $centre_nou, $centre_exercici_nou, centre_constants.tiplan, centre_constants.peninsula, descpp_compras_id.id, descpp_ventas_id.id,	anticipos_compras_id.id, anticipos_ventas_id.id,
			irpf_ventas_id.id, irpf_compras_id.id, rci_compras_id.id, rci_ventas_id.id, centre_constants.profes, centre_constants.pctge_irpf, centre_constants.pctge_rci, cuota_comp_iva_id.id,
			cuota_pagar_iva_id.id, centre_constants.cuota_comp_igic_OLD, cuota_pagar_igc.id, centre_constants.prorrata, centre_constants.pctge_pro, iva_cce_ventas_id.id,
			iva_cce_compras_id.id, iva_ext_ventas_id.id, iva_ext_compras_id.id, centre_constants.aranceles, centre_constants.reg_espagp_vta_pos, centre_constants.reg_espagp_comp_neg, reg_inv_pos_id.id,
			reg_inv_neg_id.id, reg_anual_pos_id.id, reg_anual_neg_id.id, centre_constants.descpp_compras_codi,
			centre_constants.descpp_ventas_codi, centre_constants.anticipos_compras_codi, centre_constants.anticipos_ventas_codi, centre_constants.irpf_ventas_codi, centre_constants.irpf_compras_codi,
			centre_constants.rci_compras_codi, centre_constants.rci_ventas_codi, centre_constants.cuota_comp_iva_codi, centre_constants.cuota_pagar_iva_codi, centre_constants.cuota_pagar_igc_codi,
			centre_constants.iva_cce_ventas_codi, centre_constants.iva_cce_compras_codi, centre_constants.iva_ext_ventas_codi, centre_constants.iva_ext_compras_codi, centre_constants.aranceles_codi,
			centre_constants.reg_espagp_vta_pos_codi, centre_constants.reg_espagp_comp_neg_codi, centre_constants.reg_inv_pos_codi, centre_constants.reg_inv_neg_codi, centre_constants.reg_anual_pos_codi,
			centre_constants.reg_anual_neg_codi, centre_constants.minim_347, cuota_dev_pos.id, cuota_dev_neg.id, ded_reg_igic_pos.id, ded_reg_igic_neg.id,
			centre_constants.cuota_dev_pos_codi, centre_constants.cuota_dev_neg_codi, centre_constants.ded_reg_igic_pos_codi, centre_constants.ded_reg_igic_neg_codi, cuota_comp_igic.id,
			centre_constants.cuota_comp_igic_codi, centre_constants.tipus_amortitzacio, centre_constants.id
		FROM centre_constants
		LEFT JOIN compte as descpp_compras_id ON (descpp_compras_id.id_ant = centre_constants.descpp_compras_id AND descpp_compras_id.centre_id = $centre_nou AND descpp_compras_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as descpp_ventas_id ON (descpp_ventas_id.id_ant = centre_constants.descpp_ventas_id AND descpp_ventas_id.centre_id = $centre_nou AND descpp_ventas_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as anticipos_compras_id ON (anticipos_compras_id.id_ant = centre_constants.anticipos_compras_id AND anticipos_compras_id.centre_id = $centre_nou AND anticipos_compras_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as anticipos_ventas_id ON (anticipos_ventas_id.id_ant = centre_constants.anticipos_ventas_id AND anticipos_ventas_id.centre_id = $centre_nou AND anticipos_ventas_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as irpf_ventas_id ON (irpf_ventas_id.id_ant = centre_constants.irpf_ventas_id AND irpf_ventas_id.centre_id = $centre_nou AND irpf_ventas_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as irpf_compras_id ON (irpf_compras_id.id_ant = centre_constants.irpf_compras_id AND irpf_compras_id.centre_id = $centre_nou AND irpf_compras_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as rci_compras_id ON (rci_compras_id.id_ant = centre_constants.rci_compras_id AND rci_compras_id.centre_id = $centre_nou AND rci_compras_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as rci_ventas_id ON (rci_ventas_id.id_ant = centre_constants.rci_ventas_id AND rci_ventas_id.centre_id = $centre_nou AND rci_ventas_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as cuota_comp_iva_id ON (cuota_comp_iva_id.id_ant = centre_constants.cuota_comp_iva_id AND cuota_comp_iva_id.centre_id = $centre_nou AND cuota_comp_iva_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as cuota_pagar_iva_id ON (cuota_pagar_iva_id.id_ant = centre_constants.cuota_pagar_iva_id AND cuota_pagar_iva_id.centre_id = $centre_nou AND cuota_pagar_iva_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as cuota_pagar_igc ON (cuota_pagar_igc.id_ant = centre_constants.cuota_pagar_igc AND cuota_pagar_igc.centre_id = $centre_nou AND cuota_pagar_igc.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as iva_cce_ventas_id ON (iva_cce_ventas_id.id_ant = centre_constants.iva_cce_ventas_id AND iva_cce_ventas_id.centre_id = $centre_nou AND iva_cce_ventas_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as iva_cce_compras_id ON (iva_cce_compras_id.id_ant = centre_constants.iva_cce_compras_id AND iva_cce_compras_id.centre_id = $centre_nou AND iva_cce_compras_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as iva_ext_ventas_id ON (iva_ext_ventas_id.id_ant = centre_constants.iva_ext_ventas_id AND iva_ext_ventas_id.centre_id = $centre_nou AND iva_ext_ventas_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as iva_ext_compras_id ON (iva_ext_compras_id.id_ant = centre_constants.iva_ext_compras_id AND iva_ext_compras_id.centre_id = $centre_nou AND iva_ext_compras_id.centre_exercici_id = $centre_exercici_nou)	
		LEFT JOIN compte as reg_inv_pos_id ON (reg_inv_pos_id.id_ant = centre_constants.reg_inv_pos_id AND reg_inv_pos_id.centre_id = $centre_nou AND reg_inv_pos_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as reg_inv_neg_id ON (reg_inv_neg_id.id_ant = centre_constants.reg_inv_neg_id AND reg_inv_neg_id.centre_id = $centre_nou AND reg_inv_neg_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as reg_anual_pos_id ON (reg_anual_pos_id.id_ant = centre_constants.reg_anual_pos_id AND reg_anual_pos_id.centre_id = $centre_nou AND reg_anual_pos_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as reg_anual_neg_id ON (reg_anual_neg_id.id_ant = centre_constants.reg_anual_neg_id AND reg_anual_neg_id.centre_id = $centre_nou AND reg_anual_neg_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as cuota_dev_pos ON (cuota_dev_pos.id_ant = centre_constants.cuota_dev_pos AND cuota_dev_pos.centre_id = $centre_nou AND cuota_dev_pos.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as cuota_dev_neg ON (cuota_dev_neg.id_ant = centre_constants.cuota_dev_neg AND cuota_dev_neg.centre_id = $centre_nou AND cuota_dev_neg.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as ded_reg_igic_pos ON (ded_reg_igic_pos.id_ant = centre_constants.ded_reg_igic_pos AND ded_reg_igic_pos.centre_id = $centre_nou AND ded_reg_igic_pos.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as ded_reg_igic_neg ON (ded_reg_igic_neg.id_ant = centre_constants.ded_reg_igic_neg AND ded_reg_igic_neg.centre_id = $centre_nou AND ded_reg_igic_neg.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as cuota_comp_igic ON (cuota_comp_igic.id_ant = centre_constants.cuota_comp_igic AND cuota_comp_igic.centre_id = $centre_nou AND cuota_comp_igic.centre_exercici_id = $centre_exercici_nou)
		
		WHERE centre_constants.centre_id = $centre_anterior AND centre_constants.centre_exercici_id = $centre_exercici_anterior; 
	END IF;
	
	/* ENTITAT: TERCERS */
	IF $entitat_tercers = 1 THEN
		INSERT INTO tercers
		SELECT null, $centre_nou, $centre_exercici_nou, compte_id.id, tercers.nom, tercers.sigles_id, tercers.adreca, tercers.casa, tercers.escala, tercers.pis, tercers.porta, tercers.poblacio_id,
			tercers.poblacio, tercers.cp_id, tercers.provincia_id, tercers.provincia, tercers.telefon, tercers.nif, tercers.fax, tercers.web, tercers.email, tercers.forma_juridica, tercers.observacions,
			tercers.forma_pagament_id, tercers.reservat, tercers.entitat, tercers.agencia, tercers.dc, tercers.ccc, tercers.banc_id, tercers.cod_compte, tercers.iva_id, tercers.re_id, compte_rcie_id.id,
			compte_pre_id.id, tercers.nom_rep, tercers.nif_rep, tercers.carrec, tercers.telefon_rep, tercers.tipus_societat, tercers.retencio_id, tercers.ex_347, tercers.logo, tercers.datacreacio,
			tercers.usuari_creacio_id, tercers.data_modificacio, tercers.usuari_modificacio_id, tercers.prog_modificacio, tercers.proces_generador, tercers.cuenta, tercers.tipus_pla, tercers.tipus_tercer,
			tercers.pais_id, tercers.compte_codi, tercers.codi_postal, tercers.compte_titol, tercers.compte_pre_codi, tercers.compte_pre_titol, tercers.compte_iva_codi, tercers.compte_rec_codi, compte_iva_id.id,
			compte_rec_id.id, tercers.pctge_iva, tercers.iva_codi, tercers.id
		FROM tercers
		LEFT JOIN compte as compte_id ON (compte_id.id_ant = tercers.compte_id AND compte_id.centre_id = $centre_nou AND compte_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as compte_rcie_id ON (compte_rcie_id.id_ant = tercers.compte_rcie_id AND compte_rcie_id.centre_id = $centre_nou AND compte_rcie_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as compte_pre_id ON (compte_pre_id.id_ant = tercers.compte_pre_id AND compte_pre_id.centre_id = $centre_nou AND compte_pre_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as compte_iva_id ON (compte_iva_id.id_ant = tercers.compte_iva_id AND compte_iva_id.centre_id = $centre_nou AND compte_iva_id.centre_exercici_id = $centre_exercici_nou)
		LEFT JOIN compte as compte_rec_id ON (compte_rec_id.id_ant = tercers.compte_rec_id AND compte_rec_id.centre_id = $centre_nou AND compte_rec_id.centre_exercici_id = $centre_exercici_nou)						
		WHERE tercers.centre_id = $centre_anterior AND tercers.centre_exercici_id = $centre_exercici_anterior; 
	END IF;
	
	/* ENTITAT: ASSENTAMENT */
	IF $entitat_assentament = 1 THEN
		INSERT INTO assentament_cab 
		SELECT null, $centre_nou, $centre_exercici_nou, assentament_cab.diari, assentament_cab.diari_id, assentament_cab.tipus_pla, assentament_cab.tipus_diari_id, assentament_cab.ano, assentament_cab.mes,
			assentament_cab.dia, assentament_cab.data_assentament, assentament_cab.num_ass, assentament_cab.num_apunt, assentament_cab.import_deure, assentament_cab.import_haver, assentament_cab.inventari_id,
			assentament_cab.es_doble, assentament_cab.minutes_cab_id, assentament_cab.minutes_det_id, assentament_cab.fra_cab_id, assentament_cab.data_creacio, assentament_cab.usuari_creacio_id,
			assentament_cab.data_modificacio, assentament_cab.usuari_modificacio_id, assentament_cab.prog_modificacio, assentament_cab.proces_generador, assentament_cab.nrr, assentament_cab.codi_importa,
			assentament_cab.hoj, assentament_cab.tipus_error, assentament_cab.automatic, assentament_cab.predefinit, assentament_cab.importacio_id, assentament_cab.data_importacio, assentament_cab.origen_importacio,
			assentament_cab.id
		FROM assentament_cab
		WHERE assentament_cab.centre_id = $centre_anterior AND assentament_cab.centre_exercici_id = $centre_exercici_anterior;
	
		INSERT INTO assentament
		SELECT null, assentament_cab_id.id, $centre_nou, $centre_exercici_nou, assentament.enviado, assentament.diari, assentament.diari_id, assentament.tipus_pla, assentament.tipus_diari_id,
			assentament.ano, assentament.mes, assentament.dia, assentament.data_assentament, compte_id.id, assentament.compte, assentament.subcompte, assentament.hoj, assentament.num_ass,
			assentament.num_apunt, assentament.fra_cab_id, assentament.concepte, assentament.codi_concepte_id, assentament.import, assentament.import_deure, assentament.import_haver, assentament.signe,
			assentament.cc, assentament.ccost_id, assentament.criteri_imputacio, assentament.compte_contra, assentament.subcompte_contra, compte_contra_id.id, assentament.nrr, assentament.document,
			assentament.punteig, assentament.descr1, assentament.descr2, assentament.justific, assentament.estat_cp, assentament.data_creacio, assentament.usuari_creacio_id, assentament.data_modificacio,
			assentament.usuari_modificacio_id, assentament.prog_modificacio, assentament.proces_generador, assentament.compte_ant, assentament.compte_contra_ant, assentament.codigo, assentament.descripcion,
			assentament.es_doble, assentament.tipus_error, assentament.minutes_cab_id, assentament.minutes_det_id, assentament.predefinit, assentament.importacio_id, assentament.compte_titol,
			assentament.contra_titol, assentament.ordre, assentament.saldo_major, assentament.data_importacio, assentament.origen_importacio, assentament.fra_det_id, assentament.inventari_id, assentament.id
		FROM assentament
			LEFT JOIN assentament_cab as assentament_cab_id ON (assentament_cab_id.id_ant = assentament.assentament_id AND assentament_cab_id.centre_id = $centre_nou AND assentament_cab_id.centre_exercici_id = $centre_exercici_nou)
			LEFT JOIN compte as compte_id ON (compte_id.id_ant = assentament.compte_id AND compte_id.centre_id = $centre_nou AND compte_id.centre_exercici_id = $centre_exercici_nou)
			LEFT JOIN compte as compte_contra_id ON (compte_contra_id.id_ant = assentament.compte_contra_id AND compte_contra_id.centre_id = $centre_nou AND compte_contra_id.centre_exercici_id = $centre_exercici_nou)
		WHERE assentament.centre_id = $centre_anterior AND assentament.centre_exercici_id = $centre_exercici_anterior;
	END IF;
	
	/* ENTITAT: INVENTARI */
	/*IF $entitat_inventari = 1 THEN
		INSERT INTO inventari
		SELECT null, $centre_nou, $centre_exercici_nou, inventari.concepte, inventari.notes, inventari.data_compra, inventari.data_ini_amor, inventari.data_ult_amor, inventari.data_fi,
			inventari.data_venda, inventari.data_baixa, inventari.baixa_id, inventari.ubicacio_id, inventari.grup_id, compte_compra_id.id, inventari.compte_compra, inventari.import_compra,
			compte_dotacion_id.id, inventari.compte_dotacio, inventari.pctge, inventari.mesos, inventari.import_acumulat, inventari.import_exercici, inventari.import_pendent, inventari.data_creacio,
			inventari.usuari_creacio_id, inventari.data_modificacio, inventari.usuari_modificacio_id, inventari.prog_modificacio, inventari.proces_generador, inventari.compte_compra_titol, inventari.descripcio_1,
			inventari.descripcio_2, inventari.fra_cab_id, inventari.fra_det_id, contrapartida_id.id, inventari.contrapartida_codi, inventari.contrapartida_titol, inventari.amortitza_id,
			inventari.amortitza_codi, inventari.amortitza_titol, inventari.D_H, inventari.comp, inventari.valor_residual, inventari.fra_compra_num, inventari.fra_venda_id, inventari.fra_venda_num,
			inventari.fra_venda_serie, inventari.id_origen, inventari.numero, inventari.id
		FROM inventari
			LEFT JOIN compte as compte_compra_id ON (compte_compra_id.id_ant = inventari.compte_compra_id AND compte_compra_id.centre_id = $centre_nou AND compte_compra_id.centre_exercici_id = $centre_exercici_nou)	
			LEFT JOIN compte as compte_dotacion_id ON (compte_dotacion_id.id_ant = inventari.compte_dotacion_id AND compte_dotacion_id.centre_id = $centre_nou AND compte_dotacion_id.centre_exercici_id = $centre_exercici_nou)	
			LEFT JOIN compte as contrapartida_id ON (contrapartida_id.id_ant = inventari.contrapartida_id AND contrapartida_id.centre_id = $centre_nou AND contrapartida_id.centre_exercici_id = $centre_exercici_nou)	
		WHERE inventari.centre_id = $centre_anterior AND inventari.centre_exercici_id = $centre_exercici_anterior;
		
		INSERT INTO inventari_hist
		SELECT null, inventari.inventari_id, $centre_nou, $centre_exercici_nou, inventari_hist.data_amortitzacio, inventari_hist.pctge, inventari_hist.import,
			inventari_hist.amortitzacio_acum, inventari_hist.valor_net, inventari_hist.pctge_ici, inventari_hist.import_ici, assentament.assentament_id, inventari_hist.data_creacio,
			inventari_hist.usuari_creacio_id, inventari_hist.data_modificacio, inventari_hist.usuari_modificacio_id, inventari_hist.prog_modificacio, inventari_hist.proces_generador, inventari_hist.num_amortitza,
			inventari_hist.id
		FROM inventari_hist
			LEFT JOIN inventari ON (inventari.id_ant = inventari_hist.inventari_id AND assentament_cab.centre_id = $centre_nou AND assentament_cab.centre_exercici_id = $centre_exercici_nou)
			LEFT JOIN assentament ON (assentament.id_ant = inventari_hist.assentament_id AND assentament_cab.centre_id = $centre_nou AND assentament_cab.centre_exercici_id = $centre_exercici_nou)			
		WHERE inventari_hist.centre_id = $centre_anterior AND inventari_hist.centre_exercici_id = $centre_exercici_anterior;
				
		UPDATE assentament
			LEFT JOIN inventari as inventari_id ON (assentament.inventari_id = inventari_id.id_ant)
		SET
			assentament.inventari_id = inventari_id.id;
	END IF;*/
	
	/* ENTITAT: FACTURES */
	IF $entitat_factures = 1 THEN
		INSERT INTO fra_cab
		SELECT null, $centre_nou, $centre_exercici_nou, fra_cab.num_factura, fra_cab.tipus_factura, fra_cab.E_R, fra_cab.serie, fra_cab.data_fra, fra_cab.nom, fra_cab.pais_id, fra_cab.tipus_operacio,
			fra_cab.compte, compte_id.id, compte_tercer_id.id, fra_cab.nif, fra_cab.adreca_anterior, fra_cab.sigles_id, fra_cab.adreca_tercer, fra_cab.casa, fra_cab.escala, fra_cab.pis, fra_cab.porta,
			fra_cab.poblacio_id, fra_cab.poblacio_tercer, fra_cab.provincia_id, fra_cab.provincia, fra_cab.cp_id, fra_cab.zona_id, fra_cab.concepte, fra_cab.dte_ppp, fra_cab.base_dpte, fra_cab.pctg_dpte,
			fra_cab.cuota_dpte, fra_cab.entbase, fra_cab.irpf, fra_cab.base_irpf, fra_cab.ptge_irpf, fra_cab.cuota_irpf, fra_cab.aduana, fra_cab.tesor_aduana, fra_cab.base_aduana, fra_cab.iva_aduana,
			fra_cab.cuota_iva_aduna, fra_cab.arancel, fra_cab.hojasi, fra_cab.suma_base, fra_cab.subtotal_fra, fra_cab.subtotal_dpte_pp, fra_cab.suma_cuotes, fra_cab.total, fra_cab.pagat, fra_cab.nrrf,
			fra_cab.nfac_rectificativa, fra_cab.inventari_id, fra_cab.fechav, fra_cab.rci, fra_cab.base_rci, fra_cab.ptge_rci, fra_cab.cuota_rci, fra_cab.forma_pagament_id, fra_cab.banc_id, fra_cab.reserva,
			fra_cab.entitat, fra_cab.agencia, fra_cab.dc, fra_cab.ccc, fra_cab.rete1, fra_cab.rete1_compta, fra_cab.rete1_compta_id, fra_cab.rete1_nom, fra_cab.rete1_base, fra_cab.rete1_ptge, fra_cab.rete1_cuota,
			fra_cab.justific, fra_cab.data_operacio, fra_cab.datacreacio, fra_cab.usuari_creacio_id, fra_cab.data_modificacio, fra_cab.usuari_modificacio_id, fra_cab.prog_modificacio, fra_cab.proces_generador,
			fra_cab.agent_aduana_id, fra_cab.serv_bien, fra_cab.total_aduana, fra_cab.num_recepcio, fra_cab.id
		FROM fra_cab
			LEFT JOIN compte as compte_id ON (compte_id.id_ant = fra_cab.compte_id AND compte_id.centre_id = $centre_nou AND compte_id.centre_exercici_id = $centre_exercici_nou)	
			LEFT JOIN compte as compte_tercer_id ON (compte_tercer_id.id_ant = fra_cab.compte_tercer_id AND compte_tercer_id.centre_id = $centre_nou AND compte_tercer_id.centre_exercici_id = $centre_exercici_nou)				
		WHERE fra_cab.centre_id = $centre_anterior AND fra_cab.centre_exercici_id = $centre_exercici_anterior;
		
		INSERT INTO fra_det
		SELECT null, $centre_nou, $centre_exercici_nou, fra_cab_id.id, fra_det.compte, compte_id.id, fra_det.cc_id, fra_det.criteri_imputacio, fra_det.concepto, fra_det.base, fra_det.dpte,
			fra_det.base_imp, fra_det.iva_id, fra_det.pgte_iva, fra_det.import_iva, compte_iva.id, fra_det.import_rec, fra_det.descripcio1, fra_det.descripcio2, fra_det.datacreacio, fra_det.usuari_creacio_id,
			fra_det.data_modificacio, fra_det.usuari_modificacio_id, fra_det.prog_modificacio, fra_det.proces_generador, fra_det.compte_titol, fra_det.compte_iva_id, fra_det.cc, fra_det.id
		FROM fra_det
			LEFT JOIN fra_cab as fra_cab_id ON (fra_cab_id.id_ant = fra_det.fra_cab_id AND fra_cab_id.centre_id = $centre_nou AND fra_cab_id.centre_exercici_id = $centre_exercici_nou)
			LEFT JOIN compte as compte_id ON (compte_id.id_ant = fra_det.compte_id AND compte_id.centre_id = $centre_nou AND compte_id.centre_exercici_id = $centre_exercici_nou)	
			LEFT JOIN compte as compte_iva ON (compte_iva.id_ant = fra_det.compte_iva AND compte_iva.centre_id = $centre_nou AND compte_iva.centre_exercici_id = $centre_exercici_nou)				
		WHERE fra_det.centre_id = $centre_anterior AND fra_det.centre_exercici_id = $centre_exercici_anterior;
		
		UPDATE assentament_cab
			LEFT JOIN fra_cab as fra_cab_id ON (assentament_cab.fra_cab_id = fra_cab_id.id_ant)
		SET
			assentament_cab.fra_cab_id = fra_cab_id.id;

		UPDATE assentament
			LEFT JOIN fra_cab as fra_cab_id ON (assentament.fra_cab_id = fra_cab_id.id_ant)
		SET
			assentament.fra_cab_id = fra_cab_id.id;
	END IF;
	
	/* ENTITAT: MINUTES */
	IF $entitat_minutes = 1 THEN
		INSERT INTO minutes_cab
		SELECT null, $centre_nou, $centre_exercici_nou, minutes_cab.mes, minutes_cab.ano, minutes_cab.diari, minutes_cab.diari_id, minutes_cab.tipus_pla, minutes_cab.tipus_diari_id,
			minutes_cab.descripcio, compte_id.id, minutes_cab.compte_codi, minutes_cab.compte_descripcio, minutes_cab.data_creacio, minutes_cab.usuari_creacio_id, minutes_cab.data_modificacio,
			minutes_cab.usuari_modificacio_id, minutes_cab.prog_modificacio, minutes_cab.proces_generador, minutes_cab.comptabilitzada, minutes_cab.data_comptabilitzacio, minutes_cab.mes_id, minutes_cab.any_mes,
			minutes_cab.mes_titol, minutes_cab.nrr, minutes_cab.id
		FROM minutes_cab
			LEFT JOIN compte as compte_id ON (compte_id.id_ant = minutes_cab.compte_id AND compte_id.centre_id = $centre_nou AND compte_id.centre_exercici_id = $centre_exercici_nou)	
		WHERE minutes_cab.centre_id = $centre_anterior AND minutes_cab.centre_exercici_id = $centre_exercici_anterior;
		
		INSERT INTO minutes_det
		SELECT null, minutes_cab.id, $centre_nou, $centre_exercici_nou, compte_id.id, minutes_det.compte, minutes_det.venciments_id, minutes_det.data_ass, minutes_det.dia,
			minutes_det.mes, minutes_det.ano, minutes_det.num_ass, minutes_det.num_apunt, minutes_det.concepte, minutes_det.codi_concepte_id, minutes_det.import, minutes_det.entrades, minutes_det.sortides,
			minutes_det.saldo, minutes_det.signe, minutes_det.cc, minutes_det.ccost_id, minutes_det.criteri_imputacio, minutes_det.document, minutes_det.data_creacio, minutes_det.usuari_creacio_id,
			minutes_det.data_modificacio, minutes_det.usuari_modificacio_id, minutes_det.prog_modificacio, minutes_det.proces_generador, minutes_det.compte_ant, minutes_det.compte_contra_ant, minutes_det.compte_idA,
			minutes_det.compte_idB, minutes_det.tipus_linia, minutes_det.compte_titol, minutes_det.id
		FROM minutes_det
			LEFT JOIN minutes_cab ON (minutes_cab.id_ant = minutes_det.minutes_cab_id AND minutes_cab.centre_id = $centre_nou AND minutes_cab.centre_exercici_id = $centre_exercici_nou)
			LEFT JOIN compte as compte_id ON (compte_id.id_ant = minutes_det.compte_id AND compte_id.centre_id = $centre_nou AND compte_id.centre_exercici_id = $centre_exercici_nou)	
		WHERE minutes_det.centre_id = $centre_anterior AND minutes_det.centre_exercici_id = $centre_exercici_anterior; 
		
		UPDATE assentament
			LEFT JOIN minutes_cab as minutes_cab_id ON (assentament.minutes_cab_id = minutes_cab_id.id_ant)
			LEFT JOIN minutes_det as minutes_det_id ON (assentament.minutes_det_id = minutes_det_id.id_ant)
		SET
			assentament.minutes_cab_id = minutes_cab_id.id,
			assentament.minutes_det_id = minutes_det_id.id;
	END IF;
	

END