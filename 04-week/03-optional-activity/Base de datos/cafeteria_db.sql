-- ================================================================
--  SISTEMA DE CAFETERÍA SENA – MODELO DE BASE DE DATOS MODULAR
--  Versión 1.0
-- ================================================================
--
--  /****************************************************
--   * MÓDULOS:                                         *
--   *                                                  *
--   * Module 1: Parameter                              *
--   *   - type_document                               *
--   *   - person                                       *
--   *                                                  *
--   * Module 2: Security                               *
--   *   - user                                         *
--   *   - role                                         *
--   *   - module                                       *
--   *   - view                                         *
--   *   - user_role        (pivot)                     *
--   *   - role_module      (pivot)                     *
--   *   - module_view      (pivot)                     *
--   *                                                  *
--   * Module 3: Inventory                              *
--   *   - category                                     *
--   *   - product                                      *
--   *                                                  *
--   * Module 4: Sales                                  *
--   *   - cart                                         *
--   *   - cart_item                                    *
--   *   - order                                        *
--   *   - order_item                                   *
--   *                                                  *
--   * Module 5: Billing                                *
--   *   - method_payment                               *
--   *   - invoice                                      *
--   *   - invoice_item                                 *
--   *   - payment                                      *
--   ****************************************************/


-- ================================================================
--  MODULE 1: PARAMETER
--  Propósito: Datos base que parametrizan el sistema.
--  RF relacionados: RN1 (actores: aprendiz, instructor, personal)
-- ================================================================

CREATE TABLE type_document (
    id_type_document  SERIAL        PRIMARY KEY,
    code              VARCHAR(10)   NOT NULL UNIQUE,
    name              VARCHAR(60)   NOT NULL,
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW()
);

INSERT INTO type_document (code, name) VALUES
    ('CC',  'Cédula de Ciudadanía'),
    ('TI',  'Tarjeta de Identidad'),
    ('CE',  'Cédula de Extranjería'),
    ('PAS', 'Pasaporte');

-- ----------------------------------------------------------------

CREATE TABLE person (
    id_person         SERIAL        PRIMARY KEY,
    first_name        VARCHAR(80)   NOT NULL,
    last_name         VARCHAR(80)   NOT NULL,
    document_number   VARCHAR(30)   NOT NULL UNIQUE,
    id_type_document  INT           NOT NULL,
    phone             VARCHAR(20),
    email             VARCHAR(120)  UNIQUE,
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP,

    CONSTRAINT fk_person_type_doc
        FOREIGN KEY (id_type_document)
        REFERENCES type_document (id_type_document)
);


-- ================================================================
--  MODULE 2: SECURITY
--  Propósito: Control de acceso, roles y permisos por módulo/vista.
--  RF relacionados: RF-4, RF-5 (solo personal autorizado cambia estados)
-- ================================================================

CREATE TABLE "user" (
    id_user           SERIAL        PRIMARY KEY,
    username          VARCHAR(60)   NOT NULL UNIQUE,
    password_hash     VARCHAR(255)  NOT NULL,
    id_person         INT           NOT NULL UNIQUE,
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP,
    last_login        TIMESTAMP,

    CONSTRAINT fk_user_person
        FOREIGN KEY (id_person) REFERENCES person (id_person)
);

-- ----------------------------------------------------------------

CREATE TABLE role (
    id_role           SERIAL        PRIMARY KEY,
    name_role         VARCHAR(60)   NOT NULL UNIQUE,
    description       VARCHAR(200),
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW()
);

INSERT INTO role (name_role, description) VALUES
    ('Administrador',    'Acceso total al sistema'),
    ('Personal Cafetín', 'Gestión de pedidos y cambio de estados - RF4 RF5'),
    ('Aprendiz',         'Consulta menú y realiza pedidos - RF1 RF2 RF3'),
    ('Instructor',       'Consulta menú y realiza pedidos - RF1 RF2 RF3');

-- ----------------------------------------------------------------

