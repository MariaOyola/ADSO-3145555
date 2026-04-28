-- ============================================================
-- ejercicio_1_demo.sql
-- Ejercicio 01 - Flujo de check-in y trazabilidad comercial
-- ============================================================
-- Demuestra el flujo completo usando datos reales del seed:
--
--   SEED CANONICO  (00_seed_canonico.sql)
--   - Usuarios reales:
--       diego.ramirez   -> 20000000-0000-0000-0000-000000000001
--       patricia.vargas -> 20000000-0000-0000-0000-000000000002
--   - check_in_status reales:
--       CANCELLED, COMPLETED, OPEN, PENDING, NO_SHOW
--   - boarding_group reales:
--       PRIORITY(1), A(2), B(3), C(4), D(5)
--   - Ticket segments canonicos con check-in ya registrado:
--       74000000-0000-0000-0000-000000000001 (Ana   FY210 BOG-MIA)
--       74000000-0000-0000-0000-000000000002 (Ana   FY711 MIA-MAD)
--       74000000-0000-0000-0000-000000000003 (Carlos FY101 BOG-MDE)
--       74000000-0000-0000-0000-000000000004 (Laura  FY305 BOG-MIA)
--
--   SEED VOLUMETRICO (01_seed_volumetrico.sql)
--   - ticket_segments BB000000-* con check-in BE000000-* (seq 1..1100)
--   - ticket_segments BB000000-* SIN check-in (seq 1101..1200)
--     -> estos son elegibles para el demo
--
-- Flujo del demo:
--   1. Busca un ticket_segment real sin check-in
--   2. Resuelve IDs reales de check_in_status y boarding_group
--   3. Usa al usuario patricia.vargas (ID real del seed)
--   4. Llama a sp_register_check_in con esos IDs reales
--   5. El trigger genera automaticamente el boarding_pass
--   6. La consulta final valida el resultado completo
-- ============================================================

DO $$
DECLARE
    v_ticket_segment_id     uuid;
    v_check_in_status_id    uuid;
    v_boarding_group_id     uuid;
    v_checked_in_by_user_id uuid;
BEGIN
    -- --------------------------------------------------------
    -- PASO 1: Obtener un ticket_segment sin check-in registrado
    -- --------------------------------------------------------
    -- El seed volumetrico crea ticket_segments BB000000-* del
    -- seq 1 al 1200, pero solo inserta check-in para seq 1..1100.
    -- Los seq 1101..1200 quedan disponibles para este demo.
    -- Se usa LEFT JOIN para confirmar que ci.check_in_id IS NULL.
    -- --------------------------------------------------------
    SELECT ts.ticket_segment_id
    INTO   v_ticket_segment_id
    FROM   ticket_segment ts
    LEFT JOIN check_in ci
        ON ci.ticket_segment_id = ts.ticket_segment_id
    WHERE  ci.check_in_id IS NULL
    ORDER BY ts.created_at
    LIMIT 1;

    -- --------------------------------------------------------
    -- PASO 2: Resolver check_in_status real del seed canonico
    -- --------------------------------------------------------
    -- Estados disponibles en check_in_status:
    --   CANCELLED, COMPLETED, OPEN, PENDING, NO_SHOW
    -- Se usa COMPLETED para reflejar un check-in exitoso.
    -- --------------------------------------------------------
    SELECT cis.check_in_status_id
    INTO   v_check_in_status_id
    FROM   check_in_status cis
    WHERE  cis.status_code = 'COMPLETED';

    -- --------------------------------------------------------
    -- PASO 3: Resolver boarding_group real del seed canonico
    -- --------------------------------------------------------
    -- Grupos disponibles: PRIORITY(1), A(2), B(3), C(4), D(5)
    -- Se toma el primero por sequence_no (PRIORITY).
    -- --------------------------------------------------------
    SELECT bg.boarding_group_id
    INTO   v_boarding_group_id
    FROM   boarding_group bg
    ORDER BY bg.sequence_no
    LIMIT 1;

    -- --------------------------------------------------------
    -- PASO 4: Usar patricia.vargas como usuario operativo
    -- --------------------------------------------------------
    -- ID real del seed canonico:
    --   20000000-0000-0000-0000-000000000002
    -- patricia.vargas es SALES_AGENT y ejecuta check-ins
    -- en los datos canonicos (FY210, FY711, FY101, FY305).
    -- --------------------------------------------------------
    SELECT ua.user_account_id
    INTO   v_checked_in_by_user_id
    FROM   user_account ua
    WHERE  ua.username = 'patricia.vargas';

    -- --------------------------------------------------------
    -- Validaciones previas a la ejecucion
    -- --------------------------------------------------------
    IF v_ticket_segment_id IS NULL THEN
        RAISE EXCEPTION
            'No existe ticket_segment disponible sin check-in. '
            'Todos los segmentos ya tienen check-in registrado.';
    END IF;

    IF v_check_in_status_id IS NULL THEN
        RAISE EXCEPTION
            'No se encontro check_in_status con status_code COMPLETED. '
            'Verificar que el seed canonico fue cargado correctamente.';
    END IF;

    -- --------------------------------------------------------
    -- PASO 5: Invocar el procedimiento almacenado
    -- --------------------------------------------------------
    -- sp_register_check_in valida el ticket_segment,
    -- inserta en check_in, y el trigger AFTER INSERT genera
    -- automaticamente el boarding_pass.
    -- --------------------------------------------------------
    CALL sp_register_check_in(
        v_ticket_segment_id,        -- check_in.ticket_segment_id
        v_check_in_status_id,       -- check_in.check_in_status_id  (COMPLETED)
        v_boarding_group_id,        -- check_in.boarding_group_id   (PRIORITY)
        v_checked_in_by_user_id,    -- check_in.checked_in_by_user_id (patricia.vargas)
        now()                       -- check_in.checked_in_at
    );

    RAISE NOTICE 'sp_register_check_in ejecutado exitosamente.';
    RAISE NOTICE 'ticket_segment_id  : %', v_ticket_segment_id;
    RAISE NOTICE 'check_in_status    : COMPLETED';
    RAISE NOTICE 'boarding_group     : PRIORITY';
    RAISE NOTICE 'usuario            : patricia.vargas';
END;
$$;

-- ============================================================
-- VALIDACION: confirmar que check_in y boarding_pass
-- quedaron registrados correctamente en el modelo
-- ============================================================
-- Esta consulta usa INNER JOIN para mostrar unicamente los
-- registros donde el flujo esta completo (check_in + boarding_pass).
-- El boarding_pass fue generado por el trigger, no por insercion
-- manual, lo que prueba que la automatizacion funciona.
-- ============================================================

SELECT
    ci.check_in_id,
    ci.ticket_segment_id,
    ci.checked_in_at,
    cis.status_code                     AS estado_checkin,
    bg.group_code                       AS grupo_abordaje,
    ua.username                         AS registrado_por,
    bp.boarding_pass_id,
    bp.boarding_pass_code,
    bp.barcode_value,
    bp.issued_at                        AS pase_emitido_at
FROM check_in ci
INNER JOIN check_in_status cis
    ON cis.check_in_status_id = ci.check_in_status_id
LEFT JOIN boarding_group bg
    ON bg.boarding_group_id = ci.boarding_group_id
LEFT JOIN user_account ua
    ON ua.user_account_id = ci.checked_in_by_user_id
INNER JOIN boarding_pass bp
    ON bp.check_in_id = ci.check_in_id
ORDER BY ci.created_at DESC
LIMIT 5;