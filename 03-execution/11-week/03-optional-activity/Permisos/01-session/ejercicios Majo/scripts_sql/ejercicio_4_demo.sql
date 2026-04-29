-- ============================================================
-- ejercicio_4_demo.sql
-- Ejercicio 04 - Acumulacion de millas y actualizacion
-- del historial de nivel
-- ============================================================
-- Demuestra el flujo completo usando datos reales del seed:
--
--   SEED CANONICO (00_seed_canonico.sql)
--   - Cuentas de fidelizacion canonicas:
--       FLY-0001-ANA  -> Ana Garcia    (tier GOLD,   50000 millas requeridas)
--       FLY-0002-CAR  -> Carlos Mendoza(tier BRONZE,     0 millas requeridas)
--       FLY-0003-LAU  -> Laura Torres  (tier SILVER, 10000 millas requeridas)
--   - Tiers reales del programa FLY Miles Program:
--       BRONZE -> required_miles =     0  priority_level = 1
--       SILVER -> required_miles = 10000  priority_level = 2
--       GOLD   -> required_miles = 50000  priority_level = 3
--   - Tipos de transaccion permitidos (check del modelo):
--       EARN, REDEEM, ADJUST
--
--   SEED VOLUMETRICO (01_seed_volumetrico.sql)
--   - 250 cuentas adicionales con tiers BRONZE/SILVER/GOLD
--   - Cada cuenta tiene al menos un registro en loyalty_account_tier
--
-- Flujo del demo:
--   1. Busca la cuenta FLY-0002-CAR (Carlos - tier BRONZE)
--      para demostrar un upgrade de BRONZE a SILVER
--   2. Verifica el tier actual de la cuenta antes del demo
--   3. Resuelve el loyalty_account_id real del seed canonico
--   4. Invoca sp_register_miles_transaction para acumular
--      millas suficientes para alcanzar el tier SILVER
--   5. El trigger evalua el saldo total y registra el upgrade
--      en loyalty_account_tier automaticamente
--   6. Las consultas de validacion confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_account_id         uuid;
    v_account_number     varchar(30);
    v_customer_name      text;
    v_current_tier       varchar(60);
    v_current_priority   integer;
    v_total_miles_before bigint;
BEGIN
    -- --------------------------------------------------------
    -- PASO 1: Obtener la cuenta de fidelizacion de Carlos
    -- --------------------------------------------------------
    -- FLY-0002-CAR tiene tier BRONZE (priority_level = 1).
    -- Acumulando 15000 millas (EARN), el saldo superara el
    -- umbral de SILVER (10000) y el trigger registrara
    -- el upgrade en loyalty_account_tier.
    -- Se usa la cuenta canonica para no interferir con los
    -- datos volumetricos.
    -- --------------------------------------------------------
    SELECT
        la.loyalty_account_id,
        la.account_number,
        p.first_name || ' ' || p.last_name
    INTO
        v_account_id,
        v_account_number,
        v_customer_name
    FROM loyalty_account la
    INNER JOIN customer c
        ON c.customer_id = la.customer_id
    INNER JOIN person p
        ON p.person_id = c.person_id
    WHERE la.account_number = 'FLY-0002-CAR';

    IF v_account_id IS NULL THEN
        RAISE EXCEPTION
            'No existe la cuenta FLY-0002-CAR. '
            'Verificar que el seed canonico fue cargado.';
    END IF;

    -- --------------------------------------------------------
    -- PASO 2: Verificar el tier actual de la cuenta
    -- --------------------------------------------------------
    SELECT
        lt.tier_name,
        lt.priority_level
    INTO
        v_current_tier,
        v_current_priority
    FROM loyalty_account_tier lat
    INNER JOIN loyalty_tier lt
        ON lt.loyalty_tier_id = lat.loyalty_tier_id
    WHERE lat.loyalty_account_id = v_account_id
    ORDER BY lat.assigned_at DESC
    LIMIT 1;

    -- --------------------------------------------------------
    -- PASO 3: Verificar saldo de millas antes del demo
    -- --------------------------------------------------------
    SELECT COALESCE(SUM(mt.miles_delta), 0)
    INTO   v_total_miles_before
    FROM   miles_transaction mt
    WHERE  mt.loyalty_account_id = v_account_id;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial de la cuenta:';
    RAISE NOTICE '  loyalty_account_id : %', v_account_id;
    RAISE NOTICE '  account_number     : %', v_account_number;
    RAISE NOTICE '  cliente            : %', v_customer_name;
    RAISE NOTICE '  tier actual        : % (priority %)',
        v_current_tier, v_current_priority;
    RAISE NOTICE '  saldo millas       : %', v_total_miles_before;
    RAISE NOTICE '==========================================';

    -- --------------------------------------------------------
    -- PASO 4: Invocar el procedimiento almacenado
    -- --------------------------------------------------------
    -- sp_register_miles_transaction inserta en miles_transaction.
    -- El trigger AFTER INSERT evalua si el saldo total supera
    -- el umbral de SILVER (10000 millas) y registra el upgrade
    -- en loyalty_account_tier automaticamente.
    --
    -- Transaccion que se registra:
    --   Tipo    : EARN
    --   Delta   : +15000 millas (supera umbral de SILVER: 10000)
    --   Ref     : DEMO-EJ04-UPGRADE-SILVER
    --   Nota    : Acumulacion demo - upgrade BRONZE a SILVER
    -- --------------------------------------------------------
    CALL sp_register_miles_transaction(
        v_account_id,                           -- loyalty_account_id
        'EARN',                                 -- transaction_type
        15000,                                  -- miles_delta (> 0)
        now(),                                  -- occurred_at
        'DEMO-EJ04-UPGRADE-SILVER',             -- reference_code
        'Acumulacion demo: upgrade de BRONZE a SILVER'  -- notes
    );

    RAISE NOTICE 'sp_register_miles_transaction ejecutado.';
    RAISE NOTICE 'Transaccion EARN de 15000 millas registrada.';
    RAISE NOTICE 'El trigger evalua el saldo y registra el upgrade.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Confirmar la transaccion insertada y el
