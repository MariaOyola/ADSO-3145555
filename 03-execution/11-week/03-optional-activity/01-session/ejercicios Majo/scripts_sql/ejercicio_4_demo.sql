-- ============================================================
-- ejercicio_4_demo.sql
-- ============================================================

DO $$
DECLARE
    v_loyalty_account_id uuid;
    v_before timestamp;
BEGIN

    -- 1. Obtener cuenta real
    SELECT loyalty_account_id
    INTO v_loyalty_account_id
    FROM loyalty_account
    LIMIT 1;

    IF v_loyalty_account_id IS NULL THEN
        RAISE EXCEPTION 'No hay cuentas de fidelizacion';
    END IF;

    -- 2. Ver estado antes
    SELECT assigned_at
    INTO v_before
    FROM loyalty_account_tier
    WHERE loyalty_account_id = v_loyalty_account_id
    LIMIT 1;

    RAISE NOTICE 'ANTES: %', v_before;

    -- 3. Ejecutar procedimiento
    CALL sp_register_miles_transaction(
        v_loyalty_account_id,
        500,
        'EARN',
        'Acumulacion por vuelo'
    );

    RAISE NOTICE 'Transaccion registrada';

END;
$$;

-- ============================================================
-- VALIDACION
-- ============================================================

SELECT
    la.loyalty_account_id,
    lat.assigned_at
FROM loyalty_account la
INNER JOIN loyalty_account_tier lat
    ON lat.loyalty_account_id = la.loyalty_account_id
ORDER BY lat.assigned_at DESC
LIMIT 5;