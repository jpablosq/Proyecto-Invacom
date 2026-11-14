SELECT COUNT(*) FROM DIM_VENDEDOR;

SELECT jobTitle, COUNT(*) FROM DIM_VENDEDOR GROUP BY jobTitle ORDER BY jobTitle;

SELECT territorio_oficina, COUNT(*) FROM DIM_VENDEDOR GROUP BY territorio_oficina ORDER BY territorio_oficina;

SELECT vendedor_key, employeeNumber, firstName, lastName, jobTitle, ciudad_oficina FROM DIM_VENDEDOR WHERE employeeNumber IN (0, 1102) ORDER BY employeeNumber;


UPDATE DIM_VENDEDOR
SET email = 'No especificado',
    officeCode = '0',
    ciudad_oficina = 'No especificado',
    pais_oficina = 'No especificado',
    territorio_oficina = 'No especificado'
WHERE vendedor_key = 0;

COMMIT;


SELECT COUNT(*)                AS filas,
       SUM(cantidad)           AS total_cantidad,
       SUM(importe_total)      AS total_importe,
       SUM(costo_total)        AS total_costo,
       SUM(margen)             AS total_margen,
       SUM(CASE WHEN estado_pedido = 'Cancelled' THEN 1 ELSE 0 END) AS lineas_canceladas
FROM fact_ventas;


SELECT COUNT(*)                     AS filas,
       SUM(monto)                   AS total_monto,
       COUNT(DISTINCT cliente_key)  AS clientes,
       MIN(fecha_key)               AS primera_fecha,
       MAX(fecha_key)               AS ultima_fecha
FROM fact_pagos;


SELECT 'DIM_CLIENTE'  AS tabla, COUNT(*) AS filas FROM dim_cliente  UNION ALL
SELECT 'DIM_PRODUCTO',          COUNT(*)          FROM dim_producto UNION ALL
SELECT 'DIM_FECHA',             COUNT(*)          FROM dim_fecha    UNION ALL
SELECT 'DIM_VENDEDOR',          COUNT(*)          FROM dim_vendedor UNION ALL
SELECT 'FACT_VENTAS',           COUNT(*)          FROM fact_ventas  UNION ALL
SELECT 'FACT_PAGOS',            COUNT(*)          FROM fact_pagos;