-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 22, 2024 at 05:10 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gymtoniclocalhost`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_producto` (IN `n_cantidad` INT, IN `n_precio` DECIMAL(10,2), IN `codigo` INT)   BEGIN
DECLARE nueva_existencia int;
DECLARE nuevo_total decimal(10,2);
DECLARE nuevo_precio decimal(10,2);

DECLARE cant_actual int;
DECLARE pre_actual decimal(10,2);

DECLARE actual_existencia int;
DECLARE actual_precio decimal(10,2);

SELECT precio, existencia INTO actual_precio, actual_existencia FROM producto WHERE codproducto = codigo;

SET nueva_existencia = actual_existencia + n_cantidad;
SET nuevo_total = n_precio;
SET nuevo_precio = nuevo_total;

UPDATE producto SET existencia = nueva_existencia, precio = nuevo_precio WHERE codproducto = codigo;

SELECT nueva_existencia, nuevo_precio;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detalle_temp` (`codigo` INT, `cantidad` INT, `token_user` VARCHAR(50))   BEGIN
DECLARE precio_actual decimal(10,2);
SELECT precio INTO precio_actual FROM producto WHERE codproducto = codigo;
INSERT INTO detalle_temp(token_user, codproducto, cantidad, precio_venta) VALUES (token_user, codigo, cantidad, precio_actual);
SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.precio_venta FROM detalle_temp tmp INNER JOIN producto p ON tmp.codproducto = p.codproducto WHERE tmp.token_user = token_user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `data` ()   BEGIN
DECLARE usuarios int;
DECLARE clientes int;
DECLARE proveedores int;
DECLARE productos int;
DECLARE ventas int;
SELECT COUNT(*) INTO usuarios FROM usuario;
SELECT COUNT(*) INTO clientes FROM cliente;
SELECT COUNT(*) INTO proveedores FROM proveedor;
SELECT COUNT(*) INTO productos FROM producto;
SELECT COUNT(*) INTO ventas FROM factura WHERE fecha > CURDATE();

SELECT usuarios, clientes, proveedores, productos, ventas;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detalle_temp` (`id_detalle` INT, `token` VARCHAR(50))   BEGIN
DELETE FROM detalle_temp WHERE correlativo = id_detalle;
SELECT tmp.correlativo, tmp.codproducto, p.descripcion, tmp.cantidad, tmp.precio_venta FROM detalle_temp tmp INNER JOIN producto p ON tmp.codproducto = p.codproducto WHERE tmp.token_user = token;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `procesar_venta` (IN `cod_usuario` INT, IN `cod_cliente` INT, IN `token` VARCHAR(50))   BEGIN
DECLARE factura INT;
DECLARE registros INT;
DECLARE total DECIMAL(10,2);
DECLARE nueva_existencia int;
DECLARE existencia_actual int;

DECLARE tmp_cod_producto int;
DECLARE tmp_cant_producto int;
DECLARE a int;
SET a = 1;

CREATE TEMPORARY TABLE tbl_tmp_tokenuser(
	id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cod_prod BIGINT,
    cant_prod int);
SET registros = (SELECT COUNT(*) FROM detalle_temp WHERE token_user = token);
IF registros > 0 THEN
INSERT INTO tbl_tmp_tokenuser(cod_prod, cant_prod) SELECT codproducto, cantidad FROM detalle_temp WHERE token_user = token;
INSERT INTO factura (usuario,codcliente) VALUES (cod_usuario, cod_cliente);
SET factura = LAST_INSERT_ID();

INSERT INTO detallefactura(nofactura,codproducto,cantidad,precio_venta) SELECT (factura) AS nofactura, codproducto, cantidad,precio_venta FROM detalle_temp WHERE token_user = token;
WHILE a <= registros DO
	SELECT cod_prod, cant_prod INTO tmp_cod_producto,tmp_cant_producto FROM tbl_tmp_tokenuser WHERE id = a;
    SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = tmp_cod_producto;
    SET nueva_existencia = existencia_actual - tmp_cant_producto;
    UPDATE producto SET existencia = nueva_existencia WHERE codproducto = tmp_cod_producto;
    SET a=a+1;
