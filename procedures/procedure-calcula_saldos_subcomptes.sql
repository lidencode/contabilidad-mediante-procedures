CREATE DEFINER=`root`@`localhost` PROCEDURE `calcula_saldos_subcomptes`(IN `$centre_id` VARCHAR(12), IN `$centre_exercici_id` VARCHAR(12))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* calcula_saldos_subcomptes */
	/* Rellena la tabla 'tmp_saldos_subcomptes' con una comprobación del saldo final con el campo D_H de las cuentas de un ejercicio añadiendo error si lo hubiese. */

	/* variables */
	DECLARE $compte_D_H VARCHAR(10);
	DECLARE $compte_compte VARCHAR(12);
	DECLARE $tipus_error, $compte_titol VARCHAR(50);
	DECLARE $compte_saldo_final DECIMAL(13,2);
	
	/* declara cursores */
	DECLARE $EOF INTEGER DEFAULT 0;
	DECLARE $cursor_compte CURSOR FOR SELECT `compte`,`titol`,`D_H`,`saldo_final` FROM compte WHERE centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET $EOF = 1;
	
	/* borra los datos de la tabla destino */
	DELETE FROM `tmp_saldos_subcomptes` WHERE centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;

	/* recorre la tabla comptes */
	SET $EOF = 0;
	OPEN $cursor_compte;
	loop_compte: LOOP
	
		FETCH $cursor_compte INTO $compte_compte, $compte_titol, $compte_D_H, $compte_saldo_final;
		IF $EOF = 1 THEN LEAVE loop_compte; END IF;

		/* establece el error (si lo hubiese) */
		SET $tipus_error = '';
		
		IF $compte_D_H = 'D' AND $compte_saldo_final < 0 THEN
			SET $tipus_error = 'Debería tener saldo D';				
		END IF;

		IF $compte_D_H = 'H' AND $compte_saldo_final > 0 THEN
			SET $tipus_error = 'Debería tener saldo H';				
		END IF;
				
		/* inserta el registro en la tabla destino */
		
		INSERT INTO `tmp_saldos_subcomptes` (`centre_id`,`centre_exercici_id`,`compte`,`titol`,`saldo_final`,`tipus_error`)
			VALUES ($centre_id, $centre_exercici_id, $compte_compte, $compte_titol, $compte_saldo_final, $tipus_error);
			
	END LOOP loop_compte;
	CLOSE $cursor_compte;
	
END