-- ============================================================
-- ejercicio_4_setup.sql
-- Ejercicio 04 - Acumulacion de millas y actualizacion
-- del historial de nivel
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
DROP TRIGGER IF EXISTS trg_ai_miles_transaction_upgrade_tier ON miles_transaction;
DROP FUNCTION IF EXISTS fn_ai_miles_transaction_upgrade_tier();
DROP PROCEDURE IF EXISTS sp_register_miles_transaction(uuid, varchar, integer, timestamptz, varchar, text);

-- ============================================================
-- REQUERIMIENTO 2
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Se dispara cuando se inserta una miles_transaction de tipo
-- EARN o ADJUST positivo sobre una cuenta de fidelizacion.
--
-- Logica:
--   1. Calcula el saldo total acumulado de la cuenta
--      sumando todos los miles_delta de sus transacciones
--   2. Busca el tier de mayor prioridad cuyo required_miles
--      <= saldo total (el tier que le corresponde al cliente)
--   3. Compara con el tier mas reciente registrado en
--      loyalty_account_tier para esa cuenta
--   4. Si el tier que le corresponde es de mayor prioridad
--      que el actual, inserta un nuevo registro en
--      loyalty_account_tier para dejar el historial
--
-- Atributos usados de loyalty_account_tier (exactos del DDL):
--   loyalty_account_id, loyalty_tier_id, assigned_at, expires_at
--
-- Constraint respetado:
--   uq_loyalty_account_tier_point UNIQUE(loyalty_account_id, assigned_at)
--   -> se usa now() con microsegundos, garantiza unicidad
-- ============================================================

CREATE OR REPLACE FUNCTION fn_ai_miles_transaction_upgrade_tier()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_miles        bigint;
    v_target_tier_id     uuid;
    v_target_priority    integer;
    v_current_priority   integer;
    v_program_id         uuid;
    v_expires_at         timestamptz;
BEGIN
    -- Solo actua ante transacciones que suman millas
    -- miles_delta puede ser negativo (REDEEM) o positivo (EARN/ADJUST)
    IF NEW.miles_delta <= 0 THEN
        RETURN NEW;
    END IF;

    -- Obtener el loyalty_program_id de la cuenta
    SELECT la.loyalty_program_id
    INTO   v_program_id
    FROM   loyalty_account la
    WHERE  la.loyalty_account_id = NEW.loyalty_account_id;

    -- Calcular el saldo total acumulado de la cuenta
    -- Suma todos los miles_delta (positivos y negativos)
    SELECT COALESCE(SUM(mt.miles_delta), 0)
    INTO   v_total_miles
    FROM   miles_transaction mt
    WHERE  mt.loyalty_account_id = NEW.loyalty_account_id;

    -- Determinar el tier que le corresponde segun el saldo
    -- El tier de mayor prioridad cuyo required_miles <= saldo total
    SELECT lt.loyalty_tier_id, lt.priority_level
    INTO   v_target_tier_id, v_target_priority
    FROM   loyalty_tier lt
    WHERE  lt.loyalty_program_id = v_program_id
      AND  lt.required_miles     <= v_total_miles
    ORDER BY lt.priority_level DESC
    LIMIT 1;

    IF v_target_tier_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Obtener la prioridad del tier mas reciente de la cuenta
    SELECT lt.priority_level
    INTO   v_current_priority
    FROM   loyalty_account_tier lat
    JOIN   loyalty_tier lt ON lt.loyalty_tier_id = lat.loyalty_tier_id
    WHERE  lat.loyalty_account_id = NEW.loyalty_account_id
    ORDER BY lat.assigned_at DESC
    LIMIT 1;

    -- Solo upgradear si el tier calculado es de mayor prioridad
    IF v_current_priority IS NULL OR v_target_priority > v_current_priority THEN
        -- Calcular expires_at: 1 año desde la asignacion
        v_expires_at := now() + INTERVAL '1 year';

        -- Insertar en loyalty_account_tier
        -- uq_loyalty_account_tier_point es UNIQUE(loyalty_account_id, assigned_at)
        -- now() en PostgreSQL incluye microsegundos: unicidad garantizada
        INSERT INTO loyalty_account_tier (
            loyalty_account_id,
            loyalty_tier_id,
            assigned_at,
            expires_at
        )
        VALUES (
            NEW.loyalty_account_id,
            v_target_tier_id,
            now(),
            v_expires_at
        );
    END IF;

    RETURN NEW;
END;
$$;

-- ============================================================
-- REQUERIMIENTO 2
-- TRIGGER AFTER INSERT SOBRE miles_transaction
-- ============================================================
-- Se dispara una vez por cada fila insertada en
-- miles_transaction. Evalua si el cliente merece un upgrade
-- de tier y lo registra en loyalty_account_tier.
-- No modifica ninguna tabla ni columna del modelo base.
-- Es compatible con la insercion que hace
-- sp_register_miles_transaction.
-- ============================================================

