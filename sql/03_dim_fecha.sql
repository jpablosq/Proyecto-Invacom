
CREATE TABLE DIM_FECHA (
    fecha_key NUMBER(8) NOT NULL,
    fecha DATE NOT NULL,
    dia NUMBER(2) NOT NULL,
    mes NUMBER(2) NOT NULL,
    nombre_mes VARCHAR2(15 CHAR) NOT NULL,
    trimestre NUMBER(1) NOT NULL,
    anio NUMBER(4) NOT NULL,
    dia_semana VARCHAR2(15 CHAR) NOT NULL,

    CONSTRAINT pk_dim_fecha PRIMARY KEY (fecha_key),
    CONSTRAINT uq_dim_fecha UNIQUE (fecha),
    CONSTRAINT ck_dim_fecha_mes CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT ck_dim_fecha_trimestre CHECK (trimestre BETWEEN 1 AND 4)
);
