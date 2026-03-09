
-- Sistema de Cafetin

/* Modelo 1: Parameter
   - type_document
   - person*/

CREATE DATABASE Cafetin;

\c Cafetin;

-- Activar extensión para UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

--------------------------------------------------------
CREATE TABLE status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(20) NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
); 

-----------------------------------------------------------------------------
-- Module 1: Parameter   Propósito: Datos base que parametrizan el sistema.
-----------------------------------------------------------------------------
CREATE TABLE type_document ( -- tipo de documento
    id_type_document UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- genera el ID automáticamente. 
    code VARCHAR(10) NOT NULL UNIQUE, -- UUID  tipo de dato universal único.
    name VARCHAR(60) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP

);
----------------------------------------------------------------------

CREATE TABLE person ( 
    id_person UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    id_type_document UUID NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(120) UNIQUE,

    CONSTRAINT fk_person_type_doc  FOREIGN KEY (id_type_document) REFERENCES type_document (id_type_document)
);
-----------------------------------------------------------------------------
-- Modulo 2  Security Propósito: Control de acceso, roles y permisos por módulo/vista.
-----------------------------------------------------------------------------
 CREATE TABLE 	users ( -- quién usa el sistema
id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
username VARCHAR (80) NOT NULL,
password_hash VARCHAR (225) NOT NULL,
id_person UUID NOT NULL, 
id_status UUID NOT NULL,
create_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE,
deleted_at TIMESTAMP WITH TIME ZONE,

created_by   UUID,
updated_by   UUID,
deleted_by   UUID,

CONSTRAINT fk_user_person FOREIGN KEY (id_person) REFERENCES person (id_person),
CONSTRAINT fk_user_status  FOREIGN KEY (id_status)  REFERENCES status (id),
CONSTRAINT fk_created_by   FOREIGN KEY (created_by)  REFERENCES users(id_user),
CONSTRAINT fk_updated_by   FOREIGN KEY (updated_by)  REFERENCES users(id_user),
CONSTRAINT fk_deleted_by   FOREIGN KEY (deleted_by)  REFERENCES users(id_user)
 ); 
 -----------------------------------------------------------------------

CREATE TABLE roles ( ---qué tipo de usuario es
id_rol UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name_role VARCHAR(60) NOT NULL,
description VARCHAR(200),
id_status UUID NOT NULL,
create_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT fk_role_status FOREIGN KEY (id_status) REFERENCES status (id)
 
); 
-------------------------------------------------------------------------
CREATE TABLE modules ( -- qué parte del sistema puede usar el usuario
id_module UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name_module VARCHAR (80) NOT NULL,
description VARCHAR(200),
id_status UUID NOT NULL,
url_prefix VARCHAR (60),
order_num SMALLINT, 
create_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE,
deleted_at TIMESTAMP WITH TIME ZONE,

created_by   UUID,
updated_by   UUID,
deleted_by   UUID,

CONSTRAINT fk_module_status FOREIGN KEY (id_status) REFERENCES status (id),
CONSTRAINT fk_created_by   FOREIGN KEY (created_by)  REFERENCES users(id_user),
CONSTRAINT fk_updated_by   FOREIGN KEY (updated_by)  REFERENCES users(id_user),
CONSTRAINT fk_deleted_by   FOREIGN KEY (deleted_by)  REFERENCES users(id_user)
); 

---------------------------------------------------------------------------------

CREATE TABLE views_ ( -- las pantallas que puede ver el ususario
id_view UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name_view VARCHAR(80) NOT NULL,
url VARCHAR(200) NOT NULL,
description VARCHAR(200),
order_num SMALLINT,
id_status UUID NOT NULL,
created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE,
deleted_at TIMESTAMP WITH TIME ZONE,

created_by   UUID,
updated_by   UUID,
deleted_by   UUID,

CONSTRAINT fk_view_status FOREIGN KEY (id_status) REFERENCES status (id),
CONSTRAINT fk_created_by   FOREIGN KEY (created_by)  REFERENCES users(id_user),
CONSTRAINT fk_updated_by   FOREIGN KEY (updated_by)  REFERENCES users(id_user),
CONSTRAINT fk_deleted_by   FOREIGN KEY (deleted_by)  REFERENCES users(id_user)
);

