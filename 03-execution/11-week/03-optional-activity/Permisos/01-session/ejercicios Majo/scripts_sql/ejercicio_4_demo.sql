-- ============================================================
-- ejercicio_4_demo.sql
-- Ejercicio 04 - Acumulacion de millas y actualizacion del
-- historial de nivel
-- ============================================================
-- Flujo del demo:
--   1. Cuenta FLY-0002-CAR (Carlos Mendoza - Bronze)
--      Carlos tiene 420 millas por FY101 BOG-MDE.
--      Se registra un EARN adicional por vuelo posterior.
--   2. CALL sp_register_miles_transaction para FLY-0002-CAR
--   3. Trigger actualiza loyalty_account.updated_at
--   4. Tres validaciones confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_account_id      uuid;
    v_account_number  varchar(50);
    v_customer_name   varchar(200);
    v_tier_name       varchar(100);
    v_account_upd     timestamptz;
    v_miles_before    integer;
    v_tx_count_before integer;
BEGIN
    -- --------------------------------------------------------
    -- Resolver la cuenta FLY-0002-CAR (Carlos Mendoza, Bronze)
    -- Carlos tiene 1 transaccion EARN de 420 millas (FY101).
    -- Se agrega un segundo EARN limpio para demonstrar el flujo.
    -- --------------------------------------------------------
    SELECT
        la.loyalty_account_id,
        la.account_number,
        p.first_name || ' ' || p.last_name,
        lt.tier_name,
        la.updated_at
    INTO
        v_account_id,
        v_account_number,
        v_customer_name,
        v_tier_name,
        v_account_upd
    FROM loyalty_account la
    JOIN customer c          ON c.customer_id          = la.customer_id
    JOIN person p            ON p.person_id             = c.person_id
    JOIN loyalty_account_tier lat ON lat.loyalty_account_id = la.loyalty_account_id
    JOIN loyalty_tier lt     ON lt.loyalty_tier_id      = lat.loyalty_tier_id
    WHERE la.account_number = 'FLY-0002-CAR';

    IF v_account_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro la cuenta FLY-0002-CAR. Verificar seed canonico.';
    END IF;

    -- Saldo actual de millas y cantidad de transacciones previas
    SELECT
        COALESCE(SUM(mt.miles_delta), 0),
        COUNT(*)
    INTO
        v_miles_before,
        v_tx_count_before
    FROM miles_transaction mt
    WHERE mt.loyalty_account_id = v_account_id;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial de la cuenta:';
    RAISE NOTICE '  loyalty_account_id : %', v_account_id;
    RAISE NOTICE '  account_number     : %', v_account_number;
    RAISE NOTICE '  cliente            : %', v_customer_name;
    RAISE NOTICE '  nivel actual       : %', v_tier_name;
    RAISE NOTICE '  updated_at         : %', v_account_upd;
    RAISE NOTICE '  saldo previo       : % millas', v_miles_before;
    RAISE NOTICE '  transacciones prev : %', v_tx_count_before;
    RAISE NOTICE '  nueva transaccion  : EARN 580 millas (FY120 BOG-MDE)';
    RAISE NOTICE '==========================================';

    CALL sp_register_miles_transaction(
        v_account_id,
        'EARN',
        580,
        TIMESTAMPTZ '2026-04-06 10:05:00-05',
        'TKT-VOL-000001-SEG1',
        'Millas acumuladas FY120 BOG-MDE Economy YB - vuelo vol. 1'
    );

    RAISE NOTICE 'sp_register_miles_transaction ejecutado.';
    RAISE NOTICE 'EARN de 580 millas registrado para cuenta %.', v_account_number;
    RAISE NOTICE 'El trigger actualiza loyalty_account.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Transaccion insertada y loyalty_account.updated_at
-- ============================================================
SELECT
    la.account_number                        AS cuenta,
    la.updated_at                            AS cuenta_updated_at,
    mt.transaction_type                      AS tipo,
    mt.miles_delta                           AS millas,
    mt.occurred_at                           AS fecha_evento,
    mt.reference_code                        AS referencia,
    mt.notes                                 AS observaciones
FROM miles_transaction mt
INNER JOIN loyalty_account la
    ON la.loyalty_account_id = mt.loyalty_account_id
WHERE la.account_number = 'FLY-0002-CAR'
ORDER BY mt.occurred_at;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa cliente -> nivel -> ventas
-- Ejecuta la consulta principal del setup para mostrar
-- el estado completo del programa de fidelizacion
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

-- ============================================================
-- VALIDACION 3: Resumen de millas y nivel por cuenta
-- ============================================================
SELECT
    p.first_name || ' ' || p.last_name      AS cliente,
    la.account_number                        AS cuenta,
    lt.tier_name                             AS nivel_actual,
    la.updated_at                            AS ultima_modificacion_cuenta,
    COUNT(mt.miles_transaction_id)           AS total_transacciones,
    SUM(mt.miles_delta)                      AS saldo_total_millas,
    SUM(CASE WHEN mt.transaction_type = 'EARN'
             THEN mt.miles_delta ELSE 0 END) AS millas_acumuladas,
    SUM(CASE WHEN mt.transaction_type IN ('REDEEM','EXPIRE')
             THEN ABS(mt.miles_delta) ELSE 0 END) AS millas_usadas,
    MAX(mt.occurred_at)                      AS ultima_transaccion
FROM loyalty_account la
INNER JOIN customer c          ON c.customer_id           = la.customer_id
INNER JOIN person p            ON p.person_id              = c.person_id
INNER JOIN loyalty_account_tier lat ON lat.loyalty_account_id = la.loyalty_account_id
INNER JOIN loyalty_tier lt     ON lt.loyalty_tier_id       = lat.loyalty_tier_id
LEFT JOIN  miles_transaction mt ON mt.loyalty_account_id  = la.loyalty_account_id
GROUP BY
    p.first_name, p.last_name,
    la.account_number,
    lt.tier_name,
    la.updated_at
ORDER BY p.last_name, p.first_name;