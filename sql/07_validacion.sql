-- Resultado esperado: 0 registros huérfanos
SELECT 'ventas-cliente' AS relacion, COUNT(*) AS huerfanas
FROM fact_ventas v
LEFT JOIN dim_cliente c ON v.cliente_key = c.cliente_key
WHERE c.cliente_key IS NULL

UNION ALL

SELECT 'ventas-producto', COUNT(*)
FROM fact_ventas v
LEFT JOIN dim_producto p ON v.producto_key = p.producto_key
WHERE p.producto_key IS NULL

UNION ALL

SELECT 'ventas-fecha', COUNT(*)
FROM fact_ventas v
LEFT JOIN dim_fecha f ON v.fecha_key = f.fecha_key
WHERE f.fecha_key IS NULL

UNION ALL

SELECT 'ventas-vendedor', COUNT(*)
FROM fact_ventas v
LEFT JOIN dim_vendedor e ON v.vendedor_key = e.vendedor_key
WHERE e.vendedor_key IS NULL

UNION ALL

SELECT 'pagos-cliente', COUNT(*)
FROM fact_pagos g
LEFT JOIN dim_cliente c ON g.cliente_key = c.cliente_key
WHERE c.cliente_key IS NULL

UNION ALL

SELECT 'pagos-fecha', COUNT(*)
FROM fact_pagos g
LEFT JOIN dim_fecha f ON g.fecha_key = f.fecha_key
WHERE f.fecha_key IS NULL

UNION ALL

SELECT 'ventas sin vendedor (clave 0)', COUNT(*)
FROM fact_ventas
WHERE vendedor_key = 0;


-- Incluye todos los estados de pedidos
SELECT f.anio,
       SUM(v.importe_total) AS importe,
       SUM(v.cantidad) AS unidades
FROM fact_ventas v
JOIN dim_fecha f ON v.fecha_key = f.fecha_key
GROUP BY f.anio
ORDER BY f.anio;


-- Ventas por año sin pedidos cancelados
SELECT f.anio,
       SUM(v.importe_total) AS importe,
       SUM(v.cantidad) AS unidades
FROM fact_ventas v
JOIN dim_fecha f ON v.fecha_key = f.fecha_key
WHERE v.estado_pedido <> 'Cancelled'
GROUP BY f.anio
ORDER BY f.anio;


-- Pedidos e importe por estado
-- Pregunta de negocio 9
-- Incluye los pedidos cancelados para su análisis
SELECT estado_pedido,
       COUNT(DISTINCT orderNumber) AS pedidos,
       COUNT(*) AS lineas,
       SUM(importe_total) AS importe
FROM fact_ventas
GROUP BY estado_pedido
ORDER BY importe DESC;



-- Importe y margen por línea de producto
-- Preguntas de negocio 2 y 11
-- Incluye todos los estados de los pedidos
SELECT p.productLine,
       SUM(v.importe_total) AS importe,
       SUM(v.margen) AS margen
FROM fact_ventas v
JOIN dim_producto p
  ON v.producto_key = p.producto_key
GROUP BY p.productLine
ORDER BY importe DESC;



-- Pagos recibidos por año
-- Validación de FACT_PAGOS
SELECT f.anio,
       COUNT(*) AS cantidad_pagos,
       ROUND(SUM(p.monto), 2) AS total_pagos
FROM fact_pagos p
JOIN dim_fecha f
  ON p.fecha_key = f.fecha_key
GROUP BY f.anio
ORDER BY f.anio;


-- Excluye pedidos cancelados
WITH compras AS (
    SELECT cliente_key,
           SUM(importe_total) AS total_compras
    FROM fact_ventas
    WHERE estado_pedido <> 'Cancelled'
    GROUP BY cliente_key
),
pagos AS (
    SELECT cliente_key,
           SUM(monto) AS total_pagos
    FROM fact_pagos
    GROUP BY cliente_key
)
SELECT
    c.customerNumber,
    c.customerName,
    NVL(co.total_compras, 0) AS total_compras,
    NVL(pa.total_pagos, 0) AS total_pagos,
    NVL(co.total_compras, 0)
      - NVL(pa.total_pagos, 0) AS diferencia
FROM dim_cliente c
LEFT JOIN compras co
    ON c.cliente_key = co.cliente_key
LEFT JOIN pagos pa
    ON c.cliente_key = pa.cliente_key
ORDER BY diferencia DESC;


-- Incluye todos los estados de pedidos
SELECT
    d.vendedor_key,
    d.firstName || ' ' || d.lastName AS vendedor,
    d.territorio_oficina AS territorio,
    COUNT(DISTINCT v.orderNumber) AS pedidos,
    SUM(v.importe_total) AS importe_total,
    SUM(v.margen) AS margen_total
FROM fact_ventas v
JOIN dim_vendedor d
    ON v.vendedor_key = d.vendedor_key
GROUP BY
    d.vendedor_key,
    d.firstName,
    d.lastName,
    d.territorio_oficina
ORDER BY importe_total DESC;


-- Control del importe total de ventas
SELECT
    COUNT(*) AS total_lineas,
    ROUND(SUM(importe_total), 2) AS total_ventas
FROM fact_ventas;
