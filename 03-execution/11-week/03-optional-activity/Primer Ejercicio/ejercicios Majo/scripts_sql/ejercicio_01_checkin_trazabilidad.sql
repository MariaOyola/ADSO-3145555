-- ============================================================
-- EJERCICIO 01 - Flujo de check-in y trazabilidad comercial
-- del pasajero
-- Base de datos: PostgreSQL 16
-- Esquema: public (modelo base sin modificaciones)
-- ============================================================
-- RESTRICCIONES RESPETADAS:
--   * No se alteran tablas ni columnas existentes
--   * No se crean entidades fuera del modelo base
--   * Solo se usan atributos y relaciones reales del DDL
-- ============================================================


-- ===========================================================
-- REQUERIMIENTO 1
-- Consulta con INNER JOIN de al menos 5 tablas
-- Trazabilidad: reserva -> pasajero -> tiquete ->
--               segmento -> vuelo
-- ===========================================================

/*
  TABLAS INVOLUCRADAS (7 tablas):
    1. reservation             -> código de reserva
    2. reservation_passenger   -> secuencia del pasajero en la reserva
    3. person                  -> nombre del pasajero
    4. ticket                  -> número de tiquete
    5. ticket_segment          -> segmento del tiquete
    6. flight_segment          -> hora programada de salida / llegada
    7. flight                  -> número y fecha de vuelo

  PROPÓSITO:
    Mostrar los pasajeros asociados a un vuelo, indicando la
    reserva, el tiquete, el segmento y la fecha del servicio.
*/

SELECT
    r.reservation_code                          AS codigo_reserva,
    f.flight_number                             AS numero_vuelo,
    f.service_date                              AS fecha_servicio,
    t.ticket_number                             AS numero_tiquete,
    rp.passenger_sequence_no                    AS secuencia_pasajero,
    p.first_name || ' ' || p.last_name          AS nombre_pasajero,
    ts.segment_sequence_no                      AS segmento_tiquete,
    fs.scheduled_departure_at                   AS hora_salida_programada,
    fs.scheduled_arrival_at                     AS hora_llegada_programada
FROM reservation                r
INNER JOIN reservation_passenger rp
       ON  rp.reservation_id    = r.reservation_id
INNER JOIN person                p
       ON  p.person_id          = rp.person_id
INNER JOIN ticket                t
       ON  t.reservation_passenger_id = rp.reservation_passenger_id
INNER JOIN ticket_segment        ts
       ON  ts.ticket_id         = t.ticket_id
INNER JOIN flight_segment        fs
       ON  fs.flight_segment_id = ts.flight_segment_id
INNER JOIN flight                f
       ON  f.flight_id          = fs.flight_id
ORDER BY
    f.service_date,
    f.flight_number,
    rp.passenger_sequence_no,
    ts.segment_sequence_no;

-- ----------------------------------------------------------------
-- Variante filtrada: pasajeros de un vuelo específico
-- (útil para operación diaria; reemplazar el número de vuelo)
-- ----------------------------------------------------------------
/*
SELECT
    r.reservation_code,
    f.flight_number,
    f.service_date,
    t.ticket_number,
    rp.passenger_sequence_no,
    p.first_name || ' ' || p.last_name  AS nombre_pasajero,
    ts.segment_sequence_no,
    fs.scheduled_departure_at,
    fs.scheduled_arrival_at
FROM reservation                r
INNER JOIN reservation_passenger rp  ON rp.reservation_id           = r.reservation_id
INNER JOIN person                p   ON p.person_id                 = rp.person_id
INNER JOIN ticket                t   ON t.reservation_passenger_id  = rp.reservation_passenger_id
INNER JOIN ticket_segment        ts  ON ts.ticket_id                = t.ticket_id
INNER JOIN flight_segment        fs  ON fs.flight_segment_id        = ts.flight_segment_id
INNER JOIN flight                f   ON f.flight_id                 = fs.flight_id
WHERE f.flight_number = 'FY120'          -- <-- reemplazar por el vuelo deseado
ORDER BY rp.passenger_sequence_no, ts.segment_sequence_no;
*/