----------------------------------------------------------------------------------------
CREATE TABLE user_role (
    id_user UUID NOT NULL,
    id_rol UUID NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    assigned_by UUID,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	created_by   UUID,

 PRIMARY KEY (id_user, id_rol),
CONSTRAINT fk_ur_user   FOREIGN KEY (id_user)      REFERENCES users (id_user),
CONSTRAINT fk_ur_role   FOREIGN KEY (id_rol)       REFERENCES roles (id_rol),
CONSTRAINT fk_ur_by     FOREIGN KEY (assigned_by)  REFERENCES users (id_user),
CONSTRAINT fk_created_by   FOREIGN KEY (created_by)  REFERENCES users(id_user)

);
---------------------------------------------------------------------------
CREATE TABLE role_module (
    id_rol UUID NOT NULL,
    id_module UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	created_by   UUID,
	

    PRIMARY KEY (id_rol, id_module),
	CONSTRAINT fk_rm_role  FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    CONSTRAINT fk_rm_module FOREIGN KEY (id_module) REFERENCES modules(id_module),
	CONSTRAINT fk_created_by   FOREIGN KEY (created_by)  REFERENCES users(id_user)
);
-----------------------------------------------------------------------------
CREATE TABLE module_view (
    id_module UUID NOT NULL,
    id_view UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	created_by   UUID,

    PRIMARY KEY (id_module, id_view),
    CONSTRAINT fk_mv_module FOREIGN KEY (id_module) REFERENCES modules(id_module),
    CONSTRAINT fk_mv_view FOREIGN KEY (id_view) REFERENCES views_ (id_view),
	CONSTRAINT fk_created_by   FOREIGN KEY (created_by)  REFERENCES users(id_user)
);
--------------------------------------------------------------------------------
-- MODULE 3: INVENTORY  Propósito: Catálogo de productos y su disponibilidad visible al cliente.
---------------------------------------------------------------------------------
CREATE TABLE category (
    id_category UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_category VARCHAR(80) NOT NULL,
    description VARCHAR(200),
    id_status UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,

	created_by   UUID,
    updated_by   UUID,
    deleted_by   UUID,

    CONSTRAINT fk_category_status FOREIGN KEY (id_status) REFERENCES status (id),
	CONSTRAINT fk_created_by   FOREIGN KEY (created_by)  REFERENCES users(id_user),
    CONSTRAINT fk_updated_by   FOREIGN KEY (updated_by)  REFERENCES users(id_user),
    CONSTRAINT fk_deleted_by   FOREIGN KEY (deleted_by)  REFERENCES users(id_user)
);
-------------------------------------------------------------------------------

CREATE TABLE product (
    id_product UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_product VARCHAR(120) NOT NULL,
    description VARCHAR(200),
    price NUMERIC(10,2),
    id_category UUID NOT NULL,
    id_status UUID NOT NULL,
	-- cuando se creo, actualizo y elimino el producto
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    --  quien creo, actualizo y elimino el producto
	created_by   UUID,
    updated_by   UUID,
    deleted_by   UUID,

   CONSTRAINT fk_product_category FOREIGN KEY (id_category) REFERENCES category(id_category),
   CONSTRAINT fk_product_status   FOREIGN KEY (id_status)   REFERENCES status   (id), 
   CONSTRAINT fk_created_by       FOREIGN KEY (created_by)  REFERENCES users(id_user),
   CONSTRAINT fk_updated_by       FOREIGN KEY (updated_by)  REFERENCES users(id_user),
   CONSTRAINT fk_deleted_by       FOREIGN KEY (deleted_by)  REFERENCES users(id_user)
);
-------------------------------------------------------------------------------------------
--  MODULE 4: SALES  Propósito: Carrito temporal, confirmación y gestión de pedidos.
--------------------------------------------------------------------------------------------
CREATE TABLE cart ( -- el carrito
    id_cart UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,

    created_by UUID,
    updated_by UUID,
    deleted_by UUID,

    CONSTRAINT fk_cart_user FOREIGN KEY (id_user) REFERENCES users (id_user),
    CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES users(id_user),
    CONSTRAINT fk_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user),
    CONSTRAINT fk_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user)
);

----------------------------------------------------------------------------------------------
CREATE TABLE cart_item ( -- lo que hay dentro del carrito
    id_cart_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_cart UUID NOT NULL,
    id_product UUID NOT NULL,
    quantity INT,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,

	created_by   UUID,
    updated_by   UUID,
    deleted_by   UUID,
	
    CONSTRAINT fk_ci_cart    FOREIGN KEY (id_cart)    REFERENCES cart    (id_cart),
    CONSTRAINT fk_ci_product FOREIGN KEY (id_product) REFERENCES product (id_product),
	CONSTRAINT fk_created_by FOREIGN KEY (created_by)  REFERENCES users(id_user),
    CONSTRAINT fk_updated_by FOREIGN KEY (updated_by)  REFERENCES users(id_user),
    CONSTRAINT fk_deleted_by FOREIGN KEY (deleted_by)  REFERENCES users(id_user)
);
------------------------------------------------------------------------------------------------
CREATE TABLE orders (
    id_order    UUID          PRIMARY KEY DEFAULT gen_random_uuid(), -- FIX 1: SERIAL → UUID
    id_user     UUID          NOT NULL,                             -- FIX 2: INT → UUID
    client_name VARCHAR(100)  NOT NULL,
    id_status   UUID          NOT NULL,
    total       NUMERIC(10,2) NOT NULL DEFAULT 0,
    notes       TEXT,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, -- FIX 3: tipo consistente con el resto
    updated_at  TIMESTAMP WITH TIME ZONE,

    created_by  UUID,
    updated_by  UUID,

    CONSTRAINT fk_order_user   FOREIGN KEY (id_user)    REFERENCES users  (id_user),
    CONSTRAINT fk_order_status FOREIGN KEY (id_status)  REFERENCES status (id),
    CONSTRAINT fk_created_by   FOREIGN KEY (created_by) REFERENCES users  (id_user),
    CONSTRAINT fk_updated_by   FOREIGN KEY (updated_by) REFERENCES users  (id_user) -- FIX 4: coma suelta al final eliminada
);

-------------------------------------------------------------------------------------------------
CREATE TABLE order_item (
    id_order_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_order UUID NOT NULL,
    id_product UUID NOT NULL,
    quantity INT,
    unit_price NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,

    CONSTRAINT fk_oi_order FOREIGN KEY (id_order) REFERENCES orders(id_order),
    CONSTRAINT fk_oi_product FOREIGN KEY (id_product) REFERENCES product(id_product),
    CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES users(id_user)
);
-------------------------------------------------------------------------------------------------------------
--- MODULE 5: BILLING,  Propósito: Métodos de pago, facturación y registro de pagos.
--------------------------------------------------------------------------------------------------------------
CREATE TABLE method_payment (
    id_method UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_method VARCHAR(60) NOT NULL UNIQUE,
    description VARCHAR(200),
    id_status   UUID   NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, 

	created_by   UUID,

	CONSTRAINT fk_method_status FOREIGN KEY (id_status) REFERENCES status(id),
	CONSTRAINT fk_created_by FOREIGN KEY (created_by)  REFERENCES users(id_user)
);

