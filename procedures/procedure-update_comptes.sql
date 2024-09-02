CREATE DEFINER=`root`@`localhost` PROCEDURE `update_comptes`(IN `$centre_id` VARCHAR(12), IN `$centre_exercici_id` VARCHAR(12))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	
	/* variables */
	DECLARE $compte_compte VARCHAR(12);
	DECLARE $compte_mes INT;
	DECLARE $compte_mes_deure, $compte_mes_haver, $compte_realitzat DECIMAL(13,2);
	
	/* declara cursores */
	DECLARE $EOF INTEGER DEFAULT 0;
	DECLARE $cursor_compte CURSOR FOR SELECT DISTINCT assentament.`compte` FROM assentament WHERE assentament.centre_id = $centre_id AND assentament.centre_exercici_id = $centre_exercici_id;
	DECLARE $cursor_compte_pare CURSOR FOR SELECT DISTINCT compte.`compte` FROM compte WHERE compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET $EOF = 1;

	/* hacer update a 0 en compte */
	UPDATE compte SET
		sumd01 = 0,	sumd02 = 0,	sumd03 = 0,	sumd04 = 0,	sumd05 = 0,	sumd06 = 0,	sumd07 = 0,	sumd08 = 0,	sumd09 = 0,	sumd10 = 0,	sumd11 = 0,	sumd12 = 0,
		sumh01 = 0,	sumh02 = 0,	sumh03 = 0,	sumh04 = 0,	sumh05 = 0,	sumh06 = 0,	sumh07 = 0,	sumh08 = 0,	sumh09 = 0,	sumh10 = 0,	sumh11 = 0,	sumh12 = 0,
		saldo_final = 0, realitzat = 0, per_realitzar = 0, pctge_per_realitzar = 0
	WHERE centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;
	
	/* recorre la tabla comptes */
	SET $EOF = 0;
	OPEN $cursor_compte;
	loop_compte: LOOP
	
		FETCH $cursor_compte INTO $compte_compte;
		IF $EOF = 1 THEN LEAVE loop_compte; END IF;
	
		/* recorre los 12 meses */
		SET $compte_mes = 1;
		
		WHILE $compte_mes <= 12 DO
			SELECT IFNULL(SUM(import_deure), 0), IFNULL(SUM(import_haver), 0) INTO $compte_mes_deure, $compte_mes_haver FROM assentament WHERE compte = $compte_compte AND mes = $compte_mes AND centre_id = $centre_id AND centre_exercici_id = $centre_exercici_id;

			IF $compte_mes = 1 THEN
				UPDATE compte SET	sumd01 = $compte_mes_deure, sumh01 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd01 = compte.sumd01 + $compte_mes_deure, compte.sumh01 = compte.sumh01 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 2 THEN
				UPDATE compte SET	sumd02 = $compte_mes_deure, sumh02 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd02 = compte.sumd02 + $compte_mes_deure, compte.sumh02 = compte.sumh02 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 3 THEN
				UPDATE compte SET	sumd03 = $compte_mes_deure, sumh03 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd03 = compte.sumd03 + $compte_mes_deure, compte.sumh03 = compte.sumh03 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 4 THEN
				UPDATE compte SET	sumd04 = $compte_mes_deure, sumh04 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd04 = compte.sumd04 + $compte_mes_deure, compte.sumh04 = compte.sumh04 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 5 THEN
				UPDATE compte SET	sumd05 = $compte_mes_deure, sumh05 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd05 = compte.sumd05 + $compte_mes_deure, compte.sumh05 = compte.sumh05 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 6 THEN
				UPDATE compte SET	sumd06 = $compte_mes_deure, sumh06 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd06 = compte.sumd06 + $compte_mes_deure, compte.sumh06 = compte.sumh06 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 7 THEN
				UPDATE compte SET	sumd07 = $compte_mes_deure, sumh07 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd07 = compte.sumd07 + $compte_mes_deure, compte.sumh07 = compte.sumh07 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 8 THEN
				UPDATE compte SET	sumd08 = $compte_mes_deure, sumh08 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd08 = compte.sumd08 + $compte_mes_deure, compte.sumh08 = compte.sumh08 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 9 THEN
				UPDATE compte SET	sumd09 = $compte_mes_deure, sumh09 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd09 = compte.sumd09 + $compte_mes_deure, compte.sumh09 = compte.sumh09 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 10 THEN
				UPDATE compte SET	sumd10 = $compte_mes_deure, sumh10 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd10 = compte.sumd10 + $compte_mes_deure, compte.sumh10 = compte.sumh10 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 11 THEN
				UPDATE compte SET	sumd11 = $compte_mes_deure, sumh11 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd11 = compte.sumd11 + $compte_mes_deure, compte.sumh11 = compte.sumh11 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			IF $compte_mes = 12 THEN
				UPDATE compte SET	sumd12 = $compte_mes_deure, sumh12 = $compte_mes_haver
				WHERE compte.compte = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
				
				UPDATE compte SET compte.sumd12 = compte.sumd12 + $compte_mes_deure, compte.sumh12 = compte.sumh12 + $compte_mes_haver
				WHERE compte.compte = LEFT($compte_compte , 3) AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
			END IF;
			
			SET $compte_mes = $compte_mes + 1;
		END WHILE;

	END LOOP loop_compte;
	CLOSE $cursor_compte;
	
	/* recorre comptes pare */
	SET $EOF = 0;
	OPEN $cursor_compte_pare;
	loop_compte_pare: LOOP
	
		FETCH $cursor_compte_pare INTO $compte_compte;
		IF $EOF = 1 THEN LEAVE loop_compte_pare; END IF;	

		/* hace un update (calcula) de los campos saldo_final, realitzat, per_realitzar, pctge_per_realitzar */
		SELECT (sumd01 + sumd02 + sumd03 + sumd04 + sumd05 + sumd06 + sumd07 + sumd08 + sumd09 + sumd10 + sumd11 + sumd12)
			- (sumh01 + sumh02 + sumh03 + sumh04 + sumh05 + sumh06 + sumh07 + sumh08 + sumh09 + sumh10 + sumh11 + sumh12)
		INTO $compte_realitzat FROM compte 
		WHERE compte.`compte` = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;


		UPDATE compte SET
			saldo_inicial = saldo_inih - saldo_inid,
			saldo_final = (saldo_inih - saldo_inid) + $compte_realitzat,
			realitzat = $compte_realitzat,
			per_realitzar = compte.`pressupost` - $compte_realitzat,
			pctge_per_realitzar = $compte_realitzat / compte.`pressupost` * 100
		WHERE compte.`compte` = $compte_compte AND compte.centre_id = $centre_id AND compte.centre_exercici_id = $centre_exercici_id;
		
	END LOOP loop_compte_pare;
	CLOSE $cursor_compte_pare;
		
	SELECT 'ok' as result;
END