-- ===========================================================
-- REQUERIMIENTO 2
-- Trigger AFTER INSERT sobre check_in
-- Acción: generar automáticamente el registro en boarding_pass
-- ===========================================================

-- -----------------------------------------------------------
-- 2.1 Función auxiliar del trigger
--     Genera boarding_pass_code y barcode_value únicos
--     a partir del check_in_id recién insertado.
--     No modifica ninguna tabla o columna del modelo base.
-- -----------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_generar_boarding_pass()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_boarding_pass_code  varchar(40);
    v_barcode_value       varchar(120);
BEGIN
    /*
      Construye códigos únicos combinando:
        - prefijo fijo 'BP'
        - los primeros 8 caracteres del check_in_id (UUID)
        - timestamp en microsegundos para unicidad garantizada
      Usa únicamente atributos de boarding_pass definidos en
      el modelo base: check_in_id, boarding_pass_code,
      barcode_value, issued_at.
    */

    v_boarding_pass_code := 'BP-'
        || upper(substring(NEW.check_in_id::text, 1, 8))
        || '-'
        || to_char(now(), 'YYYYMMDDHH24MISSUS');

    v_barcode_value := 'BARCODE-'
        || upper(replace(NEW.check_in_id::text, '-', ''))
        || '-'
        || extract(epoch from now())::bigint::text;

    INSERT INTO boarding_pass (
        boarding_pass_id,
        check_in_id,
        boarding_pass_code,
        barcode_value,
        issued_at,
        created_at,
        updated_at
    )
    VALUES (
        gen_random_uuid(),
        NEW.check_in_id,
        v_boarding_pass_code,
        v_barcode_value,
        now(),
        now(),
        now()
    );

    RETURN NEW;
END;
$$;


-- -----------------------------------------------------------
-- 2.2 Trigger AFTER INSERT sobre check_in
--     Se dispara una vez por cada fila insertada.
--     Compatible con el procedimiento almacenado del
--     Requerimiento 3.
-- -----------------------------------------------------------

DROP TRIGGER IF EXISTS trg_after_checkin_generar_boarding_pass
    ON check_in;

CREATE TRIGGER trg_after_checkin_generar_boarding_pass
    AFTER INSERT
    ON check_in
    FOR EACH ROW
    EXECUTE FUNCTION fn_generar_boarding_pass();


-- -----------------------------------------------------------
-- 2.3 Script de prueba del trigger
--     Dispara el trigger de forma aislada usando datos
--     reales del seed volumétrico (TKT-VOL1-*).
--     Valida que boarding_pass quede registrado.
-- -----------------------------------------------------------

DO $$
DECLARE
    v_ticket_segment_id   uuid;
    v_check_in_status_id  uuid;
    v_boarding_group_id   uuid;
    v_user_account_id     uuid;
    v_check_in_id         uuid;
    v_bp_code             varchar(40);
BEGIN

    -- 1) Obtener un ticket_segment que NO tenga check_in aún
    --    (del seed VOL1, que no tiene check-in pre-cargado)
    SELECT ts.ticket_segment_id
    INTO   v_ticket_segment_id
    FROM   ticket_segment ts
    JOIN   ticket t ON t.ticket_id = ts.ticket_id
    WHERE  t.ticket_number LIKE 'TKT-VOL1-%'
      AND  NOT EXISTS (
               SELECT 1 FROM check_in ci
               WHERE ci.ticket_segment_id = ts.ticket_segment_id
           )
    LIMIT 1;

    IF v_ticket_segment_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró ticket_segment disponible para la prueba del trigger.';
    END IF;

    -- 2) Obtener un check_in_status válido
    SELECT check_in_status_id
    INTO   v_check_in_status_id
    FROM   check_in_status
    LIMIT 1;

    -- 3) Obtener un boarding_group (opcional, puede ser NULL)
    SELECT boarding_group_id
    INTO   v_boarding_group_id
    FROM   boarding_group
    ORDER BY sequence_no
    LIMIT 1;

    -- 4) Obtener un usuario válido
    SELECT user_account_id
    INTO   v_user_account_id
    FROM   user_account
    LIMIT 1;

    -- 5) Insertar en check_in → dispara el trigger automáticamente
    v_check_in_id := gen_random_uuid();

    INSERT INTO check_in (
        check_in_id,
        ticket_segment_id,
        check_in_status_id,
        boarding_group_id,
        checked_in_by_user_id,
        checked_in_at,
        created_at,
        updated_at
    )
    VALUES (
        v_check_in_id,
        v_ticket_segment_id,
        v_check_in_status_id,
        v_boarding_group_id,
        v_user_account_id,
        now(),
        now(),
        now()
    );

    -- 6) Verificar que el trigger generó el boarding_pass
    SELECT boarding_pass_code
    INTO   v_bp_code
    FROM   boarding_pass
    WHERE  check_in_id = v_check_in_id;

    IF v_bp_code IS NULL THEN
        RAISE EXCEPTION 'FALLO: el trigger no generó el boarding_pass para check_in_id = %', v_check_in_id;
    ELSE
        RAISE NOTICE 'OK: Trigger ejecutado correctamente.';
        RAISE NOTICE '    check_in_id       = %', v_check_in_id;
        RAISE NOTICE '    boarding_pass_code = %', v_bp_code;
    END IF;