-----------------------------------------------------------------------------------------------------------------

CREATE TABLE invoice (
    id_invoice UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    id_order UUID NOT NULL,
    issue_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,-- , cuándo se creó oficialmente la factura del pedido.
    total NUMERIC(12,2) NOT NULL,
    id_status UUID NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, 

	created_by   UUID,

	CONSTRAINT fk_invoice_order  FOREIGN KEY (id_order)   REFERENCES orders (id_order),
    CONSTRAINT fk_invoice_status FOREIGN KEY (id_status)  REFERENCES status (id),
	CONSTRAINT fk_created_by FOREIGN KEY (created_by)  REFERENCES users(id_user)
);

---------------------------------------------------------------------------------------------------------------------
CREATE TABLE invoice_item (
    id_invoice_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_invoice UUID NOT NULL,
    id_product UUID NOT NULL,
    quantity INT,
    unit_price NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, 

    CONSTRAINT fk_ii_invoice FOREIGN KEY (id_invoice) REFERENCES invoice (id_invoice),
    CONSTRAINT fk_ii_product FOREIGN KEY (id_product) REFERENCES product (id_product)
);

-----------------------------------------------------------------------------------------------------------------------

CREATE TABLE payment (
    id_payment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_invoice UUID NOT NULL,
    id_method UUID NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    status VARCHAR(20),
    transaction_ref VARCHAR(100),
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pay_invoice FOREIGN KEY (id_invoice) REFERENCES invoice(id_invoice), 
    CONSTRAINT fk_pay_method FOREIGN KEY (id_method) REFERENCES method_payment(id_method)
);

INSERT INTO status (id, name) VALUES
    ('a1000000-0000-0000-0000-000000000001', 'activo'),
    ('a1000000-0000-0000-0000-000000000002', 'inactivo'),
    ('a1000000-0000-0000-0000-000000000003', 'eliminado'),
    ('a1000000-0000-0000-0000-000000000004', 'pendiente'),
    ('a1000000-0000-0000-0000-000000000005', 'preparado'),
    ('a1000000-0000-0000-0000-000000000006', 'entregado'),
    ('a1000000-0000-0000-0000-000000000007', 'cancelado'),
    ('a1000000-0000-0000-0000-000000000008', 'pagado'),
    ('a1000000-0000-0000-0000-000000000009', 'anulado'),
    ('a1000000-0000-0000-0000-000000000010', 'bloqueado');

---------------------------------------------------------------------------------------------------
-- MODULE 1: PARAMETER
----------------------------------------------------------------------------------------------------

INSERT INTO type_document (id_type_document, code, name) VALUES
    ('b1000000-0000-0000-0000-000000000001', 'CC',   'Cédula de Ciudadanía'),
    ('b1000000-0000-0000-0000-000000000002', 'TI',   'Tarjeta de Identidad'),
    ('b1000000-0000-0000-0000-000000000003', 'CE',   'Cédula de Extranjería'),
    ('b1000000-0000-0000-0000-000000000004', 'PAS',  'Pasaporte'),
    ('b1000000-0000-0000-0000-000000000005', 'NIT',  'Número de Identificación Tributaria'),
    ('b1000000-0000-0000-0000-000000000006', 'RC',   'Registro Civil'),
    ('b1000000-0000-0000-0000-000000000007', 'DIE',  'Documento de Identidad Extranjero'),
    ('b1000000-0000-0000-0000-000000000008', 'NUIP', 'Número Único de Identificación Personal'),
    ('b1000000-0000-0000-0000-000000000009', 'PEP',  'Permiso Especial de Permanencia'),
    ('b1000000-0000-0000-0000-000000000010', 'PPT',  'Permiso de Protección Temporal');

-- ----------------------------------------------------------------
INSERT INTO person (id_person, name, last_name, id_type_document, phone, email) VALUES
    ('c1000000-0000-0000-0000-000000000001', 'Carlos',    'Ramírez',   'b1000000-0000-0000-0000-000000000001', '3101234567', 'carlos.ramirez@sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000002', 'María',     'López',     'b1000000-0000-0000-0000-000000000001', '3209876543', 'maria.lopez@sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000003', 'Juan',      'Torres',    'b1000000-0000-0000-0000-000000000002', '3151112233', 'juan.torres@aprendiz.sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000004', 'Valentina', 'Gómez',     'b1000000-0000-0000-0000-000000000002', '3173334455', 'valentina.gomez@aprendiz.sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000005', 'Andrés',    'Martínez',  'b1000000-0000-0000-0000-000000000001', '3185556677', 'andres.martinez@sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000006', 'Luisa',     'Herrera',   'b1000000-0000-0000-0000-000000000002', '3007778899', 'luisa.herrera@aprendiz.sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000007', 'Felipe',    'Castro',    'b1000000-0000-0000-0000-000000000001', '3119990011', 'felipe.castro@sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000008', 'Daniela',   'Vargas',    'b1000000-0000-0000-0000-000000000002', '3141122334', 'daniela.vargas@aprendiz.sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000009', 'Miguel',    'Sánchez',   'b1000000-0000-0000-0000-000000000001', '3202233445', 'miguel.sanchez@sena.edu.co'),
    ('c1000000-0000-0000-0000-000000000010', 'Paola',     'Jiménez',   'b1000000-0000-0000-0000-000000000001', '3163344556', 'paola.jimenez@sena.edu.co');