CREATE TABLE "module" (
    id_module         SERIAL        PRIMARY KEY,
    name_module       VARCHAR(80)   NOT NULL UNIQUE,
    description       VARCHAR(200),
    url_prefix        VARCHAR(120),
    icon              VARCHAR(60),
    order_num         SMALLINT      NOT NULL DEFAULT 0,
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------

CREATE TABLE "view" (
    id_view           SERIAL        PRIMARY KEY,
    name_view         VARCHAR(80)   NOT NULL,
    url               VARCHAR(200)  NOT NULL,
    description       VARCHAR(200),
    order_num         SMALLINT      NOT NULL DEFAULT 0,
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------
-- PIVOT: N:M  user <-> role

CREATE TABLE user_role (
    id_user           INT           NOT NULL,
    id_role           INT           NOT NULL,
    assigned_at       TIMESTAMP     NOT NULL DEFAULT NOW(),
    assigned_by       INT,

    PRIMARY KEY (id_user, id_role),
    CONSTRAINT fk_ur_user  FOREIGN KEY (id_user)     REFERENCES "user" (id_user),
    CONSTRAINT fk_ur_role  FOREIGN KEY (id_role)     REFERENCES role   (id_role),
    CONSTRAINT fk_ur_by    FOREIGN KEY (assigned_by) REFERENCES "user" (id_user)
);

-- ----------------------------------------------------------------
-- PIVOT: N:M  role <-> module

CREATE TABLE role_module (
    id_role           INT           NOT NULL,
    id_module         INT           NOT NULL,

    PRIMARY KEY (id_role, id_module),
    CONSTRAINT fk_rm_role   FOREIGN KEY (id_role)   REFERENCES role     (id_role),
    CONSTRAINT fk_rm_module FOREIGN KEY (id_module) REFERENCES "module" (id_module)
);

-- ----------------------------------------------------------------
-- PIVOT: N:M  module <-> view

CREATE TABLE module_view (
    id_module         INT           NOT NULL,
    id_view           INT           NOT NULL,

    PRIMARY KEY (id_module, id_view),
    CONSTRAINT fk_mv_module FOREIGN KEY (id_module) REFERENCES "module" (id_module),
    CONSTRAINT fk_mv_view   FOREIGN KEY (id_view)   REFERENCES "view"   (id_view)
);


-- ================================================================
--  MODULE 3: INVENTORY
--  Propósito: Catálogo de productos y su disponibilidad visible al cliente.
--  RF relacionados: RF-1 (visualizar productos: nombre, precio, disponibilidad)
-- ================================================================

CREATE TABLE category (
    id_category       SERIAL        PRIMARY KEY,
    name_category     VARCHAR(80)   NOT NULL UNIQUE,
    description       VARCHAR(200),
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP
);

INSERT INTO category (name_category) VALUES
    ('Bebidas Calientes'),
    ('Bebidas Frías'),
    ('Alimentos'),
    ('Snacks'),
    ('Combos');

-- ----------------------------------------------------------------

CREATE TABLE product (
    id_product        SERIAL          PRIMARY KEY,
    name_product      VARCHAR(120)    NOT NULL,
    description       TEXT,
    price             NUMERIC(10,2)   NOT NULL CHECK (price >= 0),
    image_url         VARCHAR(255),
    id_category       INT             NOT NULL,
    -- RF-1: estado visible al cliente
    state             VARCHAR(20)     NOT NULL DEFAULT 'Disponible'
                          CHECK (state IN ('Disponible','Agotado','Inactivo')),
    created_at        TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP,

    CONSTRAINT fk_product_category
        FOREIGN KEY (id_category) REFERENCES category (id_category)
);


-- ================================================================
--  MODULE 4: SALES
--  Propósito: Carrito temporal, confirmación y gestión de pedidos.
--  RF relacionados:
--    RF-2 → cart / cart_item  (agregar, modificar, eliminar productos)
--    RF-3 → order / order_item (confirmar pedido con nombre del cliente)
--    RF-4 → order (listar pedidos por orden cronológico al personal)
--    RF-5 → order.status  (Pendiente → Preparado → Entregado)
-- ================================================================

-- RF-2: carrito temporal (1 por usuario activo)
CREATE TABLE cart (
    id_cart           SERIAL        PRIMARY KEY,
    id_user           INT           NOT NULL UNIQUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP,

    CONSTRAINT fk_cart_user FOREIGN KEY (id_user) REFERENCES "user" (id_user)
);

-- ----------------------------------------------------------------

CREATE TABLE cart_item (
    id_cart_item      SERIAL          PRIMARY KEY,
    id_cart           INT             NOT NULL,
    id_product        INT             NOT NULL,
    quantity          INT             NOT NULL DEFAULT 1 CHECK (quantity > 0),

    UNIQUE (id_cart, id_product),

    CONSTRAINT fk_ci_cart    FOREIGN KEY (id_cart)    REFERENCES cart    (id_cart),
    CONSTRAINT fk_ci_product FOREIGN KEY (id_product) REFERENCES product (id_product)
);

-- ----------------------------------------------------------------
-- RF-3: pedido confirmado | RF-4: lista cronológica | RF-5: cambio de estado

CREATE TYPE order_status AS ENUM ('Pendiente','Preparado','Entregado','Cancelado');

CREATE TABLE "order" (
    id_order          SERIAL          PRIMARY KEY,
    id_user           INT             NOT NULL,
    client_name       VARCHAR(160)    NOT NULL,   -- RF-3: identificar al cliente
    status            order_status    NOT NULL DEFAULT 'Pendiente',
    total             NUMERIC(12,2)   NOT NULL DEFAULT 0,
    notes             TEXT,
    created_at        TIMESTAMP       NOT NULL DEFAULT NOW(),   -- RF-4: orden cronológico
    updated_at        TIMESTAMP,
    delivered_at      TIMESTAMP,

    CONSTRAINT fk_order_user FOREIGN KEY (id_user) REFERENCES "user" (id_user)
);

-- ----------------------------------------------------------------

CREATE TABLE order_item (
    id_order_item     SERIAL          PRIMARY KEY,
    id_order          INT             NOT NULL,
    id_product        INT             NOT NULL,
    quantity          INT             NOT NULL CHECK (quantity > 0),
    unit_price        NUMERIC(10,2)   NOT NULL,   -- precio fijo al confirmar (RF-3)
    subtotal          NUMERIC(12,2)   GENERATED ALWAYS AS (quantity * unit_price) STORED,

    CONSTRAINT fk_oi_order   FOREIGN KEY (id_order)   REFERENCES "order"  (id_order),
    CONSTRAINT fk_oi_product FOREIGN KEY (id_product) REFERENCES product  (id_product)
);


-- ================================================================
--  MODULE 5: BILLING
--  Propósito: Métodos de pago, facturación y registro de pagos.
--  RF relacionados: RF-3 (confirmar pedido puede generar factura)
-- ================================================================

CREATE TABLE method_payment (
    id_method         SERIAL        PRIMARY KEY,
    name_method       VARCHAR(60)   NOT NULL UNIQUE,
    description       VARCHAR(200),
    state             BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     NOT NULL DEFAULT NOW()
);

INSERT INTO method_payment (name_method) VALUES
    ('Efectivo'),
    ('Tarjeta Débito'),
    ('Tarjeta Crédito'),
    ('Transferencia Bancaria'),
    ('Billetera Digital');

-- ----------------------------------------------------------------

CREATE TABLE invoice (
    id_invoice        SERIAL          PRIMARY KEY,
    invoice_number    VARCHAR(30)     NOT NULL UNIQUE,
    id_order          INT             NOT NULL UNIQUE,   -- 1:1 con order
    issue_date        TIMESTAMP       NOT NULL DEFAULT NOW(),
    total             NUMERIC(12,2)   NOT NULL,
    state             BOOLEAN         NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_invoice_order FOREIGN KEY (id_order) REFERENCES "order" (id_order)
);

-- ----------------------------------------------------------------

CREATE TABLE invoice_item (
    id_invoice_item   SERIAL          PRIMARY KEY,
    id_invoice        INT             NOT NULL,
    id_product        INT             NOT NULL,
    quantity          INT             NOT NULL CHECK (quantity > 0),
    unit_price        NUMERIC(10,2)   NOT NULL,
    subtotal          NUMERIC(12,2)   GENERATED ALWAYS AS (quantity * unit_price) STORED,

    CONSTRAINT fk_ii_invoice FOREIGN KEY (id_invoice) REFERENCES invoice (id_invoice),
    CONSTRAINT fk_ii_product FOREIGN KEY (id_product) REFERENCES product (id_product)
);

-- ----------------------------------------------------------------

CREATE TYPE payment_status AS ENUM ('Pendiente','Completado','Fallido','Reembolsado');

CREATE TABLE payment (
    id_payment        SERIAL          PRIMARY KEY,
    id_invoice        INT             NOT NULL,
    id_method         INT             NOT NULL,
    amount            NUMERIC(12,2)   NOT NULL CHECK (amount > 0),
    status            payment_status  NOT NULL DEFAULT 'Pendiente',
    transaction_ref   VARCHAR(100),
    paid_at           TIMESTAMP,
    created_at        TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_pay_invoice FOREIGN KEY (id_invoice) REFERENCES invoice        (id_invoice),
    CONSTRAINT fk_pay_method  FOREIGN KEY (id_method)  REFERENCES method_payment  (id_method)
);


-- ================================================================
--  ÍNDICES
-- ================================================================

-- Security
CREATE INDEX idx_user_role_user   ON user_role  (id_user);
CREATE INDEX idx_user_role_role   ON user_role  (id_role);

-- Inventory (RF-1: filtrar productos disponibles rápido)
CREATE INDEX idx_product_state    ON product    (state);
CREATE INDEX idx_product_category ON product    (id_category);

-- Sales (RF-4: listar pedidos cronológicamente)
CREATE INDEX idx_order_status     ON "order"    (status);
CREATE INDEX idx_order_created    ON "order"    (created_at DESC);
CREATE INDEX idx_order_user       ON "order"    (id_user);
CREATE INDEX idx_order_item_order ON order_item (id_order);
CREATE INDEX idx_cart_item_cart   ON cart_item  (id_cart);

-- Billing
CREATE INDEX idx_invoice_order    ON invoice    (id_order);
CREATE INDEX idx_payment_invoice  ON payment    (id_invoice);
