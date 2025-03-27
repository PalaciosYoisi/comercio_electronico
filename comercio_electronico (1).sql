-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 27-03-2025 a las 23:28:01
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `comercio_electronico`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_stock` (IN `p_id_producto` INT, IN `p_cantidad` INT)   BEGIN
    DECLARE cantidad_actual INT;

    SELECT cantidad INTO cantidad_actual 
    FROM inventario 
    WHERE id_producto = p_id_producto;

    UPDATE inventario 
    SET cantidad = p_cantidad
    WHERE id_producto = p_id_producto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `aplicar_cupon` (IN `p_id_detalle` INT, IN `p_id_orden` INT, IN `p_id_cliente` INT, IN `p_id_producto` INT, IN `p_cantidad` INT, IN `p_descuento_cupon` DECIMAL(10,2), IN `p_fecha_venta` DATE)   BEGIN
    DECLARE p_precio_unitario DECIMAL(10,3);
    DECLARE p_subtotal DECIMAL(10,3);
    DECLARE p_total DECIMAL(10,3);
    
    -- Obtener el precio unitario del producto
    SELECT precio_unitario INTO p_precio_unitario
    FROM detalles_orden
    WHERE id_detalle = p_id_detalle;

    -- Calcular el subtotal
    SET p_subtotal = p_precio_unitario * p_cantidad;

    -- Calcular el total con el descuento (si aplica)
    SET p_total = p_subtotal - (p_subtotal * p_descuento_cupon / 100);

    -- Insertar los datos en la tabla ventas
    INSERT INTO ventas(
        id_orden, id_cliente, id_producto, cantidad, subtotal, descuento_cupon, total, fecha_venta
    ) VALUES (
        p_id_orden, p_id_cliente, p_id_producto, p_cantidad, p_subtotal, p_descuento_cupon, p_total, p_fecha_venta
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `productos_categorias` (IN `p_id_producto` INT)   BEGIN 

SELECT c.id_categoria, p.id_producto, p.nombre 

FROM categorias c JOIN productos p ON c.id_categoria = p.id_categoria
WHERE id_producto = p_id_producto;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporte_ventas` (IN `fecha_inicio` DATE, IN `fecha_fin` DATE)   BEGIN

SELECT v.id_venta, v.id_producto, p.nombre, v.total FROM ventas v JOIN productos p ON v.id_producto = p.id_producto 

WHERE fecha_venta BETWEEN fecha_inicio AND fecha_fin;

END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `AplicarImpuesto` (`p_monto` DECIMAL(10,3), `p_id_impuesto` INT) RETURNS DECIMAL(10,3) DETERMINISTIC BEGIN
    DECLARE tasa_impuesto DECIMAL(10,2);
    DECLARE monto_final DECIMAL(10,2);

    -- Obtener la tasa del impuesto desde la tabla impuestos
    SELECT tasa INTO tasa_impuesto 
    FROM impuestos 
    WHERE id_impuesto = p_id_impuesto 
    LIMIT 1;

    -- Calcular el monto con el impuesto aplicado
    SET monto_final = p_monto + (p_monto * tasa_impuesto / 100);

    RETURN monto_final;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CalcularTotalOrden` (`p_id_detalle` INT) RETURNS DECIMAL(10,3) DETERMINISTIC BEGIN 
DECLARE total DECIMAL(10, 3); 
SELECT SUM(cantidad * precio_unitario) INTO total FROM detalles_Orden 
WHERE  id_detalle = p_id_detalle; 
RETURN total; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ObtenerNombreUsuario` (`id_usuario` INT) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE nombre VARCHAR(100);
    
    SELECT nombre_usuario INTO nombre 
    FROM usuarios 
    WHERE usuarios.id_usuario = id_usuario 
    LIMIT 1;

    RETURN nombre;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre`) VALUES
(1, 'Belleza'),
(2, 'Electrónica'),
(3, 'Hogar'),
(4, 'Ropa'),
(5, 'Zapatos'),
(6, 'Accesorios'),
(7, 'Electrodomésticos'),
(8, 'Niños');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL,
  `nombre_cliente` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefono` varchar(100) DEFAULT NULL,
  `direccion` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombre_cliente`, `email`, `telefono`, `direccion`) VALUES
(1, 'Yoisi Palacios', 'yoisi.palacios@email.com', '12345', 'Centro'),
(2, 'Maria Gomez', 'maria@gmail.com', '56789', 'Centro'),
(3, 'Luis Moreno', 'luis@gmail.com', '23456', 'Yesquita'),
(4, 'Jose Cordoba', 'jose@gmail.com', '345678', 'Yesquita'),
(5, 'Yarlenis Moreno', 'yoisi@hotmail.com', '863528', 'Centro');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras_proveedores`
--

