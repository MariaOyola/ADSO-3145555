-- Sistema de Cafetin

/* Modelo 1: Parameter
   - type_document
   - person*/

CREATE DATABASE Cafetin;

\c Cafetin;

-- Activar extensión para UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE type_document (
    id_type_document UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- genera el ID automáticamente. 
    code VARCHAR(10) NOT NULL UNIQUE, -- UUID  tipo de dato universal único.
    name VARCHAR(60) NOT NULL,
    state BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE person ( 
    id_person UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    id_type_document UUID NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(120) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_person_type_doc 
        FOREIGN KEY (id_type_document)
        REFERENCES type_document (id_type_document)
);


INSERT INTO type_document (code, name) VALUES ('CC', 'Cedula');
INSERT INTO type_document (code, name) VALUES ('TI', 'Tarjeta Identidad');
INSERT INTO type_document (code, name) VALUES ('CE', 'Cedula Extranjeria');
INSERT INTO type_document (code, name) VALUES ('PA', 'Pasaporte');
INSERT INTO type_document (code, name) VALUES ('RC', 'Registro Civil');
INSERT INTO type_document (code, name) VALUES ('NIT', 'Numero Tributario');
INSERT INTO type_document (code, name) VALUES ('DNI', 'Documento Nacional');
INSERT INTO type_document (code, name) VALUES ('LIC', 'Licencia Conducir');
INSERT INTO type_document (code, name) VALUES ('SSN', 'Seguro Social');
INSERT INTO type_document (code, name) VALUES ('OTR', 'Otro');


INSERT INTO person (name, last_name, id_type_document, phone, email)
VALUES 
('Maria', 'Lopez', (SELECT id_type_document FROM type_document WHERE code='CC'), '3001111111', 'maria1@gmail.com'),
('Juan', 'Perez', (SELECT id_type_document FROM type_document WHERE code='TI'), '3002222222', 'juan2@gmail.com'),
('Ana', 'Gomez', (SELECT id_type_document FROM type_document WHERE code='CE'), '3003333333', 'ana3@gmail.com'),
('Carlos', 'Rodriguez', (SELECT id_type_document FROM type_document WHERE code='PA'), '3004444444', 'carlos4@gmail.com'),
('Laura', 'Martinez', (SELECT id_type_document FROM type_document WHERE code='RC'), '3005555555', 'laura5@gmail.com'),
('Andres', 'Torres', (SELECT id_type_document FROM type_document WHERE code='NIT'), '3006666666', 'andres6@gmail.com'),
('Sofia', 'Ramirez', (SELECT id_type_document FROM type_document WHERE code='DNI'), '3007777777', 'sofia7@gmail.com'),
('Diego', 'Morales', (SELECT id_type_document FROM type_document WHERE code='LIC'), '3008888888', 'diego8@gmail.com'),
('Valentina', 'Castro', (SELECT id_type_document FROM type_document WHERE code='SSN'), '3009999999', 'valentina9@gmail.com'),
('Mateo', 'Herrera', (SELECT id_type_document FROM type_document WHERE code='OTR'), '3010000000', 'mateo10@gmail.com');
		 




  

 
  


   

