-- Base de Datos: Ventas_Tech_DB
-- Entrega: Módulo 5 — Consultas con JOINs para el proyecto


-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Objetivo: Vista desnormalizada para Power BI que combina ventas, clientes, productos y categorías en un único conjunto de datos.
-- Contiene: fecha, identificación/nombre del cliente, descripción del producto, categoría, ciudad/región, cantidad, precio unitario y total.

SELECT 
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS region_cliente,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c 
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat 
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta ASC;


-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Objetivo: Identificar clientes registrados en la base que todavía no tienen compras asociadas en la tabla ventas para acciones de CRM.

SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v 
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Objetivo: Identificar artículos del catálogo sin movimiento comercial  para que el área de producto revise stock o discontinuaciones.

SELECT 
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat 
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v 
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Consulta 4 — Consolidado por canal (UNION ALL)
-- Objetivo: Simular la segmentación de canales ('Online' vs 'Presencial') mediante literales dentro de dos SELECTs sobre ventas, apilándolos con UNION ALL y agrupando para obtener la facturación total por canal.

SELECT 
    canal,
    SUM(total) AS total_canal
FROM (
    -- Subconsulta 1: Canal Online (ejemplo: ventas de la primera mitad del período / IDs impares)
    SELECT 
        fecha_venta,
        (cantidad * precio_unitario) AS total,
        'Online' AS canal
    FROM ventas
    WHERE id_venta % 2 <> 0

    UNION ALL

    -- Subconsulta 2: Canal Presencial (ejemplo: IDs pares)
    SELECT 
        fecha_venta,
        (cantidad * precio_unitario) AS total,
        'Presencial' AS canal
    FROM ventas
    WHERE id_venta % 2 = 0
) AS consolidado
GROUP BY canal;