----------------------------------------------------------------------
-- MODULE 2: SECURITY
----------------------------------------------------------------------
INSERT INTO users (id_user, username, password_hash, id_person, id_status, created_by) VALUES
    ('d1000000-0000-0000-0000-000000000001', 'admin.carlos',      '$2b$10$hashAdminCarlos',     'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', NULL),
    ('d1000000-0000-0000-0000-000000000002', 'personal.maria',    '$2b$10$hashPersonalMaria',   'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000003', 'aprendiz.juan',     '$2b$10$hashAprendizJuan',    'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000004', 'aprendiz.vale',     '$2b$10$hashAprendizVale',    'c1000000-0000-0000-0000-000000000004', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000005', 'instructor.andres', '$2b$10$hashInstructorAndres','c1000000-0000-0000-0000-000000000005', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000006', 'aprendiz.luisa',    '$2b$10$hashAprendizLuisa',   'c1000000-0000-0000-0000-000000000006', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000007', 'personal.felipe',   '$2b$10$hashPersonalFelipe',  'c1000000-0000-0000-0000-000000000007', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000008', 'aprendiz.dani',     '$2b$10$hashAprendizDani',    'c1000000-0000-0000-0000-000000000008', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000009', 'instructor.miguel', '$2b$10$hashInstructorMiguel','c1000000-0000-0000-0000-000000000009', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('d1000000-0000-0000-0000-000000000010', 'personal.paola',    '$2b$10$hashPersonalPaola',   'c1000000-0000-0000-0000-000000000010', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001');

