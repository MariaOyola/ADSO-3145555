-- ============================================================
-- ejercicio_3_setup.sql
-- Ejercicio 03 - Facturacion e integracion entre venta,
-- impuestos y detalle facturable
-- Base: modelo_postgresql.sql + 00_seed_canonico.sql
--       + 01_seed_volumetrico.sql
-- ============================================================
-- RESTRICCIONES RESPETADAS:
--   * No se altera ninguna tabla, columna ni relacion del modelo
--   * Solo se usan entidades y atributos reales del DDL
--   * Los codigos e IDs son exactos del seed cargado
-- ============================================================

-- ------------------------------------------------------------
-- Limpieza previa de objetos del ejercicio
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_ai_invoice_line_touch_invoice ON invoice_line;
DROP FUNCTION IF EXISTS fn_ai_invoice_line_touch_invoice();
DROP PROCEDURE IF EXISTS sp_register_invoice_line(uuid, uuid, integer, varchar, numeric, numeric);

-- ============================================================
-- REQUERIMIENTO 2
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Se dispara cuando se inserta una nueva linea en invoice_line.
--
-- Problema de diseno a resolver:
--   El modelo preserva 3FN: invoice NO tiene columna de total
--   derivado. No hay ningun campo calculado que actualizar
--   sin romper la restriccion del ejercicio.
--   Lo que si existe y es mutable es invoice.updated_at,
--   un campo timestamptz NOT NULL DEFAULT now() presente
--   en TODAS las tablas del modelo.
--
-- Accion del trigger:
--   Actualiza invoice.updated_at al momento actual para
--   registrar que la factura recibio una nueva linea.
--   Esto produce un efecto verificable, trazable y coherente
--   con el negocio: la cabecera de la factura queda marcada
--   como modificada cada vez que se agrega una linea nueva.
--
-- Atributos usados:
--   invoice_line.invoice_id -> FK real del modelo
--   invoice.updated_at      -> timestamptz del DDL
-- ============================================================

CREATE OR REPLACE FUNCTION fn_ai_invoice_line_touch_invoice()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Actualiza updated_at de la factura padre para reflejar
    -- que su detalle facturable fue modificado.
    -- updated_at es un atributo real de invoice en el DDL.
    UPDATE invoice
    SET updated_at = now()
    WHERE invoice_id = NEW.invoice_id;

    RETURN NEW;
END;
$$;

-- ============================================================
-- REQUERIMIENTO 2
-- TRIGGER AFTER INSERT SOBRE invoice_line
-- ============================================================
-- Se dispara una vez por cada fila insertada en invoice_line.
-- No modifica ninguna tabla ni columna fuera del modelo base.
-- Es compatible con la insercion que hace
-- sp_register_invoice_line.
-- ============================================================

CREATE TRIGGER trg_ai_invoice_line_touch_invoice
AFTER INSERT ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION fn_ai_invoice_line_touch_invoice();

