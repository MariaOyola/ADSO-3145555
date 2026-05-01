-- ============================================================
-- ejercicio_2_setup.sql
-- Ejercicio 02 - Control de pagos y trazabilidad de
-- transacciones financieras
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
DROP TRIGGER IF EXISTS trg_ai_payment_transaction_register_refund ON payment_transaction;
DROP FUNCTION IF EXISTS fn_ai_payment_transaction_register_refund();
DROP PROCEDURE IF EXISTS sp_register_payment_transaction(uuid, varchar, numeric, timestamptz, text);

-- ============================================================
-- REQUERIMIENTO 2
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Se dispara cuando se inserta una payment_transaction de tipo
-- REFUND sobre un pago existente.
--
-- Logica:
--   1. Evalua si la nueva transaccion es de tipo REFUND
--   2. Verifica que no exista ya un refund registrado para
--      ese payment_id con la misma transaction_reference
--      (evita duplicados)
--   3. Si no existe, inserta un nuevo registro en refund
--      usando los datos de la transaccion recien insertada
--
-- Atributos usados de refund (exactos del DDL):
--   payment_id, refund_reference, amount,
--   requested_at, processed_at, refund_reason
--
-- Coherencia con el negocio:
--   Cuando el area financiera registra una transaccion de
--   tipo REFUND en payment_transaction, el sistema debe
--   crear automaticamente el registro de devolucion en
--   refund para mantener la trazabilidad completa del
--   ciclo de pago.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_ai_payment_transaction_register_refund()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_refund_reference  varchar(80);
BEGIN
    -- Solo actua ante transacciones de tipo REFUND
    IF NEW.transaction_type <> 'REFUND' THEN
        RETURN NEW;
    END IF;

    -- Construir la referencia del refund a partir de la
    -- referencia de la transaccion para garantizar unicidad
    v_refund_reference := 'RFD-AUTO-' || NEW.transaction_reference;

    -- Verificar que no exista ya un refund con esa referencia
    -- para este pago (evita duplicados ante reinserciones)
    IF EXISTS (
        SELECT 1 FROM refund
        WHERE payment_id       = NEW.payment_id
          AND refund_reference = v_refund_reference
    ) THEN
        RETURN NEW;
    END IF;

    -- Insertar en refund usando atributos reales del DDL.
    -- requested_at = processed_at de la transaccion (momento
    -- en que el proveedor confirmo el reembolso).
    -- refund_reason: mensaje del proveedor de la transaccion.
    INSERT INTO refund (
        payment_id,
        refund_reference,
        amount,
        requested_at,
        processed_at,
        refund_reason
    )
    VALUES (
        NEW.payment_id,
        v_refund_reference,
        NEW.transaction_amount,
        NEW.processed_at,
        NEW.processed_at,
        COALESCE(NEW.provider_message, 'Reembolso registrado automaticamente por transaccion REFUND.')
    );

    RETURN NEW;
END;
$$;

-- ============================================================
-- REQUERIMIENTO 2
-- TRIGGER AFTER INSERT SOBRE payment_transaction
-- ============================================================
-- Se dispara una vez por cada fila insertada en
-- payment_transaction. Si el tipo es REFUND, crea
-- automaticamente el registro en refund.
-- No modifica ninguna tabla ni columna del modelo base.
-- Es compatible con la insercion que hace
-- sp_register_payment_transaction.
-- ============================================================

CREATE TRIGGER trg_ai_payment_transaction_register_refund
AFTER INSERT ON payment_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_ai_payment_transaction_register_refund();