-- saldo total actualizado de la cuenta
-- ============================================================

SELECT
    la.account_number,
    mt.transaction_type,
    mt.miles_delta,
    mt.occurred_at,
    mt.reference_code,
    mt.notes,
    SUM(mt2.miles_delta) OVER (
        PARTITION BY mt2.loyalty_account_id
    )                               AS saldo_total_cuenta
FROM miles_transaction mt
INNER JOIN loyalty_account la
    ON la.loyalty_account_id = mt.loyalty_account_id
INNER JOIN miles_transaction mt2
    ON mt2.loyalty_account_id = mt.loyalty_account_id
WHERE la.account_number = 'FLY-0002-CAR'
  AND mt.reference_code = 'DEMO-EJ04-UPGRADE-SILVER'
ORDER BY mt.occurred_at DESC
LIMIT 1;

-- ============================================================
-- VALIDACION 2: Confirmar el upgrade de tier registrado
-- por el trigger en loyalty_account_tier
-- ============================================================

SELECT
    la.account_number,
    p.first_name || ' ' || p.last_name     AS cliente,
    lt.tier_name                            AS nivel,
    lt.priority_level,
    lt.required_miles                       AS millas_requeridas,
    lat.assigned_at                         AS fecha_asignacion,
    lat.expires_at                          AS vencimiento
FROM loyalty_account_tier lat
INNER JOIN loyalty_account la
    ON la.loyalty_account_id = lat.loyalty_account_id
INNER JOIN loyalty_tier lt
    ON lt.loyalty_tier_id = lat.loyalty_tier_id
INNER JOIN customer c
    ON c.customer_id = la.customer_id
INNER JOIN person p
    ON p.person_id = c.person_id
WHERE la.account_number = 'FLY-0002-CAR'
ORDER BY lat.assigned_at DESC;

-- ============================================================
-- VALIDACION 3: Trazabilidad completa cliente -> cuenta ->
-- programa -> tier actual -> transacciones de millas
-- ============================================================

SELECT
    p.first_name || ' ' || p.last_name     AS cliente,
    la.account_number,
    lp.program_name,
    lt.tier_name                            AS nivel_actual,
    lt.priority_level,
    lat.assigned_at                         AS fecha_asignacion_nivel,
    mt.transaction_type,
    mt.miles_delta,
    mt.reference_code,
    mt.occurred_at                          AS fecha_transaccion
FROM loyalty_account la
INNER JOIN customer c
    ON c.customer_id = la.customer_id
INNER JOIN person p
    ON p.person_id = c.person_id
INNER JOIN loyalty_program lp
    ON lp.loyalty_program_id = la.loyalty_program_id
INNER JOIN loyalty_account_tier lat
    ON lat.loyalty_account_id = la.loyalty_account_id
INNER JOIN loyalty_tier lt
    ON lt.loyalty_tier_id = lat.loyalty_tier_id
INNER JOIN miles_transaction mt
    ON mt.loyalty_account_id = la.loyalty_account_id
WHERE la.account_number = 'FLY-0002-CAR'
  AND lat.assigned_at = (
      SELECT MAX(lat2.assigned_at)
      FROM loyalty_account_tier lat2
      WHERE lat2.loyalty_account_id = la.loyalty_account_id
  )
ORDER BY mt.occurred_at DESC;