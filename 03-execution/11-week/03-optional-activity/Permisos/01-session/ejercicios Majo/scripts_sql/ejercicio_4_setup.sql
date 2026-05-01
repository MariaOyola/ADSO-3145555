-- ============================================================
-- ejercicio_4_setup.sql
-- Ejercicio 04 - Acumulacion de millas y actualizacion del
-- historial de nivel
-- ============================================================

DROP TRIGGER IF EXISTS trg_ai_miles_transaction_touch_account ON miles_transaction;
DROP FUNCTION IF EXISTS fn_ai_miles_transaction_touch_account();
DROP PROCEDURE IF EXISTS sp_register_miles_transaction(uuid, varchar, integer, timestamptz, varchar, text);

-- ============================================================
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Cada vez que se registra una transaccion de millas en
-- miles_transaction, el trigger actualiza
-- loyalty_account.updated_at para que la cuenta de
-- fidelizacion quede marcada con el timestamp del evento.
-- Esta accion es verificable, no rompe 3FN y es coherente
-- con la trazabilidad del programa: la cuenta refleja que
-- su historial de millas fue modificado.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_ai_miles_transaction_touch_account()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE loyalty_account
    SET updated_at = now()
    WHERE loyalty_account_id = NEW.loyalty_account_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT SOBRE miles_transaction
-- ============================================================
CREATE TRIGGER trg_ai_miles_transaction_touch_account
AFTER INSERT ON miles_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_ai_miles_transaction_touch_account();

-- ============================================================
-- PROCEDIMIENTO sp_register_miles_transaction
-- ============================================================
-- Parametros:
--   p_loyalty_account_id : cuenta de fidelizacion afectada
--   p_transaction_type   : tipo (EARN, REDEEM, ADJUST, EXPIRE)
--   p_miles_delta        : millas a acumular o descontar
--                          (positivo para EARN/ADJUST,
--                           negativo para REDEEM/EXPIRE)
--   p_occurred_at        : fecha y hora del evento
--   p_reference_code     : referencia unica del movimiento
--   p_notes              : notas opcionales
-- Validaciones internas:
--   1. loyalty_account_id debe existir en loyalty_account
--   2. p_transaction_type debe ser un valor valido del modelo
--   3. p_miles_delta no puede ser cero
--   4. p_occurred_at no puede ser nulo
--   5. p_reference_code no puede ser nulo ni vacio
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_register_miles_transaction(
    p_loyalty_account_id uuid,
    p_transaction_type   varchar(20),
    p_miles_delta        integer,
    p_occurred_at        timestamptz,
    p_reference_code     varchar(100),
    p_notes              text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM loyalty_account
        WHERE loyalty_account_id = p_loyalty_account_id
    ) THEN
        RAISE EXCEPTION 'loyalty_account_id % no existe en loyalty_account.', p_loyalty_account_id;
    END IF;

    IF p_transaction_type NOT IN ('EARN', 'REDEEM', 'ADJUST', 'EXPIRE') THEN
        RAISE EXCEPTION 'transaction_type % no es valido. Valores permitidos: EARN, REDEEM, ADJUST, EXPIRE.', p_transaction_type;
    END IF;

    IF p_miles_delta IS NULL OR p_miles_delta = 0 THEN
        RAISE EXCEPTION 'p_miles_delta no puede ser cero ni nulo. Valor recibido: %', p_miles_delta;
    END IF;

    IF p_occurred_at IS NULL THEN
        RAISE EXCEPTION 'p_occurred_at no puede ser nulo.';
    END IF;

    IF p_reference_code IS NULL OR trim(p_reference_code) = '' THEN
        RAISE EXCEPTION 'p_reference_code no puede ser nulo ni vacio.';
    END IF;

    INSERT INTO miles_transaction (
        loyalty_account_id,
        transaction_type,
        miles_delta,
        occurred_at,
        reference_code,
        notes
    )
    VALUES (
        p_loyalty_account_id,
        p_transaction_type,
        p_miles_delta,
        p_occurred_at,
        p_reference_code,
        p_notes
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1 - CONSULTA INNER JOIN - 7 TABLAS
-- ============================================================
-- Tablas involucradas:
--   customer             - cliente registrado en la aerolinea
--   person               - identidad real del cliente
--   loyalty_account      - cuenta de fidelizacion del cliente
--   loyalty_program      - programa al que pertenece la cuenta
--   loyalty_account_tier - nivel activo o historico de la cuenta
--   loyalty_tier         - definicion del nivel (Bronze/Silver/Gold)
--   sale                 - ventas asociadas al cliente via reserva
-- ============================================================
SELECT
    p.first_name || ' ' || p.last_name      AS cliente,
    c.customer_since                         AS cliente_desde,
    cc.category_name                         AS categoria_cliente,
    la.account_number                        AS cuenta_fidelizacion,
    la.opened_at                             AS apertura_cuenta,
    lp.program_name                          AS programa,
    lt.tier_name                             AS nivel,
    lt.tier_code                             AS codigo_nivel,
    lt.required_miles                        AS millas_requeridas,
    lat.assigned_at                          AS nivel_asignado_en,
    lat.expires_at                           AS nivel_expira_en,
    s.sale_code                              AS venta,
    s.sold_at                                AS fecha_venta
FROM customer c
INNER JOIN person p
    ON p.person_id = c.person_id
INNER JOIN customer_category cc
    ON cc.customer_category_id = c.customer_category_id
INNER JOIN loyalty_account la
    ON la.customer_id = c.customer_id
INNER JOIN loyalty_program lp
    ON lp.loyalty_program_id = la.loyalty_program_id
INNER JOIN loyalty_account_tier lat
    ON lat.loyalty_account_id = la.loyalty_account_id
INNER JOIN loyalty_tier lt
    ON lt.loyalty_tier_id = lat.loyalty_tier_id
INNER JOIN sale s
    ON s.reservation_id IN (
        SELECT r.reservation_id
        FROM reservation r
        WHERE r.booked_by_customer_id = c.customer_id
    )
ORDER BY p.last_name, p.first_name, lat.assigned_at DESC;