-- ============================================================
-- REQUERIMIENTO 3
-- PROCEDIMIENTO ALMACENADO sp_register_payment_transaction
-- ============================================================
-- Registra una transaccion financiera sobre un pago existente
-- y deja la operacion lista para que el trigger evalúe si
-- debe crear un registro de devolucion en refund.
--
-- Parametros (mapeados a columnas reales del DDL):
--   p_payment_id           -> payment_transaction.payment_id
--   p_transaction_type     -> payment_transaction.transaction_type
--                             Valores validos del modelo:
--                             AUTH, CAPTURE, REFUND, CHARGEBACK
--   p_transaction_amount   -> payment_transaction.transaction_amount
--   p_processed_at         -> payment_transaction.processed_at
--   p_provider_message     -> payment_transaction.provider_message (nullable)
--
-- Validaciones internas:
--   1. El pago debe existir en payment
--   2. El tipo de transaccion debe ser valido segun el modelo
--   3. El monto de la transaccion debe ser mayor que cero
--
-- Efecto posterior:
--   El trigger trg_ai_payment_transaction_register_refund
--   evalua si la transaccion es de tipo REFUND y, si es asi,
--   inserta automaticamente en refund.
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_register_payment_transaction(
    p_payment_id           uuid,
    p_transaction_type     varchar(30),
    p_transaction_amount   numeric(12,2),
    p_processed_at         timestamptz,
    p_provider_message     text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tx_reference  varchar(100);
BEGIN
    -- Validacion 1: el pago debe existir en payment
    IF NOT EXISTS (
        SELECT 1 FROM payment
        WHERE payment_id = p_payment_id
    ) THEN
        RAISE EXCEPTION
            'payment_id % no existe en el modelo.',
            p_payment_id;
    END IF;

    -- Validacion 2: el tipo de transaccion debe ser valido
    -- Valores coherentes con el modelo y el seed:
    -- AUTH, CAPTURE, REFUND, CHARGEBACK
    IF p_transaction_type NOT IN ('AUTH', 'CAPTURE', 'REFUND', 'CHARGEBACK') THEN
        RAISE EXCEPTION
            'transaction_type ''%'' no es valido. '
            'Valores permitidos: AUTH, CAPTURE, REFUND, CHARGEBACK.',
            p_transaction_type;
    END IF;

    -- Validacion 3: el monto debe ser mayor que cero
    IF p_transaction_amount <= 0 THEN
        RAISE EXCEPTION
            'transaction_amount debe ser mayor que cero. '
            'Valor recibido: %.',
            p_transaction_amount;
    END IF;

    -- Generar referencia unica para la transaccion
    -- usando el payment_id y el tipo mas el timestamp
    v_tx_reference := 'TXN-AUTO-'
        || p_transaction_type
        || '-'
        || to_char(COALESCE(p_processed_at, now()), 'YYYYMMDD-HH24MISS')
        || '-'
        || left(p_payment_id::text, 8);

    -- Insercion en payment_transaction usando atributos del DDL.
    -- El trigger AFTER INSERT evalua si es REFUND y registra
    -- automaticamente en refund si corresponde.
    INSERT INTO payment_transaction (
        payment_id,
        transaction_reference,
        transaction_type,
        transaction_amount,
        processed_at,
        provider_message
    )
    VALUES (
        p_payment_id,
        v_tx_reference,
        p_transaction_type,
        p_transaction_amount,
        COALESCE(p_processed_at, now()),
        p_provider_message
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1
-- CONSULTA CON INNER JOIN - 6 TABLAS
-- ============================================================
-- Ciclo completo de pago por venta: reserva, venta, pago,
-- estado, metodo, transacciones financieras y moneda.
--
-- Tablas involucradas:
--   1. reservation        -> origen comercial de la venta
--   2. sale               -> documento de venta
--   3. payment            -> pago registrado sobre la venta
--   4. payment_status     -> estado actual del pago
--   5. payment_method     -> metodo de pago utilizado
--   6. payment_transaction-> transacciones financieras del pago
--   7. currency           -> moneda de la operacion
--                           (INNER JOIN: toda venta tiene moneda)
--
-- Datos canonicos que retorna esta consulta:
--   SAL-20260305-001 (USD) - Ana   - PAY-20260305-001
--     TXN AUTH  2842.00  Autorizacion aprobada
--     TXN CAP   2842.00  Captura confirmada
--   SAL-20260310-001 (COP) - Carlos - PAY-20260310-001
--     TXN CAP   359600   Debito inmediato procesado
--   SAL-20260312-001 (USD) - Laura  - PAY-20260312-001
--     TXN AUTH   719.20  Autorizacion aprobada
--     TXN CAP    719.20  Captura confirmada
--   + registros volumetricos PAY-VOL-* y PAY-VOL2-*
-- ============================================================

SELECT
    r.reservation_code,
    s.sale_code,
    p.payment_reference,
    ps.status_name                  AS estado_pago,
    pm.method_name                  AS metodo_pago,
    pt.transaction_reference,
    pt.transaction_type             AS tipo_transaccion,
    pt.transaction_amount           AS monto_transaccion,
    pt.processed_at                 AS fecha_procesamiento,
    pt.provider_message             AS mensaje_proveedor,
    cu.iso_currency_code            AS moneda
FROM reservation r
INNER JOIN sale s
    ON s.reservation_id = r.reservation_id
INNER JOIN payment p
    ON p.sale_id = s.sale_id
INNER JOIN payment_status ps
    ON ps.payment_status_id = p.payment_status_id
INNER JOIN payment_method pm
    ON pm.payment_method_id = p.payment_method_id
INNER JOIN payment_transaction pt
    ON pt.payment_id = p.payment_id
INNER JOIN currency cu
    ON cu.currency_id = p.currency_id
ORDER BY s.sale_code, p.payment_reference, pt.processed_at;