END WHILE;
SET total = (SELECT SUM(cantidad * precio_venta) FROM detalle_temp WHERE token_user = token);
UPDATE factura SET totalfactura = total WHERE nofactura = factura;
DELETE FROM detalle_temp WHERE token_user = token;
TRUNCATE TABLE tbl_tmp_tokenuser;
SELECT * FROM factura WHERE nofactura = factura;
ELSE
SELECT 0;
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cliente`
--

CREATE TABLE `cliente` (
  `idcliente` int(11) NOT NULL,
  `documento` int(11) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` int(20) NOT NULL,
  `direccion` varchar(200) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `cliente`
--

INSERT INTO `cliente` (`idcliente`, `documento`, `nombre`, `telefono`, `direccion`, `usuario_id`) VALUES
(1, 551243694, 'Juan García', 310123456, 'Calle 123 # 45-67', 1),
(2, 968819435, 'Laura Martínez', 317234567, 'Carrera 78A # 90-12\n', 1),
(3, 579282567, 'Carlos López\n', 300345678, 'Avenida 34 Sur # 56-78\n', 1),
(4, 831415309, 'Ana Sánchez\n', 313456789, 'Diagonal 10 # 20-30\n', 1),
(5, 600280947, 'Alejandro Rodríguez', 301567890, 'Transversal 56 Este # 78-90\n', 1),
(6, 650013837, 'Sandra Pérez\n', 304678901, 'Calle 89A Bis # 34-56\n', 1),
(7, 945338962, 'Javier Martínez\n', 318789012, 'Carrera 45D # 67-89\n', 2),
(8, 851984368, 'Isabel López\n', 312890123, 'Avenida 12 Este # 56-78\n', 2),
(9, 1049831371, 'Martín Sánchez\n', 305901234, 'Diagonal 30 Sur # 45-67\n', 2),
(10, 760834115, 'María Rodríguez', 319012345, 'Transversal 67 Oeste # 89-01', 1);

-- --------------------------------------------------------

--
-- Table structure for table `configuracion`
--