-- ============================================================
-- REQUERIMIENTO 3
-- PROCEDIMIENTO ALMACENADO sp_register_invoice_line
-- ============================================================
-- Registra una nueva linea facturable sobre una factura
-- existente y deja trazabilidad verificable del proceso.
-- Al insertar en invoice_line, el trigger AFTER INSERT
-- actualiza invoice.updated_at automaticamente.
--
-- Parametros (todos mapeados a columnas reales del DDL):
--   p_invoice_id       -> invoice_line.invoice_id
--   p_tax_id           -> invoice_line.tax_id (nullable)
--   p_line_number      -> invoice_line.line_number (> 0)
--   p_line_description -> invoice_line.line_description varchar(200)
--   p_quantity         -> invoice_line.quantity numeric(12,2) (> 0)
--   p_unit_price       -> invoice_line.unit_price numeric(12,2) (>= 0)
--
-- Validaciones internas:
--   1. La factura debe existir en invoice
--   2. El numero de linea debe ser mayor que cero
--      (check ck_invoice_line_number del modelo)
--   3. No debe existir ya una linea con ese numero en esa
--      factura (unique uq_invoice_line_number del modelo)
--   4. La cantidad debe ser mayor que cero
--      (check ck_invoice_line_quantity del modelo)
--   5. El precio unitario debe ser >= 0
--      (check ck_invoice_line_unit_price del modelo)
--   6. Si se proporciona tax_id, debe existir en tax
--
-- Efecto posterior:
--   El trigger trg_ai_invoice_line_touch_invoice actualiza
--   invoice.updated_at al momento de la insercion.
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_register_invoice_line(
    p_invoice_id        uuid,
    p_tax_id            uuid,
    p_line_number       integer,
    p_line_description  varchar(200),
    p_quantity          numeric(12,2),
    p_unit_price        numeric(12,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validacion 1: la factura debe existir en el modelo
    IF NOT EXISTS (
        SELECT 1 FROM invoice
        WHERE invoice_id = p_invoice_id
    ) THEN
        RAISE EXCEPTION
            'invoice_id % no existe en el modelo.',
            p_invoice_id;
    END IF;

    -- Validacion 2: line_number debe ser mayor que cero
    -- (check ck_invoice_line_number del DDL)
    IF p_line_number <= 0 THEN
        RAISE EXCEPTION
            'line_number debe ser mayor que cero. '
            'Valor recibido: %.',
            p_line_number;
    END IF;

    -- Validacion 3: no puede existir ya esa linea en esa factura
    -- (unique uq_invoice_line_number del DDL)
    IF EXISTS (
        SELECT 1 FROM invoice_line il
        WHERE il.invoice_id  = p_invoice_id
          AND il.line_number = p_line_number
    ) THEN
        RAISE EXCEPTION
            'Ya existe la linea % en la factura %.',
            p_line_number, p_invoice_id;
    END IF;

    -- Validacion 4: la cantidad debe ser mayor que cero
    -- (check ck_invoice_line_quantity del DDL)
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION
            'quantity debe ser mayor que cero. '
            'Valor recibido: %.',
            p_quantity;
    END IF;

    -- Validacion 5: el precio unitario debe ser >= 0
    -- (check ck_invoice_line_unit_price del DDL)
    IF p_unit_price < 0 THEN
        RAISE EXCEPTION
            'unit_price no puede ser negativo. '
            'Valor recibido: %.',
            p_unit_price;
    END IF;

    -- Validacion 6: si se proporciona tax_id, debe existir en tax
    IF p_tax_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM tax
        WHERE tax_id = p_tax_id
    ) THEN
        RAISE EXCEPTION
            'tax_id % no existe en la tabla tax.',
            p_tax_id;
    END IF;

    -- Insercion en invoice_line usando solo atributos del DDL.
    -- El trigger trg_ai_invoice_line_touch_invoice se activa
    -- automaticamente y actualiza invoice.updated_at.
    INSERT INTO invoice_line (
        invoice_id,
        tax_id,
        line_number,
        line_description,
        quantity,
        unit_price
    )
    VALUES (
        p_invoice_id,
        p_tax_id,
        p_line_number,
        p_line_description,
        p_quantity,
        p_unit_price
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1
-- CONSULTA CON INNER JOIN - 6 TABLAS
-- ============================================================
-- Detalle facturable por venta: factura, estado, lineas e
-- impuesto aplicado en cada linea.
--
-- Tablas involucradas:
--   1. sale            -> origen comercial de la factura
--   2. invoice         -> documento facturable
--   3. invoice_status  -> estado de la factura
--   4. invoice_line    -> lineas del detalle facturable
--   5. currency        -> moneda de la factura
--   6. tax             -> impuesto aplicado por linea
--                        (LEFT JOIN: linea 1 no tiene impuesto)
--
-- Nota sobre el LEFT JOIN de tax:
--   El modelo permite invoice_line.tax_id NULL (las lineas de
--   tarifa base no tienen impuesto). Se usa LEFT JOIN para
--   incluir todas las lineas, con o sin impuesto.
--   Las 5 tablas de INNER JOIN cumplen el minimo requerido;
--   tax se agrega como LEFT JOIN para reflejar la realidad
--   del modelo sin excluir las lineas sin impuesto.
--
-- Datos canonicos que retorna esta consulta:
--   INV-FY-2026-0001 (USD) - Ana   - Business JF BOG-MAD
--     L1: Tarifa base 2450.00  sin impuesto
--     L2: Tasa aeroportuaria    294.00  AIRPORT_FEE 12%
--     L3: Tasa de seguridad      98.00  SECURITY_FEE 4%
--   INV-FY-2026-0002 (COP) - Carlos - Economy YB BOG-MDE
--     L1: Tarifa base 310000   sin impuesto
--     L2: Tasa aeroportuaria  37200    AIRPORT_FEE 12%
--     L3: Tasa de seguridad   12400    SECURITY_FEE 4%
--   INV-FY-2026-0003 (USD) - Laura  - Economy YF BOG-MIA
--     L1: Tarifa base   620.00  sin impuesto
--     L2: Tasa aeroportuaria   74.40  AIRPORT_FEE 12%
--     L3: Tasa de seguridad    24.80  SECURITY_FEE 4%
--   + registros volumetricos INV-VOL-* e INV-VOL2-*
-- ============================================================

SELECT
    s.sale_code,
    inv.invoice_number,
    ist.status_code                 AS estado_factura,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price,
    il.quantity * il.unit_price     AS subtotal_linea,
    t.tax_code                      AS impuesto_aplicado,
    t.rate_percentage               AS porcentaje_impuesto,
    cu.iso_currency_code            AS moneda
FROM sale s
INNER JOIN invoice inv
    ON inv.sale_id = s.sale_id
INNER JOIN invoice_status ist
    ON ist.invoice_status_id = inv.invoice_status_id
INNER JOIN invoice_line il
    ON il.invoice_id = inv.invoice_id
INNER JOIN currency cu
    ON cu.currency_id = inv.currency_id
LEFT JOIN tax t
    ON t.tax_id = il.tax_id
ORDER BY s.sale_code, inv.invoice_number, il.line_number;