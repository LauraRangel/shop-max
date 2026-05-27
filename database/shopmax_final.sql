-- ============================================================
-- SHOP-MAX — Base de datos completa
-- 14 tablas · Lista para importar en XAMPP
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS `shopmax`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `shopmax`;

-- --------------------------------------------------------
-- 1. ROL
-- --------------------------------------------------------
CREATE TABLE `rol` (
  `ID_ROL`    int(11)      NOT NULL AUTO_INCREMENT,
  `NOMBRE`    varchar(50)  NOT NULL,
  `PERMISOS`  text         DEFAULT NULL,
  PRIMARY KEY (`ID_ROL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `rol` (`ID_ROL`, `NOMBRE`) VALUES
(1, 'Administrador'),
(2, 'Gerente de Tienda'),
(3, 'Cajero'),
(4, 'Vendedor');

-- --------------------------------------------------------
-- 2. TIENDA
-- --------------------------------------------------------
CREATE TABLE `tienda` (
  `ID_TIENDA`  int(11)      NOT NULL AUTO_INCREMENT,
  `NOMBRE`     varchar(50)  DEFAULT NULL,
  `DIRECCION`  varchar(200) DEFAULT NULL,
  `TELEFONO`   varchar(9)   DEFAULT NULL,
  PRIMARY KEY (`ID_TIENDA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `tienda` VALUES
(1, 'Piura',  'Av. Grau N° 1505',        '900999900'),
(2, 'Lima',   'Av. Miraflores N° 1880',  '980089908'),
(3, 'Cusco',  'Av. San Antonio N° 452',  '932888888');

-- --------------------------------------------------------
-- 3. USUARIO
-- --------------------------------------------------------
CREATE TABLE `usuario` (
  `ID_USUARIO`    int(11)      NOT NULL AUTO_INCREMENT,
  `ID_ROL`        int(11)      DEFAULT NULL,
  `ID_TIENDA`     int(11)      DEFAULT NULL,
  `NOMBRE`        varchar(100) DEFAULT NULL,
  `EMAIL`         varchar(100) DEFAULT NULL,
  `PASSWORD_HASH` varchar(255) DEFAULT NULL,
  `ACTIVO`        tinyint(1)   DEFAULT 1,
  PRIMARY KEY (`ID_USUARIO`),
  UNIQUE KEY `EMAIL` (`EMAIL`),
  KEY `ID_ROL`   (`ID_ROL`),
  KEY `ID_TIENDA`(`ID_TIENDA`),
  CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`ID_ROL`)    REFERENCES `rol`   (`ID_ROL`),
  CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`ID_TIENDA`) REFERENCES `tienda`(`ID_TIENDA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- IMPORTANTE: las contraseñas deben insertarse ya hasheadas con SHA-256
-- Usar: echo -n "contraseña" | shasum -a 256
INSERT INTO `usuario` (`ID_USUARIO`,`ID_ROL`,`ID_TIENDA`,`NOMBRE`,`EMAIL`,`PASSWORD_HASH`,`ACTIVO`) VALUES
(1, 1, 1, 'Bryam Correa',     'bryamci@gmail.com',   '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', 1),
(2, 1, 2, 'Maria Garcia',     'maria@gmail.com',     '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 1),
(3, 1, 3, 'Carlos Zapata',    'carlosz@gmail.com',   'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 1),
(4, 4, 1, 'Pedro Lopez',      'pedrol@gmail.com',    '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 1),
(5, 4, 2, 'Pepito Nandez',    'pepiton@gmail.com',   '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 1),
(6, 3, 2, 'Julio Nandez',     'julion@gmail.com',    '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 1),
(7, 1, 1, 'Luciana Calderon', 'lucianac@gmail.com',  '2527e3b78c1f7b44507a4bef1a79f15e3fcc174ddcc0b9f36f87e0284caa72a6', 1),
(8, 4, 2, 'Paula Perez',      'paulap@gmail.com',    '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 1);

-- --------------------------------------------------------
-- 4. CATEGORIA
-- --------------------------------------------------------
CREATE TABLE `categoria` (
  `ID_CATEGORIA` int(11)      NOT NULL AUTO_INCREMENT,
  `NOMBRE`       varchar(100) NOT NULL,
  `DESCRIPCION`  text         DEFAULT NULL,
  PRIMARY KEY (`ID_CATEGORIA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `categoria` VALUES
(1, 'Electrónica',  'Celulares, laptops y accesorios'),
(2, 'Ropa',         'Prendas de vestir para adultos y niños'),
(3, 'Hogar',        'Artículos para el hogar y cocina'),
(4, 'Deportes',     'Equipos y ropa deportiva');

-- --------------------------------------------------------
-- 5. PRODUCTO
-- --------------------------------------------------------
CREATE TABLE `producto` (
  `ID_PRODUCTO`  int(11)        NOT NULL AUTO_INCREMENT,
  `ID_CATEGORIA` int(11)        NOT NULL,
  `CODIGO`       varchar(50)    DEFAULT NULL,
  `NOMBRE`       varchar(150)   NOT NULL,
  `PRECIO`       decimal(10,2)  NOT NULL,
  `STOCK_MINIMO` int(11)        DEFAULT 5,
  PRIMARY KEY (`ID_PRODUCTO`),
  UNIQUE KEY `CODIGO` (`CODIGO`),
  CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`ID_CATEGORIA`) REFERENCES `categoria`(`ID_CATEGORIA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `producto` VALUES
(1, 1, 'ELEC-001', 'Smartphone Samsung A15',   799.90, 5),
(2, 1, 'ELEC-002', 'Audífonos Bluetooth JBL',  149.90, 5),
(3, 2, 'ROPA-001', 'Polo deportivo Nike',        89.90, 10),
(4, 3, 'HOGA-001', 'Cafetera Oster 12 tazas',  199.90, 3),
(5, 4, 'DEPO-001', 'Pelota de fútbol N°5',       59.90, 8);

-- --------------------------------------------------------
-- 6. CLIENTE
-- --------------------------------------------------------
CREATE TABLE `cliente` (
  `ID_CLIENTE`     int(11)      NOT NULL AUTO_INCREMENT,
  `NOMBRE`         varchar(150) NOT NULL,
  `EMAIL`          varchar(100) DEFAULT NULL,
  `TELEFONO`       varchar(15)  DEFAULT NULL,
  `DOCUMENTO`      varchar(20)  DEFAULT NULL,
  `FECHA_REGISTRO` date         DEFAULT NULL,
  PRIMARY KEY (`ID_CLIENTE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `cliente` VALUES
(1, 'Juan Pérez',   'juan@gmail.com',   '987654321', '45678901', '2026-01-10'),
(2, 'María García', 'mariag@gmail.com', '976543210', '32165498', '2026-02-15'),
(3, 'Carlos López', 'carlos@gmail.com', '965432109', '12345678', '2026-03-20');

-- --------------------------------------------------------
-- 7. INVENTARIO_TIENDA
-- --------------------------------------------------------
CREATE TABLE `inventario_tienda` (
  `ID_INVENTARIO`        int(11)   NOT NULL AUTO_INCREMENT,
  `ID_PRODUCTO`          int(11)   NOT NULL,
  `ID_TIENDA`            int(11)   NOT NULL,
  `CANTIDAD`             int(11)   NOT NULL DEFAULT 0,
  `ULTIMA_ACTUALIZACION` datetime  DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_INVENTARIO`),
  CONSTRAINT `inv_ibfk_1` FOREIGN KEY (`ID_PRODUCTO`) REFERENCES `producto`(`ID_PRODUCTO`),
  CONSTRAINT `inv_ibfk_2` FOREIGN KEY (`ID_TIENDA`)   REFERENCES `tienda`  (`ID_TIENDA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `inventario_tienda` (`ID_PRODUCTO`, `ID_TIENDA`, `CANTIDAD`) VALUES
(1, 1, 20),
(2, 1,  3),
(3, 2, 15),
(4, 2,  8),
(5, 3,  4);

-- --------------------------------------------------------
-- 8. MOVIMIENTO_INVENTARIO
-- --------------------------------------------------------
CREATE TABLE `movimiento_inventario` (
  `ID_MOVIMIENTO` int(11)     NOT NULL AUTO_INCREMENT,
  `ID_PRODUCTO`   int(11)     NOT NULL,
  `TIPO`          varchar(20) DEFAULT NULL COMMENT 'entrada / salida',
  `CANTIDAD`      int(11)     NOT NULL,
  `FECHA`         datetime    DEFAULT current_timestamp(),
  `ORIGEN`        varchar(50) DEFAULT NULL COMMENT 'venta / compra / ajuste',
  PRIMARY KEY (`ID_MOVIMIENTO`),
  CONSTRAINT `mov_ibfk_1` FOREIGN KEY (`ID_PRODUCTO`) REFERENCES `producto`(`ID_PRODUCTO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- 9. VENTA
-- --------------------------------------------------------
CREATE TABLE `venta` (
  `ID_VENTA`   int(11)        NOT NULL AUTO_INCREMENT,
  `ID_CLIENTE` int(11)        DEFAULT NULL,
  `ID_USUARIO` int(11)        NOT NULL,
  `ID_TIENDA`  int(11)        NOT NULL,
  `FECHA`      datetime       DEFAULT current_timestamp(),
  `TOTAL`      decimal(10,2)  DEFAULT 0.00,
  `ESTADO`     varchar(20)    DEFAULT 'completada' COMMENT 'completada / anulada',
  `TIPO_PAGO`  varchar(20)    DEFAULT NULL     COMMENT 'efectivo / tarjeta',
  PRIMARY KEY (`ID_VENTA`),
  CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`ID_CLIENTE`) REFERENCES `cliente` (`ID_CLIENTE`),
  CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`ID_USUARIO`) REFERENCES `usuario` (`ID_USUARIO`),
  CONSTRAINT `venta_ibfk_3` FOREIGN KEY (`ID_TIENDA`)  REFERENCES `tienda`  (`ID_TIENDA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `venta` VALUES
(1, 1, 1, 1, '2026-04-20 10:30:00', 949.80, 'completada',  'efectivo'),
(2, 2, 4, 2, '2026-04-21 14:15:00',  89.90, 'completada',  'tarjeta'),
(3, 3, 1, 1, '2026-04-22 09:00:00', 259.80, 'anulada', 'efectivo');

-- --------------------------------------------------------
-- 10. DETALLE_VENTA
-- --------------------------------------------------------
CREATE TABLE `detalle_venta` (
  `ID_DETALLE`      int(11)        NOT NULL AUTO_INCREMENT,
  `ID_VENTA`        int(11)        NOT NULL,
  `ID_PRODUCTO`     int(11)        NOT NULL,
  `CANTIDAD`        int(11)        NOT NULL,
  `PRECIO_UNITARIO` decimal(10,2)  NOT NULL,
  `DESCUENTO`       decimal(10,2)  DEFAULT 0.00,
  PRIMARY KEY (`ID_DETALLE`),
  CONSTRAINT `dv_ibfk_1` FOREIGN KEY (`ID_VENTA`)    REFERENCES `venta`   (`ID_VENTA`),
  CONSTRAINT `dv_ibfk_2` FOREIGN KEY (`ID_PRODUCTO`) REFERENCES `producto`(`ID_PRODUCTO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `detalle_venta` VALUES
(1, 1, 1, 1, 799.90, 0.00),
(2, 1, 2, 1, 149.90, 0.00),
(3, 2, 3, 1,  89.90, 0.00),
(4, 3, 4, 1, 199.90, 0.00),
(5, 3, 5, 1,  59.90, 0.00);

-- --------------------------------------------------------
-- 11. COMPROBANTE
-- --------------------------------------------------------
CREATE TABLE `comprobante` (
  `ID_COMPROBANTE` int(11)     NOT NULL AUTO_INCREMENT,
  `ID_VENTA`       int(11)     NOT NULL,
  `NUMERO`         varchar(20) DEFAULT NULL,
  `TIPO`           varchar(20) DEFAULT NULL COMMENT 'boleta / factura',
  `EMISION`        datetime    DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_COMPROBANTE`),
  UNIQUE KEY `NUMERO` (`NUMERO`),
  CONSTRAINT `comp_ibfk_1` FOREIGN KEY (`ID_VENTA`) REFERENCES `venta`(`ID_VENTA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `comprobante` VALUES
(1, 1, 'B001-00001', 'boleta',  '2026-04-20 10:30:00'),
(2, 2, 'B001-00002', 'boleta',  '2026-04-21 14:15:00'),
(3, 3, 'B001-00003', 'factura', '2026-04-22 09:00:00');

-- --------------------------------------------------------
-- 12. PROVEEDOR
-- --------------------------------------------------------
CREATE TABLE `proveedor` (
  `ID_PROVEEDOR` int(11)      NOT NULL AUTO_INCREMENT,
  `RAZON_SOCIAL` varchar(150) NOT NULL,
  `RUC`          varchar(11)  DEFAULT NULL,
  `CONTACTO`     varchar(100) DEFAULT NULL,
  `TELEFONO`     varchar(15)  DEFAULT NULL,
  `EMAIL`        varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ID_PROVEEDOR`),
  UNIQUE KEY `RUC` (`RUC`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `proveedor` VALUES
(1, 'Samsung Perú S.A.C.',    '20512345678', 'Luis Torres',  '014567890', 'ltorres@samsung.pe'),
(2, 'Nike Distribuidora SAC', '20598765432', 'Ana Quispe',   '017654321', 'aquispe@nike.pe'),
(3, 'Oster Importaciones',    '20576543219', 'Jorge Mamani', '016543210', 'jmamani@oster.pe');

-- --------------------------------------------------------
-- 13. ORDEN_COMPRA
-- --------------------------------------------------------
CREATE TABLE `orden_compra` (
  `ID_ORDEN`     int(11)        NOT NULL AUTO_INCREMENT,
  `ID_PROVEEDOR` int(11)        NOT NULL,
  `FECHA`        datetime       DEFAULT current_timestamp(),
  `ESTADO`       varchar(20)    DEFAULT 'pendiente' COMMENT 'pendiente / recibida',
  `TOTAL`        decimal(10,2)  DEFAULT 0.00,
  PRIMARY KEY (`ID_ORDEN`),
  CONSTRAINT `oc_ibfk_1` FOREIGN KEY (`ID_PROVEEDOR`) REFERENCES `proveedor`(`ID_PROVEEDOR`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `orden_compra` VALUES
(1, 1, '2026-04-18 09:00:00', 'recibida',  15998.00),
(2, 2, '2026-04-19 11:00:00', 'pendiente',  2697.00);

-- --------------------------------------------------------
-- 14. DETALLE_ORDEN
-- --------------------------------------------------------
CREATE TABLE `detalle_orden` (
  `ID_DETALLE`         int(11)       NOT NULL AUTO_INCREMENT,
  `ID_ORDEN`           int(11)       NOT NULL,
  `ID_PRODUCTO`        int(11)       NOT NULL,
  `CANTIDAD`           int(11)       NOT NULL,
  `PRECIO_COMPRA`      decimal(10,2) DEFAULT NULL,
  `CANTIDAD_RECIBIDA`  int(11)       NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID_DETALLE`),
  CONSTRAINT `do_ibfk_1` FOREIGN KEY (`ID_ORDEN`)    REFERENCES `orden_compra`(`ID_ORDEN`),
  CONSTRAINT `do_ibfk_2` FOREIGN KEY (`ID_PRODUCTO`) REFERENCES `producto`    (`ID_PRODUCTO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Si ya tienes la tabla creada, ejecuta en XAMPP:
-- ALTER TABLE detalle_orden ADD COLUMN CANTIDAD_RECIBIDA INT NOT NULL DEFAULT 0;
-- UPDATE orden_compra SET ESTADO='recibida' WHERE ESTADO='recibida'; -- (sin cambio, solo referencia)
-- UPDATE detalle_orden do JOIN orden_compra oc ON do.ID_ORDEN = oc.ID_ORDEN
--   SET do.CANTIDAD_RECIBIDA = do.CANTIDAD WHERE oc.ESTADO = 'recibida';

INSERT INTO `detalle_orden` VALUES
(1, 1, 1, 20, 599.90),
(2, 1, 2, 10,  99.90),
(3, 2, 3, 30,  59.90);

-- ============================================================
-- FIN — 14 tablas creadas con datos de prueba
-- Contraseñas de usuarios (SHA-256):
--   12345   → 5994471a...
--   1234    → 03ac6742...
--   123     → a665a459...
--   luciana → 2527e3b7...
-- ============================================================
