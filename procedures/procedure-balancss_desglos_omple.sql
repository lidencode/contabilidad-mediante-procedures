CREATE DEFINER=`root`@`localhost` PROCEDURE `balancss_desglos_omple`(IN `_centre_id` INT, IN `_centre_exercici_id` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

	/* variables */
	DECLARE _cursor_compte_compte, _balancss_compte INT;
	DECLARE _cursor_compte_titol VARCHAR(50);
	
	/* cursor compte */
	DECLARE cursor_eof INTEGER DEFAULT 0;	
	DECLARE cursor_compte CURSOR FOR 
		SELECT compte.compte, compte_pare.titol FROM compte
		LEFT JOIN compte as compte_pare ON (compte_pare.compte = LEFT(compte.compte, 3))
		WHERE compte.centre_id = _centre_id AND compte.centre_exercici_id = _centre_exercici_id
		GROUP BY compte.compte ORDER BY compte ASC;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_eof = 1;

	/* bucle sobre el cursor comptes */
	SET cursor_eof = 0;
	OPEN cursor_compte;
	get_compte: LOOP

		FETCH cursor_compte INTO _cursor_compte_compte, _cursor_compte_titol;

		IF cursor_eof = 1 THEN
			LEAVE get_compte;
		END IF;
		
		/* busca la cuenta en balancss_desglos por número de digitos */
		SET _balancss_compte = NULL;
		IF LENGTH(_cursor_compte_compte) >= 5 THEN
			SET _cursor_compte_compte = LEFT(_cursor_compte_compte, 5);
			SELECT compte INTO _balancss_compte FROM balancss_desglos WHERE compte = _cursor_compte_compte LIMIT 1;
			/* si no encuentra la cuenta de 5 digitos la crea */
			IF ISNULL(_balancss_compte) = TRUE THEN
				INSERT INTO balancss_desglos (`centre_id`, `centre_exercici_id`, `compte`, `titol`) VALUES (_centre_id, _centre_exercici_id, _cursor_compte_compte, _cursor_compte_titol);
			END IF;
		END IF;

		SET _balancss_compte = NULL;
		IF LENGTH(_cursor_compte_compte) >= 4 THEN
			SET _cursor_compte_compte = LEFT(_cursor_compte_compte, 4);
			SELECT compte INTO _balancss_compte FROM balancss_desglos WHERE compte = _cursor_compte_compte LIMIT 1;
			/* si no encuentra la cuenta de 4 digitos la crea */
			IF ISNULL(_balancss_compte) = TRUE THEN
				INSERT INTO balancss_desglos (`centre_id`, `centre_exercici_id`, `compte`, `titol`) VALUES (_centre_id, _centre_exercici_id, _cursor_compte_compte, _cursor_compte_titol);
			END IF;
		END IF;

		SET _balancss_compte = NULL;
		IF LENGTH(_cursor_compte_compte) >= 2 THEN
			SET _cursor_compte_compte = LEFT(_cursor_compte_compte, 2);
			SELECT compte INTO _balancss_compte FROM balancss_desglos WHERE compte = _cursor_compte_compte LIMIT 1;
			/* si no encuentra la cuenta de 2 digitos la crea */
			IF ISNULL(_balancss_compte) = TRUE THEN
				INSERT INTO balancss_desglos (`centre_id`, `centre_exercici_id`, `compte`, `titol`) VALUES (_centre_id, _centre_exercici_id, _cursor_compte_compte, _cursor_compte_titol);
			END IF;
		END IF;

		SET _balancss_compte = NULL;
		IF LENGTH(_cursor_compte_compte) >= 1 THEN
			SET _cursor_compte_compte = LEFT(_cursor_compte_compte, 1);
			SELECT compte INTO _balancss_compte FROM balancss_desglos WHERE compte = _cursor_compte_compte LIMIT 1;
			/* si no encuentra la cuenta de 1 digitos la crea */
			IF ISNULL(_balancss_compte) = TRUE THEN
				INSERT INTO balancss_desglos (`centre_id`, `centre_exercici_id`, `compte`, `titol`) VALUES (_centre_id, _centre_exercici_id, _cursor_compte_compte, _cursor_compte_titol);
			END IF;
		END IF;
		
		/* deja de nuevo el EOF a 0 porque ha cambiado con el select anterior */
		SET cursor_eof = 0;
	END LOOP get_compte;
	CLOSE cursor_compte;

	SELECT 'ok' as result;
END