DROP DATABASE henry_m3_hw;
CREATE DATABASE IF NOT EXISTS henry_m3_hw;
USE henry_m3_hw;

/* Función Capitaliza */
-- cuando el registro binario está habilitado, esta variable estará habilitada. Controla si se puede confiar en el creador de la función almacenada y no creará una función almacenada que cause eventos inseguros al escribir en el registro binario. Si se establece en 0 (predeterminado), los usuarios no deben crear ni modificar funciones almacenadas a menos que tengan permisos SUPER además de los privilegios CREATE ROUTINE o ALTER ROUTINE. Establecer a 0 también fuerza el uso de características DETERMINISTAS o READS SQL DATA o NO características SQL para declarar límites de funciones. Si la variable se establece en 1, MySQL no aplicará estas restricciones en la creación de funciones almacenadas. Esta variable también se aplica a la creación de disparadores. Consulte la Sección 23.7 "Registro binario de programas almacenados".
SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS `UC_Words`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `UC_Words`( str VARCHAR(255) ) RETURNS varchar(255) CHARSET utf8
BEGIN  
  DECLARE c CHAR(1);  
  DECLARE s VARCHAR(255);  
  DECLARE i INT DEFAULT 1;  
  DECLARE bool INT DEFAULT 1;  
  DECLARE punct CHAR(17) DEFAULT ' ()[]{},.-_!@;:?/';  
  SET s = LCASE( str );  
  WHILE i < LENGTH( str ) DO  
     BEGIN  
       SET c = SUBSTRING( s, i, 1 );  
       IF LOCATE( c, punct ) > 0 THEN  
        SET bool = 1;  
      ELSEIF bool=1 THEN  
        BEGIN  
          IF c >= 'a' AND c <= 'z' THEN  
             BEGIN  
               SET s = CONCAT(LEFT(s,i-1),UCASE(c),SUBSTRING(s,i+1));  
               SET bool = 0;  
             END;  
           ELSEIF c >= '0' AND c <= '9' THEN  
            SET bool = 0;  
          END IF;  
        END;  
      END IF;  
      SET i = i+1;  
    END;  
  END WHILE;  
  RETURN s;  
END$$
DELIMITER;

DROP PROCEDURE IF EXISTS `Llenar_dimension_calendario`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Llenar_dimension_calendario`(IN `startdate` DATE, IN `stopdate` DATE)
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
        INSERT INTO calendario VALUES (
                        YEAR(currentdate)*10000+MONTH(currentdate)*100 + DAY(currentdate),
                        currentdate,
                        YEAR(currentdate),
                        MONTH(currentdate),
                        DAY(currentdate),
                        QUARTER(currentdate),
                        WEEKOFYEAR(currentdate),
                        DATE_FORMAT(currentdate,'%W'),
                        DATE_FORMAT(currentdate,'%M'));
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

/*Importacion de las tablas*/
DROP TABLE IF EXISTS `gasto`;
CREATE TABLE IF NOT EXISTS `gasto` (
  	`IdGasto` 		INTEGER,
  	`IdSucursal` 	INTEGER,
  	`IdTipoGasto` 	INTEGER,
    `Fecha`			DATE,
  	`Monto` 		DECIMAL(10,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Gasto.csv'
INTO TABLE `gasto` 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT *
FROM gasto;

DROP TABLE IF EXISTS `compra`;
CREATE TABLE IF NOT EXISTS `compra` (
  `IdCompra`			INTEGER,
  `Fecha` 				DATE,
  `IdProducto`			INTEGER,
  `Cantidad`			INTEGER,
  `Precio`				DECIMAL(10,2),
  `IdProveedor`			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\compra.csv' 
INTO TABLE `compra` 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT *
FROM compra;

DROP TABLE IF EXISTS `venta`;
CREATE TABLE IF NOT EXISTS `venta` (
  `IdVenta`				INTEGER,
  `Fecha` 				DATE NOT NULL,
  `Fecha_Entrega` 		DATE NOT NULL,
  `IdCanal`				INTEGER, 
  `IdCliente`			INTEGER, 
  `IdSucursal`			INTEGER,
  `IdEmpleado`			INTEGER,
  `IdProducto`			INTEGER,
  `Precio`				VARCHAR(30),
  `Cantidad`			VARCHAR(30)
  -- `Precio`			DECIMAL(10,2),
  -- `Cantidad`			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\venta.csv' 
INTO TABLE `venta` 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

SELECT * 
FROM venta;

DROP TABLE IF EXISTS `canal_venta`;
CREATE TABLE IF NOT EXISTS `canal_venta` (
  `IdCanal`				INTEGER,
  `Canal` 				VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CanalDeVenta.csv' 
INTO TABLE `canal_venta` 
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT *
FROM canal_venta;

DROP TABLE IF EXISTS `tipo_gasto`;
CREATE TABLE IF NOT EXISTS `tipo_gasto` (
  `IdTipoGasto` int(11) NOT NULL AUTO_INCREMENT,
  `Descripcion` varchar(100) NOT NULL,
  `Monto_Aproximado` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`IdTipoGasto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TiposDeGasto.csv' 
INTO TABLE `tipo_gasto` 
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT *
FROM tipo_gasto;

