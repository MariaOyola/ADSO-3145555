-- ============================================================
-- ejercicio_4_setup.sql
-- Ejercicio 04 - Acumulacion de millas y niveles
-- ============================================================

-- Limpieza
DROP TRIGGER IF EXISTS trg_ai_miles_transaction ON miles_transaction;
DROP FUNCTION IF EXISTS fn_ai_miles_transaction();
DROP PROCEDURE IF EXISTS sp_register_miles_transaction(uuid, numeric, varchar, varchar);

-- ============================================================
-- FUNCION DEL TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION fn_ai_miles_transaction()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Accion verificable:
    -- actualizar fecha de asignacion del nivel
    UPDATE loyalty_account_tier
    SET assigned_at = now()
    WHERE loyalty_account_id = NEW.loyalty_account_id;

    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT
-- ============================================================

CREATE TRIGGER trg_ai_miles_transaction
AFTER INSERT ON miles_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_ai_miles_transaction();

-- ============================================================
-- PROCEDIMIENTO ALMACENADO
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_register_miles_transaction(
    p_loyalty_account_id uuid,
    p_miles numeric,
    p_type varchar,
    p_description varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    -- Validacion 1
    IF NOT EXISTS (
        SELECT 1 FROM loyalty_account
        WHERE loyalty_account_id = p_loyalty_account_id
    ) THEN
        RAISE EXCEPTION 'Cuenta de fidelizacion no existe';
    END IF;

    -- Validacion 2
    IF p_miles = 0 THEN
        RAISE EXCEPTION 'Las millas no pueden ser 0';
    END IF;

    -- Insercion
    INSERT INTO miles_transaction (
        loyalty_account_id,
        miles_amount,
        transaction_type,
        description,
        created_at
    )
    VALUES (
        p_loyalty_account_id,
        p_miles,
        p_type,
        p_description,
        now()
    );

END;
$$;

-- ============================================================
-- CONSULTA INNER JOIN (MIN 5 TABLAS)
-- ============================================================

SELECT
    c.customer_id,
    p.first_name,
    p.last_name,
    la.loyalty_account_id,
    lp.program_name,
    lt.tier_name,
    lat.assigned_at,
    s.sale_id
FROM customer c
INNER JOIN person p
    ON p.person_id = c.person_id
INNER JOIN loyalty_account la
    ON la.customer_id = c.customer_id
INNER JOIN loyalty_program lp
    ON lp.loyalty_program_id = la.loyalty_program_id
INNER JOIN loyalty_account_tier lat
    ON lat.loyalty_account_id = la.loyalty_account_id
INNER JOIN loyalty_tier lt
    ON lt.loyalty_tier_id = lat.loyalty_tier_id
INNER JOIN sale s
    ON s.customer_id = c.customer_id;