
-- Base de Datos: Ventas_Tech_DB
-- Proyecto: TechStore - Back-End de Ventas (Retail)
-- Archivo: ventas_tech_db.sql
-- Autor: Tomás



-- 1. CREACIÓN DE BASE DE DATOS

-- CREATE DATABASE Ventas_Tech_DB;


-- 2. SECCIÓN DDL: ELIMINACIÓN DE TABLAS (Orden Inverso por FK)

-- Para garantizar idempotencia y re-ejecución sin errores
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;


-- =====================================================================
-- 3. SECCIÓN DDL: CREACIÓN DE TABLAS Y RESTRICCIONES DE INTEGRIDAD
-- =====================================================================

-- 3.1. Tabla: categorias
CREATE TABLE categorias (
    -- id_categoria: Clave primaria entera para identificar cada familia de artículos
    id_categoria INT PRIMARY KEY,
    -- nombre_categoria: VARCHAR(50) evita desperdiciar almacenamiento; NOT NULL porque toda categoría debe nombrarse
    nombre_categoria VARCHAR(50) NOT NULL,
    -- descripcion: Texto descriptivo opcional para detallar el alcance de la categoría
    descripcion VARCHAR(200)
);

-- 3.2. Tabla: clientes
CREATE TABLE clientes (
    -- id_cliente: Clave primaria (PK) para indexación eficiente
    id_cliente INT PRIMARY KEY,
    -- nombre: VARCHAR(100) obligatorio para registrar la identidad del comprador o razón social
    nombre VARCHAR(100) NOT NULL,
    -- email: UNIQUE garantiza que no existan cuentas duplicadas bajo el mismo correo
    email VARCHAR(100) UNIQUE,
    -- ciudad: VARCHAR(50) para análisis geográfico y segmentación de mercado
    ciudad VARCHAR(50),
    -- fecha_registro: DATE porque solo necesitamos día/mes/año; omitimos TIMESTAMP para ahorrar bytes
    fecha_registro DATE NOT NULL
);

-- 3.3. Tabla: productos 
CREATE TABLE productos (
    -- id_producto: Clave primaria numérica de catálogo (PK)
    id_producto INT PRIMARY KEY,
    -- nombre_producto: Nombre comercial obligatorio del producto
    nombre_producto VARCHAR(100) NOT NULL,
    -- id_categoria: (FK) que asegura que el producto pertenezca a una categoría válida
    id_categoria INT NOT NULL,
    -- precio: DECIMAL(10,2) asegura precisión monetaria exacta; evito FLOAT por los desfasajes de redondeo
    precio DECIMAL(10, 2) NOT NULL,
    -- stock: Entero con valor por defecto 0 para representar existencias en depósito
    stock INT DEFAULT 0,
    -- activo: SMALLINT (1 o 0) con DEFAULT 1
    activo SMALLINT DEFAULT 1,
    -- Restricción de integridad referencial hacia categorias
    CONSTRAINT fk_productos_categorias 
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- 3.4. Tabla: ventas (Tabla de Hechos central transaccional)
CREATE TABLE ventas (
    -- id_venta: Clave primaria que identifica cada línea de facturación
    id_venta INT PRIMARY KEY,
    -- id_cliente: FK obligatoria; no puede existir una venta sin un cliente registrado
    id_cliente INT NOT NULL,
    -- id_producto: FK obligatoria; impide transaccionar artículos inexistentes en catálogo
    id_producto INT NOT NULL,
    -- cantidad: Unidades físicas vendidas (debe ser mayor a 0)
    cantidad INT NOT NULL,
    -- precio_unitario: DECIMAL(10,2) para congelar el precio histórico al momento de la venta
    precio_unitario DECIMAL(10, 2) NOT NULL,
    -- fecha_venta: Registro cronológico de la operación para análisis temporal y estacionalidad
    fecha_venta DATE NOT NULL,
    -- Restricciones de integridad referencial
    CONSTRAINT fk_ventas_clientes 
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_ventas_productos 
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


-- 4. SECCIÓN DML: CARGA INICIAL DE DATOS (INSERT)

-- El orden de inserción respeta estrictamente las dependencias:
-- 1° Categorías y Clientes (tablas maestras)
-- 2° Productos (depende de Categorías)
-- 3° Ventas (depende de Clientes y Productos)

-- 4.1. Carga de Categorías (4 registros)
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computación', 'Laptops, PCs y monitores'),
    (2, 'Accesorios', 'Periféricos y complementos'),
    (3, 'Audio', 'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');

-- 4.2. Carga de Clientes (5 registros)
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'María López',   'maria@mail.com',   'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',   'carlos@mail.com',  'Córdoba',      '2024-01-10'),
    (3, 'Ana Gómez',     'ana@mail.com',     'Rosario',      '2024-02-01'),
    (4, 'Pedro Sanz',    'pedro@mail.com',   'Mendoza',      '2024-02-15'),
    (5, 'Laura Torres',  'laura@mail.com',   'Tucumán',      '2024-03-01');

-- 4.3. Carga de Productos (6 registros)
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15',       1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',   2,   28.00, 80, 1),
    (3, 'Monitor 4K 27"',      1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro',  3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',     4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',    2,   95.00, 40, 1);

-- 4.4. Carga de Ventas (10 registros transaccionales)
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (1,  1, 1, 2, 1200.00, '2024-03-05'),
    (2,  2, 2, 5,   28.00, '2024-03-06'),
    (3,  3, 3, 1,  450.00, '2024-03-07'),
    (4,  1, 4, 2,  120.00, '2024-03-08'),
    (5,  4, 5, 3,  130.00, '2024-03-10'),
    (6,  2, 6, 4,   95.00, '2024-03-11'),
    (7,  5, 1, 1, 1200.00, '2024-03-12'),
    (8,  3, 2, 8,   28.00, '2024-03-13'),
    (9,  4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15');



-- 5. VALIDACIÓN DE CARGA Y CONSULTAS DE INTEGRIDAD

SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