-- ----------------------------------------------------------------
INSERT INTO roles (id_rol, name_role, description, id_status) VALUES
    ('e1000000-0000-0000-0000-000000000001', 'Administrador',    'Acceso total al sistema',                          'a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000002', 'Personal Cafetín', 'Gestiona pedidos y cambia estados (RF-4, RF-5)',   'a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000003', 'Aprendiz',         'Consulta menú y realiza pedidos (RF-1, RF-2, RF-3)','a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000004', 'Instructor',       'Consulta menú y realiza pedidos (RF-1, RF-2, RF-3)','a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000005', 'Auditor',          'Solo lectura, acceso a reportes',                  'a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000006', 'Supervisor',       'Supervisa operaciones del cafetín',                'a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000007', 'Cajero',           'Gestiona pagos y facturas',                        'a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000008', 'Cocinero',         'Prepara pedidos en cocina',                        'a1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000009', 'Visitante',        'Acceso solo lectura al menú',                      'a1000000-0000-0000-0000-000000000002'),
    ('e1000000-0000-0000-0000-000000000010', 'Soporte',          'Soporte técnico del sistema',                      'a1000000-0000-0000-0000-000000000001');
	
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO modules (id_module, name_module, description, id_status, url_prefix, order_num, created_by) VALUES
    ('f1000000-0000-0000-0000-000000000001', 'Dashboard',    'Panel principal del sistema',             'a1000000-0000-0000-0000-000000000001', '/dashboard',    1, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000002', 'Seguridad',    'Gestión de usuarios, roles y permisos',   'a1000000-0000-0000-0000-000000000001', '/security',     2, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000003', 'Inventario',   'Gestión de productos y categorías',       'a1000000-0000-0000-0000-000000000001', '/inventory',    3, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000004', 'Ventas',       'Carrito, pedidos y estado de entregas',   'a1000000-0000-0000-0000-000000000001', '/sales',        4, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000005', 'Facturación',  'Facturas, pagos y métodos de pago',       'a1000000-0000-0000-0000-000000000001', '/billing',      5, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000006', 'Reportes',     'Reportes y estadísticas del sistema',     'a1000000-0000-0000-0000-000000000001', '/reports',      6, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000007', 'Parámetros',   'Configuración general del sistema',       'a1000000-0000-0000-0000-000000000001', '/parameters',   7, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000008', 'Menú Cliente', 'Vista del menú para clientes',            'a1000000-0000-0000-0000-000000000001', '/menu',         8, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000009', 'Panel Cocina', 'Vista de pedidos para el personal',       'a1000000-0000-0000-0000-000000000001', '/kitchen',      9, 'd1000000-0000-0000-0000-000000000001'),
    ('f1000000-0000-0000-0000-000000000010', 'Auditoría',    'Historial de cambios y trazabilidad',     'a1000000-0000-0000-0000-000000000001', '/audit',       10, 'd1000000-0000-0000-0000-000000000001');

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO views_ (id_view, name_view, url, description, order_num, id_status, created_by) VALUES
    ('m1000000-0000-0000-0000-000000000001', 'Lista de Productos',   '/inventory/products',         'Ver todos los productos',           1, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000002', 'Crear Producto',       '/inventory/products/create',  'Formulario nuevo producto',         2, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000003', 'Lista de Pedidos',     '/sales/orders',               'Ver todos los pedidos',             1, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000004', 'Panel Cocina',         '/kitchen/orders',             'Pedidos pendientes en cocina',      1, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000005', 'Menú del Cliente',     '/menu',                       'Menú visible al cliente (RF-1)',    1, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000006', 'Carrito',              '/menu/cart',                  'Carrito de compras (RF-2)',         2, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000007', 'Confirmar Pedido',     '/menu/checkout',              'Confirmación de pedido (RF-3)',     3, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000008', 'Lista de Usuarios',    '/security/users',             'Gestión de usuarios',              1, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000009', 'Lista de Facturas',    '/billing/invoices',           'Ver facturas generadas',           1, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('g1000000-0000-0000-0000-000000000010', 'Reportes de Ventas',   '/reports/sales',              'Estadísticas de ventas',           1, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001');

INSERT INTO user_role (id_user, id_rol, assigned_by, created_by) VALUES
    ('d1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', NULL,                                       NULL),                                       -- carlos → Administrador
    ('d1000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- maria → Personal Cafetín
    ('d1000000-0000-0000-0000-000000000003', 'e1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- juan → Aprendiz
    ('d1000000-0000-0000-0000-000000000004', 'e1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- valentina → Aprendiz
    ('d1000000-0000-0000-0000-000000000005', 'e1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- andrés → Instructor
    ('d1000000-0000-0000-0000-000000000006', 'e1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- luisa → Aprendiz
    ('d1000000-0000-0000-0000-000000000007', 'e1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- felipe → Personal Cafetín
    ('d1000000-0000-0000-0000-000000000008', 'e1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- daniela → Aprendiz
    ('d1000000-0000-0000-0000-000000000009', 'e1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001'),     -- miguel → Instructor
    ('d1000000-0000-0000-0000-000000000010', 'e1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001',     'd1000000-0000-0000-0000-000000000001');     -- paola → Personal Cafetín

-- ----------------------------------------------------------------
-- role_module  (qué módulos puede ver cada rol)
-- ----------------------------------------------------------------
INSERT INTO role_module (id_rol, id_module, created_by) VALUES
    -- Administrador: todos los módulos
    ('e1000000-0000-0000-0000-000000000001', 'f1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000001', 'f1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000001', 'f1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001'),
    -- Personal Cafetín: ventas y panel cocina
    ('e1000000-0000-0000-0000-000000000002', 'f1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000002', 'f1000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000001'),
    -- Aprendiz: solo menú cliente y carrito
    ('e1000000-0000-0000-0000-000000000003', 'f1000000-0000-0000-0000-000000000008', 'd1000000-0000-0000-0000-000000000001'),
    -- Instructor: menú cliente y carrito
    ('e1000000-0000-0000-0000-000000000004', 'f1000000-0000-0000-0000-000000000008', 'd1000000-0000-0000-0000-000000000001'),
    -- Auditor: solo reportes
    ('e1000000-0000-0000-0000-000000000005', 'f1000000-0000-0000-0000-000000000006', 'd1000000-0000-0000-0000-000000000001'),
    ('e1000000-0000-0000-0000-000000000005', 'f1000000-0000-0000-0000-000000000010', 'd1000000-0000-0000-0000-000000000001'),
    -- Cajero: facturación
    ('e1000000-0000-0000-0000-000000000007', 'f1000000-0000-0000-0000-000000000005', 'd1000000-0000-0000-0000-000000000001');

-- ----------------------------------------------------------------
-- module_view  (qué vistas tiene cada módulo)
-- ----------------------------------------------------------------
INSERT INTO module_view (id_module, id_view, created_by) VALUES
    ('f1000000-0000-0000-0000-000000000003', 'g1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'), -- Inventario → Lista Productos
    ('f1000000-0000-0000-0000-000000000003', 'g1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001'), -- Inventario → Crear Producto
    ('f1000000-0000-0000-0000-000000000004', 'g1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001'), -- Ventas → Lista Pedidos
    ('f1000000-0000-0000-0000-000000000009', 'g1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000001'), -- Panel Cocina → Panel Cocina
    ('f1000000-0000-0000-0000-000000000008', 'g1000000-0000-0000-0000-000000000005', 'd1000000-0000-0000-0000-000000000001'), -- Menú Cliente → Menú
    ('f1000000-0000-0000-0000-000000000008', 'g1000000-0000-0000-0000-000000000006', 'd1000000-0000-0000-0000-000000000001'), -- Menú Cliente → Carrito
    ('f1000000-0000-0000-0000-000000000008', 'g1000000-0000-0000-0000-000000000007', 'd1000000-0000-0000-0000-000000000001'), -- Menú Cliente → Confirmar Pedido
    ('f1000000-0000-0000-0000-000000000002', 'g1000000-0000-0000-0000-000000000008', 'd1000000-0000-0000-0000-000000000001'), -- Seguridad → Lista Usuarios
    ('f1000000-0000-0000-0000-000000000005', 'g1000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000001'), -- Facturación → Lista Facturas
    ('f1000000-0000-0000-0000-000000000006', 'g1000000-0000-0000-0000-000000000010', 'd1000000-0000-0000-0000-000000000001'); -- Reportes → Reportes Ventas


-- ================================================================
-- MODULE 3: INVENTORY
-- ================================================================

-- category
INSERT INTO category (id_category, name_category, description, id_status, created_by) VALUES
    ('h1000000-0000-0000-0000-000000000001', 'Bebidas Calientes', 'Café, chocolate, aromáticas',                'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000002', 'Bebidas Frías',     'Jugos, limonadas, gaseosas',                 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000003', 'Alimentos',         'Platos principales y comidas',               'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000004', 'Snacks',            'Pasabocas, galletas, dulces',                'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000005', 'Combos',            'Combinación de bebida + alimento',           'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000006', 'Desayunos',         'Desayunos completos',                        'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000007', 'Postres',           'Dulces, pasteles y postres',                 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000008', 'Ensaladas',         'Ensaladas y opciones saludables',            'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000009', 'Sopas',             'Sopas y caldos',                             'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('h1000000-0000-0000-0000-000000000010', 'Panadería',         'Pan, croissants, pandebono',                 'a1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001'); -- inactivo

-- ----------------------------------------------------------------
-- product
-- ----------------------------------------------------------------
INSERT INTO product (id_product, name_product, description, price, id_category, id_status, created_by) VALUES
    ('i1000000-0000-0000-0000-000000000001', 'Café Americano',      'Café negro sin azúcar',                   2500.00, 'h1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000002', 'Chocolate Caliente',  'Chocolate en leche caliente',             3000.00, 'h1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000003', 'Jugo de Naranja',     'Jugo natural de naranja 350ml',           2000.00, 'h1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000004', 'Empanada de Pipián',  'Empanada típica colombiana con ají',      1500.00, 'h1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000005', 'Almuerzo Ejecutivo',  'Sopa + seco + jugo del día',              8000.00, 'h1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000006', 'Pandebono',           'Pandebono recién horneado',               1000.00, 'h1000000-0000-0000-0000-000000000010', 'a1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000002'), -- inactivo
    ('i1000000-0000-0000-0000-000000000007', 'Combo Desayuno',      'Café + pandebono + jugo',                 5000.00, 'h1000000-0000-0000-0000-000000000005', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000008', 'Brownie de Chocolate','Brownie artesanal con nueces',            2500.00, 'h1000000-0000-0000-0000-000000000007', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000009', 'Limonada Natural',    'Limonada fría con hierbabuena',           2000.00, 'h1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002'),
    ('i1000000-0000-0000-0000-000000000010', 'Sopa de Lentejas',    'Sopa tradicional de lentejas con arroz',  4500.00, 'h1000000-0000-0000-0000-000000000009', 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002');


-- ================================================================
-- MODULE 4: SALES
-- ================================================================

-- cart  (1 carrito activo por usuario – solo clientes)
INSERT INTO cart (id_cart, id_user, created_by) VALUES
    ('j1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000003'), -- juan
    ('j1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000004'), -- valentina
    ('j1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000005', 'd1000000-0000-0000-0000-000000000005'), -- andrés
    ('j1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000006', 'd1000000-0000-0000-0000-000000000006'), -- luisa
    ('j1000000-0000-0000-0000-000000000005', 'd1000000-0000-0000-0000-000000000008', 'd1000000-0000-0000-0000-000000000008'), -- daniela
    ('j1000000-0000-0000-0000-000000000006', 'd1000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000009'), -- miguel
    ('j1000000-0000-0000-0000-000000000007', 'd1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'), -- carlos (admin también puede pedir)
    ('j1000000-0000-0000-0000-000000000008', 'd1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000002'), -- maria
    ('j1000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000007', 'd1000000-0000-0000-0000-000000000007'), -- felipe
    ('j1000000-0000-0000-0000-000000000010', 'd1000000-0000-0000-0000-000000000010', 'd1000000-0000-0000-0000-000000000010'); -- paola

-- ----------------------------------------------------------------
-- cart_item  (productos en el carrito de cada usuario)
-- ----------------------------------------------------------------
INSERT INTO cart_item (id_cart_item, id_cart, id_product, quantity, created_by) VALUES
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000001', 'i1000000-0000-0000-0000-000000000001', 1, 'd1000000-0000-0000-0000-000000000003'), -- juan: 1 Café
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000001', 'i1000000-0000-0000-0000-000000000004', 2, 'd1000000-0000-0000-0000-000000000003'), -- juan: 2 Empanadas
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000002', 'i1000000-0000-0000-0000-000000000007', 1, 'd1000000-0000-0000-0000-000000000004'), -- valentina: 1 Combo Desayuno
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000003', 'i1000000-0000-0000-0000-000000000005', 1, 'd1000000-0000-0000-0000-000000000005'), -- andrés: 1 Almuerzo
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000003', 'i1000000-0000-0000-0000-000000000003', 1, 'd1000000-0000-0000-0000-000000000005'), -- andrés: 1 Jugo
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000004', 'i1000000-0000-0000-0000-000000000002', 2, 'd1000000-0000-0000-0000-000000000006'), -- luisa: 2 Chocolates
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000005', 'i1000000-0000-0000-0000-000000000008', 1, 'd1000000-0000-0000-0000-000000000008'), -- daniela: 1 Brownie
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000005', 'i1000000-0000-0000-0000-000000000009', 1, 'd1000000-0000-0000-0000-000000000008'), -- daniela: 1 Limonada
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000006', 'i1000000-0000-0000-0000-000000000010', 1, 'd1000000-0000-0000-0000-000000000009'), -- miguel: 1 Sopa
    (gen_random_uuid(), 'j1000000-0000-0000-0000-000000000007', 'i1000000-0000-0000-0000-000000000001', 2, 'd1000000-0000-0000-0000-000000000001'); -- carlos: 2 Cafés

-- ----------------------------------------------------------------
-- orders  (pedidos confirmados – RF-3)
-- ----------------------------------------------------------------
INSERT INTO orders (id_order, id_user, client_name, id_status, total, notes, created_by) VALUES
    ('k1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000003', 'Juan Torres',        'a1000000-0000-0000-0000-000000000006', 5500.00,  NULL,                   'd1000000-0000-0000-0000-000000000003'), -- entregado
    ('k1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000004', 'Valentina Gómez',    'a1000000-0000-0000-0000-000000000005', 5000.00,  'Sin azúcar por favor', 'd1000000-0000-0000-0000-000000000004'), -- preparado
    ('k1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000005', 'Andrés Martínez',    'a1000000-0000-0000-0000-000000000004', 10000.00, NULL,                   'd1000000-0000-0000-0000-000000000005'), -- pendiente
    ('k1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000006', 'Luisa Herrera',      'a1000000-0000-0000-0000-000000000006', 6000.00,  NULL,                   'd1000000-0000-0000-0000-000000000006'), -- entregado
    ('k1000000-0000-0000-0000-000000000005', 'd1000000-0000-0000-0000-000000000008', 'Daniela Vargas',     'a1000000-0000-0000-0000-000000000004', 4500.00,  'Sin hielo',             'd1000000-0000-0000-0000-000000000008'), -- pendiente
    ('k1000000-0000-0000-0000-000000000006', 'd1000000-0000-0000-0000-000000000009', 'Miguel Sánchez',     'a1000000-0000-0000-0000-000000000005', 4500.00,  NULL,                   'd1000000-0000-0000-0000-000000000009'), -- preparado
    ('k1000000-0000-0000-0000-000000000007', 'd1000000-0000-0000-0000-000000000001', 'Carlos Ramírez',     'a1000000-0000-0000-0000-000000000006', 5000.00,  NULL,                   'd1000000-0000-0000-0000-000000000001'), -- entregado
    ('k1000000-0000-0000-0000-000000000008', 'd1000000-0000-0000-0000-000000000003', 'Juan Torres',        'a1000000-0000-0000-0000-000000000007', 3000.00,  NULL,                   'd1000000-0000-0000-0000-000000000003'), -- cancelado
    ('k1000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000005', 'Andrés Martínez',    'a1000000-0000-0000-0000-000000000006', 8000.00,  'Llevar a salón 203',    'd1000000-0000-0000-0000-000000000005'), -- entregado
    ('k1000000-0000-0000-0000-000000000010', 'd1000000-0000-0000-0000-000000000004', 'Valentina Gómez',    'a1000000-0000-0000-0000-000000000004', 2500.00,  NULL,                   'd1000000-0000-0000-0000-000000000004'); -- pendiente

-- ----------------------------------------------------------------
-- order_item  (detalle de cada pedido)
-- ----------------------------------------------------------------
INSERT INTO order_item (id_order_item, id_order, id_product, quantity, unit_price, created_by) VALUES
    -- Pedido 1: Juan → Café + 2 Empanadas = 2500 + 3000 = 5500
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000001', 'i1000000-0000-0000-0000-000000000001', 1, 2500.00, 'd1000000-0000-0000-0000-000000000003'),
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000001', 'i1000000-0000-0000-0000-000000000004', 2, 1500.00, 'd1000000-0000-0000-0000-000000000003'),
    -- Pedido 2: Valentina → Combo Desayuno = 5000
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000002', 'i1000000-0000-0000-0000-000000000007', 1, 5000.00, 'd1000000-0000-0000-0000-000000000004'),
    -- Pedido 3: Andrés → Almuerzo + Jugo = 8000 + 2000 = 10000
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000003', 'i1000000-0000-0000-0000-000000000005', 1, 8000.00, 'd1000000-0000-0000-0000-000000000005'),
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000003', 'i1000000-0000-0000-0000-000000000003', 1, 2000.00, 'd1000000-0000-0000-0000-000000000005'),
    -- Pedido 4: Luisa → 2 Chocolates = 6000
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000004', 'i1000000-0000-0000-0000-000000000002', 2, 3000.00, 'd1000000-0000-0000-0000-000000000006'),
    -- Pedido 5: Daniela → Brownie + Limonada = 2500 + 2000 = 4500
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000005', 'i1000000-0000-0000-0000-000000000008', 1, 2500.00, 'd1000000-0000-0000-0000-000000000008'),
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000005', 'i1000000-0000-0000-0000-000000000009', 1, 2000.00, 'd1000000-0000-0000-0000-000000000008'),
    -- Pedido 6: Miguel → Sopa = 4500
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000006', 'i1000000-0000-0000-0000-000000000010', 1, 4500.00, 'd1000000-0000-0000-0000-000000000009'),
    -- Pedido 7: Carlos → Combo Desayuno = 5000
    (gen_random_uuid(), 'k1000000-0000-0000-0000-000000000007', 'i1000000-0000-0000-0000-000000000007', 1, 5000.00, 'd1000000-0000-0000-0000-000000000001');


-- ================================================================
-- MODULE 5: BILLING
-- ================================================================

-- method_payment
INSERT INTO method_payment (id_method, name_method, description, id_status, created_by) VALUES
    ('l1000000-0000-0000-0000-000000000001', 'Efectivo',            'Pago en efectivo en caja',               'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000002', 'Tarjeta Débito',      'Pago con tarjeta débito',                'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000003', 'Tarjeta Crédito',     'Pago con tarjeta crédito',               'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000004', 'Transferencia',       'Transferencia bancaria o Nequi/Daviplata','a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000005', 'Billetera Digital',   'Nequi, Daviplata, Bancolombia a la mano','a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000006', 'QR Bancolombia',      'Pago por código QR Bancolombia',         'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000007', 'PSE',                 'Pago en línea por PSE',                  'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000008', 'Cupón Descuento',     'Pago con cupón de descuento SENA',       'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001'),
    ('l1000000-0000-0000-0000-000000000009', 'Crédito Interno',     'Descuento de nómina o carnet SENA',      'a1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001'), -- inactivo
    ('l1000000-0000-0000-0000-000000000010', 'Contra Entrega',      'Pago al recibir el pedido',              'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001');

-- ----------------------------------------------------------------
-- invoice  (solo pedidos entregados o preparados generan factura)
-- ----------------------------------------------------------------
INSERT INTO invoice (id_invoice, invoice_number, id_order, total, id_status, created_by) VALUES
    ('m1000000-0000-0000-0000-000000000001', 'FAC-2025-0001', 'k1000000-0000-0000-0000-000000000001',  5500.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000002', 'FAC-2025-0002', 'k1000000-0000-0000-0000-000000000002',  5000.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000003', 'FAC-2025-0003', 'k1000000-0000-0000-0000-000000000003', 10000.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000004', 'FAC-2025-0004', 'k1000000-0000-0000-0000-000000000004',  6000.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000005', 'FAC-2025-0005', 'k1000000-0000-0000-0000-000000000005',  4500.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000006', 'FAC-2025-0006', 'k1000000-0000-0000-0000-000000000006',  4500.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000007', 'FAC-2025-0007', 'k1000000-0000-0000-0000-000000000007',  5000.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000008', 'FAC-2025-0008', 'k1000000-0000-0000-0000-000000000009',  8000.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000009', 'FAC-2025-0009', 'k1000000-0000-0000-0000-000000000010',  2500.00, 'a1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000010'),
    ('m1000000-0000-0000-0000-000000000010', 'FAC-2025-0010', 'k1000000-0000-0000-0000-000000000008',  3000.00, 'a1000000-0000-0000-0000-000000000009', 'd1000000-0000-0000-0000-000000000010'); -- anulada (pedido cancelado)

-- ----------------------------------------------------------------
-- invoice_item  (espejo del order_item para efectos fiscales)
-- ----------------------------------------------------------------
INSERT INTO invoice_item (id_invoice_item, id_invoice, id_product, quantity, unit_price) VALUES
    -- FAC-0001: Juan → Café + 2 Empanadas
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000001', 'i1000000-0000-0000-0000-000000000001', 1, 2500.00),
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000001', 'i1000000-0000-0000-0000-000000000004', 2, 1500.00),
    -- FAC-0002: Valentina → Combo Desayuno
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000002', 'i1000000-0000-0000-0000-000000000007', 1, 5000.00),
    -- FAC-0003: Andrés → Almuerzo + Jugo
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000003', 'i1000000-0000-0000-0000-000000000005', 1, 8000.00),
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000003', 'i1000000-0000-0000-0000-000000000003', 1, 2000.00),
    -- FAC-0004: Luisa → 2 Chocolates
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000004', 'i1000000-0000-0000-0000-000000000002', 2, 3000.00),
    -- FAC-0005: Daniela → Brownie + Limonada
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000005', 'i1000000-0000-0000-0000-000000000008', 1, 2500.00),
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000005', 'i1000000-0000-0000-0000-000000000009', 1, 2000.00),
    -- FAC-0006: Miguel → Sopa
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000006', 'i1000000-0000-0000-0000-000000000010', 1, 4500.00),
    -- FAC-0007: Carlos → Combo Desayuno
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000007', 'i1000000-0000-0000-0000-000000000007', 1, 5000.00);

-- ----------------------------------------------------------------
-- payment  (pagos realizados)
-- ----------------------------------------------------------------
INSERT INTO payment (id_payment, id_invoice, id_method, amount, status, transaction_ref, paid_at) VALUES
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000001', 'l1000000-0000-0000-0000-000000000001',  5500.00, 'pagado',    NULL,           NOW() - INTERVAL '5 days'),  -- Juan pagó efectivo
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000002', 'l1000000-0000-0000-0000-000000000005',  5000.00, 'pagado',    'NEQ-20250301', NOW() - INTERVAL '4 days'),  -- Valentina pagó Nequi
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000003', 'l1000000-0000-0000-0000-000000000002', 10000.00, 'pagado',    NULL,           NOW() - INTERVAL '3 days'),  -- Andrés tarjeta débito
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000004', 'l1000000-0000-0000-0000-000000000001',  6000.00, 'pagado',    NULL,           NOW() - INTERVAL '3 days'),  -- Luisa efectivo
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000005', 'l1000000-0000-0000-0000-000000000006',  4500.00, 'pendiente', 'QR-20250305',  NULL),                        -- Daniela QR pendiente
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000006', 'l1000000-0000-0000-0000-000000000004',  4500.00, 'pagado',    'TRF-20250304', NOW() - INTERVAL '2 days'),  -- Miguel transferencia
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000007', 'l1000000-0000-0000-0000-000000000001',  5000.00, 'pagado',    NULL,           NOW() - INTERVAL '1 day'),   -- Carlos efectivo
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000008', 'l1000000-0000-0000-0000-000000000003',  8000.00, 'pagado',    'VISA-20250302',NOW() - INTERVAL '2 days'),  -- Andrés tarjeta crédito
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000009', 'l1000000-0000-0000-0000-000000000001',  2500.00, 'pendiente', NULL,           NULL),                        -- Valentina pendiente
    (gen_random_uuid(), 'm1000000-0000-0000-0000-000000000010', 'l1000000-0000-0000-0000-000000000001',  3000.00, 'reembolsado',NULL,          NOW() - INTERVAL '1 day'));  -- Juan reembolso (pedido cancelado)



  

 
  


   