DROP TABLE IF EXISTS cliente;
CREATE TABLE IF NOT EXISTS cliente (
	ID					INTEGER,
	Provincia			VARCHAR(50),
	Nombre_y_Apellido	VARCHAR(80),
	Domicilio			VARCHAR(150),
	Telefono			VARCHAR(30),
	Edad				VARCHAR(5),
	Localidad			VARCHAR(80),
	X					VARCHAR(30),
	Y					VARCHAR(30),
	col10				VARCHAR(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Clientes.csv'
INTO TABLE cliente
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT *
FROM cliente;

DROP TABLE IF EXISTS proveedor;
CREATE TABLE IF NOT EXISTS proveedor (
	IDProveedor		INTEGER,
	Nombre			VARCHAR(80),
	Domicilio		VARCHAR(150),
	Ciudad			VARCHAR(80),
	Provincia		VARCHAR(50),
	Pais			VARCHAR(20),
	Departamento	VARCHAR(80)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Proveedores.csv' 
INTO TABLE proveedor
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * 
FROM proveedor;

DROP TABLE IF EXISTS producto;
CREATE TABLE IF NOT EXISTS producto (
	IDProducto					INTEGER,
	Concepto					VARCHAR(255),
	Tipo						VARCHAR(50),
	Precio2						VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Productos.csv' 
INTO TABLE `producto` 
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT *
FROM producto;

DROP TABLE IF EXISTS empleado;
CREATE TABLE IF NOT EXISTS empleado (
	IDEmpleado					VARCHAR(100),
	Apellido					VARCHAR(100),
	Nombre						VARCHAR(100),
	Sucursal					VARCHAR(50),
	Sector						VARCHAR(50),
	Cargo						VARCHAR(50),
	Salario2					VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Empleados.csv' 
INTO TABLE `empleado` 
FIELDS TERMINATED BY '|' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT COUNT(*)
FROM empleado;

DROP TABLE IF EXISTS sucursal;
CREATE TABLE IF NOT EXISTS sucursal (
	IDSucursal			INTEGER,
	Sucursal	VARCHAR(40),
	Domicilio	VARCHAR(150),
	Localidad	VARCHAR(80),
	Provincia	VARCHAR(50),
	Latitud2	VARCHAR(30),
	Longitud2	VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Sucursales.csv' 
INTO TABLE sucursal
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT *
FROM sucursal;

/*Se genera la dimension calendario*/
DROP TABLE IF EXISTS `calendario`;
CREATE TABLE calendario (
        id                      INTEGER PRIMARY KEY,  -- year*10000+month*100+day
        fecha                 	DATE NOT NULL,
        anio                    INTEGER NOT NULL,
        mes                   	INTEGER NOT NULL, -- 1 to 12
        dia                     INTEGER NOT NULL, -- 1 to 31
        trimestre               INTEGER NOT NULL, -- 1 to 4
        semana                  INTEGER NOT NULL, -- 1 to 52/53
        dia_nombre              VARCHAR(9) NOT NULL, -- 'Monday', 'Tuesday'...
        mes_nombre              VARCHAR(9) NOT NULL -- 'January', 'February'...
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

CALL Llenar_dimension_calendario('2015-01-01','2020-12-31');
SELECT * FROM calendario;
SELECT UC_Words('alvaro nadie');

SHOW TABLES FROM henry_m3_hw;
DESCRIBE sucursal;


/*Clase 02*/
ALTER TABLE `calendario` CHANGE `id` `IdFecha` INT(11) NOT NULL;
ALTER TABLE `cliente` CHANGE `ID` `IdCliente` INT(11) NOT NULL;
ALTER TABLE `empleado` CHANGE `IDEmpleado` `IdEmpleado` INT(11) NOT NULL;
ALTER TABLE `proveedor` CHANGE `IDProveedor` `IdProveedor` INT(11) NOT NULL;
ALTER TABLE `sucursal` CHANGE `IDSucursal` `IdSucursal` INT NOT NULL;
ALTER TABLE `tipo_gasto` CHANGE `Descripcion` `Tipo_Gasto` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL;
ALTER TABLE `producto` CHANGE `IDProducto` `IdProducto` INT(11) NOT NULL;
ALTER TABLE `producto` CHANGE `Concepto` `Producto` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NULL DEFAULT NULL;

select * from producto;

/*Tipos de Datos*/
ALTER TABLE `cliente` 	
	ADD `Latitud` DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER `Y`, 
	ADD `Longitud` DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER `Latitud`;

SET SQL_SAFE_UPDATES = 0;
UPDATE cliente SET Y='0' WHERE Y='';
UPDATE cliente SET X = '0' WHERE X = '';
UPDATE `cliente` SET Latitud = REPLACE(Y,',','.');
UPDATE `cliente` SET Longitud = REPLACE(X,',','.');

SELECT * FROM `cliente`;
ALTER TABLE `cliente` DROP `Y`;
ALTER TABLE `cliente` DROP `X`;
SELECT * FROM `cliente`;

ALTER TABLE `empleado` ADD `Salario` DECIMAL(10,2) NOT NULL DEFAULT '0' AFTER `Salario2`;
UPDATE `empleado` SET Salario = REPLACE(Salario2,',','.');
ALTER TABLE `empleado` DROP `Salario2`;
SELECT * FROM empleado;

ALTER TABLE `producto` ADD `Precio` DECIMAL(15,3) NOT NULL DEFAULT '0' AFTER `Precio2`;
UPDATE `producto` SET Precio = REPLACE(Precio2,',','.');
ALTER TABLE `producto` DROP `Precio2`;
SELECT * FROM producto;

ALTER TABLE `sucursal` 	ADD `Latitud` DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER `Longitud2`, 
						ADD `Longitud` DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER `Latitud`;
UPDATE `sucursal` SET Latitud = REPLACE(Latitud2,',','.');
UPDATE `sucursal` SET Longitud = REPLACE(Longitud2,',','.');
SELECT * FROM `sucursal`;
ALTER TABLE `sucursal` DROP `Latitud2`;
ALTER TABLE `sucursal` DROP `Longitud2`;
SELECT * FROM sucursal;

UPDATE `venta` SET `Precio` = 0 WHERE `Precio` = '';
ALTER TABLE `venta` CHANGE `Precio` `Precio` DECIMAL(15,2) NOT NULL DEFAULT '0';
SELECT * FROM venta;

/*Columnas sin usar*/
ALTER TABLE `cliente` DROP `col10`;
SELECT * FROM cliente;

-- SELECT trim('     Hola Mundo      ');

/*Imputar Valores Faltantes*/
UPDATE `cliente` SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE `cliente` SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);
UPDATE `cliente` SET Nombre_y_Apellido = 'Sin Dato' WHERE TRIM(Nombre_y_Apellido) = "" OR ISNULL(Nombre_y_Apellido);
UPDATE `cliente` SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);
SELECT * FROM cliente;

UPDATE `empleado` SET Apellido = 'Sin Dato' WHERE TRIM(Apellido) = "" OR ISNULL(Apellido);
UPDATE `empleado` SET Nombre = 'Sin Dato' WHERE TRIM(Nombre) = "" OR ISNULL(Nombre);
UPDATE `empleado` SET Sucursal = 'Sin Dato' WHERE TRIM(Sucursal) = "" OR ISNULL(Sucursal);
UPDATE `empleado` SET Sector = 'Sin Dato' WHERE TRIM(Sector) = "" OR ISNULL(Sector);
UPDATE `empleado` SET Cargo = 'Sin Dato' WHERE TRIM(Cargo) = "" OR ISNULL(Cargo);
SELECT * FROM empleado;

UPDATE `producto` SET Producto = 'Sin Dato' WHERE TRIM(Producto) = "" OR ISNULL(Producto);
UPDATE `producto` SET Tipo = 'Sin Dato' WHERE TRIM(Tipo) = "" OR ISNULL(Tipo);
SELECT * FROM producto;

UPDATE `proveedor` SET Nombre = 'Sin Dato' WHERE TRIM(Nombre) = "" OR ISNULL(Nombre);
UPDATE `proveedor` SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE `proveedor` SET Ciudad = 'Sin Dato' WHERE TRIM(Ciudad) = "" OR ISNULL(Ciudad);
UPDATE `proveedor` SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);
UPDATE `proveedor` SET Pais = 'Sin Dato' WHERE TRIM(Pais) = "" OR ISNULL(Pais);
UPDATE `proveedor` SET Departamento = 'Sin Dato' WHERE TRIM(Departamento) = "" OR ISNULL(Departamento);
SELECT * FROM proveedor;

UPDATE `sucursal` SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE `sucursal` SET Sucursal = 'Sin Dato' WHERE TRIM(Sucursal) = "" OR ISNULL(Sucursal);
UPDATE `sucursal` SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);
UPDATE `sucursal` SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);
SELECT * FROM sucursal;


select * from venta
where Precio = '' or Cantidad = '';
select count(*) from venta;

/*Tabla ventas limpieza y normalizacion*/
UPDATE venta v 
JOIN producto p ON (v.IdProducto = p.IdProducto) 
SET v.Precio = p.Precio
WHERE v.Precio = 0;

/*Tabla auxiliar donde se guardarán registros con problemas:
1-Cantidad en Cero
*/
DROP TABLE IF EXISTS `aux_venta`;
CREATE TABLE IF NOT EXISTS `aux_venta` (
  `IdVenta`				INTEGER,
  `Fecha` 				DATE NOT NULL,
  `Fecha_Entrega` 		DATE NOT NULL,
  `IdCliente`			INTEGER, 
  `IdSucursal`			INTEGER,
  `IdEmpleado`			INTEGER,
  `IdProducto`			INTEGER,
  `Precio`				FLOAT,
  `Cantidad`			INTEGER,
  `Motivo`				INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

UPDATE venta SET Cantidad = REPLACE(Cantidad, '\r', '');

INSERT INTO aux_venta 
(IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT 
IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, 0, 1
FROM venta WHERE Cantidad = '' 
or Cantidad is null;

UPDATE venta SET Cantidad = '1' WHERE Cantidad = '' or Cantidad is null;
ALTER TABLE `venta` CHANGE `Cantidad` `Cantidad` INTEGER NOT NULL DEFAULT '0';

/*Normalizacion a Letra Capital*/
UPDATE cliente SET 	Provincia = UC_Words(TRIM(Provincia)),
					Localidad = UC_Words(TRIM(Localidad)),
                    Domicilio = UC_Words(TRIM(Domicilio)),
                    Nombre_y_Apellido = UC_Words(TRIM(Nombre_y_Apellido));

UPDATE sucursal SET Provincia = UC_Words(TRIM(Provincia)),
					Localidad = UC_Words(TRIM(Localidad)),
                    Domicilio = UC_Words(TRIM(Domicilio)),
                    Sucursal = UC_Words(TRIM(Sucursal));
                    
UPDATE proveedor SET Provincia = UC_Words(TRIM(Provincia)),
					Ciudad = UC_Words(TRIM(Ciudad)),
                    Departamento = UC_Words(TRIM(Departamento)),
                    Pais = UC_Words(TRIM(Pais)),
                    Nombre = UC_Words(TRIM(Nombre)),
                    Domicilio = UC_Words(TRIM(Domicilio));

UPDATE producto SET Producto = UC_Words(TRIM(Producto)),
					Tipo = UC_Words(TRIM(Tipo));
					
UPDATE empleado SET Sucursal = UC_Words(TRIM(Sucursal)),
                    Sector = UC_Words(TRIM(Sector)),
                    Cargo = UC_Words(TRIM(Cargo)),
                    Nombre = UC_Words(TRIM(Nombre)),
                    Apellido = UC_Words(TRIM(Apellido));
                    
/*Chequeo de claves duplicadas*/
SELECT IdCliente, COUNT(*) FROM cliente GROUP BY IdCliente HAVING COUNT(*) > 1;
SELECT IdSucursal, COUNT(*) FROM sucursal GROUP BY IdSucursal HAVING COUNT(*) > 1;
SELECT IdEmpleado, COUNT(*) FROM empleado GROUP BY IdEmpleado HAVING COUNT(*) > 1;
SELECT IdProveedor, COUNT(*) FROM proveedor GROUP BY IdProveedor HAVING COUNT(*) > 1;
SELECT IdProducto, COUNT(*) FROM producto GROUP BY IdProducto HAVING COUNT(*) > 1;

select count(*) from empleado;

SELECT e.*, s.IdSucursal, s.Sucursal
FROM empleado e
JOIN sucursal s	ON (e.Sucursal = s.Sucursal);

select distinct Sucursal from empleado
where Sucursal NOT IN (select Sucursal from sucursal);

/*Generacion de clave única tabla empleado mediante creacion de clave subrogada*/
UPDATE empleado SET Sucursal = 'Mendoza1' WHERE Sucursal = 'Mendoza 1';
UPDATE empleado SET Sucursal = 'Mendoza2' WHERE Sucursal = 'Mendoza 2';
-- UPDATE empleado SET Sucursal = 'Córdoba Quiroz' WHERE Sucursal = 'Cordoba Quiroz';

ALTER TABLE `empleado` ADD `IdSucursal` INT NULL DEFAULT '0' AFTER `Sucursal`;

UPDATE empleado e
JOIN sucursal s	ON (e.Sucursal = s.Sucursal)
SET e.IdSucursal = s.IdSucursal;

SELECT * FROM `empleado`;

ALTER TABLE `empleado` DROP `Sucursal`;

ALTER TABLE `empleado` ADD `CodigoEmpleado` INT NULL DEFAULT '0' AFTER `IdEmpleado`;

UPDATE empleado SET CodigoEmpleado = IdEmpleado;
UPDATE empleado SET IdEmpleado = (IdSucursal * 1000000) + CodigoEmpleado;

/*Chequeo de claves duplicadas*/
SELECT * FROM `empleado`;
SELECT IdEmpleado, COUNT(*) FROM empleado GROUP BY IdEmpleado HAVING COUNT(*) > 1;

/*Modificacion de la clave foranea de empleado en venta*/
UPDATE venta SET IdEmpleado = (IdSucursal * 1000000) + IdEmpleado;

/*Normalizacion tabla empleado*/
DROP TABLE IF EXISTS `cargo`;
CREATE TABLE IF NOT EXISTS `cargo` (
  `IdCargo` int(11) NOT NULL AUTO_INCREMENT,
  `Cargo` varchar(50) NOT NULL,
  PRIMARY KEY (`IdCargo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS `sector`;
CREATE TABLE IF NOT EXISTS `sector` (
  `IdSector` int(11) NOT NULL AUTO_INCREMENT,
  `Sector` varchar(50) NOT NULL,
  PRIMARY KEY (`IdSector`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO cargo (Cargo) SELECT DISTINCT Cargo FROM empleado ORDER BY 1;
INSERT INTO sector (Sector) SELECT DISTINCT Sector FROM empleado ORDER BY 1;

select * from cargo;
select * from sector;

ALTER TABLE `empleado` 	ADD `IdSector` INT NOT NULL DEFAULT '0' AFTER `IdSucursal`, 
						ADD `IdCargo` INT NOT NULL DEFAULT '0' AFTER `IdSector`;

UPDATE empleado e JOIN cargo c ON (c.Cargo = e.Cargo) SET e.IdCargo = c.IdCargo;
UPDATE empleado e JOIN sector s ON (s.Sector = e.Sector) SET e.IdSector = s.IdSector;

ALTER TABLE `empleado` DROP `Cargo`;
ALTER TABLE `empleado` DROP `Sector`;

SELECT * FROM `empleado`;

/*Normalización tabla producto*/
SELECT * FROM producto;
ALTER TABLE `producto` ADD `IdTipoProducto` INT NOT NULL DEFAULT '0' AFTER `Precio`;
SELECT * FROM producto;

DROP TABLE IF EXISTS `tipo_producto`;
CREATE TABLE IF NOT EXISTS `tipo_producto` (
  `IdTipoProducto` int(11) NOT NULL AUTO_INCREMENT,
  `TipoProducto` varchar(50) NOT NULL,
  PRIMARY KEY (`IdTipoProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO tipo_producto (TipoProducto) SELECT DISTINCT Tipo FROM producto ORDER BY 1;
SELECT * FROM producto;

UPDATE producto p JOIN tipo_producto t ON (p.Tipo = t.TipoProducto) SET p.IdTipoProducto = t.IdTipoProducto;

SELECT * FROM `producto`;

ALTER TABLE `producto` DROP `Tipo`;

/*Normalización Localidad Provincia*/
DROP TABLE IF EXISTS aux_Localidad;
CREATE TABLE IF NOT EXISTS aux_Localidad (
	Localidad_Original	VARCHAR(80),
	Provincia_Original	VARCHAR(50),
	Localidad_Normalizada	VARCHAR(80),
	Provincia_Normalizada	VARCHAR(50),
	IdLocalidad			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO aux_localidad (Localidad_Original, Provincia_Original, Localidad_Normalizada, Provincia_Normalizada, IdLocalidad)
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM cliente
UNION
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM sucursal
UNION
SELECT DISTINCT Ciudad, Provincia, Ciudad, Provincia, 0 FROM proveedor
ORDER BY 2, 1;

SELECT * FROM aux_localidad ORDER BY Provincia_Original;

UPDATE `aux_localidad` SET Provincia_Normalizada = 'Buenos Aires'
WHERE Provincia_Original IN ('B. Aires',
                            'B.Aires',
                            'Bs As',
                            'Bs.As.',
                            'Buenos Aires',
                            'C Debuenos Aires',
                            'Caba',
                            'Ciudad De Buenos Aires',
                            'Pcia Bs As',
                            'Prov De Bs As.',
                            'Provincia De Buenos Aires');
							
UPDATE `aux_localidad` SET Localidad_Normalizada = 'Capital Federal'
WHERE Localidad_Original IN ('Boca De Atencion Monte Castro',
                            'Caba',
                            'Cap.   Federal',
                            'Cap. Fed.',
                            'Capfed',
                            'Capital',
                            'Capital Federal',
                            'Cdad De Buenos Aires',
                            'Ciudad De Buenos Aires')
AND Provincia_Normalizada = 'Buenos Aires';
							
UPDATE `aux_localidad` SET Localidad_Normalizada = 'Córdoba'
WHERE Localidad_Original IN ('Coroba',
                            'Cordoba',
							'Cã³rdoba')
AND Provincia_Normalizada = 'Córdoba';

DROP TABLE IF EXISTS `localidad`;
CREATE TABLE IF NOT EXISTS `localidad` (
  `IdLocalidad` int(11) NOT NULL AUTO_INCREMENT,
  `Localidad` varchar(80) NOT NULL,
  `Provincia` varchar(80) NOT NULL,
  `IdProvincia` int(11) NOT NULL,
  PRIMARY KEY (`IdLocalidad`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS `provincia`;
CREATE TABLE IF NOT EXISTS `provincia` (
  `IdProvincia` int(11) NOT NULL AUTO_INCREMENT,
  `Provincia` varchar(50) NOT NULL,
  PRIMARY KEY (`IdProvincia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO Localidad (Localidad, Provincia, IdProvincia)
SELECT	DISTINCT Localidad_Normalizada, Provincia_Normalizada, 0
FROM aux_localidad
ORDER BY Provincia_Normalizada, Localidad_Normalizada;

INSERT INTO provincia (Provincia)
SELECT DISTINCT Provincia_Normalizada
FROM aux_localidad
ORDER BY Provincia_Normalizada;

select * from provincia;
select * from localidad;

UPDATE localidad l
JOIN provincia p ON (l.Provincia = p.Provincia)
SET l.IdProvincia = p.IdProvincia;

UPDATE aux_localidad a
JOIN localidad l ON (l.Localidad = a.Localidad_Normalizada
                AND a.Provincia_Normalizada = l.Provincia)
SET a.IdLocalidad = l.IdLocalidad;

select * from aux_localidad;

ALTER TABLE `cliente` ADD `IdLocalidad` INT NOT NULL DEFAULT '0' AFTER `Localidad`;
ALTER TABLE `proveedor` ADD `IdLocalidad` INT NOT NULL DEFAULT '0' AFTER `Departamento`;
ALTER TABLE `sucursal` ADD `IdLocalidad` INT NOT NULL DEFAULT '0' AFTER `Provincia`;

UPDATE cliente c JOIN aux_localidad a
	ON (c.Provincia = a.Provincia_Original AND c.Localidad = a.Localidad_Original)
SET c.IdLocalidad = a.IdLocalidad;

UPDATE sucursal s JOIN aux_localidad a
	ON (s.Provincia = a.Provincia_Original AND s.Localidad = a.Localidad_Original)
SET s.IdLocalidad = a.IdLocalidad;

UPDATE proveedor p JOIN aux_localidad a
	ON (p.Provincia = a.Provincia_Original AND p.Ciudad = a.Localidad_Original)
SET p.IdLocalidad = a.IdLocalidad;

select * from cliente;
select * from proveedor;
select * from sucursal;

ALTER TABLE `cliente`
  DROP `Provincia`,
  DROP `Localidad`;
  
ALTER TABLE `proveedor`
  DROP `Ciudad`,
  DROP `Provincia`,
  DROP `Pais`,
  DROP `Departamento`;
  
ALTER TABLE `sucursal`
  DROP `Localidad`,
  DROP `Provincia`;
  
ALTER TABLE `localidad`
  DROP `Provincia`;
  
SELECT * FROM `cliente`;
SELECT * FROM `proveedor`;
SELECT * FROM `sucursal`;
SELECT * FROM `localidad`;
SELECT * FROM `provincia`;

/*Discretización*/
ALTER TABLE `cliente` ADD `Rango_Etario` VARCHAR(20) NOT NULL DEFAULT '-' AFTER `Edad`;

UPDATE cliente SET Rango_Etario = '1_Hasta 30 años' WHERE Edad <= 30;
UPDATE cliente SET Rango_Etario = '2_De 31 a 40 años' WHERE Edad <= 40 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '3_De 41 a 50 años' WHERE Edad <= 50 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '4_De 51 a 60 años' WHERE Edad <= 60 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '5_Desde 60 años' WHERE Edad > 60 AND Rango_Etario = '-';

select Rango_Etario, count(*)
from cliente
group by Rango_Etario;

SELECT * from venta
UNION ALL
SELECT * from aux_venta;

SELECT * FROM producto;
ALTER TABLE producto RENAME COLUMN IDProducto TO IdProducto;

SET SQL_SAFE_UPDATES = 1;

DESCRIBE empleado;


/*Clase 03 - ETL*/
-- Trabajando los outliers de precio y cantidad
SELECT IdProducto, 
		-- Recuerda que algunos datos caeran en negativo por lo que calcular el outlier minimo no es tan necesario
        AVG(Precio) - (3 * STDDEV(precio)) AS minimo,
        AVG(precio) AS promedio,
        AVG(precio) + (3 * STDDEV(precio)) AS maximo
FROM venta
GROUP BY IdProducto;

SELECT v.*, o.promedio, o.maximo
FROM venta v
JOIN (SELECT IdProducto, 
			AVG(precio) AS promedio,
			AVG(precio) + (3 * STDDEV(precio)) AS maximo
			FROM venta
			GROUP BY IdProducto) o
	ON (v.IdProducto = o.IdProducto)
WHERE v.Precio > o.maximo;


SELECT v.*, o.promedio, o.maximo
FROM venta v
JOIN (SELECT IdProducto, 
			AVG(Cantidad) AS promedio,
			AVG(Cantidad) + (3 * STDDEV(Cantidad)) AS maximo
			FROM venta
			GROUP BY IdProducto) o
	ON (v.IdProducto = o.IdProducto)
WHERE v.Cantidad > o.maximo;

-- Introducimos los outliers de cantidad en la tabla aux_venta

INSERT into aux_venta
select v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal, v.IdEmpleado,
v.IdProducto, v.Precio, v.Cantidad, 2
from venta v
JOIN (SELECT IdProducto, avg(Cantidad) as promedio, stddev(Cantidad) as Desv
	from venta
	GROUP BY IdProducto) v2
ON (v.IdProducto = v2.IdProducto)
WHERE v.Cantidad > (v2.Promedio + (3*v2.Desv)) OR v.Cantidad < (v2.Promedio - (3*v2.Desv)) OR v.Cantidad < 0;

-- Introducimos los outliers de precio en la tabla aux_venta

INSERT into aux_venta
select v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal,
v.IdEmpleado, v.IdProducto, v.Precio, v.Cantidad, 3
from venta v
JOIN (SELECT IdProducto, avg(Precio) as promedio, stddev(Precio) as Desv
	from venta
	GROUP BY IdProducto) v2
ON (v.IdProducto = v2.IdProducto)
WHERE v.Precio > (v2.Promedio + (3*v2.Desv)) OR v.Precio < (v2.Promedio - (3*v2.Desv)) OR v.Precio < 0;

SET SQL_SAFE_UPDATES = 0;
-- Agrego 0 a los outliers en la tabla venta
ALTER TABLE venta ADD Outlier TINYINT  NOT NULL DEFAULT '1' AFTER Cantidad;
UPDATE venta v
JOIN aux_venta a
ON (v.IdVenta = a.IdVenta AND a.Motivo IN (2,3))
SET v.Outlier = 0;

-- Ventas con y sin outliers

SELECT 	co.TipoProducto,
		co.PromedioVentaConOutliers,
        so.PromedioVentaSinOutliers
FROM
	(SELECT 	tp.TipoProducto,
			AVG(v.Precio * v.Cantidad) as PromedioVentaConOutliers
	FROM 	venta v JOIN producto p
		ON (v.IdProducto = p.IdProducto)
			JOIN tipo_producto tp
		ON (p.IdTipoProducto = tp.IdTipoProducto)
	GROUP BY tp.TipoProducto) co
JOIN
	(SELECT 	tp.TipoProducto,
			AVG(v.Precio * v.Cantidad) as PromedioVentaSinOutliers
	FROM 	venta v JOIN producto p
		ON (v.IdProducto = p.IdProducto and v.Outlier = 1)
			JOIN tipo_producto tp
		ON (p.IdTipoProducto = tp.IdTipoProducto)
	GROUP BY tp.TipoProducto) so
ON co.TipoProducto = so.TipoProducto;

-- KPI: Margen de Ganancia por producto superior a 20%
SELECT 	venta.Producto, 
		venta.SumaVentas, 
        venta.CantidadVentas, 
        venta.SumaVentasOutliers,
        compra.SumaCompras, 
        compra.CantidadCompras,
        ((venta.SumaVentas / compra.SumaCompras - 1) * 100) as margen
FROM
	(SELECT 	p.Producto,
			SUM(v.Precio * v.Cantidad * v.Outlier) 	as 	SumaVentas,
			SUM(v.Outlier) 							as	CantidadVentas,
			SUM(v.Precio * v.Cantidad) 				as 	SumaVentasOutliers,
			COUNT(*) 								as	CantidadVentasOutliers
	FROM venta v JOIN producto p
		ON (v.IdProducto = p.IdProducto
			AND YEAR(v.Fecha) = 2019)
	GROUP BY p.Producto) AS venta
JOIN
	(SELECT 	p.Producto,
			SUM(c.Precio * c.Cantidad) 				as SumaCompras,
			COUNT(*)								as CantidadCompras
	FROM compra c JOIN producto p
		ON (c.IdProducto = p.IdProducto
			AND YEAR(c.Fecha) = 2019)
	GROUP BY p.Producto) as compra
ON (venta.Producto = compra.Producto);


SET SQL_SAFE_UPDATES = 1;

USE henry_m3_hw;

-- Venta agrupado por trimestre y rango etario
SELECT ca.trimestre, c.Rango_Etario, SUM(v.Precio * v.Cantidad) as venta
FROM venta v
JOIN cliente c ON(v.IdCliente = c.IdCliente) -- AND YEAR(v.Fecha) = 2020)
JOIN calendario ca ON(ca.Fecha = v.Fecha)
WHERE YEAR(v.Fecha) = 2020
GROUP BY ca.trimestre, c.Rango_Etario
ORDER BY ca.trimestre, c.Rango_Etario;
-- 12.45 seg
-- 0.25 seg

-- Venta agrupado por año, trimestre tipo de producto
SELECT ca.anio, ca.trimestre, tp.TipoProducto, SUM(v.Precio * v.Cantidad) as venta
FROM venta v
JOIN producto p ON (p.IdProducto = v.IdProducto)
JOIN tipo_producto tp ON (tp.IdTipoProducto = p.IdTipoProducto)
JOIN calendario ca ON (ca.Fecha = v.Fecha)
GROUP BY ca.anio, ca.trimestre
ORDER BY ca.anio, ca.trimestre;
-- 1.594 segundos

-- Venta agrupado por sucursal, canal, mayor a 5000000
SELECT s.IdSucursal, cv.IdCanal, SUM(v.Precio * v.Cantidad) as ventas
FROM venta v
JOIN sucursal s ON (s.IdSucursal = v.IdSucursal)
JOIN canal_venta cv ON (cv.IdCanal = v.IdCanal)
GROUP BY s.IdSucursal, cv.IdCanal
HAVING ventas > 5000000
ORDER BY s.IdSucursal, cv.IdCanal;
-- .172

-- Gastos agrupados por año y tipo de gasto
SELECT YEAR(g.Fecha), tg.Tipo_Gasto, SUM(g.Monto)
FROM gasto g
JOIN tipo_gasto tg ON(tg.IdTipoGasto = g.IdTipoGasto)
GROUP BY YEAR(g.Fecha), tg.Tipo_Gasto
ORDER BY 3 DESC;

ALTER TABLE `venta` ADD PRIMARY KEY(`IdVenta`);
ALTER TABLE `venta` ADD INDEX(`IdProducto`);
ALTER TABLE `venta` ADD INDEX(`IdEmpleado`);
ALTER TABLE `venta` ADD INDEX(`Fecha`);
ALTER TABLE `venta` ADD INDEX(`Fecha_Entrega`);
ALTER TABLE `venta` ADD INDEX(`IdCliente`);
ALTER TABLE `venta` ADD INDEX(`IdSucursal`);
ALTER TABLE `venta` ADD INDEX(`IdCanal`);

ALTER TABLE `calendario` ADD UNIQUE(`fecha`);

ALTER TABLE `canal_venta` ADD PRIMARY KEY(`IdCanal`);

ALTER TABLE `producto` ADD PRIMARY KEY(`IdProducto`);
ALTER TABLE `producto` ADD INDEX(`IdTipoProducto`);

-- ALTER TABLE `tipo_producto` ADD PRIMARY KEY(`IdTipoProducto`); -- Ya fue definido como PK

ALTER TABLE `sucursal` ADD PRIMARY KEY(`IdSucursal`);
ALTER TABLE `sucursal` ADD INDEX(`IdLocalidad`);

ALTER TABLE `empleado` ADD PRIMARY KEY(`IdEmpleado`); -- Revisar duplicados
-- ALTER TABLE `empleado` ADD PRIMARY KEY(`CodigoEmpleado`); -- Esto da error de clave duplicada
ALTER TABLE `empleado` ADD INDEX(`IdSucursal`);
ALTER TABLE `empleado` ADD INDEX(`IdSector`);
ALTER TABLE `empleado` ADD INDEX(`IdCargo`);

ALTER TABLE `localidad` ADD INDEX(`IdProvincia`);

ALTER TABLE `proveedor` ADD PRIMARY KEY(`IdProveedor`);
ALTER TABLE `proveedor` ADD INDEX(`IdLocalidad`);

ALTER TABLE `gasto` ADD PRIMARY KEY(`IdGasto`);
ALTER TABLE `gasto` ADD INDEX(`IdSucursal`);
ALTER TABLE `gasto` ADD INDEX(`IdTipoGasto`);
ALTER TABLE `gasto` ADD INDEX(`Fecha`);

ALTER TABLE `cliente` ADD PRIMARY KEY(`IdCliente`);
ALTER TABLE `cliente` ADD INDEX(`IdLocalidad`);

ALTER TABLE `compra` ADD PRIMARY KEY(`IdCompra`);
ALTER TABLE `compra` ADD INDEX(`Fecha`);

ALTER TABLE `compra` ADD INDEX(`IdProducto`);
ALTER TABLE `compra` ADD INDEX(`IdProveedor`);

-- DROP INDEX IdCliente ON venta; -- Ejemplo borrar índice

/*Creamos las relaciones entre las tablas, y con ellas las restricciones*/
ALTER TABLE venta ADD CONSTRAINT `venta_fk_fecha` FOREIGN KEY (fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT `venta_fk_cliente` FOREIGN KEY (IdCliente) REFERENCES cliente (IdCliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT `venta_fk_sucursal` FOREIGN KEY (IdSucursal) REFERENCES sucursal (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT `venta_fk_producto` FOREIGN KEY (IdProducto) REFERENCES producto (IdProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT `venta_fk_empleado` FOREIGN KEY (IdEmpleado) REFERENCES empleado (IdEmpleado) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT `venta_fk_canal` FOREIGN KEY (IdCanal) REFERENCES canal_venta (IdCanal) ON DELETE RESTRICT ON UPDATE RESTRICT;

SELECT * FROM venta WHERE IdCliente = 969;
DELETE FROM cliente WHERE IdCliente = 969;

SELECT * FROM cliente WHERE IdCliente
NOT IN (SELECT DISTINCT IdCliente FROM venta);

ALTER TABLE producto ADD CONSTRAINT `producto_fk_tipoproducto` FOREIGN KEY (IdTipoProducto) REFERENCES tipo_producto (IdTipoProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE empleado ADD CONSTRAINT `empleado_fk_sector` FOREIGN KEY (IdSector) REFERENCES sector (IdSector) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleado ADD CONSTRAINT `empleado_fk_cargo` FOREIGN KEY (IdCargo) REFERENCES cargo (IdCargo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleado ADD CONSTRAINT `empleado_fk_sucursal` FOREIGN KEY (IdSucursal) REFERENCES sucursal (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE cliente ADD CONSTRAINT `cliente_fk_localidad` FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE proveedor ADD CONSTRAINT `proveedor_fk_localidad` FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE sucursal ADD CONSTRAINT `sucursal_fk_localidad` FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE localidad ADD CONSTRAINT `localidad_fk_provincia` FOREIGN KEY (IdProvincia) REFERENCES provincia (IdProvincia) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE compra ADD CONSTRAINT `compra_fk_fecha` FOREIGN KEY (Fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE compra ADD CONSTRAINT `compra_fk_producto` FOREIGN KEY (IdProducto) REFERENCES producto (IdProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE compra ADD CONSTRAINT `compra_fk_proveedor` FOREIGN KEY (IdProveedor) REFERENCES proveedor (IdProveedor) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE gasto ADD CONSTRAINT `gasto_fk_fecha` FOREIGN KEY (Fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE gasto ADD CONSTRAINT `gasto_fk_sucursal` FOREIGN KEY (IdSucursal) REFERENCES sucursal (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE gasto ADD CONSTRAINT `gasto_fk_tipogasto` FOREIGN KEY (IdTipoGasto) REFERENCES tipo_gasto (IdTipoGasto) ON DELETE RESTRICT ON UPDATE RESTRICT;

/*Cracion de Tablas de Hechos para modelo Estrella*/
DROP TABLE IF EXISTS `fact_venta`;
CREATE TABLE IF NOT EXISTS `fact_venta` (
  `IdVenta`				INTEGER,
  `Fecha` 				DATE NOT NULL,
  `Fecha_Entrega` 		DATE NOT NULL,
  `IdCanal`				INTEGER, 
  `IdCliente`			INTEGER, 
  `IdEmpleado`			INTEGER,
  `IdProducto`			INTEGER,
  `Precio`				DECIMAL(15,2),
  `Cantidad`			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO fact_venta
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
FROM venta
WHERE YEAR(Fecha) = 2020;

ALTER TABLE `fact_venta` ADD PRIMARY KEY(`IdVenta`);
ALTER TABLE `fact_venta` ADD INDEX(`IdProducto`);
ALTER TABLE `fact_venta` ADD INDEX(`IdEmpleado`);
ALTER TABLE `fact_venta` ADD INDEX(`Fecha`);
ALTER TABLE `fact_venta` ADD INDEX(`Fecha_Entrega`);
ALTER TABLE `fact_venta` ADD INDEX(`IdCliente`);
ALTER TABLE `fact_venta` ADD INDEX(`IdCanal`);

DROP TABLE IF EXISTS dim_cliente;
CREATE TABLE IF NOT EXISTS dim_cliente (
	IdCliente			INTEGER,
	Nombre_y_Apellido	VARCHAR(80),
	Domicilio			VARCHAR(150),
	Telefono			VARCHAR(30),
	Rango_Etario		VARCHAR(20),
	IdLocalidad			INTEGER,
	Latitud				DECIMAL(13,10),
	Longitud			DECIMAL(13,10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO dim_cliente
SELECT IdCliente, Nombre_y_Apellido, Domicilio, Telefono, Rango_Etario, IdLocalidad, Latitud, Longitud
FROM cliente
WHERE IdCliente IN (SELECT distinct IdCliente FROM fact_venta);

DROP TABLE IF EXISTS dim_producto;
CREATE TABLE IF NOT EXISTS dim_producto (
	IdProducto					INTEGER,
	Producto					VARCHAR(100),
	IdTipoProducto				VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO dim_producto
SELECT IdProducto, Producto, IdTipoProducto
FROM producto
WHERE IdProducto IN (SELECT distinct IdProducto FROM fact_venta);

/*Clase 05 HW*/
use henry_m3_hw;

-- Creamos la tabla que auditará a los usuarios que realizan cambios
DROP TABLE IF EXISTS `fact_venta_auditoria`;
CREATE TABLE IF NOT EXISTS `fact_venta_auditoria` (
	IdFactVentaAuditoria INT NOT NULL AUTO_INCREMENT,
    `Fecha`				DATE,
	`Fecha_Entrega`		DATE,
  	`IdCanal` 			INTEGER,
  	`IdCliente` 		INTEGER,
  	`IdEmpleado` 		INTEGER,
  	`IdProducto` 		INTEGER,
    `usuario` 			VARCHAR(30),
    `fechaModificacion` 	DATETIME,
    PRIMARY KEY(IdFactVentaAuditoria)
);

DROP TRIGGER fact_venta_auditoria;
CREATE TRIGGER fact_venta_auditoria AFTER INSERT ON fact_venta
FOR EACH ROW
INSERT INTO fact_venta_auditoria (Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado,
 IdProducto, usuario, fechaModificacion)
VALUES (NEW.Fecha, NEW.Fecha_Entrega, NEW.IdCanal, NEW.IdCliente, NEW.IdEmpleado,
 NEW.IdProducto, current_user(), NOW());

TRUNCATE TABLE fact_venta;

INSERT INTO fact_venta
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
FROM venta
LIMIT 30;

-- Creamos la tabla que llevara una cuenta de los registros.
DROP TABLE IF EXISTS `fact_venta_registros`;
CREATE TABLE IF NOT EXISTS `fact_venta_registros` (
  	IdFactVentaRegistros INT NOT NULL AUTO_INCREMENT,
	cantidadRegistros INT,
	usuario VARCHAR (20),
	fechaHora DATETIME,
	PRIMARY KEY (IdFactVentaRegistros)
);

DROP TRIGGER fact_venta_registros;
CREATE TRIGGER fact_venta_registros AFTER INSERT ON fact_venta
FOR EACH ROW
INSERT INTO fact_venta_registros (cantidadRegistros, usuario, fechaHora)
VALUES ((SELECT count(*) FROM fact_venta), current_user(), now());

-- Creamos una tabla donde podremos almacenar la cantidad de registros por día
DROP TABLE registros_tablas;
CREATE TABLE registros_tablas (
idRegistros INT NOT NULL AUTO_INCREMENT,
tabla VARCHAR(30),
fechaHora DATETIME,
cantidadRegistros INT,
PRIMARY KEY (idRegistros)
);

INSERT INTO registros_tablas (tabla, fechaHora, cantidadRegistros)
SELECT 'venta', NOW(), COUNT(*)
FROM venta;

INSERT INTO registros_tablas (tabla, fechaHora, cantidadRegistros)
SELECT 'gasto', NOW(), COUNT(*)
FROM gasto;

-- Creamos una tabla para auditar cambios
DROP TABLE IF EXISTS `fact_venta_cambios`;
CREATE TABLE IF NOT EXISTS `fact_venta_cambios` (
  	IdFactVentaCambios INT NOT NULL AUTO_INCREMENT,
    `Fecha` 			DATE,
  	`IdCliente` 		INTEGER,
  	`IdProducto` 		INTEGER,
    `Precio` 			DECIMAL(15,3),
    `Cantidad` 			INTEGER,
    `usuario` 			VARCHAR(20),
    `fechaHoraModificacion` 	DATETIME,
    PRIMARY KEY(IdFactVentaCambios)
);

DROP TRIGGER control_actualizacion;
CREATE TRIGGER control_actualizacion AFTER UPDATE ON fact_venta
FOR EACH ROW
INSERT INTO fact_venta_cambios
VALUES (NULL, OLD.Fecha, OLD.IdCliente, OLD.IdProducto, OLD.Precio, OLD.Cantidad, current_user(), NOW());

-- Bonus Track Tabla para eliminados (cuidado con eliminar datos sin un control estricto)

DROP TABLE IF EXISTS `fact_venta_eliminados`;
CREATE TABLE IF NOT EXISTS fact_venta_eliminados (
  	IdFactVentaEliminados INT NOT NULL AUTO_INCREMENT,
    `Fecha` 			DATE,
  	`IdCliente` 		INTEGER,
  	`IdProducto` 		INTEGER,
    `Precio` 			DECIMAL(15,3),
    `Cantidad` 			INTEGER,
    `usuario` 			VARCHAR(20),
    `fechaHoraModificacion` 	DATETIME,
    PRIMARY KEY(IdFactVentaEliminados)
);

DROP TRIGGER control_eliminados;
CREATE TRIGGER control_eliminados AFTER DELETE ON fact_venta
FOR EACH ROW
INSERT INTO fact_venta_eliminados
VALUES (NULL, OLD.Fecha, OLD.IdCliente, OLD.IdProducto, OLD.Precio, OLD.Cantidad, current_user(), NOW());

UPDATE fact_venta
SET Cantidad = 2
WHERE IdVenta = 2;

DELETE
FROM fact_venta
WHERE IdVenta = 2;