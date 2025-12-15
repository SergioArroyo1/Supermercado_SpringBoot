DROP TABLE DETALLE CASCADE CONSTRAINTS;
DROP TABLE FACTURA CASCADE CONSTRAINTS;
DROP TABLE PRODUCTO CASCADE CONSTRAINTS;
DROP TABLE CLIENTE CASCADE CONSTRAINTS;

DROP TYPE tDetalle FORCE;
DROP TYPE tFactura FORCE;
DROP TYPE tProducto FORCE;
DROP TYPE tColores FORCE;
DROP TYPE tDomicilio FORCE;



CREATE USER arroyo IDENTIFIED BY 1234;

GRANT DBA TO arroyo;

-- ELIMINAR USUARIO (SI EXISTE)
------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP USER arroyo CASCADE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------
-- TIPO tDomicilio
------------------------------------------------
CREATE OR REPLACE TYPE tDomicilio AS OBJECT (
    calle VARCHAR2(50),
    numero INT,
    piso INT,
    escalera INT,
    puerta CHAR(2),
    MEMBER FUNCTION getDomicilio RETURN VARCHAR2
);
/ 

CREATE OR REPLACE TYPE BODY tDomicilio AS
    MEMBER FUNCTION getDomicilio RETURN VARCHAR2 IS
    BEGIN
        RETURN calle || ' ' || numero || ' Piso: ' || piso ||
               ' Escalera: ' || escalera || ' Puerta: ' || puerta;
    END;
END;
/

------------------------------------------------
-- TABLA CLIENTE
------------------------------------------------
CREATE TABLE CLIENTE (
    NIF CHAR(9) PRIMARY KEY,
    NOMBRE VARCHAR2(50),
    DOMICILIO tDomicilio,
    TLF VARCHAR2(25),
    CIUDAD VARCHAR2(25)
);

------------------------------------------------
-- INSERTS CLIENTE
------------------------------------------------
INSERT INTO CLIENTE VALUES ('55555555D','ANA GOMEZ MARTINEZ',
    tDomicilio('Marte',12,2,1,'B'),'912345678','BARCELONA');

INSERT INTO CLIENTE VALUES ('66666666E','JORGE RAMIREZ LOPEZ',
    tDomicilio('Estrella',45,1,2,'C'),'623456789','VALENCIA');

INSERT INTO CLIENTE VALUES ('77777777F','LAURA FERNANDEZ SANTOS',
    tDomicilio('Cometa',33,4,3,'A'),'634567890','MALAGA');

INSERT INTO CLIENTE VALUES ('88888888G','MARIO PEREZ ORTIZ',
    tDomicilio('Galaxia',7,3,1,'D'),'645678901','ZARAGOZA');

------------------------------------------------
-- TIPO VARRAY tColores
------------------------------------------------
CREATE OR REPLACE TYPE tColores AS VARRAY(10) OF VARCHAR2(20);
/

------------------------------------------------
-- TIPO tProducto
------------------------------------------------
CREATE OR REPLACE TYPE tProducto AS OBJECT (
    codigo CHAR(4),
    descripcion VARCHAR2(100),
    colores tColores,
    precio FLOAT,
    stock INTEGER,
    minimo INTEGER,
    MEMBER FUNCTION getReponer RETURN INTEGER,
    MEMBER FUNCTION getRecaudacion RETURN FLOAT,
    MEMBER FUNCTION getColores RETURN VARCHAR2,
    MEMBER FUNCTION getColoresCount RETURN INTEGER,
    MEMBER FUNCTION getColoresFirst RETURN VARCHAR2
);
/ 

CREATE OR REPLACE TYPE BODY tProducto AS
    MEMBER FUNCTION getReponer RETURN INTEGER IS
    BEGIN
        IF stock < minimo THEN
            RETURN minimo - stock;
        ELSE
            RETURN 0;
        END IF;
    END;

    MEMBER FUNCTION getRecaudacion RETURN FLOAT IS
    BEGIN
        RETURN precio * stock;
    END;

    MEMBER FUNCTION getColores RETURN VARCHAR2 IS
        cadena VARCHAR2(200);
        i INT := 1;
    BEGIN
        cadena := 'Disponible en ';
        LOOP
            cadena := cadena || colores(i) || ' ';
            EXIT WHEN i = colores.COUNT;
            i := i + 1;
        END LOOP;
        RETURN cadena;
    END;

    MEMBER FUNCTION getColoresCount RETURN INTEGER IS
    BEGIN
        RETURN colores.COUNT;
    END;

    MEMBER FUNCTION getColoresFirst RETURN VARCHAR2 IS
    BEGIN
        RETURN colores(1);
    END;
END;
/

------------------------------------------------
-- TABLA PRODUCTO
------------------------------------------------
CREATE TABLE PRODUCTO OF tProducto;
ALTER TABLE PRODUCTO ADD PRIMARY KEY (codigo);

------------------------------------------------
-- INSERTS PRODUCTO
------------------------------------------------
INSERT INTO PRODUCTO VALUES ('CHA1','CHANDAL NIÑO 5-6 AÑOS',
    tColores('Amarillo','Azul','Verde'),20.50,5,8);

INSERT INTO PRODUCTO VALUES ('CHA2','CHANDAL NIÑO 7-8 AÑOS',
    tColores('Rosa','Azul','Gris'),22.00,6,9);

