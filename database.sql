-- ============================================================================
-- CADENA DE RESTAURANTES - SISTEMA DE GESTIÓN MULTI-SEDE
-- 18 TABLAS - SCRIPT SQL COMPLETO
-- ============================================================================
 
DROP DATABASE IF EXISTS cadena_restaurantes;
CREATE DATABASE cadena_restaurantes;
USE cadena_restaurantes;
 
-- ============================================================================
-- 🟣 MÓDULO ACCESO - TABLAS PADRE
-- ============================================================================
 
CREATE TABLE sede (
    id_sed_pk INT PRIMARY KEY AUTO_INCREMENT,
    nom_sed VARCHAR(50) NOT NULL,
    dir_sed VARCHAR(100) NOT NULL,
    tel_sed VARCHAR(20) NOT NULL,
    cap_sed INT NOT NULL,
    hrio_sed VARCHAR(50) NOT NULL,
    mun_sed VARCHAR(50) NOT NULL,
    UNIQUE KEY uq_sede_nombre_municipio (nom_sed, mun_sed)
) ENGINE=InnoDB;
 
CREATE TABLE empleado (
    id_emp_pk INT PRIMARY KEY AUTO_INCREMENT,
    nom_emp VARCHAR(50) NOT NULL,
    ape_emp VARCHAR(50) NOT NULL,
    tel_emp VARCHAR(20) NOT NULL,
    ema_emp VARCHAR(50) NOT NULL,
    car_emp VARCHAR(50) NOT NULL,
    sal_emp INT NOT NULL,
    fec_ing_emp DATE NOT NULL,
    hro_emp VARCHAR(50) NOT NULL,
    id_sed_fk INT NOT NULL,
    FOREIGN KEY (id_sed_fk) REFERENCES sede(id_sed_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE usuario (
    id_usu_pk INT PRIMARY KEY AUTO_INCREMENT,
    use_usu VARCHAR(50) NOT NULL UNIQUE,
    pas_usu VARCHAR(255) NOT NULL,
    est_usu VARCHAR(20) NOT NULL,
    id_emp_fk INT NOT NULL UNIQUE,
    FOREIGN KEY (id_emp_fk) REFERENCES empleado(id_emp_pk) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE nomina (
    id_nom_pk INT PRIMARY KEY AUTO_INCREMENT,
    fec_nom DATE NOT NULL,
    per_nom VARCHAR(20) NOT NULL,
    val_nom INT NOT NULL,
    ded_sal INT NOT NULL,
    ded_pen INT NOT NULL,
    ded_otr INT NOT NULL,
    sop_nom VARCHAR(50) NOT NULL,
    id_emp_fk INT NOT NULL,
    FOREIGN KEY (id_emp_fk) REFERENCES empleado(id_emp_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🔵 MÓDULO VENTAS - TABLAS CLIENTE Y MESAS
-- ============================================================================
 
CREATE TABLE cliente (
    id_cli_pk INT PRIMARY KEY AUTO_INCREMENT,
    nom_cli VARCHAR(50) NOT NULL,
    ape_cli VARCHAR(50) NOT NULL,
    tel_cli VARCHAR(20) NOT NULL UNIQUE,
    ema_cli VARCHAR(50) NOT NULL,
    pun_cli INT DEFAULT 0,
    val_acu_cli INT DEFAULT 0
) ENGINE=InnoDB;
 
CREATE TABLE mesa (
    id_mes_pk INT PRIMARY KEY AUTO_INCREMENT,
    num_mes INT NOT NULL,
    cap_mes INT NOT NULL,
    est_mes VARCHAR(20) NOT NULL,
    id_sed_fk INT NOT NULL,
    FOREIGN KEY (id_sed_fk) REFERENCES sede(id_sed_pk) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🔵 MÓDULO VENTAS - PEDIDOS Y FACTURAS
-- ============================================================================
 
CREATE TABLE pedido (
    id_ped_pk INT PRIMARY KEY AUTO_INCREMENT,
    hor_ini_ped TIME NOT NULL,
    hor_fin_ped TIME,
    mpa_ped VARCHAR(50) NOT NULL,
    pro_ped INT DEFAULT 0,
    id_mes_fk INT NOT NULL,
    id_emp_fk INT NOT NULL,
    id_cli_fk INT,
    FOREIGN KEY (id_mes_fk) REFERENCES mesa(id_mes_pk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_emp_fk) REFERENCES empleado(id_emp_pk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_cli_fk) REFERENCES cliente(id_cli_pk) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE factura (
    id_fac_pk INT PRIMARY KEY AUTO_INCREMENT,
    fec_fac DATE NOT NULL,
    sub_fac INT NOT NULL,
    imp_fac INT NOT NULL,
    tot_fac INT NOT NULL,
    id_ped_fk INT NOT NULL,
    FOREIGN KEY (id_ped_fk) REFERENCES pedido(id_ped_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🟢 MÓDULO PRODUCTO - TABLAS BASE
-- ============================================================================
 
CREATE TABLE categoria (
    id_cat_pk INT PRIMARY KEY AUTO_INCREMENT,
    nom_cat VARCHAR(50) NOT NULL UNIQUE,
    des_cat VARCHAR(255)
) ENGINE=InnoDB;
 
CREATE TABLE producto (
    id_pro_pk INT PRIMARY KEY AUTO_INCREMENT,
    nom_pro VARCHAR(50) NOT NULL,
    des_pro TEXT,
    pre_pro INT NOT NULL,
    tie_pre_pro INT NOT NULL,
    dis_pro VARCHAR(20) NOT NULL,
    id_cat_fk INT NOT NULL,
    FOREIGN KEY (id_cat_fk) REFERENCES categoria(id_cat_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🔵 MÓDULO VENTAS - DETALLE (TABLA HIJA)
-- ============================================================================
 
CREATE TABLE detalle_factura (
    id_det_fac_pk INT PRIMARY KEY AUTO_INCREMENT,
    can_det INT NOT NULL,
    pre_unit_det INT NOT NULL,
    sub_det INT NOT NULL,
    id_fac_fk INT NOT NULL,
    id_pro_fk INT NOT NULL,
    FOREIGN KEY (id_fac_fk) REFERENCES factura(id_fac_pk) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_pro_fk) REFERENCES producto(id_pro_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🟢 MÓDULO PRODUCTO - DISPONIBILIDAD POR SEDE (TABLA HIJA)
-- ============================================================================
 
CREATE TABLE sede_producto (
    id_sed_fk INT NOT NULL,
    id_pro_fk INT NOT NULL,
    dis_sed_pro VARCHAR(20) DEFAULT 'disponible',
    PRIMARY KEY (id_sed_fk, id_pro_fk),
    FOREIGN KEY (id_sed_fk) REFERENCES sede(id_sed_pk) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_pro_fk) REFERENCES producto(id_pro_pk) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🟡 MÓDULO RESERVAS Y CLIENTES
-- ============================================================================
 
CREATE TABLE reserva (
    id_res_pk INT PRIMARY KEY AUTO_INCREMENT,
    fec_res DATE NOT NULL,
    hor_res TIME NOT NULL,
    com_res INT NOT NULL,
    est_res VARCHAR(20) NOT NULL,
    id_cli_fk INT NOT NULL,
    id_mes_fk INT NOT NULL,
    id_sed_fk INT NOT NULL,
    FOREIGN KEY (id_cli_fk) REFERENCES cliente(id_cli_pk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_mes_fk) REFERENCES mesa(id_mes_pk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_sed_fk) REFERENCES sede(id_sed_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE incidente (
    id_inc_pk INT PRIMARY KEY AUTO_INCREMENT,
    fec_inc DATE NOT NULL,
    tip_inc VARCHAR(50) NOT NULL,
    des_inc TEXT NOT NULL,
    gra_inc VARCHAR(20) NOT NULL,
    seg_inc VARCHAR(255),
    id_emp_fk INT NOT NULL,
    id_cli_fk INT,
    FOREIGN KEY (id_emp_fk) REFERENCES empleado(id_emp_pk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_cli_fk) REFERENCES cliente(id_cli_pk) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🟠 MÓDULO INVENTARIO - TABLAS BASE
-- ============================================================================
 
CREATE TABLE proveedor (
    id_prv_pk INT PRIMARY KEY AUTO_INCREMENT,
    nom_prv VARCHAR(50) NOT NULL UNIQUE,
    tel_prv VARCHAR(20) NOT NULL,
    ema_prv VARCHAR(50) NOT NULL,
    dir_prv VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
 
CREATE TABLE ingrediente (
    id_ing_pk INT PRIMARY KEY AUTO_INCREMENT,
    nom_ing VARCHAR(50) NOT NULL UNIQUE,
    sto_ing INT NOT NULL,
    min_ing INT NOT NULL,
    fec_ven_ing DATE,
    uni_ing VARCHAR(20) NOT NULL
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🟠 MÓDULO INVENTARIO - ÓRDENES DE COMPRA
-- ============================================================================
 
CREATE TABLE orden_compra (
    id_ord_pk INT PRIMARY KEY AUTO_INCREMENT,
    fec_ord DATE NOT NULL,
    est_ord VARCHAR(20) NOT NULL,
    tot_ord INT NOT NULL,
    id_prv_fk INT NOT NULL,
    id_emp_fk INT NOT NULL,
    id_sed_fk INT NOT NULL,
    FOREIGN KEY (id_prv_fk) REFERENCES proveedor(id_prv_pk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_emp_fk) REFERENCES empleado(id_emp_pk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_sed_fk) REFERENCES sede(id_sed_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE detalle_compra (
    id_det_ord_pk INT PRIMARY KEY AUTO_INCREMENT,
    can_det INT NOT NULL,
    pre_det INT NOT NULL,
    id_ord_fk INT NOT NULL,
    id_ing_fk INT NOT NULL,
    FOREIGN KEY (id_ord_fk) REFERENCES orden_compra(id_ord_pk) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_ing_fk) REFERENCES ingrediente(id_ing_pk) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ============================================================================
-- 🔴 INSERTS - DATOS DE EJEMPLO
-- ============================================================================
 
-- SEDES
INSERT INTO sede (nom_sed, dir_sed, tel_sed, cap_sed, hrio_sed, mun_sed) VALUES
('Sede Bogotá Centro', 'Cra 7 # 24-10', '6015551234', 50, '11:00-23:00', 'Bogotá'),
('Sede Bogotá Chapinero', 'Cra 13 # 60-20', '6015555678', 40, '11:00-22:00', 'Bogotá'),
('Sede Fusagasugá', 'Calle 5 # 4-50', '8714561234', 30, '12:00-21:00', 'Fusagasugá'),
('Sede Girardot', 'Cra 12 # 20-30', '8363215678', 35, '11:00-22:00', 'Girardot'),
('Sede Soacha', 'Calle 10 # 15-40', '6017659876', 25, '11:00-21:00', 'Soacha');
 
-- EMPLEADOS
INSERT INTO empleado (nom_emp, ape_emp, tel_emp, ema_emp, car_emp, sal_emp, fec_ing_emp, hro_emp, id_sed_fk) VALUES
('Carlos', 'Mendoza', '3001234567', 'carlos.m@rest.com', 'Administrador', 2500000, '2023-01-15', '08:00-17:00', 1),
('Ana', 'García', '3001234568', 'ana.g@rest.com', 'Cajero', 1800000, '2023-03-20', '11:00-19:00', 1),
('Juan', 'Pérez', '3001234569', 'juan.p@rest.com', 'Chef', 2200000, '2023-02-10', '10:00-18:00', 1),
('María', 'López', '3001234570', 'maria.l@rest.com', 'Mesero', 1500000, '2023-04-05', '11:00-20:00', 1),
('Pedro', 'Rodríguez', '3001234571', 'pedro.r@rest.com', 'Bodeguero', 1700000, '2023-05-12', '06:00-14:00', 1),
('Laura', 'Martínez', '3002234567', 'laura.m@rest.com', 'Administrador', 2500000, '2023-01-20', '08:00-17:00', 2),
('David', 'Sánchez', '3002234568', 'david.s@rest.com', 'Chef', 2200000, '2023-03-15', '10:00-18:00', 2),
('Sofia', 'Torres', '3003234567', 'sofia.t@rest.com', 'Administrador', 2500000, '2023-02-01', '08:00-17:00', 3),
('Miguel', 'Ruiz', '3004234567', 'miguel.r@rest.com', 'Chef', 2200000, '2023-04-10', '10:00-18:00', 4),
('Patricia', 'Vega', '3005234567', 'patricia.v@rest.com', 'Administrador', 2500000, '2023-03-05', '08:00-17:00', 5);
 
-- USUARIOS
INSERT INTO usuario (use_usu, pas_usu, est_usu, id_emp_fk) VALUES
('carlos.m', 'pass123456', 'activo', 1),
('ana.g', 'pass123456', 'activo', 2),
('juan.p', 'pass123456', 'activo', 3),
('maria.l', 'pass123456', 'activo', 4),
('pedro.r', 'pass123456', 'activo', 5),
('laura.m', 'pass123456', 'activo', 6),
('david.s', 'pass123456', 'activo', 7),
('sofia.t', 'pass123456', 'activo', 8),
('miguel.r', 'pass123456', 'activo', 9),
('patricia.v', 'pass123456', 'activo', 10);
 
-- NÓMINA
INSERT INTO nomina (fec_nom, per_nom, val_nom, ded_sal, ded_pen, ded_otr, sop_nom, id_emp_fk) VALUES
('2024-06-15', 'quincena 1', 1250000, 150000, 200000, 50000, 'transferencia', 1),
('2024-06-15', 'quincena 1', 900000, 100000, 140000, 30000, 'transferencia', 2),
('2024-06-15', 'quincena 1', 1100000, 130000, 180000, 40000, 'transferencia', 3),
('2024-06-15', 'quincena 1', 750000, 85000, 120000, 25000, 'transferencia', 4),
('2024-06-15', 'quincena 1', 850000, 100000, 135000, 28000, 'transferencia', 5),
('2024-06-15', 'quincena 1', 1250000, 150000, 200000, 50000, 'transferencia', 6),
('2024-06-15', 'quincena 1', 1100000, 130000, 180000, 40000, 'transferencia', 7),
('2024-06-15', 'quincena 1', 1250000, 150000, 200000, 50000, 'transferencia', 8),
('2024-06-15', 'quincena 1', 1100000, 130000, 180000, 40000, 'transferencia', 9),
('2024-06-15', 'quincena 1', 1250000, 150000, 200000, 50000, 'transferencia', 10);
 
-- CLIENTES
INSERT INTO cliente (nom_cli, ape_cli, tel_cli, ema_cli, pun_cli, val_acu_cli) VALUES
('Roberto', 'Acosta', '3101234567', 'roberto.a@mail.com', 150, 5000000),
('Elena', 'Blanco', '3101234568', 'elena.b@mail.com', 200, 7500000),
('Fernanda', 'Castro', '3101234569', 'fernanda.c@mail.com', 100, 3500000),
('Gregorio', 'Díaz', '3101234570', 'gregorio.d@mail.com', 50, 2000000),
('Inesita', 'Escobar', '3101234571', 'inesita.e@mail.com', 120, 4200000);
 
-- MESAS
INSERT INTO mesa (num_mes, cap_mes, est_mes, id_sed_fk) VALUES
(1, 4, 'disponible', 1), (2, 4, 'disponible', 1), (3, 6, 'disponible', 1),
(4, 8, 'disponible', 1), (5, 4, 'disponible', 1),
(1, 4, 'disponible', 2), (2, 6, 'disponible', 2), (3, 4, 'disponible', 2),
(1, 4, 'disponible', 3), (2, 6, 'disponible', 3),
(1, 4, 'disponible', 4), (2, 8, 'disponible', 4),
(1, 4, 'disponible', 5);
 
-- CATEGORÍAS
INSERT INTO categoria (nom_cat, des_cat) VALUES
('Entradas', 'Platos para comenzar'),
('Platos Principales', 'Platos fuertes'),
('Postres', 'Postres y dulces'),
('Bebidas', 'Bebidas variadas'),
('Acompañamientos', 'Complementos de los platos');
 
-- PRODUCTOS
INSERT INTO producto (nom_pro, des_pro, pre_pro, tie_pre_pro, dis_pro, id_cat_fk) VALUES
('Bandeja Paisa', 'Plato típico colombiano', 35000, 25, 'disponible', 2),
('Ajiaco Bogotano', 'Sopa tradicional', 18000, 15, 'disponible', 2),
('Arepa con Queso', 'Arepa rellena de queso', 8000, 8, 'disponible', 1),
('Ceviche', 'Entrada marina', 22000, 10, 'disponible', 1),
('Brazuelo a la Brasa', 'Carne asada', 45000, 30, 'disponible', 2),
('Ensalada Tropical', 'Ensalada fresca', 12000, 5, 'disponible', 5),
('Flan de Caramelo', 'Postre tradicional', 8000, 5, 'disponible', 3),
('Jugo Natural', 'Bebida refrescante', 6000, 5, 'disponible', 4),
('Cerveza Artesanal', 'Bebida fría', 10000, 0, 'disponible', 4),
('Tinto Tinto', 'Café colombiano', 3000, 3, 'disponible', 4);
 
-- SEDE_PRODUCTO
INSERT INTO sede_producto (id_sed_fk, id_pro_fk, dis_sed_pro) VALUES
(1, 1, 'disponible'), (1, 2, 'disponible'), (1, 3, 'disponible'), (1, 4, 'disponible'),
(1, 5, 'disponible'), (1, 6, 'disponible'), (1, 7, 'disponible'), (1, 8, 'disponible'),
(2, 1, 'disponible'), (2, 2, 'disponible'), (2, 3, 'disponible'), (2, 5, 'disponible'),
(3, 1, 'disponible'), (3, 2, 'disponible'), (3, 3, 'disponible'), (3, 4, 'disponible'),
(4, 1, 'disponible'), (4, 5, 'disponible'), (4, 6, 'disponible'),
(5, 2, 'disponible'), (5, 3, 'disponible'), (5, 4, 'disponible');
 
-- PEDIDOS
INSERT INTO pedido (hor_ini_ped, hor_fin_ped, mpa_ped, pro_ped, id_mes_fk, id_emp_fk, id_cli_fk) VALUES
('12:30:00', '13:15:00', 'efectivo', 5000, 1, 4, 1),
('13:00:00', '13:45:00', 'tarjeta', 3500, 2, 4, 2),
('13:30:00', '14:10:00', 'transferencia', 2000, 3, 4, 3),
('14:00:00', '14:50:00', 'efectivo', 4200, 4, 4, 4),
('12:45:00', '13:30:00', 'tarjeta', 6000, 6, 7, 5);
 
-- FACTURAS
INSERT INTO factura (fec_fac, sub_fac, imp_fac, tot_fac, id_ped_fk) VALUES
('2024-06-20', 69000, 13110, 82110, 1),
('2024-06-20', 55000, 10450, 65450, 2),
('2024-06-20', 38000, 7220, 45220, 3),
('2024-06-20', 80000, 15200, 95200, 4),
('2024-06-20', 70000, 13300, 83300, 5);
 
-- DETALLE_FACTURA
INSERT INTO detalle_factura (can_det, pre_unit_det, sub_det, id_fac_fk, id_pro_fk) VALUES
(1, 35000, 35000, 1, 1),
(2, 12000, 24000, 1, 6),
(1, 10000, 10000, 1, 9),
(1, 18000, 18000, 2, 2),
(1, 22000, 22000, 2, 4),
(2, 8000, 16000, 2, 3),
(2, 8000, 16000, 3, 3),
(1, 22000, 22000, 3, 4),
(2, 45000, 90000, 4, 5),
(1, 12000, 12000, 4, 6),
(1, 45000, 45000, 5, 5),
(1, 18000, 18000, 5, 2),
(1, 8000, 8000, 5, 7);
 
-- RESERVAS
INSERT INTO reserva (fec_res, hor_res, com_res, est_res, id_cli_fk, id_mes_fk, id_sed_fk) VALUES
('2024-06-25', '19:00:00', 4, 'confirmada', 1, 1, 1),
('2024-06-26', '19:30:00', 6, 'confirmada', 2, 3, 1),
('2024-06-27', '20:00:00', 4, 'confirmada', 3, 6, 2),
('2024-06-28', '19:00:00', 8, 'confirmada', 4, 4, 1),
('2024-06-29', '20:00:00', 4, 'confirmada', 5, 9, 3);
 
-- INCIDENTES
INSERT INTO incidente (fec_inc, tip_inc, des_inc, gra_inc, seg_inc, id_emp_fk, id_cli_fk) VALUES
('2024-06-15', 'sugerencia', 'El servicio fue excelente', 'baja', 'Agradecimiento registrado', 4, 1),
('2024-06-18', 'queja', 'Demora en la entrega del pedido', 'media', 'Se conversó con el cliente, se ofreció descuento', 4, 2),
('2024-06-20', 'felicitación', 'Comida deliciosa, ambiente agradable', 'baja', 'Comunicar al chef', 7, 3),
('2024-06-21', 'queja', 'Plato llegó frío', 'alta', 'Se cambió el plato inmediatamente', 4, 4),
('2024-06-22', 'sugerencia', 'Agregar opciones vegetarianas', 'baja', 'Evaluado para menú', 7, NULL);
 
-- PROVEEDORES
INSERT INTO proveedor (nom_prv, tel_prv, ema_prv, dir_prv) VALUES
('Distribuidora Andina', '6015551000', 'pedidos@andina.com', 'Calle 80 # 10-50'),
('Alimentos Colombia', '6015552000', 'ventas@alimentos.com', 'Carrera 15 # 85-40'),
('Carnes Premium', '6015553000', 'carnes@premium.com', 'Diagonal 120 # 50-20'),
('Verduras y Frutas', '6015554000', 'verduras@fresh.com', 'Calle 5 # 100-10'),
('Lácteos del Valle', '6015555000', 'lacteos@valle.com', 'Carrera 20 # 90-30');
 
-- INGREDIENTES
INSERT INTO ingrediente (nom_ing, sto_ing, min_ing, fec_ven_ing, uni_ing) VALUES
('Carne Molida', 50, 10, '2024-07-05', 'kg'),
('Harina de Maíz', 100, 20, '2024-08-15', 'kg'),
('Queso Fresco', 30, 5, '2024-06-28', 'kg'),
('Tomate', 80, 15, '2024-06-25', 'kg'),
('Cebolla', 60, 12, '2024-06-26', 'kg'),
('Papas', 120, 25, '2024-06-27', 'kg'),
('Lechuga', 40, 10, '2024-06-24', 'kg'),
('Huevos', 300, 50, '2024-06-30', 'unidad'),
('Leche Fresca', 100, 20, '2024-06-23', 'L'),
('Aceite', 80, 15, '2024-08-10', 'L');
 
-- ÓRDENES DE COMPRA
INSERT INTO orden_compra (fec_ord, est_ord, tot_ord, id_prv_fk, id_emp_fk, id_sed_fk) VALUES
('2024-06-18', 'recibida', 800000, 1, 5, 1),
('2024-06-19', 'recibida', 600000, 2, 5, 1),
('2024-06-19', 'recibida', 1200000, 3, 5, 1),
('2024-06-20', 'recibida', 400000, 4, 5, 1),
('2024-06-20', 'pendiente', 500000, 5, 5, 1),
('2024-06-18', 'recibida', 700000, 1, 7, 2),
('2024-06-19', 'recibida', 600000, 3, 7, 2),
('2024-06-18', 'recibida', 500000, 2, 5, 3);
 
-- DETALLE COMPRA
INSERT INTO detalle_compra (can_det, pre_det, id_ord_fk, id_ing_fk) VALUES
(30, 20000, 1, 1),
(20, 15000, 1, 8),
(50, 8000, 2, 2),
(30, 12000, 2, 3),
(50, 18000, 3, 1),
(40, 12000, 3, 4),
(80, 30000, 4, 6),
(50, 8000, 4, 5),
(30, 35000, 5, 9),
(20, 20000, 5, 10),
(40, 15000, 6, 2),
(20, 25000, 6, 1),
(50, 18000, 7, 1),
(30, 12000, 8, 3);