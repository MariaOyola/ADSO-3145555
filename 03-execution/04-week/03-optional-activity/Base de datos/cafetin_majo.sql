
-- Sistema de Cafetin

/* Modelo 1: Parameter
   - type_document
   - person*/
-- Sistema de Cafetin

/* Modelo 1: Parameter
   - type_document
   - person*/

CREATE DATABASE Cafetin;

\c Cafetin;

-- Activar extensión para UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DROP TABLE modules CASCADE;
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
    ('00000001-0000-0000-0000-000000000001', 'activo'),
    ('00000001-0000-0000-0000-000000000002', 'inactivo'),
    ('00000001-0000-0000-0000-000000000003', 'eliminado'),
    ('00000001-0000-0000-0000-000000000004', 'pendiente'),
    ('00000001-0000-0000-0000-000000000005', 'preparado'),
    ('00000001-0000-0000-0000-000000000006', 'entregado'),
    ('00000001-0000-0000-0000-000000000007', 'cancelado'),
    ('00000001-0000-0000-0000-000000000008', 'pagado'),
    ('00000001-0000-0000-0000-000000000009', 'anulado'),
    ('00000001-0000-0000-0000-000000000010', 'bloqueado');

-- ================================================================
-- MODULE 1: PARAMETER
-- ================================================================

INSERT INTO type_document (id_type_document, code, name) VALUES
    ('00000002-0000-0000-0000-000000000001', 'CC',   'Cédula de Ciudadanía'),
    ('00000002-0000-0000-0000-000000000002', 'TI',   'Tarjeta de Identidad'),
    ('00000002-0000-0000-0000-000000000003', 'CE',   'Cédula de Extranjería'),
    ('00000002-0000-0000-0000-000000000004', 'PAS',  'Pasaporte'),
    ('00000002-0000-0000-0000-000000000005', 'NIT',  'Número de Identificación Tributaria'),
    ('00000002-0000-0000-0000-000000000006', 'RC',   'Registro Civil'),
    ('00000002-0000-0000-0000-000000000007', 'DIE',  'Documento de Identidad Extranjero'),
    ('00000002-0000-0000-0000-000000000008', 'NUIP', 'Número Único de Identificación Personal'),
    ('00000002-0000-0000-0000-000000000009', 'PEP',  'Permiso Especial de Permanencia'),
    ('00000002-0000-0000-0000-000000000010', 'PPT',  'Permiso de Protección Temporal');

INSERT INTO person (id_person, name, last_name, id_type_document, phone, email) VALUES
    ('00000003-0000-0000-0000-000000000001', 'Carlos',    'Ramírez',  '00000002-0000-0000-0000-000000000001', '3101234567', 'carlos.ramirez@sena.edu.co'),
    ('00000003-0000-0000-0000-000000000002', 'María',     'López',    '00000002-0000-0000-0000-000000000001', '3209876543', 'maria.lopez@sena.edu.co'),
    ('00000003-0000-0000-0000-000000000003', 'Juan',      'Torres',   '00000002-0000-0000-0000-000000000002', '3151112233', 'juan.torres@aprendiz.sena.edu.co'),
    ('00000003-0000-0000-0000-000000000004', 'Valentina', 'Gómez',    '00000002-0000-0000-0000-000000000002', '3173334455', 'valentina.gomez@aprendiz.sena.edu.co'),
    ('00000003-0000-0000-0000-000000000005', 'Andrés',    'Martínez', '00000002-0000-0000-0000-000000000001', '3185556677', 'andres.martinez@sena.edu.co'),
    ('00000003-0000-0000-0000-000000000006', 'Luisa',     'Herrera',  '00000002-0000-0000-0000-000000000002', '3007778899', 'luisa.herrera@aprendiz.sena.edu.co'),
    ('00000003-0000-0000-0000-000000000007', 'Felipe',    'Castro',   '00000002-0000-0000-0000-000000000001', '3119990011', 'felipe.castro@sena.edu.co'),
    ('00000003-0000-0000-0000-000000000008', 'Daniela',   'Vargas',   '00000002-0000-0000-0000-000000000002', '3141122334', 'daniela.vargas@aprendiz.sena.edu.co'),
    ('00000003-0000-0000-0000-000000000009', 'Miguel',    'Sánchez',  '00000002-0000-0000-0000-000000000001', '3202233445', 'miguel.sanchez@sena.edu.co'),
    ('00000003-0000-0000-0000-000000000010', 'Paola',     'Jiménez',  '00000002-0000-0000-0000-000000000001', '3163344556', 'paola.jimenez@sena.edu.co');