CREATE TABLE `configuracion` (
  `id` int(11) NOT NULL,
  `documento` int(11) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `razon_social` varchar(255) DEFAULT NULL,
  `telefono` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `direccion` text NOT NULL,
  `igv` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `configuracion`
--

INSERT INTO `configuracion` (`id`, `documento`, `nombre`, `razon_social`, `telefono`, `email`, `direccion`, `igv`) VALUES
(1, 2580, 'GYM & TONIC', 'GYM & TONIC S.A', 925491523, 'gym&toniccol@gmail.com', 'Bogotá - Colombia', 1.19);

-- --------------------------------------------------------

--
-- Table structure for table `detallefactura`
--

CREATE TABLE `detallefactura` (
  `correlativo` bigint(20) NOT NULL,
  `nofactura` bigint(20) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `detallefactura`
--

INSERT INTO `detallefactura` (`correlativo`, `nofactura`, `codproducto`, `cantidad`, `precio_venta`) VALUES
(1, 1, 5, 6, 280.00),
(2, 2, 67, 12, 700.00),
(3, 3, 6, 5, 120.00),
(4, 3, 4, 2, 150.00),
(6, 4, 56, 16, 700.00),
(7, 5, 78, 6, 650.00),
(8, 6, 45, 10, 1000.00),
(9, 7, 45, 6, 1000.00),
(10, 8, 7, 16, 90.00),
(11, 8, 5, 1, 280.00);

-- --------------------------------------------------------

--
-- Table structure for table `detalle_temp`
--

CREATE TABLE `detalle_temp` (
  `correlativo` int(11) NOT NULL,
  `token_user` varchar(50) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entradas`
--

CREATE TABLE `entradas` (
  `correlativo` int(11) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `factura`
--

CREATE TABLE `factura` (
  `nofactura` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) NOT NULL,
  `codcliente` int(11) NOT NULL,
  `totalfactura` decimal(10,2) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `factura`
--

INSERT INTO `factura` (`nofactura`, `fecha`, `usuario`, `codcliente`, `totalfactura`, `estado`) VALUES
(1, '2024-03-12 07:44:39', 1, 2, 1680.00, 1),
(2, '2024-03-12 08:01:31', 1, 3, 8400.00, 1),
(3, '2024-03-12 08:13:18', 1, 4, 900.00, 1),
(4, '2024-03-12 08:23:11', 1, 5, 11200.00, 1),
(5, '2024-03-12 08:24:40', 1, 6, 3900.00, 1),
(6, '2024-03-12 08:34:22', 2, 7, 10000.00, 1),
(7, '2024-03-12 08:44:19', 2, 8, 6000.00, 1),
(8, '2024-03-12 09:37:00', 2, 1, 1720.00, 1);

-- --------------------------------------------------------

--
-- Table structure for table `producto`
--

CREATE TABLE `producto` (
  `codproducto` int(11) NOT NULL,
  `descripcion` varchar(200) NOT NULL,
  `proveedor` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `existencia` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `producto`
--

INSERT INTO `producto` (`codproducto`, `descripcion`, `proveedor`, `precio`, `existencia`, `usuario_id`) VALUES
(1, 'Proteína en polvo de suero de leche (whey protein)', 1, 429.00, 49, 2),
(2, 'Proteína en polvo de caseína', 1, 327.90, 79, 1),
(3, 'Proteína en polvo de soja', 1, 80.00, 0, 1),
(4, 'Proteína en polvo de huevo', 3, 150.00, 3, 1),
(5, 'Proteína en polvo vegana', 2, 280.00, 23, 2),
(6, 'BCAA (aminoácidos de cadena ramificada) en polvo', 4, 120.00, 40, 3),
(7, 'Glutamina en polvo', 4, 90.00, 9, 3),
(8, 'Creatina monohidratada', 1, 140.00, 60, 2),
(9, 'Creatina en formato líquido', 3, 130.00, 15, 1),
(10, 'Creatina en cápsulas', 1, 90.00, 40, 2),
(11, 'Óxido nítrico pre-entrenamiento', 2, 200.00, 20, 1),
(12, 'Pre-entrenamiento con cafeína', 3, 100.00, 35, 3),
(13, 'Pre-entrenamiento sin estimulantes', 1, 190.00, 10, 2),
(14, 'Quemadores de grasa termogénicos', 2, 220.00, 5, 3),
(15, 'L-carnitina líquida', 4, 150.00, 30, 1),
(16, 'Multivitamínicos para deportistas', 1, 120.00, 55, 3),
(17, 'Omega-3 (aceite de pescado)', 3, 80.00, 70, 2),
(18, 'Vitaminas antioxidantes', 2, 100.00, 45, 1),
(19, 'Zinc y magnesio para mejorar el sueño', 4, 130.00, 20, 3),
(20, 'Colágeno en polvo', 1, 160.00, 25, 2),
(21, 'Barritas de proteína', 3, 35.00, 100, 1),
(22, 'Barritas energéticas', 2, 30.00, 120, 2),
(23, 'Bebidas isotónicas', 1, 40.00, 80, 3),
(24, 'Bebidas energéticas', 4, 25.00, 70, 1),
(25, 'Bebidas de recuperación post-entrenamiento', 3, 30.00, 60, 2),
(26, 'Geles energéticos', 2, 150.00, 90, 1),
(27, 'Glucosa en polvo para durante el entrenamiento', 1, 180.00, 110, 3),
(28, 'Batidos de proteína listos para beber', 4, 50.00, 40, 2),
(29, 'Batidos de recuperación post-entrenamiento', 3, 45.00, 35, 1),
(30, 'Batidos sustitutivos de comida', 2, 50.00, 25, 3),
(31, 'Aminoácidos esenciales (EAAs) en polvo', 1, 170.00, 15, 2),
(32, 'Suplementos de calcio', 3, 600.00, 75, 1),
(33, 'Suplementos de vitamina D', 4, 700.00, 65, 2),
(34, 'Suplementos de vitamina C', 2, 500.00, 85, 3),
(35, 'Suplementos de vitamina B12', 1, 550.00, 80, 1),
(36, 'Suplementos de hierro', 3, 400.00, 70, 2),
(37, 'Suplementos de zinc', 4, 450.00, 60, 3),
(38, 'Suplementos de magnesio', 2, 700.00, 45, 1),
(39, 'Suplementos de potasio', 1, 600.00, 50, 2),
(40, 'Suplementos de selenio', 3, 550.00, 55, 3),
(41, 'Suplementos de cromo', 4, 800.00, 40, 1),
(42, 'Suplementos de yodo', 2, 750.00, 35, 2),
(43, 'Suplementos de fibra', 1, 300.00, 90, 3),
(44, 'Suplementos de glucosamina y condroitina', 3, 900.00, 25, 1),
(45, 'Suplementos de MSM (metilsulfonilmetano)', 4, 1000.00, 4, 2),
(46, 'Suplementos de ácido hialurónico para las articulaciones', 2, 1200.00, 15, 3),
(47, 'Suplementos de colina', 1, 700.00, 40, 1),
(48, 'Suplementos de inositol', 3, 800.00, 35, 2),
(49, 'Suplementos de aceite de pescado', 4, 600.00, 50, 3),
(50, 'Suplementos de aceite de krill', 2, 850.00, 30, 1),
(51, 'Suplementos de aceite de linaza', 1, 500.00, 65, 2),
(52, 'Suplementos de aceite de coco', 3, 450.00, 70, 3),
(53, 'Suplementos de aceite de cártamo', 4, 400.00, 80, 1),
(54, 'Suplementos de aceite de onagra', 2, 550.00, 55, 2),
(55, 'Suplementos de aceite de borraja', 1, 600.00, 45, 3),
(56, 'Suplementos de aceite de semilla de uva', 3, 700.00, 24, 1),
(57, 'Suplementos de aceite de alga', 4, 650.00, 35, 2),
(58, 'Suplementos de L-arginina', 2, 1000.00, 25, 3),
(59, 'Suplementos de L-citrulina', 1, 1100.00, 20, 1),
(60, 'Suplementos de beta-alanina', 3, 1200.00, 15, 2),
(61, 'Suplementos de taurina', 4, 900.00, 30, 3),
(62, 'Suplementos de glucosamina', 2, 800.00, 35, 1),
(63, 'Suplementos de condroitina', 1, 700.00, 40, 2),
(64, 'Suplementos de sulfato de glucosamina', 3, 750.00, 25, 3),
(65, 'Suplementos de HMB (beta-hidroxi-beta-metilbutirato)', 4, 1300.00, 10, 1),
(66, 'Suplementos de aceite de pescado omega-3', 1, 600.00, 50, 2),
(67, 'Suplementos de aceite de hígado de bacalao', 2, 700.00, 33, 3),
(68, 'Suplementos de aceite de linaza', 3, 500.00, 60, 1),
(69, 'Suplementos de aceite de cártamo', 4, 400.00, 70, 2),
(70, 'Suplementos de aceite de borraja', 1, 600.00, 45, 3),
(71, 'Suplementos de aceite de semilla de grosella negra', 2, 750.00, 35, 1),
(72, 'Suplementos de aceite de onagra', 3, 550.00, 55, 2),
(73, 'Suplementos de aceite de sésamo', 4, 500.00, 60, 3),
(74, 'Suplementos de aceite de germen de trigo', 1, 450.00, 65, 1),
(75, 'Suplementos de aceite de argán', 2, 700.00, 40, 2),
(76, 'Suplementos de aceite de rosa mosqueta', 3, 800.00, 35, 3),
(77, 'Suplementos de aceite de avellana', 4, 750.00, 30, 1),
(78, 'Suplementos de aceite de nuez', 1, 650.00, 34, 2),
(79, 'Suplementos de aceite de almendra', 2, 600.00, 45, 3),
(80, 'Suplementos de aceite de macadamia', 3, 700.00, 35, 1),
(81, 'Suplementos de aceite de marula', 4, 850.00, 25, 2),
(82, 'Suplementos de aceite de aguacate', 1, 750.00, 30, 3),
(83, 'Suplementos de aceite de oliva', 2, 800.00, 25, 1),
(84, 'Suplementos de aceite de pepita de uva', 3, 700.00, 35, 2),
(85, 'Suplementos de aceite de semilla de granada', 4, 600.00, 40, 3),
(86, 'Suplementos de aceite de semilla de albaricoque', 1, 550.00, 45, 1),
(87, 'Suplementos de aceite de semilla de chía', 2, 500.00, 50, 2),
(88, 'Suplementos de aceite de semilla de calabaza', 3, 450.00, 55, 3),
(89, 'Suplementos de aceite de semilla de girasol', 4, 400.00, 60, 1),
(90, 'Suplementos de aceite de semilla de cáñamo', 1, 350.00, 65, 2),
(91, 'Suplementos de aceite de semilla de amapola', 2, 300.00, 70, 3),
(92, 'Suplementos de aceite de semilla de lino', 3, 250.00, 75, 1),
(93, 'Suplementos de aceite de semilla de arándano', 4, 200.00, 80, 2),
(94, 'Suplementos de aceite de semilla de grosella negra', 1, 150.00, 85, 3),
(95, 'Suplementos de aceite de semilla de lila', 2, 100.00, 90, 1),
(96, 'Suplementos de aceite de semilla de rosa', 3, 50.00, 95, 2),
(97, 'Suplementos de aceite de semilla de espino amarillo', 4, 1000.00, 100, 3),
(98, 'Suplementos de aceite de semilla de camelia', 1, 950.00, 105, 1),
(99, 'Suplementos de aceite de semilla de cártamo', 2, 900.00, 110, 2),
(100, 'Suplementos de aceite de semilla de sésamo', 3, 850.00, 115, 3);

-- --------------------------------------------------------

--
-- Table structure for table `proveedor`
--

CREATE TABLE `proveedor` (
  `codproveedor` int(11) NOT NULL,
  `proveedor` varchar(100) NOT NULL,
  `contacto` varchar(100) NOT NULL,
  `telefono` int(11) NOT NULL,
  `direccion` varchar(100) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `proveedor`
--

INSERT INTO `proveedor` (`codproveedor`, `proveedor`, `contacto`, `telefono`, `direccion`, `usuario_id`) VALUES
(1, 'FitNutri', 'Ana Martínez', 987654321, 'Avenida del Fitness, Edificio Nutrición', 2),
(2, 'HealthyGains', 'Roberto Rodríguez', 654321987, 'Calle Saludable, Bloque Bienestar', 1),
(3, 'Suplementos Max', 'Juan Pérez', 123456789, 'Calle Principal, Ciudad Gimnasio', 1),
(4, 'NutriFitness', 'María Gómez', 987654321, 'Avenida Deportista, Centro Comercial Fitness', 3),
(5, 'NutriVida', 'Luisa Martínez', 987123456, 'Avenida Atlética, Edificio Vitalidad', 2),
(6, 'FitSupps', 'Carlos Rodríguez', 654789321, 'Carrera Deportiva, Bloque Energía', 1),
(7, 'MusclePro', 'Ana García', 321654987, 'Plaza del Entrenamiento, Local Muscular', 3),
(8, 'PowerNutrition', 'Pedro Sánchez', 789456123, 'Gimnasio Avenue, Torre Poderosa', 2),
(9, 'GymFuel', 'Sofía López', 456789012, 'Calle Fitness, Casa en Forma', 1),
(10, 'SportSupplies', 'Jorge Ramírez', 210987654, 'Estadio Street, Block Athlete', 3),
(11, 'FitLab', 'Gabriela Castro', 987654321, 'Avenida Fitness, Edificio Saludable', 2),
(12, 'NutriSport', 'Roberto Herrera', 654321987, 'Calle Deportiva, Bloque Nutrición', 1),
(13, 'BodyFuel', 'Marcela Torres', 321987654, 'Plaza del Entrenamiento, Local Energético', 3),
(14, 'ProSuplementos', 'Andrés García', 789012345, 'Gimnasio Avenue, Torre Pro', 2),
(15, 'EcoFit', 'Laura Ramírez', 456789012, 'Calle Verde, Casa en Forma', 1),
(16, 'VitalitySupplies', 'Daniel Sánchez', 210987654, 'Estadio Street, Block Vital', 3),
(17, 'FitnessWorld', 'Carolina Pérez', 987654321, 'Carrera Deportiva, Edificio Salud', 2),
(18, 'MuscleLab', 'Diego Gómez', 654321987, 'Avenida del Cuerpo, Bloque Muscular', 1),
(19, 'PowerUp', 'Fernanda López', 321987654, 'Plaza del Fitness, Local Poder', 3),
(20, 'SportLife', 'José Martínez', 789012345, 'Gimnasio Avenue, Torre Deporte', 2);

-- --------------------------------------------------------

--
-- Table structure for table `rol`
--

CREATE TABLE `rol` (
  `idrol` int(11) NOT NULL,
  `rol` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `rol`
--

INSERT INTO `rol` (`idrol`, `rol`) VALUES
(1, 'Administrador'),
(2, 'Vendedor');

-- --------------------------------------------------------

--
-- Table structure for table `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `usuario` varchar(20) NOT NULL,
  `clave` varchar(50) NOT NULL,
  `rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `correo`, `usuario`, `clave`, `rol`) VALUES
(1, 'Jhors Administrador', 'jorge@gmail.com', 'admin', '21232f297a57a5a743894a0e4a801fc3', 1),
(2, 'Nicolas Vendedor', 'nico@gmail.com', 'Nicolas', '4118af4d1a8ac07d93f11ce4f3bf1f58', 2),
(10, 'Instructor Administrador ', 'instructoradmin@gmail.com', 'instructoradmin', '2f39289530ee9c50bcd58849688835bb', 1),
(11, 'Instructor Vendedor ', 'instructorvendedor@gmail.com', 'instructorvendedor', '51639e4ca51b7f36fda790fb915f91cb', 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idcliente`);

--
-- Indexes for table `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `detallefactura`
--
ALTER TABLE `detallefactura`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indexes for table `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indexes for table `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indexes for table `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`nofactura`);

--
-- Indexes for table `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`codproducto`);

--
-- Indexes for table `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`codproveedor`);

--
-- Indexes for table `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`idrol`);

--
-- Indexes for table `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idusuario`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idcliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `configuracion`
--
ALTER TABLE `configuracion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `detallefactura`
--
ALTER TABLE `detallefactura`
  MODIFY `correlativo` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `detalle_temp`
--
ALTER TABLE `detalle_temp`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `entradas`
--
ALTER TABLE `entradas`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `factura`
--
ALTER TABLE `factura`
  MODIFY `nofactura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `producto`
--
ALTER TABLE `producto`
  MODIFY `codproducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `codproveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `rol`
--
ALTER TABLE `rol`
  MODIFY `idrol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