INSERT INTO PRODUCTO VALUES ('COR1','CORTA VIENTOS HOMBRE',
    tColores('Negro','Azul'),18,4,6);

INSERT INTO PRODUCTO VALUES ('CORM','CORTA VIENTOS MUJER',
    tColores('Rojo','Blanco'),19,5,7);

INSERT INTO PRODUCTO VALUES ('PA1','PANTALON CORTO 8-9 AÑOS',
    tColores('Rojo','Amarillo','Verde','Azul'),12,7,10);

INSERT INTO PRODUCTO VALUES ('PA2','PANTALON CORTO 10-11 AÑOS',
    tColores('Negro','Azul','Rosa','Verde'),14,3,8);

INSERT INTO PRODUCTO VALUES ('BAF1','BALON FUTBOL Nº 3',
    tColores('Blanco','Negro'),8,6,10);

INSERT INTO PRODUCTO VALUES ('BAF2','BALON FUTBOL Nº 4',
    tColores('Blanco','Amarillo'),7,4,9);

INSERT INTO PRODUCTO VALUES ('BAB1','BALON BALONCESTO Nº 5',
    tColores('Naranja','Negro'),9,5,8);

INSERT INTO PRODUCTO VALUES ('BAB2','BALON BALONCESTO Nº 6',
    tColores('Azul','Blanco'),10,2,5);

INSERT INTO PRODUCTO VALUES ('BI1','BICICLETA 16 PULGADAS',
    tColores('Rojo','Negro'),120,3,5);

------------------------------------------------
-- TIPO tFactura
------------------------------------------------
CREATE OR REPLACE TYPE tFactura AS OBJECT (
    numero INT,
    fecha DATE,
    nif CHAR(9),
    MEMBER FUNCTION getFactura RETURN VARCHAR2
);
/ 

CREATE OR REPLACE TYPE BODY tFactura AS
    MEMBER FUNCTION getFactura RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Factura nº ' || numero || ' - ' || fecha || ' - ' || nif;
    END;
END;
/

------------------------------------------------
-- TABLA FACTURA
------------------------------------------------
CREATE TABLE FACTURA OF tFactura;
ALTER TABLE FACTURA ADD PRIMARY KEY (numero);
ALTER TABLE FACTURA ADD FOREIGN KEY (nif) REFERENCES CLIENTE(nif);

------------------------------------------------
-- INSERTS FACTURA
------------------------------------------------
INSERT INTO FACTURA VALUES (6000, DATE '2023-01-10', '55555555D');
INSERT INTO FACTURA VALUES (6001, DATE '2023-01-11', '55555555D');
INSERT INTO FACTURA VALUES (6002, DATE '2023-02-12', '66666666E');
INSERT INTO FACTURA VALUES (6003, DATE '2023-02-15', '66666666E');
INSERT INTO FACTURA VALUES (6004, DATE '2023-03-20', '77777777F');
INSERT INTO FACTURA VALUES (6005, DATE '2023-03-22', '88888888G');

------------------------------------------------
-- TIPO tDetalle
------------------------------------------------
CREATE OR REPLACE TYPE tDetalle AS OBJECT (
    idetalle INTEGER,
    numero INTEGER,
    codigo CHAR(4),
    unidades INTEGER,
    precio FLOAT,
    MEMBER FUNCTION subtotal RETURN FLOAT,
    MEMBER FUNCTION informa RETURN VARCHAR2
);
/ 

CREATE OR REPLACE TYPE BODY tDetalle AS
    MEMBER FUNCTION subtotal RETURN FLOAT IS
    BEGIN
        RETURN precio * unidades;
    END;

    MEMBER FUNCTION informa RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Venta de ' || unidades || ' unidades del artículo ' || codigo;
    END;
END;
/

------------------------------------------------
-- TABLA DETALLE
------------------------------------------------
CREATE TABLE DETALLE OF tDetalle;
ALTER TABLE DETALLE ADD PRIMARY KEY (idetalle);
ALTER TABLE DETALLE ADD FOREIGN KEY (numero) REFERENCES FACTURA(numero);
ALTER TABLE DETALLE ADD FOREIGN KEY (codigo) REFERENCES PRODUCTO(codigo);

------------------------------------------------
-- INSERTS DETALLE
------------------------------------------------
INSERT INTO DETALLE VALUES (101, 6000, 'CHA1', 2, 20.50);
INSERT INTO DETALLE VALUES (102, 6000, 'CHA2', 1, 22.00);
INSERT INTO DETALLE VALUES (103, 6000, 'BAF1', 3, 8);
INSERT INTO DETALLE VALUES (104, 6001, 'BI1', 1, 120);
INSERT INTO DETALLE VALUES (105, 6001, 'BAB1', 2, 9);
INSERT INTO DETALLE VALUES (106, 6002, 'PA1', 2, 12);
INSERT INTO DETALLE VALUES (107, 6002, 'PA2', 1, 14);
INSERT INTO DETALLE VALUES (108, 6003, 'BAB2', 3, 10);
INSERT INTO DETALLE VALUES (109, 6004, 'COR1', 2, 18);
INSERT INTO DETALLE VALUES (110, 6004, 'CORM', 1, 19);
INSERT INTO DETALLE VALUES (111, 6005, 'BAF2', 2, 7);
INSERT INTO DETALLE VALUES (112, 6005, 'BAB1', 1, 9);



