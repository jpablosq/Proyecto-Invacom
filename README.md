# Data Warehouse de Invacom Inc. S. A.

Proyecto 1 del curso Minería de Datos, Universidad Técnica Nacional, Sede Regional de San Carlos, 2026.

Integrantes: Edgar Eliam Araya Alvarado y José Pablo Soto Quesada.

Herramientas: Pentaho Data Integration 9.4 (Kettle), Oracle Database XE, SQL Developer, Microsoft Excel, Git y GitHub.

## Objetivo

Construir un Data Warehouse con los datos de ventas de la base Classic Models, cargado con procesos ETL de Pentaho, para analizar las ventas y los pagos de Invacom con tablas dinámicas de Excel conectadas a Oracle.

## Modelo dimensional

Se utiliza un modelo de constelación de hechos (Kimball y Ross, 2013):

- Dimensiones: DIM_CLIENTE, DIM_PRODUCTO, DIM_FECHA y DIM_VENDEDOR.
- FACT_VENTAS: una fila por cada línea de pedido, con cantidad, importe, costo y margen.
- FACT_PAGOS: una fila por cada pago, con su monto.
- Cliente y fecha son dimensiones compartidas por las dos tablas de hechos.

### Conteos verificados

| Tabla | Filas |
|---|---:|
| DIM_CLIENTE | 122 |
| DIM_PRODUCTO | 110 |
| DIM_FECHA | 1.096 |
| DIM_VENDEDOR | 24 (23 empleados y el registro desconocido con clave 0) |
| FACT_VENTAS | 2.996 |
| FACT_PAGOS | 273 |

Si se cambian los datos de origen, hay que volver a ejecutar las consultas de validación.

## Carpetas

```text
base_datos/          Archivos CSV de origen y products_limpio.csv (staging)
etl/                 Transformaciones de Pentaho (.ktr) y Job de carga (.kjb)
sql/                 Creación de dimensiones y hechos, y consultas de validación
documentacion/       Documento del proyecto y diagrama del modelo dimensional
excel/               Libro de reportes conectado a Oracle
evidencias/          Capturas de ejecución, validación y reportes
```

## Cómo ejecutar el proyecto

1. Instalar Oracle XE y crear el usuario `INVACOM_DW` en el servicio `XEPDB1` con `sql/ELIAM/Invacom_Admin.sql`, cambiando `TU_CONTRASEÑA` por una contraseña propia.
2. Con el usuario `INVACOM_DW`, ejecutar en orden los archivos `sql/01_dim_cliente.sql` a `sql/06_fact_pagos.sql`.
3. Instalar Pentaho Data Integration 9.4 y copiar el driver `ojdbc11.jar` en la carpeta `data-integration/lib`.
4. Agregar al archivo `kettle.properties` de la computadora (en la carpeta `.kettle` del usuario) la línea `INVACOM_DW_PASSWORD=` con la contraseña de Oracle. Las transformaciones leen la contraseña de esa variable, por lo que no se guarda en el repositorio. No se deben subir contraseñas a GitHub.
5. Abrir `etl/Carga_Invacom.kjb` en Spoon y ejecutar el Job. La conexión `INVACOM_DW` usa la URL `jdbc:oracle:thin:@//localhost:1521/XEPDB1`.
6. Ejecutar `sql/07_validacion.sql` en SQL Developer y comparar los resultados con las capturas de `evidencias/`.
7. Abrir `excel/Invacom_Reportes.xlsx`, actualizar los datos y revisar los reportes.

El libro de Excel se conecta al Oracle XE local con Power Query. En otra computadora hay que instalar un cliente de Oracle compatible con la versión de Excel (32 o 64 bits) e ingresar el usuario y la contraseña de Oracle al actualizar.

## Validación

- FACT_VENTAS tiene 2.996 líneas, con un importe de USD 9.604.190,61 y un margen bruto estimado de USD 3.825.880,25.
- FACT_PAGOS tiene 273 pagos, que suman USD 8.853.839,23.
- Los 6 pedidos cancelados (79 líneas) se conservan en el DW con su estado. Sin ellos, las ventas suman USD 9.365.336,43 y el margen USD 3.731.511,97.
- Entre las compras sin cancelados y los pagos hay una diferencia de USD 511.497,20. Hay 98 clientes con compras y 98 con pagos.
- Las consultas de integridad, ventas por año, pedidos por estado, margen por línea de producto, pagos por año, compras contra pagos y ventas por vendedor están en `sql/07_validacion.sql`.

## Reportes de Excel

| Hoja | Reporte | Pedidos cancelados |
|---|---|---|
| 01_Ventas_Anuales | Ventas por año | Excluidos |
| 02_Ventas_Categorias | Ventas por línea de producto | Excluidos |
| 03_Ventas_Vendedores | 10 vendedores con más ventas, con filtro por territorio | Excluidos |
| 04_Pagos_Anuales | Pagos recibidos por año | No aplica |
| 05_Ventas_vs_Pagos | Ventas y pagos por año | Excluidos de las ventas |
| 06_Margen_Categorias | Ventas y margen bruto por línea de producto | Excluidos |
| 07_Pedidos_Estado | Pedidos e importe por estado | Incluidos |

Los reportes que excluyen los cancelados tienen el filtro "Estado del pedido" sobre la tabla dinámica. Se puede cambiar para incluirlos.

## Trabajo en equipo

El trabajo se organizó en cuatro iteraciones de una semana. José Pablo Soto Quesada fue el Scrum Master. Los avances y las revisiones semanales se coordinaron por WhatsApp. No se utilizó un tablero Kanban, por lo que el reparto de tareas quedó en los mensajes del grupo y en los commits.

| Iteración | Fechas (2026) | Actividades | Commits |
|---|---|---|---|
| 1 | 21 al 25 de octubre | Repositorio, archivos CSV y primer modelo dimensional | 2 |
| 2 | 26 de octubre al 1 de noviembre | Fuentes y calidad de datos, limpieza de productos en Pentaho, modelo con pagos y tablas en Oracle | 6 |
| 3 | 2 al 8 de noviembre | Carga de dimensiones y hechos, Job de carga completa y validación de integridad, ventas y márgenes | 5 |
| 4 | 9 al 13 de noviembre | Validaciones de pagos y vendedores, reportes de Excel, documentación y README | 3 |

En total se realizaron 16 commits, 8 de cada integrante.

## Notas

- Los montos están en dólares estadounidenses, como indicó el profesor del curso.
- El margen es una estimación bruta (precio de venta menos costo de compra) y no incluye otros gastos.
- Las ventas y los pagos son eventos distintos. No se deben unir fila por fila, porque las filas se multiplican. Se suman por separado y después se comparan por cliente o por fecha.

## Referencias

- Kimball, R. y Caserta, J. (2004). The data warehouse ETL toolkit: Practical techniques for extracting, cleaning, conforming, and delivering data. Wiley.
- Kimball, R. y Ross, M. (2013). The data warehouse toolkit: The definitive guide to dimensional modeling (3.ª ed.). Wiley.
- Universidad Técnica Nacional. (2026). Proyecto #1 Minería de datos 3C2026 [Enunciado del proyecto]. Sede Regional de San Carlos.

Las demás fuentes, incluidos los videos de Pentaho, están en la bibliografía de `documentacion/Proyecto1_Invacom.docx`.