END;
$$;

-- Consulta de validación post-prueba
SELECT
    ci.check_in_id,
    ci.ticket_segment_id,
    ci.checked_in_at,
    bp.boarding_pass_code,
    bp.barcode_value,
    bp.issued_at
FROM check_in    ci
JOIN boarding_pass bp ON bp.check_in_id = ci.check_in_id
WHERE ci.checked_in_at >= now() - interval '5 minutes'
ORDER BY ci.checked_in_at DESC
LIMIT 5;


-- ===========================================================
-- REQUERIMIENTO 3
-- Procedimiento almacenado: sp_registrar_checkin
-- Encapsula el registro completo del check-in de un pasajero
-- que ya tiene un ticket_segment válido.
-- ===========================================================

/*
  PARÁMETROS DE ENTRADA:
    p_ticket_segment_id      uuid   -> ticket_segment a registrar
    p_check_in_status_code   varchar-> código del estado (ej: 'CHECKED_IN')
    p_boarding_group_code    varchar-> código del grupo de abordaje (opcional)
    p_user_account_id        uuid   -> usuario que ejecuta el check-in
    p_checked_in_at          timestamptz -> fecha/hora del check-in

  PARÁMETROS DE SALIDA:
    p_check_in_id            uuid   -> ID del check_in generado
    p_boarding_pass_code     varchar-> código del pase de abordar creado
                                       por el trigger

  FLUJO INTERNO:
    1. Valida que el ticket_segment exista y no tenga check_in previo
    2. Resuelve el check_in_status_id a partir del código
    3. Resuelve el boarding_group_id (si se proporciona)
    4. Inserta en check_in  →  el trigger AFTER INSERT genera
       automáticamente el boarding_pass
    5. Retorna el check_in_id y el boarding_pass_code generado
*/

