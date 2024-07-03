-- --------------------------------------------------------
-- Host:                         localhost
-- Versión del servidor:         11.2.2-MariaDB - mariadb.org binary distribution
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.3.0.6589
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Volcando estructura para tabla almacencontenedores.contenedores
CREATE TABLE IF NOT EXISTS `contenedores` (
  `NumeroContenedor` varchar(20) NOT NULL,
  `Tamano` varchar(10) DEFAULT NULL CHECK (`Tamano` in ('20HC','40HC')),
  `FechaEntrada` datetime DEFAULT NULL,
  `FechaSalida` datetime DEFAULT NULL,
  `NumeroEconomico` varchar(20) DEFAULT NULL,
  `Flujo` varchar(10) DEFAULT NULL CHECK (`Flujo` in ('Entrada','Salida')),
  PRIMARY KEY (`NumeroContenedor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla almacencontenedores.inventario
CREATE TABLE IF NOT EXISTS `inventario` (
  `NumeroContenedor` varchar(20) NOT NULL,
  `Tamano` varchar(10) DEFAULT NULL CHECK (`Tamano` in ('20HC','40HC')),
  `FechaEntrada` datetime DEFAULT NULL,
  `NumeroEconomico` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`NumeroContenedor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para vista almacencontenedores.vistahistorialsalidas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vistahistorialsalidas` (
	`NumeroContenedor` VARCHAR(20) NOT NULL COLLATE 'latin1_swedish_ci',
	`Tamano` VARCHAR(10) NULL COLLATE 'latin1_swedish_ci',
	`FechaEntrada` DATETIME NULL,
	`FechaSalida` DATETIME NULL,
	`NumeroEconomico` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista almacencontenedores.vistainventarioactual
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vistainventarioactual` (
	`NumeroContenedor` VARCHAR(20) NOT NULL COLLATE 'latin1_swedish_ci',
	`Tamano` VARCHAR(10) NULL COLLATE 'latin1_swedish_ci',
	`FechaEntrada` DATETIME NULL,
	`NumeroEconomico` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Volcando estructura para procedimiento almacencontenedores.RegistrarEntrada
DELIMITER //
CREATE PROCEDURE `RegistrarEntrada`(
    IN NumeroContenedor VARCHAR(20),
    IN Tamano VARCHAR(10),
    IN FechaEntrada DATETIME,
    IN NumeroEconomico VARCHAR(20)
)
BEGIN
    -- Declaración de variables
    DECLARE Conteo20HC INT DEFAULT 0;
    DECLARE Conteo40HC INT DEFAULT 0;

    -- Verificar que el número de contenedor no exista ya en el inventario
    IF EXISTS (SELECT 1 FROM Inventario WHERE NumeroContenedor = NumeroContenedor) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El contenedor ya está en el inventario.';
    ELSE
        -- Verificar que la combinación de contenedores sea correcta
        SELECT COUNT(*) INTO Conteo20HC FROM Inventario 
        WHERE NumeroEconomico = NumeroEconomico AND Tamano = '20HC';

        SELECT COUNT(*) INTO Conteo40HC FROM Inventario 
        WHERE NumeroEconomico = NumeroEconomico AND Tamano = '40HC';

        IF Tamano = '20HC' AND Conteo20HC >= 2 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un camión no puede traer más de 2 contenedores de 20HC.';
        ELSEIF Tamano = '40HC' AND Conteo40HC >= 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un camión no puede traer más de 1 contenedor de 40HC.';
        ELSE
            -- Insertar en la tabla de inventario
            INSERT INTO Inventario (NumeroContenedor, Tamano, FechaEntrada, NumeroEconomico)
            VALUES (NumeroContenedor, Tamano, FechaEntrada, NumeroEconomico);

            -- Registrar en la tabla de contenedores
            INSERT INTO Contenedores (NumeroContenedor, Tamano, FechaEntrada, NumeroEconomico, Flujo)
            VALUES (NumeroContenedor, Tamano, FechaEntrada, NumeroEconomico, 'Entrada');
        END IF;
    END IF;
END//
DELIMITER ;

-- Volcando estructura para procedimiento almacencontenedores.RegistrarSalida
DELIMITER //
CREATE PROCEDURE `RegistrarSalida`(
    IN NumeroContenedor VARCHAR(20),
    IN FechaSalida DATETIME
)
BEGIN
    -- Declaración de variables
    DECLARE Tamano VARCHAR(10);
    DECLARE NumeroEconomico VARCHAR(20);
    DECLARE Conteo20HC INT DEFAULT 0;
    DECLARE Conteo40HC INT DEFAULT 0;

    -- Verificar que el contenedor exista en el inventario
    IF NOT EXISTS (SELECT 1 FROM Inventario WHERE NumeroContenedor = NumeroContenedor) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El contenedor no está en el inventario.';
    ELSE
        -- Obtener los detalles del contenedor
        SELECT Tamano, NumeroEconomico INTO Tamano, NumeroEconomico 
        FROM Inventario WHERE NumeroContenedor = NumeroContenedor;

        -- Verificar que la combinación de contenedores sea correcta
        SELECT COUNT(*) INTO Conteo20HC FROM Inventario 
        WHERE NumeroEconomico = NumeroEconomico AND Tamano = '20HC';

        SELECT COUNT(*) INTO Conteo40HC FROM Inventario 
        WHERE NumeroEconomico = NumeroEconomico AND Tamano = '40HC';

        IF Tamano = '20HC' AND Conteo20HC > 2 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La combinación de contenedores no es correcta para la salida.';
        ELSEIF Tamano = '40HC' AND Conteo40HC > 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La combinación de contenedores no es correcta para la salida.';
        ELSE
            -- Actualizar la tabla de inventario
            DELETE FROM Inventario WHERE NumeroContenedor = NumeroContenedor;

            -- Registrar en la tabla de contenedores
            UPDATE Contenedores
            SET FechaSalida = FechaSalida, Flujo = 'Salida'
            WHERE NumeroContenedor = NumeroContenedor;
        END IF;
    END IF;
END//
DELIMITER ;

-- Volcando estructura para vista almacencontenedores.vistahistorialsalidas
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vistahistorialsalidas`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vistahistorialsalidas` AS SELECT NumeroContenedor, Tamano, FechaEntrada, FechaSalida, NumeroEconomico
FROM Contenedores
WHERE Flujo = 'Salida' ;

-- Volcando estructura para vista almacencontenedores.vistainventarioactual
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vistainventarioactual`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vistainventarioactual` AS SELECT NumeroContenedor, Tamano, FechaEntrada, NumeroEconomico
FROM Inventario ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
