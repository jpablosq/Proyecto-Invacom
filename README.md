# Data Warehouse Invacom Inc. S. A.

Proyecto académico de **Minería de Datos – Universidad Técnica Nacional, Sede Regional San Carlos (2026)**.

**Integrantes:** Edgar Eliam Araya Alvarado y José Pablo Soto Quesada.
**Herramientas:** Pentaho Data Integration 9.4 (Kettle), Oracle Database XE, SQL Developer, Microsoft Excel, Git y GitHub.

## Objetivo

Implementar un Data Warehouse que integre los datos transaccionales de Classic Models, permita analizar ventas y pagos y ofrezca reportes con tablas dinámicas conectadas a Oracle.

## Modelo dimensional

Se utiliza una **constelación de hechos**:

- **DIM_CLIENTE**, **DIM_PRODUCTO**, **DIM_FECHA**, **DIM_VENDEDOR**.
- **FACT_VENTAS:** una fila por línea de pedido; medidas de cantidad, importe, costo y margen.
- **FACT_PAGOS:** una fila por pago; medida de importe.
- Dimensiones compartidas por ambas tablas de hechos: cliente y fecha.

### Conteos verificados

| Tabla | Filas |
|---|---:|
| DIM_CLIENTE | 122 |
| DIM_PRODUCTO | 110 |
| DIM_FECHA | 1.096 |
| DIM_VENDEDOR | 24 (incluye desconocido) |
| FACT_VENTAS | 2.996 |
| FACT_PAGOS | 273 |

Las cifras corresponden a la carga validada durante el proyecto; volver a ejecutar las consultas si se modifican los datos.

## Estructura principal

```text
base_datos/          CSV fuente y archivo de staging de productos
etl/                 Transformaciones Kettle (.ktr) y Job (.kjb)
sql/                 Creación de dimensiones/hechos y consultas de validación
documentacion/       Informe académico y modelo dimensional
excel/               Libro de reportes conectados a Oracle
evidencias/          Capturas de ejecución, validación y reportes
```

## Ejecución

1. Instalar Oracle XE y crear el esquema `INVACOM_DW` en el servicio `XEPDB1`.
2. Ejecutar en orden los scripts `sql/01_dim_cliente.sql` hasta `sql/06_fact_pagos.sql` con una conexión apropiada al esquema (verificar antes de ejecutar en una base con datos).
3. Instalar Pentaho Data Integration y un driver JDBC compatible con Oracle.
4. En Pentaho, configurar `INVACOM_DW` con URL `jdbc:oracle:thin:@//localhost:1521/XEPDB1`, controlador `oracle.jdbc.OracleDriver` y usuario `INVACOM_DW`.
5. Guardar la contraseña únicamente en la configuración privada de Kettle (`kettle.properties`) como `INVACOM_DW_PASSWORD`. **Nunca publicar contraseñas ni incluirlas en archivos versionados.**
6. Abrir `etl/Carga_Invacom.kjb` en Spoon y ejecutar el Job completo.
7. Ejecutar `sql/07_validacion.sql` en SQL Developer y contrastar los resultados con las evidencias.
8. Abrir `excel/Invacom_Reportes.xlsx`, actualizar la conexión a Oracle y comprobar los reportes.

> El libro de Excel está preparado para conectarse al Oracle XE local. En otro equipo es necesario instalar un cliente Oracle compatible con la arquitectura de Excel y configurar las credenciales del usuario localmente.

## Validación

- `FACT_VENTAS`: **2.996 líneas**, importe **USD 9.604.190,61**, margen bruto estimado **USD 3.825.880,25**.
- `FACT_PAGOS`: **273 pagos**, monto **USD 8.853.839,23**.
- Pedidos cancelados: **6 pedidos**, **79 líneas**; se mantienen en el DW y pueden excluirse en los reportes por el estado del pedido.
- Validaciones de relaciones, ventas por año, estado del pedido, línea de producto, pagos por año y vendedor: `sql/07_validacion.sql`.

## Reportes de Excel

1. Ventas anuales.
2. Ventas por categoría de producto.
3. Top 10 de vendedores.
4. Pagos anuales.
5. Ventas versus pagos por año.
6. Margen por categoría.
7. Pedidos por estado.

## Equipo y evidencias de colaboración

El historial de commits y los archivos en `evidencias/` documentan etapas del trabajo. **Antes de la entrega**, agregar aquí el enlace del tablero Kanban real, el calendario de sprints y la referencia a capturas de las ceremonias/seguimiento que efectivamente se realizaron. No declarar reuniones o sprints que no tengan respaldo.

## Notas de interpretación

- Los importes son expresados en USD conforme a la definición del ejercicio.
- El margen calculado es una estimación bruta, no utilidad neta.
- Ventas y pagos corresponden a eventos diferentes y no deben unirse directamente a nivel de fila, para evitar multiplicación de registros.
