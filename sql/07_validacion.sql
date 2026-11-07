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