CREATE OR REPLACE PROCEDURE sp_registrar_checkin(
    IN  p_ticket_segment_id    uuid,
    IN  p_check_in_status_code varchar(20),
    IN  p_boarding_group_code  varchar(10),
    IN  p_user_account_id      uuid,
    IN  p_checked_in_at        timestamptz,
    OUT p_check_in_id          uuid,
    OUT p_boarding_pass_code   varchar(40)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_check_in_status_id   uuid;
    v_boarding_group_id    uuid;
    v_existing_checkin     uuid;
BEGIN

    -- ---------------------------------------------------
    -- Validación 1: el ticket_segment debe existir
    -- ---------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 FROM ticket_segment
        WHERE ticket_segment_id = p_ticket_segment_id
    ) THEN
        RAISE EXCEPTION
            'ticket_segment_id % no existe en el modelo.',
            p_ticket_segment_id;
    END IF;

    -- ---------------------------------------------------
    -- Validación 2: no debe existir check_in previo
    --   (restricción UNIQUE del modelo base)
    -- ---------------------------------------------------
    SELECT check_in_id
    INTO   v_existing_checkin
    FROM   check_in
    WHERE  ticket_segment_id = p_ticket_segment_id;

    IF v_existing_checkin IS NOT NULL THEN
        RAISE EXCEPTION
            'Ya existe un check_in (%) para ticket_segment_id %.',
            v_existing_checkin,
            p_ticket_segment_id;
    END IF;

    -- ---------------------------------------------------
    -- Resolución del check_in_status_id
    -- ---------------------------------------------------
    SELECT check_in_status_id
    INTO   v_check_in_status_id
    FROM   check_in_status
    WHERE  status_code = p_check_in_status_code;

    IF v_check_in_status_id IS NULL THEN
        RAISE EXCEPTION
            'status_code ''%'' no existe en check_in_status.',
            p_check_in_status_code;
    END IF;

    -- ---------------------------------------------------
    -- Resolución del boarding_group_id (opcional)
    -- ---------------------------------------------------
    IF p_boarding_group_code IS NOT NULL THEN
        SELECT boarding_group_id
        INTO   v_boarding_group_id
        FROM   boarding_group
        WHERE  group_code = p_boarding_group_code;

        IF v_boarding_group_id IS NULL THEN
            RAISE EXCEPTION
                'boarding_group_code ''%'' no existe en boarding_group.',
                p_boarding_group_code;
        END IF;
    END IF;

    -- ---------------------------------------------------
    -- Inserción en check_in
    -- El trigger trg_after_checkin_generar_boarding_pass
    -- genera el boarding_pass automáticamente.
    -- ---------------------------------------------------
    p_check_in_id := gen_random_uuid();

    INSERT INTO check_in (
        check_in_id,
        ticket_segment_id,
        check_in_status_id,
        boarding_group_id,
        checked_in_by_user_id,
        checked_in_at,
        created_at,
        updated_at
    )
    VALUES (
        p_check_in_id,
        p_ticket_segment_id,
        v_check_in_status_id,
        v_boarding_group_id,
        p_user_account_id,
        COALESCE(p_checked_in_at, now()),
        now(),
        now()
    );

    -- ---------------------------------------------------
    -- Recuperar el boarding_pass generado por el trigger
    -- ---------------------------------------------------
    SELECT boarding_pass_code
    INTO   p_boarding_pass_code
    FROM   boarding_pass
    WHERE  check_in_id = p_check_in_id;

END;
$$;


-- ===========================================================
-- REQUERIMIENTO 3 - Script de invocación del procedimiento
-- ===========================================================

DO $$
DECLARE
    -- Variables para resolver IDs reales del modelo
    v_ticket_segment_id   uuid;
    v_user_account_id     uuid;

    -- Variables de salida del procedimiento
    v_check_in_id         uuid;
    v_boarding_pass_code  varchar(40);
BEGIN

    -- -------------------------------------------------------
    -- PASO 1: Identificar un ticket_segment elegible
    --   Criterios:
    --     - Pertenece a un ticket del seed VOL1
    --     - No tiene check_in previo registrado
    -- -------------------------------------------------------
    SELECT ts.ticket_segment_id
    INTO   v_ticket_segment_id
    FROM   ticket_segment ts
    JOIN   ticket t ON t.ticket_id = ts.ticket_id
    WHERE  t.ticket_number LIKE 'TKT-VOL1-%'
      AND  NOT EXISTS (
               SELECT 1 FROM check_in ci
               WHERE ci.ticket_segment_id = ts.ticket_segment_id
           )
    ORDER BY ts.ticket_segment_id
    LIMIT 1;

    IF v_ticket_segment_id IS NULL THEN
        RAISE EXCEPTION
            'No se encontró un ticket_segment disponible para invocar el procedimiento.';
    END IF;

    RAISE NOTICE 'ticket_segment_id seleccionado: %', v_ticket_segment_id;

    -- -------------------------------------------------------
    -- PASO 2: Obtener un usuario operativo válido
    -- -------------------------------------------------------
    SELECT user_account_id
    INTO   v_user_account_id
    FROM   user_account
    LIMIT 1;

    RAISE NOTICE 'user_account_id seleccionado:   %', v_user_account_id;

    -- -------------------------------------------------------
    -- PASO 3: Invocar el procedimiento almacenado
    --   - status_code   'CHECKED_IN'  -> debe existir en seed
    --   - group_code    'GRP-A'       -> debe existir en seed
    --     Si no existe en tu seed, cambia al código real o usa NULL
    -- -------------------------------------------------------
    CALL sp_registrar_checkin(
        p_ticket_segment_id    => v_ticket_segment_id,
        p_check_in_status_code => 'CHECKED_IN',
        p_boarding_group_code  => NULL,           -- ajustar al código real del seed
        p_user_account_id      => v_user_account_id,
        p_checked_in_at        => now(),
        p_check_in_id          => v_check_in_id,
        p_boarding_pass_code   => v_boarding_pass_code
    );

    -- -------------------------------------------------------
    -- PASO 4: Evidencia del resultado
    -- -------------------------------------------------------
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Procedimiento ejecutado correctamente.';
    RAISE NOTICE '  check_in_id       = %', v_check_in_id;
    RAISE NOTICE '  boarding_pass_code = %', v_boarding_pass_code;
    RAISE NOTICE '==========================================';