CREATE TRIGGER trg_ai_miles_transaction_upgrade_tier
AFTER INSERT ON miles_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_ai_miles_transaction_upgrade_tier();

-- ============================================================
-- REQUERIMIENTO 3
-- PROCEDIMIENTO ALMACENADO sp_register_miles_transaction
-- ============================================================
-- Registra una transaccion de millas sobre una cuenta de
-- fidelizacion existente y deja la operacion lista para
-- que el trigger evalúe un posible upgrade de tier.
--
-- Parametros (mapeados a columnas reales del DDL):
--   p_loyalty_account_id -> miles_transaction.loyalty_account_id
--   p_transaction_type   -> miles_transaction.transaction_type
--                           Valores validos (check del modelo):
--                           EARN, REDEEM, ADJUST
--   p_miles_delta        -> miles_transaction.miles_delta (≠ 0)
--   p_occurred_at        -> miles_transaction.occurred_at
--   p_reference_code     -> miles_transaction.reference_code (nullable)
--   p_notes              -> miles_transaction.notes (nullable)
--
-- Validaciones internas:
--   1. La cuenta de fidelizacion debe existir en loyalty_account
--   2. El tipo debe ser EARN, REDEEM o ADJUST
--      (check ck_miles_transaction_type del modelo)
--   3. miles_delta no puede ser cero
--      (check ck_miles_delta_non_zero del modelo)
--
-- Efecto posterior:
--   El trigger trg_ai_miles_transaction_upgrade_tier evalua
--   si corresponde un upgrade de nivel y lo registra en
--   loyalty_account_tier.
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_register_miles_transaction(
    p_loyalty_account_id uuid,
    p_transaction_type   varchar(20),
    p_miles_delta        integer,
    p_occurred_at        timestamptz,
    p_reference_code     varchar(60),
    p_notes              text
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validacion 1: la cuenta debe existir en loyalty_account
    IF NOT EXISTS (
        SELECT 1 FROM loyalty_account
        WHERE loyalty_account_id = p_loyalty_account_id
    ) THEN
        RAISE EXCEPTION
            'loyalty_account_id % no existe en el modelo.',
            p_loyalty_account_id;
    END IF;

    -- Validacion 2: el tipo debe ser EARN, REDEEM o ADJUST
    -- (check ck_miles_transaction_type del DDL)
    IF p_transaction_type NOT IN ('EARN', 'REDEEM', 'ADJUST') THEN
        RAISE EXCEPTION
            'transaction_type ''%'' no es valido. '
            'Valores permitidos: EARN, REDEEM, ADJUST.',
            p_transaction_type;
    END IF;

    -- Validacion 3: miles_delta no puede ser cero
    -- (check ck_miles_delta_non_zero del DDL)
    IF p_miles_delta = 0 THEN
        RAISE EXCEPTION
            'miles_delta no puede ser cero. '
            'Use un valor positivo (EARN) o negativo (REDEEM/ADJUST).';
    END IF;

    -- Insercion en miles_transaction usando atributos del DDL.
    -- El trigger AFTER INSERT evalua el saldo total y registra
    -- un upgrade de tier en loyalty_account_tier si corresponde.
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
        COALESCE(p_occurred_at, now()),
        p_reference_code,
        p_notes
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1
-- CONSULTA CON INNER JOIN - 7 TABLAS
-- ============================================================
-- Relacion completa entre cliente, persona, cuenta de
-- fidelizacion, programa, nivel actual e historial de ventas.
--
-- Tablas involucradas:
--   1. customer              -> cliente registrado en la aerolinea
--   2. person                -> identidad real del cliente
--   3. loyalty_account       -> cuenta del programa de millas
--   4. loyalty_program       -> programa al que pertenece
--   5. loyalty_account_tier  -> historial de niveles asignados
--   6. loyalty_tier          -> definicion del nivel (nombre, millas)
--   7. airline               -> aerolinea propietaria del programa
--
-- Datos canonicos que retorna esta consulta:
--   Ana Garcia    - FLY-0001-ANA - FLY Miles Program - GOLD   (50000 miles)
--   Carlos Mendoza- FLY-0002-CAR - FLY Miles Program - BRONZE (0 miles)
--   Laura Torres  - FLY-0003-LAU - FLY Miles Program - SILVER (10000 miles)
--   + 250 cuentas volumetricas con tiers BRONZE/SILVER/GOLD
-- ============================================================

SELECT
    p.first_name || ' ' || p.last_name     AS cliente,
    p.first_name,
    p.last_name,
    la.account_number,
    lp.program_name,
    lt.tier_name                            AS nivel,
    lt.required_miles                       AS millas_requeridas,
    lat.assigned_at                         AS fecha_asignacion_nivel,
    lat.expires_at                          AS vencimiento_nivel,
    al.airline_name
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
INNER JOIN airline al
    ON al.airline_id = lp.airline_id
ORDER BY lat.assigned_at DESC, p.last_name, p.first_name;