CREATE TABLE `compras_proveedores` (
  `id_compra` int(11) NOT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_compra` decimal(10,3) DEFAULT NULL,
  `fecha_compra` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `compras_proveedores`
--

INSERT INTO `compras_proveedores` (`id_compra`, `id_proveedor`, `id_producto`, `cantidad`, `precio_compra`, `fecha_compra`) VALUES
(1, 1, 1, 300, 7.000, '2025-03-01'),
(2, 2, 2, 200, 50.000, '2025-03-01'),
(3, 3, 3, 100, 9.000, '2025-03-01'),
(4, 4, 4, 150, 45.000, '2025-03-01'),
(5, 5, 5, 100, 30.000, '2025-03-01'),
(6, 6, 6, 100, 2.000, '2025-03-01'),
(7, 7, 7, 200, 30.000, '2025-03-01'),
(8, 8, 8, 300, 35.000, '2025-03-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion_sitio`
--

CREATE TABLE `configuracion_sitio` (
  `id_configuracion` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `valor` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cupones`
--

CREATE TABLE `cupones` (
  `id_cupon` int(11) NOT NULL,
  `codigo` varchar(100) DEFAULT NULL,
  `descuento` decimal(10,2) DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cupones`
--

INSERT INTO `cupones` (`id_cupon`, `codigo`, `descuento`, `fecha_inicio`, `fecha_fin`) VALUES
(1, '12345', 20.00, '2025-03-15', '2025-03-30'),
(2, '56789', 15.00, '2025-03-15', '2025-03-30'),
(3, '645352', 15.00, '2025-03-15', '2025-03-30'),
(4, '977252', 12.00, '2025-03-25', '2025-04-05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos_empleados`
--

CREATE TABLE `departamentos_empleados` (
  `id_departamento` int(11) NOT NULL,
  `nombre_departamento` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `departamentos_empleados`
--

INSERT INTO `departamentos_empleados` (`id_departamento`, `nombre_departamento`) VALUES
(1, 'Ventas'),
(2, 'Marketing'),
(3, 'Atencion al cliente'),
(4, 'Mantenimiento'),
(5, 'Contabilidad');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_orden`
--

CREATE TABLE `detalles_orden` (
  `id_detalle` int(11) NOT NULL,
  `id_orden` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_unitario` decimal(10,3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalles_orden`
--

INSERT INTO `detalles_orden` (`id_detalle`, `id_orden`, `id_producto`, `cantidad`, `precio_unitario`) VALUES
(1, 1, 2, 3, 76.000),
(2, 2, 4, 2, 69.000),
(3, 3, 2, 4, 76.000),
(4, 4, 1, 4, 11.000),
(5, 5, 5, 2, 60.000);

--
-- Disparadores `detalles_orden`
--
DELIMITER $$
CREATE TRIGGER `verificar_stock` BEFORE INSERT ON `detalles_orden` FOR EACH ROW BEGIN
    DECLARE stock_actual INT;

    -- Obtener el stock actual del producto desde la tabla inventario
    SELECT cantidad INTO stock_actual
    FROM inventario
    WHERE id_producto = NEW.id_producto;

    -- Verificar si hay suficiente stock disponible
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock insuficiente para este producto.';
    ELSE
        -- Reducir el stock disponible
        UPDATE inventario 
        SET cantidad = cantidad - NEW.cantidad
        WHERE id_producto = NEW.id_producto;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direcciones_usuarios`
--

CREATE TABLE `direcciones_usuarios` (
  `id_direccion` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `ciudad` varchar(100) DEFAULT NULL,
  `codigo_postal` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(11) NOT NULL,
  `id_departamento` int(11) DEFAULT NULL,
  `nombre_empleado` varchar(100) DEFAULT NULL,
  `cargo` varchar(100) DEFAULT NULL,
  `salario` decimal(10,2) DEFAULT NULL,
  `fecha_contratacion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `id_departamento`, `nombre_empleado`, `cargo`, `salario`, `fecha_contratacion`) VALUES
(1, 1, 'David Gomez', 'Asesor Comercial', 3500000.00, '2024-08-01'),
(2, 1, 'Luis Mena', 'Asesor de ventas', 3500000.00, '2025-01-10'),
(3, 2, 'Fernanda Lopez', 'Especialista en Marketing', 4000000.00, '2023-01-10'),
(4, 2, 'Antonio Salinas', 'Auxiliar en Marketing', 2000000.00, '2024-03-20'),
(5, 3, 'Tatiana Serna', 'Asesora', 3000000.00, '2025-02-01'),
(6, 3, 'Juliana Rivas', 'Asesora', 3000000.00, '2025-01-31'),
(7, 4, 'Nikol Moreno', 'Ingeniera Teleinformatica', 5000000.00, '2023-03-01'),
(8, 4, 'Alex Moya', 'Tecnico en sistemas', 3000000.00, '2025-03-01'),
(9, 5, 'Andres Salcedo', 'Contador', 4500000.00, '2024-10-01'),
(10, 5, 'Janeth Arroyo', 'Contadora', 4500000.00, '2024-03-28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `envios`
--

CREATE TABLE `envios` (
  `id_envio` int(11) NOT NULL,
  `id_orden` int(11) DEFAULT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `ciudad` varchar(100) DEFAULT NULL,
  `codigo_postal` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `envios`
--

INSERT INTO `envios` (`id_envio`, `id_orden`, `direccion`, `ciudad`, `codigo_postal`) VALUES
(1, 3, 'Calle 123', 'Pereira', '0000213'),
(2, 4, 'Avenida 456', 'Cartagena', '0000056'),
(3, 5, 'Barrio Jardin', 'Quibdó', '0000034');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_precios`
--

CREATE TABLE `historial_precios` (
  `id_historial` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `precio_anterior` decimal(10,3) DEFAULT NULL,
  `precio_nuevo` decimal(10,3) DEFAULT NULL,
  `fecha_cambio` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial_precios`
--

INSERT INTO `historial_precios` (`id_historial`, `id_producto`, `precio_anterior`, `precio_nuevo`, `fecha_cambio`) VALUES
(1, 5, 60.000, 62.000, '2025-03-27'),
(2, 6, 5.000, 6.000, '2025-03-27'),
(3, 7, 51.000, 55.000, '2025-03-27'),
(4, 8, 69.000, 71.000, '2025-03-27');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `imagenes_productos`
--

CREATE TABLE `imagenes_productos` (
  `id_imagen` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `impuestos`
--

CREATE TABLE `impuestos` (
  `id_impuesto` int(11) NOT NULL,
  `nombre_impuesto` varchar(100) DEFAULT NULL,
  `tasa` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `impuestos`
--

INSERT INTO `impuestos` (`id_impuesto`, `nombre_impuesto`, `tasa`) VALUES
(1, 'IVA', 16.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `id` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `ubicacion` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`id`, `id_producto`, `id_proveedor`, `cantidad`, `ubicacion`) VALUES
(1, 1, 1, 200, 'Medellin'),
(2, 2, 2, 500, 'Medellin'),
(3, 3, 3, 400, 'Medellin'),
(4, 4, 4, 250, 'Medellin'),
(5, 5, 5, 300, 'Medellin'),
(6, 6, 6, 100, 'Medellin'),
(7, 7, 7, 250, 'Medellin'),
(8, 8, 8, 250, 'Medellin');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `logs_sistema`
--

CREATE TABLE `logs_sistema` (
  `id_log` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `accion` varchar(100) DEFAULT NULL,
  `tabla_afectada` varchar(100) DEFAULT NULL,
  `fecha_hora` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ordenes`
--

CREATE TABLE `ordenes` (
  `id_orden` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_orden` date DEFAULT NULL,
  `estado` enum('Pendiente pago','Pagada','Preparando','Enviado','En reparto','Entregado') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ordenes`
--

INSERT INTO `ordenes` (`id_orden`, `id_usuario`, `fecha_orden`, `estado`) VALUES
(1, 1, '2025-03-20', 'Preparando'),
(2, 1, '2025-03-21', 'Preparando'),
(3, 1, '2025-03-26', 'Enviado'),
(4, 1, '2025-03-26', 'Enviado'),
(5, 1, '2025-03-25', 'Enviado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id_pago` int(11) NOT NULL,
  `id_orden` int(11) DEFAULT NULL,
  `monto` decimal(10,3) DEFAULT NULL,
  `metodo_pago` enum('Tarjeta','Efectivo','PSE') DEFAULT NULL,
  `fecha_pago` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pagos`
--

INSERT INTO `pagos` (`id_pago`, `id_orden`, `monto`, `metodo_pago`, `fecha_pago`) VALUES
(1, 3, 304.000, 'Tarjeta', '2025-03-25'),
(2, 4, 44.000, 'PSE', '2025-03-27');

--
-- Disparadores `pagos`
--
DELIMITER $$
CREATE TRIGGER `ectualizar_estado_orden` AFTER INSERT ON `pagos` FOR EACH ROW BEGIN
    -- Actualizar el estado de la orden a "Pagada"
    UPDATE ordenes
    SET estado = 'Pagada'
    WHERE id_orden = NEW.id_orden;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `precio` decimal(10,3) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `calificacion` decimal(10,1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `id_categoria`, `nombre`, `descripcion`, `precio`, `stock`, `calificacion`) VALUES
(1, 1, 'Paleta de sombras', 'Paleta de maquillaje de 9 colores, acabado semimate y brillante', 11.000, 300, 4.9),
(2, 2, 'Auriculares Inalámbricos', 'Auriculares Inalámbricos con diadema, Larga batería, compatible con ipad/celular', 76.000, 200, 4.2),
(3, 3, 'Lampara de escritorio', 'Lampara de escritorio LED, color blanco', 15.000, 100, 3.7),
(4, 4, 'Vestido manga corta', 'Vestido con estampado floral color azul', 69.000, 150, 4.0),
(5, 5, 'Sandalias para mujer', 'Sandalias de verano, planas, casuales, de moda, transpirables y ligeras', 62.000, 100, 4.0),
(6, 6, 'Collar', 'Collar con diseño de cereza', 6.000, 100, 4.3),
(7, 7, 'Aspiradora inalámbrica', 'Aspiradora inalámbrica de alta potencia de 120W, para uso doméstico', 55.000, 200, 4.6),
(8, 8, 'Pijama para niña', 'Pijama de 2 piezas, manga larga', 71.000, 300, 4.5);

--
-- Disparadores `productos`
--
DELIMITER $$
CREATE TRIGGER `registrar_cambio_precio` AFTER UPDATE ON `productos` FOR EACH ROW BEGIN
    -- Insertar en historial_precios solo si el precio cambió
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO historial_precios (id_producto, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio, NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id_proveedor` int(11) NOT NULL,
  `nombre_proveedor` varchar(100) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `telefono` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id_proveedor`, `nombre_proveedor`, `correo`, `telefono`) VALUES
(1, 'Vogue', 'voguecolombia@email.com', '123567'),
(2, 'TechNova', 'technova@email.com', '12345'),
(3, 'HomeHorizon\r\n\r\n', 'homehorizon@gmail.com\r\n\r\n', '1235678'),
(4, 'ModernaTextil', 'moderna@hotmail.com', '7847673'),
(5, 'ZapatoModa', 'zapatomoda@email.com', '36366272'),
(6, 'Glamora Distribution', 'glamora@email.com', '67363452'),
(7, 'ElectroMax', 'electromax@email.com', '36737282'),
(8, 'PequeTrend ', 'pequetrend@gmail.com', '3367282');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reviews`
--

CREATE TABLE `reviews` (
  `id_review` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `calificacion` decimal(10,2) DEFAULT NULL,
  `comentario` varchar(100) DEFAULT NULL,
  `fecha_review` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `reviews`
--

INSERT INTO `reviews` (`id_review`, `id_producto`, `id_usuario`, `calificacion`, `comentario`, `fecha_review`) VALUES
(3, 1, 1, 4.90, 'Buena Calidad', '2025-03-01'),
(4, 2, 2, 4.20, 'Podria mejorar la duracion de la carga', '2025-03-08');

--
-- Disparadores `reviews`
--
DELIMITER $$
CREATE TRIGGER `ActualizarPromedioCalificacion` AFTER INSERT ON `reviews` FOR EACH ROW BEGIN
    DECLARE nuevo_promedio DECIMAL(10,2);

    -- Calcular el nuevo promedio de calificaciones
    SELECT AVG(calificacion) INTO nuevo_promedio
    FROM reviews
    WHERE id_producto = NEW.id_producto;

    -- Actualizar el promedio en la tabla productos
    UPDATE productos
    SET calificacion = nuevo_promedio
    WHERE id_producto = NEW.id_producto;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesiones_usuarios`
--

CREATE TABLE `sesiones_usuarios` (
  `id_sesion` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `token` int(11) DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `clave` varchar(100) DEFAULT NULL,
  `rol` enum('Administrador','Empleado') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_usuario`, `email`, `clave`, `rol`) VALUES
(1, 'Juan Perez', 'juan@gmail.com', 'juan123', 'Empleado'),
(2, 'Carlos Palacios', 'carlos@email.com', 'carlos123', 'Administrador'),
(3, 'Nikol Moreno', 'nikolm@email.com', 'nikol123', 'Administrador'),
(4, 'Alex Moya', 'alex@gmail.com', 'alex123', 'Empleado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id_venta` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `subtotal` decimal(10,3) NOT NULL,
  `descuento_cupon` decimal(10,2) NOT NULL,
  `total` decimal(10,3) NOT NULL,
  `fecha_venta` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id_venta`, `id_orden`, `id_cliente`, `id_producto`, `cantidad`, `subtotal`, `descuento_cupon`, `total`, `fecha_venta`) VALUES
(2, 1, 1, 4, 2, 138.000, 0.15, 117.300, '2025-03-18'),
(5, 3, 2, 2, 4, 304.000, 10.00, 273.600, '2025-03-20'),
(6, 4, 3, 1, 4, 44.000, 20.00, 35.200, '2025-03-21'),
(7, 5, 1, 5, 2, 120.000, 15.00, 102.000, '2025-03-24'),
(8, 2, 3, 4, 2, 138.000, 50.00, 69.000, '2025-03-25');

--
-- Disparadores `ventas`
--
DELIMITER $$
CREATE TRIGGER `actualizar_inventario` AFTER INSERT ON `ventas` FOR EACH ROW BEGIN
    -- Reducir el stock en la tabla inventario
    UPDATE inventario
    SET cantidad = cantidad - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Indices de la tabla `compras_proveedores`
--
ALTER TABLE `compras_proveedores`
  ADD PRIMARY KEY (`id_compra`),
  ADD KEY `id_proveedor` (`id_proveedor`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `configuracion_sitio`
--
ALTER TABLE `configuracion_sitio`
  ADD PRIMARY KEY (`id_configuracion`);

--
-- Indices de la tabla `cupones`
--
ALTER TABLE `cupones`
  ADD PRIMARY KEY (`id_cupon`);

--
-- Indices de la tabla `departamentos_empleados`
--
ALTER TABLE `departamentos_empleados`
  ADD PRIMARY KEY (`id_departamento`);

--
-- Indices de la tabla `detalles_orden`
--
ALTER TABLE `detalles_orden`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_orden` (`id_orden`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `direcciones_usuarios`
--
ALTER TABLE `direcciones_usuarios`
  ADD PRIMARY KEY (`id_direccion`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`),
  ADD KEY `id_departamento` (`id_departamento`);

--
-- Indices de la tabla `envios`
--
ALTER TABLE `envios`
  ADD PRIMARY KEY (`id_envio`),
  ADD KEY `id_orden` (`id_orden`);

--
-- Indices de la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `imagenes_productos`
--
ALTER TABLE `imagenes_productos`
  ADD PRIMARY KEY (`id_imagen`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `impuestos`
--
ALTER TABLE `impuestos`
  ADD PRIMARY KEY (`id_impuesto`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_proveedor` (`id_proveedor`);

--
-- Indices de la tabla `logs_sistema`
--
ALTER TABLE `logs_sistema`
  ADD PRIMARY KEY (`id_log`);

--
-- Indices de la tabla `ordenes`
--
ALTER TABLE `ordenes`
  ADD PRIMARY KEY (`id_orden`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id_pago`),
  ADD KEY `id_orden` (`id_orden`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id_proveedor`);

--
-- Indices de la tabla `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id_review`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `sesiones_usuarios`
--
ALTER TABLE `sesiones_usuarios`
  ADD PRIMARY KEY (`id_sesion`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_orden` (`id_orden`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `compras_proveedores`
--
ALTER TABLE `compras_proveedores`
  MODIFY `id_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `configuracion_sitio`
--
ALTER TABLE `configuracion_sitio`
  MODIFY `id_configuracion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cupones`
--
ALTER TABLE `cupones`
  MODIFY `id_cupon` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `departamentos_empleados`
--
ALTER TABLE `departamentos_empleados`
  MODIFY `id_departamento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `detalles_orden`
--
ALTER TABLE `detalles_orden`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `direcciones_usuarios`
--
ALTER TABLE `direcciones_usuarios`
  MODIFY `id_direccion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `envios`
--
ALTER TABLE `envios`
  MODIFY `id_envio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `imagenes_productos`
--
ALTER TABLE `imagenes_productos`
  MODIFY `id_imagen` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `impuestos`
--
ALTER TABLE `impuestos`
  MODIFY `id_impuesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `logs_sistema`
--
ALTER TABLE `logs_sistema`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ordenes`
--
ALTER TABLE `ordenes`
  MODIFY `id_orden` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id_review` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `sesiones_usuarios`
--
ALTER TABLE `sesiones_usuarios`
  MODIFY `id_sesion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `compras_proveedores`
--
ALTER TABLE `compras_proveedores`
  ADD CONSTRAINT `compras_proveedores_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`),
  ADD CONSTRAINT `compras_proveedores_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `detalles_orden`
--
ALTER TABLE `detalles_orden`
  ADD CONSTRAINT `detalles_orden_ibfk_1` FOREIGN KEY (`id_orden`) REFERENCES `ordenes` (`id_orden`),
  ADD CONSTRAINT `detalles_orden_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `empleados_ibfk_1` FOREIGN KEY (`id_departamento`) REFERENCES `departamentos_empleados` (`id_departamento`);

--
-- Filtros para la tabla `envios`
--
ALTER TABLE `envios`
  ADD CONSTRAINT `envios_ibfk_1` FOREIGN KEY (`id_orden`) REFERENCES `ordenes` (`id_orden`);

--
-- Filtros para la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  ADD CONSTRAINT `historial_precios_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `imagenes_productos`
--
ALTER TABLE `imagenes_productos`
  ADD CONSTRAINT `imagenes_productos_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `inventario_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  ADD CONSTRAINT `inventario_ibfk_2` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`);

--
-- Filtros para la tabla `ordenes`
--
ALTER TABLE `ordenes`
  ADD CONSTRAINT `ordenes_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`id_orden`) REFERENCES `ordenes` (`id_orden`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`);

--
-- Filtros para la tabla `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