END;
$$;


-- ===========================================================
-- CONSULTAS DE VALIDACIÓN FINALES
-- Verifican el flujo completo end-to-end
-- ===========================================================

-- -----------------------------------------------------------
-- V1: Verificar check_ins recientes con su boarding_pass
--     Evidencia que el trigger y el procedimiento funcionan
-- -----------------------------------------------------------
SELECT
    ci.check_in_id,
    ci.checked_in_at,
    cis.status_code                             AS estado_checkin,
    bg.group_code                               AS grupo_abordaje,
    ts.segment_sequence_no                      AS segmento,
    t.ticket_number,
    bp.boarding_pass_code,
    bp.barcode_value,
    bp.issued_at                                AS pase_emitido_at
FROM check_in       ci
JOIN check_in_status  cis ON cis.check_in_status_id = ci.check_in_status_id
LEFT JOIN boarding_group bg ON bg.boarding_group_id  = ci.boarding_group_id
JOIN ticket_segment   ts  ON ts.ticket_segment_id   = ci.ticket_segment_id
JOIN ticket           t   ON t.ticket_id             = ts.ticket_id
LEFT JOIN boarding_pass bp ON bp.check_in_id         = ci.check_in_id
WHERE ci.checked_in_at >= now() - interval '10 minutes'
ORDER BY ci.checked_in_at DESC;

-- -----------------------------------------------------------
-- V2: Trazabilidad completa del pasajero recién registrado
--     reserva -> tiquete -> segmento -> vuelo -> check_in
--     -> boarding_pass
-- -----------------------------------------------------------
SELECT
    r.reservation_code,
    p.first_name || ' ' || p.last_name          AS pasajero,
    f.flight_number,
    f.service_date,
    t.ticket_number,
    ts.segment_sequence_no,
    fs.scheduled_departure_at,
    cis.status_code                             AS estado_checkin,
    bp.boarding_pass_code,
    bp.issued_at                                AS pase_emitido_at
FROM check_in        ci
JOIN check_in_status   cis ON cis.check_in_status_id    = ci.check_in_status_id
JOIN ticket_segment    ts  ON ts.ticket_segment_id      = ci.ticket_segment_id
JOIN ticket            t   ON t.ticket_id               = ts.ticket_id
JOIN reservation_passenger rp
                           ON rp.reservation_passenger_id = t.reservation_passenger_id
JOIN person            p   ON p.person_id               = rp.person_id
JOIN reservation       r   ON r.reservation_id          = rp.reservation_id
JOIN flight_segment    fs  ON fs.flight_segment_id      = ts.flight_segment_id
JOIN flight            f   ON f.flight_id               = fs.flight_id
LEFT JOIN boarding_pass bp ON bp.check_in_id            = ci.check_in_id
WHERE ci.checked_in_at >= now() - interval '10 minutes'
ORDER BY ci.checked_in_at DESC;

-- -----------------------------------------------------------
-- V3: Conteo de boarding_passes generados por el trigger
--     en la sesión actual (últimos 10 minutos)
-- -----------------------------------------------------------
SELECT
    count(*) AS boarding_passes_generados_hoy,
    min(bp.issued_at) AS primer_pase,
    max(bp.issued_at) AS ultimo_pase
FROM boarding_pass bp
WHERE bp.issued_at >= now() - interval '10 minutes';