-- ================================================================
-- MODULE 2: SECURITY
-- ================================================================

INSERT INTO users (id_user, username, password_hash, id_person, id_status, created_by) VALUES
    ('00000004-0000-0000-0000-000000000001', 'admin.carlos',      '$2b$10$hashAdminCarlos',      '00000003-0000-0000-0000-000000000001', '00000001-0000-0000-0000-000000000001', NULL),
    ('00000004-0000-0000-0000-000000000002', 'personal.maria',    '$2b$10$hashPersonalMaria',    '00000003-0000-0000-0000-000000000002', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000003', 'aprendiz.juan',     '$2b$10$hashAprendizJuan',     '00000003-0000-0000-0000-000000000003', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000004', 'aprendiz.vale',     '$2b$10$hashAprendizVale',     '00000003-0000-0000-0000-000000000004', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000005', 'instructor.andres', '$2b$10$hashInstructorAndres', '00000003-0000-0000-0000-000000000005', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000006', 'aprendiz.luisa',    '$2b$10$hashAprendizLuisa',    '00000003-0000-0000-0000-000000000006', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000007', 'personal.felipe',   '$2b$10$hashPersonalFelipe',   '00000003-0000-0000-0000-000000000007', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000008', 'aprendiz.dani',     '$2b$10$hashAprendizDani',     '00000003-0000-0000-0000-000000000008', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000009', 'instructor.miguel', '$2b$10$hashInstructorMiguel', '00000003-0000-0000-0000-000000000009', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000010', 'personal.paola',    '$2b$10$hashPersonalPaola',    '00000003-0000-0000-0000-000000000010', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001');

INSERT INTO roles (id_rol, name_role, description, id_status) VALUES
    ('00000005-0000-0000-0000-000000000001', 'Administrador',    'Acceso total al sistema',                           '00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000002', 'Personal Cafetín', 'Gestiona pedidos y cambia estados (RF-4, RF-5)',    '00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000003', 'Aprendiz',         'Consulta menú y realiza pedidos (RF-1, RF-2, RF-3)','00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000004', 'Instructor',       'Consulta menú y realiza pedidos (RF-1, RF-2, RF-3)','00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000005', 'Auditor',          'Solo lectura, acceso a reportes',                   '00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000006', 'Supervisor',       'Supervisa operaciones del cafetín',                 '00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000007', 'Cajero',           'Gestiona pagos y facturas',                         '00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000008', 'Cocinero',         'Prepara pedidos en cocina',                         '00000001-0000-0000-0000-000000000001'),
    ('00000005-0000-0000-0000-000000000009', 'Visitante',        'Acceso solo lectura al menú',                       '00000001-0000-0000-0000-000000000002'),
    ('00000005-0000-0000-0000-000000000010', 'Soporte',          'Soporte técnico del sistema',                       '00000001-0000-0000-0000-000000000001');

INSERT INTO modules (id_module, name_module, description, id_status, url_prefix, order_num, created_by) VALUES
    ('00000006-0000-0000-0000-000000000001', 'Dashboard',    'Panel principal del sistema',           '00000001-0000-0000-0000-000000000001', '/dashboard',  1,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000002', 'Seguridad',    'Gestión de usuarios, roles y permisos', '00000001-0000-0000-0000-000000000001', '/security',   2,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000003', 'Inventario',   'Gestión de productos y categorías',     '00000001-0000-0000-0000-000000000001', '/inventory',  3,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000004', 'Ventas',       'Carrito, pedidos y estado de entregas', '00000001-0000-0000-0000-000000000001', '/sales',      4,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000005', 'Facturación',  'Facturas, pagos y métodos de pago',     '00000001-0000-0000-0000-000000000001', '/billing',    5,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000006', 'Reportes',     'Reportes y estadísticas del sistema',   '00000001-0000-0000-0000-000000000001', '/reports',    6,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000007', 'Parámetros',   'Configuración general del sistema',     '00000001-0000-0000-0000-000000000001', '/parameters', 7,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000008', 'Menú Cliente', 'Vista del menú para clientes',          '00000001-0000-0000-0000-000000000001', '/menu',       8,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000009', 'Panel Cocina', 'Vista de pedidos para el personal',     '00000001-0000-0000-0000-000000000001', '/kitchen',    9,  '00000004-0000-0000-0000-000000000001'),
    ('00000006-0000-0000-0000-000000000010', 'Auditoría',    'Historial de cambios y trazabilidad',   '00000001-0000-0000-0000-000000000001', '/audit',      10, '00000004-0000-0000-0000-000000000001');

INSERT INTO views_ (id_view, name_view, url, description, order_num, id_status, created_by) VALUES
    ('00000007-0000-0000-0000-000000000001', 'Lista de Productos', '/inventory/products',        'Ver todos los productos',          1, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000002', 'Crear Producto',     '/inventory/products/create', 'Formulario nuevo producto',        2, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000003', 'Lista de Pedidos',   '/sales/orders',              'Ver todos los pedidos',            1, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000004', 'Panel Cocina',       '/kitchen/orders',            'Pedidos pendientes en cocina',     1, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000005', 'Menú del Cliente',   '/menu',                      'Menú visible al cliente (RF-1)',   1, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000006', 'Carrito',            '/menu/cart',                 'Carrito de compras (RF-2)',        2, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000007', 'Confirmar Pedido',   '/menu/checkout',             'Confirmación de pedido (RF-3)',    3, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000008', 'Lista de Usuarios',  '/security/users',            'Gestión de usuarios',             1, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000009', 'Lista de Facturas',  '/billing/invoices',          'Ver facturas generadas',          1, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000007-0000-0000-0000-000000000010', 'Reportes de Ventas', '/reports/sales',             'Estadísticas de ventas',          1, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001');

INSERT INTO user_role (id_user, id_rol, assigned_by, created_by) VALUES
    ('00000004-0000-0000-0000-000000000001', '00000005-0000-0000-0000-000000000001', NULL,                                   NULL),
    ('00000004-0000-0000-0000-000000000002', '00000005-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000003', '00000005-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000004', '00000005-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000005', '00000005-0000-0000-0000-000000000004', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000006', '00000005-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000007', '00000005-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000008', '00000005-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000009', '00000005-0000-0000-0000-000000000004', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000004-0000-0000-0000-000000000010', '00000005-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001');

INSERT INTO role_module (id_rol, id_module, created_by) VALUES
    ('00000005-0000-0000-0000-000000000001', '00000006-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'), -- Admin → Dashboard
    ('00000005-0000-0000-0000-000000000001', '00000006-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000001'), -- Admin → Seguridad
    ('00000005-0000-0000-0000-000000000001', '00000006-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000001'), -- Admin → Inventario
    ('00000005-0000-0000-0000-000000000002', '00000006-0000-0000-0000-000000000004', '00000004-0000-0000-0000-000000000001'), -- Personal → Ventas
    ('00000005-0000-0000-0000-000000000002', '00000006-0000-0000-0000-000000000009', '00000004-0000-0000-0000-000000000001'), -- Personal → Panel Cocina
    ('00000005-0000-0000-0000-000000000003', '00000006-0000-0000-0000-000000000008', '00000004-0000-0000-0000-000000000001'), -- Aprendiz → Menú Cliente
    ('00000005-0000-0000-0000-000000000004', '00000006-0000-0000-0000-000000000008', '00000004-0000-0000-0000-000000000001'), -- Instructor → Menú Cliente
    ('00000005-0000-0000-0000-000000000005', '00000006-0000-0000-0000-000000000006', '00000004-0000-0000-0000-000000000001'), -- Auditor → Reportes
    ('00000005-0000-0000-0000-000000000005', '00000006-0000-0000-0000-000000000010', '00000004-0000-0000-0000-000000000001'), -- Auditor → Auditoría
    ('00000005-0000-0000-0000-000000000007', '00000006-0000-0000-0000-000000000005', '00000004-0000-0000-0000-000000000001'); -- Cajero → Facturación

INSERT INTO module_view (id_module, id_view, created_by) VALUES
    ('00000006-0000-0000-0000-000000000003', '00000007-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'), -- Inventario → Lista Productos
    ('00000006-0000-0000-0000-000000000003', '00000007-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000001'), -- Inventario → Crear Producto
    ('00000006-0000-0000-0000-000000000004', '00000007-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000001'), -- Ventas → Lista Pedidos
    ('00000006-0000-0000-0000-000000000009', '00000007-0000-0000-0000-000000000004', '00000004-0000-0000-0000-000000000001'), -- Panel Cocina → Panel Cocina
    ('00000006-0000-0000-0000-000000000008', '00000007-0000-0000-0000-000000000005', '00000004-0000-0000-0000-000000000001'), -- Menú Cliente → Menú
    ('00000006-0000-0000-0000-000000000008', '00000007-0000-0000-0000-000000000006', '00000004-0000-0000-0000-000000000001'), -- Menú Cliente → Carrito
    ('00000006-0000-0000-0000-000000000008', '00000007-0000-0000-0000-000000000007', '00000004-0000-0000-0000-000000000001'), -- Menú Cliente → Confirmar Pedido
    ('00000006-0000-0000-0000-000000000002', '00000007-0000-0000-0000-000000000008', '00000004-0000-0000-0000-000000000001'), -- Seguridad → Lista Usuarios
    ('00000006-0000-0000-0000-000000000005', '00000007-0000-0000-0000-000000000009', '00000004-0000-0000-0000-000000000001'), -- Facturación → Lista Facturas
    ('00000006-0000-0000-0000-000000000006', '00000007-0000-0000-0000-000000000010', '00000004-0000-0000-0000-000000000001'); -- Reportes → Reportes Ventas

-- ================================================================
-- MODULE 3: INVENTORY
-- ================================================================

INSERT INTO category (id_category, name_category, description, id_status, created_by) VALUES
    ('00000008-0000-0000-0000-000000000001', 'Bebidas Calientes', 'Café, chocolate, aromáticas',       '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000002', 'Bebidas Frías',     'Jugos, limonadas, gaseosas',        '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000003', 'Alimentos',         'Platos principales y comidas',      '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000004', 'Snacks',            'Pasabocas, galletas, dulces',       '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000005', 'Combos',            'Combinación de bebida + alimento',  '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000006', 'Desayunos',         'Desayunos completos',               '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000007', 'Postres',           'Dulces, pasteles y postres',        '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000008', 'Ensaladas',         'Ensaladas y opciones saludables',   '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000009', 'Sopas',             'Sopas y caldos',                    '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('00000008-0000-0000-0000-000000000010', 'Panadería',         'Pan, croissants, pandebono',        '00000001-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000001'); -- inactivo

INSERT INTO product (id_product, name_product, description, price, id_category, id_status, created_by) VALUES
    ('00000009-0000-0000-0000-000000000001', 'Café Americano',       'Café negro sin azúcar',                  2500.00, '00000008-0000-0000-0000-000000000001', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000002', 'Chocolate Caliente',   'Chocolate en leche caliente',            3000.00, '00000008-0000-0000-0000-000000000001', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000003', 'Jugo de Naranja',      'Jugo natural de naranja 350ml',          2000.00, '00000008-0000-0000-0000-000000000002', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000004', 'Empanada de Pipián',   'Empanada típica colombiana con ají',     1500.00, '00000008-0000-0000-0000-000000000003', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000005', 'Almuerzo Ejecutivo',   'Sopa + seco + jugo del día',             8000.00, '00000008-0000-0000-0000-000000000003', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000006', 'Pandebono',            'Pandebono recién horneado',              1000.00, '00000008-0000-0000-0000-000000000010', '00000001-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000002'), -- inactivo
    ('00000009-0000-0000-0000-000000000007', 'Combo Desayuno',       'Café + pandebono + jugo',                5000.00, '00000008-0000-0000-0000-000000000005', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000008', 'Brownie de Chocolate', 'Brownie artesanal con nueces',           2500.00, '00000008-0000-0000-0000-000000000007', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000009', 'Limonada Natural',     'Limonada fría con hierbabuena',          2000.00, '00000008-0000-0000-0000-000000000002', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002'),
    ('00000009-0000-0000-0000-000000000010', 'Sopa de Lentejas',     'Sopa tradicional de lentejas con arroz', 4500.00, '00000008-0000-0000-0000-000000000009', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000002');

-- ================================================================
-- MODULE 4: SALES
-- ================================================================

INSERT INTO cart (id_cart, id_user, created_by) VALUES
    ('0000000a-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000003'), -- juan
    ('0000000a-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000004', '00000004-0000-0000-0000-000000000004'), -- valentina
    ('0000000a-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000005', '00000004-0000-0000-0000-000000000005'), -- andrés
    ('0000000a-0000-0000-0000-000000000004', '00000004-0000-0000-0000-000000000006', '00000004-0000-0000-0000-000000000006'), -- luisa
    ('0000000a-0000-0000-0000-000000000005', '00000004-0000-0000-0000-000000000008', '00000004-0000-0000-0000-000000000008'), -- daniela
    ('0000000a-0000-0000-0000-000000000006', '00000004-0000-0000-0000-000000000009', '00000004-0000-0000-0000-000000000009'), -- miguel
    ('0000000a-0000-0000-0000-000000000007', '00000004-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'), -- carlos
    ('0000000a-0000-0000-0000-000000000008', '00000004-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000002'), -- maria
    ('0000000a-0000-0000-0000-000000000009', '00000004-0000-0000-0000-000000000007', '00000004-0000-0000-0000-000000000007'), -- felipe
    ('0000000a-0000-0000-0000-000000000010', '00000004-0000-0000-0000-000000000010', '00000004-0000-0000-0000-000000000010'); -- paola

INSERT INTO cart_item (id_cart_item, id_cart, id_product, quantity, created_by) VALUES
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000001', '00000009-0000-0000-0000-000000000001', 1, '00000004-0000-0000-0000-000000000003'), -- juan: 1 Café
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000001', '00000009-0000-0000-0000-000000000004', 2, '00000004-0000-0000-0000-000000000003'), -- juan: 2 Empanadas
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000002', '00000009-0000-0000-0000-000000000007', 1, '00000004-0000-0000-0000-000000000004'), -- valentina: Combo
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000003', '00000009-0000-0000-0000-000000000005', 1, '00000004-0000-0000-0000-000000000005'), -- andrés: Almuerzo
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000003', '00000009-0000-0000-0000-000000000003', 1, '00000004-0000-0000-0000-000000000005'), -- andrés: Jugo
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000004', '00000009-0000-0000-0000-000000000002', 2, '00000004-0000-0000-0000-000000000006'), -- luisa: 2 Chocolates
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000005', '00000009-0000-0000-0000-000000000008', 1, '00000004-0000-0000-0000-000000000008'), -- daniela: Brownie
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000005', '00000009-0000-0000-0000-000000000009', 1, '00000004-0000-0000-0000-000000000008'), -- daniela: Limonada
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000006', '00000009-0000-0000-0000-000000000010', 1, '00000004-0000-0000-0000-000000000009'), -- miguel: Sopa
    (gen_random_uuid(), '0000000a-0000-0000-0000-000000000007', '00000009-0000-0000-0000-000000000001', 2, '00000004-0000-0000-0000-000000000001'); -- carlos: 2 Cafés

INSERT INTO orders (id_order, id_user, client_name, id_status, total, notes, created_by) VALUES
    ('0000000b-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000003', 'Juan Torres',     '00000001-0000-0000-0000-000000000006', 5500.00,  NULL,                 '00000004-0000-0000-0000-000000000003'), -- entregado
    ('0000000b-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000004', 'Valentina Gómez', '00000001-0000-0000-0000-000000000005', 5000.00,  'Sin azúcar',         '00000004-0000-0000-0000-000000000004'), -- preparado
    ('0000000b-0000-0000-0000-000000000003', '00000004-0000-0000-0000-000000000005', 'Andrés Martínez', '00000001-0000-0000-0000-000000000004', 10000.00, NULL,                 '00000004-0000-0000-0000-000000000005'), -- pendiente
    ('0000000b-0000-0000-0000-000000000004', '00000004-0000-0000-0000-000000000006', 'Luisa Herrera',   '00000001-0000-0000-0000-000000000006', 6000.00,  NULL,                 '00000004-0000-0000-0000-000000000006'), -- entregado
    ('0000000b-0000-0000-0000-000000000005', '00000004-0000-0000-0000-000000000008', 'Daniela Vargas',  '00000001-0000-0000-0000-000000000004', 4500.00,  'Sin hielo',          '00000004-0000-0000-0000-000000000008'), -- pendiente
    ('0000000b-0000-0000-0000-000000000006', '00000004-0000-0000-0000-000000000009', 'Miguel Sánchez',  '00000001-0000-0000-0000-000000000005', 4500.00,  NULL,                 '00000004-0000-0000-0000-000000000009'), -- preparado
    ('0000000b-0000-0000-0000-000000000007', '00000004-0000-0000-0000-000000000001', 'Carlos Ramírez',  '00000001-0000-0000-0000-000000000006', 5000.00,  NULL,                 '00000004-0000-0000-0000-000000000001'), -- entregado
    ('0000000b-0000-0000-0000-000000000008', '00000004-0000-0000-0000-000000000003', 'Juan Torres',     '00000001-0000-0000-0000-000000000007', 3000.00,  NULL,                 '00000004-0000-0000-0000-000000000003'), -- cancelado
    ('0000000b-0000-0000-0000-000000000009', '00000004-0000-0000-0000-000000000005', 'Andrés Martínez', '00000001-0000-0000-0000-000000000006', 8000.00,  'Llevar a salón 203', '00000004-0000-0000-0000-000000000005'), -- entregado
    ('0000000b-0000-0000-0000-000000000010', '00000004-0000-0000-0000-000000000004', 'Valentina Gómez', '00000001-0000-0000-0000-000000000004', 2500.00,  NULL,                 '00000004-0000-0000-0000-000000000004'); -- pendiente

INSERT INTO order_item (id_order_item, id_order, id_product, quantity, unit_price, created_by) VALUES
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000001', '00000009-0000-0000-0000-000000000001', 1, 2500.00, '00000004-0000-0000-0000-000000000003'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000001', '00000009-0000-0000-0000-000000000004', 2, 1500.00, '00000004-0000-0000-0000-000000000003'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000002', '00000009-0000-0000-0000-000000000007', 1, 5000.00, '00000004-0000-0000-0000-000000000004'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000003', '00000009-0000-0000-0000-000000000005', 1, 8000.00, '00000004-0000-0000-0000-000000000005'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000003', '00000009-0000-0000-0000-000000000003', 1, 2000.00, '00000004-0000-0000-0000-000000000005'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000004', '00000009-0000-0000-0000-000000000002', 2, 3000.00, '00000004-0000-0000-0000-000000000006'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000005', '00000009-0000-0000-0000-000000000008', 1, 2500.00, '00000004-0000-0000-0000-000000000008'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000005', '00000009-0000-0000-0000-000000000009', 1, 2000.00, '00000004-0000-0000-0000-000000000008'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000006', '00000009-0000-0000-0000-000000000010', 1, 4500.00, '00000004-0000-0000-0000-000000000009'),
    (gen_random_uuid(), '0000000b-0000-0000-0000-000000000007', '00000009-0000-0000-0000-000000000007', 1, 5000.00, '00000004-0000-0000-0000-000000000001');

-- ================================================================
-- MODULE 5: BILLING
-- ================================================================

INSERT INTO method_payment (id_method, name_method, description, id_status, created_by) VALUES
    ('0000000c-0000-0000-0000-000000000001', 'Efectivo',          'Pago en efectivo en caja',                '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000002', 'Tarjeta Débito',    'Pago con tarjeta débito',                 '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000003', 'Tarjeta Crédito',   'Pago con tarjeta crédito',                '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000004', 'Transferencia',     'Transferencia bancaria o Nequi/Daviplata','00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000005', 'Billetera Digital', 'Nequi, Daviplata, Bancolombia a la mano', '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000006', 'QR Bancolombia',    'Pago por código QR Bancolombia',          '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000007', 'PSE',               'Pago en línea por PSE',                   '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000008', 'Cupón Descuento',   'Pago con cupón de descuento SENA',        '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001'),
    ('0000000c-0000-0000-0000-000000000009', 'Crédito Interno',   'Descuento de nómina o carnet SENA',       '00000001-0000-0000-0000-000000000002', '00000004-0000-0000-0000-000000000001'), -- inactivo
    ('0000000c-0000-0000-0000-000000000010', 'Contra Entrega',    'Pago al recibir el pedido',               '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000001');

INSERT INTO invoice (id_invoice, invoice_number, id_order, total, id_status, created_by) VALUES
    ('0000000d-0000-0000-0000-000000000001', 'FAC-2025-0001', '0000000b-0000-0000-0000-000000000001',  5500.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000002', 'FAC-2025-0002', '0000000b-0000-0000-0000-000000000002',  5000.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000003', 'FAC-2025-0003', '0000000b-0000-0000-0000-000000000003', 10000.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000004', 'FAC-2025-0004', '0000000b-0000-0000-0000-000000000004',  6000.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000005', 'FAC-2025-0005', '0000000b-0000-0000-0000-000000000005',  4500.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000006', 'FAC-2025-0006', '0000000b-0000-0000-0000-000000000006',  4500.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000007', 'FAC-2025-0007', '0000000b-0000-0000-0000-000000000007',  5000.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000008', 'FAC-2025-0008', '0000000b-0000-0000-0000-000000000009',  8000.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000009', 'FAC-2025-0009', '0000000b-0000-0000-0000-000000000010',  2500.00, '00000001-0000-0000-0000-000000000001', '00000004-0000-0000-0000-000000000010'),
    ('0000000d-0000-0000-0000-000000000010', 'FAC-2025-0010', '0000000b-0000-0000-0000-000000000008',  3000.00, '00000001-0000-0000-0000-000000000009', '00000004-0000-0000-0000-000000000010'); -- anulada

INSERT INTO invoice_item (id_invoice_item, id_invoice, id_product, quantity, unit_price) VALUES
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000001', '00000009-0000-0000-0000-000000000001', 1, 2500.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000001', '00000009-0000-0000-0000-000000000004', 2, 1500.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000002', '00000009-0000-0000-0000-000000000007', 1, 5000.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000003', '00000009-0000-0000-0000-000000000005', 1, 8000.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000003', '00000009-0000-0000-0000-000000000003', 1, 2000.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000004', '00000009-0000-0000-0000-000000000002', 2, 3000.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000005', '00000009-0000-0000-0000-000000000008', 1, 2500.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000005', '00000009-0000-0000-0000-000000000009', 1, 2000.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000006', '00000009-0000-0000-0000-000000000010', 1, 4500.00),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000007', '00000009-0000-0000-0000-000000000007', 1, 5000.00);

INSERT INTO payment (id_payment, id_invoice, id_method, amount, status, transaction_ref, paid_at) VALUES
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000001', '0000000c-0000-0000-0000-000000000001',  5500.00, 'pagado',      NULL,            NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000002', '0000000c-0000-0000-0000-000000000005',  5000.00, 'pagado',      'NEQ-20250301',  NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000003', '0000000c-0000-0000-0000-000000000002', 10000.00, 'pagado',      NULL,            NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000004', '0000000c-0000-0000-0000-000000000001',  6000.00, 'pagado',      NULL,            NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000005', '0000000c-0000-0000-0000-000000000006',  4500.00, 'pendiente',   'QR-20250305',   NULL),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000006', '0000000c-0000-0000-0000-000000000004',  4500.00, 'pagado',      'TRF-20250304',  NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000007', '0000000c-0000-0000-0000-000000000001',  5000.00, 'pagado',      NULL,            NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000008', '0000000c-0000-0000-0000-000000000003',  8000.00, 'pagado',      'VISA-20250302', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000009', '0000000c-0000-0000-0000-000000000001',  2500.00, 'pendiente',   NULL,            NULL),
    (gen_random_uuid(), '0000000d-0000-0000-0000-000000000010', '0000000c-0000-0000-0000-000000000001',  3000.00, 'reembolsado', NULL,            NOW() - INTERVAL '1 day');
