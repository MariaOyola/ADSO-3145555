-- ============================================================
-- ejercicio_6_setup.sql
-- Ejercicio 06 - Retrasos operativos y analisis de impacto
-- por segmento de vuelo
-- ============================================================

DROP TRIGGER IF EXISTS trg_ai_flight_delay_update_segment ON flight_delay;
DROP FUNCTION IF EXISTS fn_ai_flight_delay_update_segment();
DROP PROCEDURE IF EXISTS sp_register_flight_delay(uuid, uuid, timestamptz, integer, text);

-- ============================================================
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Cada vez que se registra una demora en flight_delay,
-- el trigger actualiza flight_segment.updated_at para que
-- el segmento quede marcado con el timestamp del evento.
-- Esta accion es verificable, no rompe 3FN y es coherente
-- con la trazabilidad operacional del negocio.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_ai_flight_delay_update_segment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE flight_segment
    SET updated_at = now()
    WHERE flight_segment_id = NEW.flight_segment_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT SOBRE flight_delay
-- ============================================================
CREATE TRIGGER trg_ai_flight_delay_update_segment
AFTER INSERT ON flight_delay
FOR EACH ROW
EXECUTE FUNCTION fn_ai_flight_delay_update_segment();

-- ============================================================
-- PROCEDIMIENTO sp_register_flight_delay
-- ============================================================
-- Parametros:
--   p_flight_segment_id    : segmento de vuelo afectado
--   p_delay_reason_type_id : motivo de la demora
--   p_reported_at          : fecha y hora del reporte
--   p_delay_minutes        : minutos de demora
--   p_notes                : observaciones opcionales
-- Validaciones internas:
--   1. flight_segment_id debe existir en flight_segment
--   2. delay_reason_type_id debe existir en delay_reason_type
--   3. p_delay_minutes debe ser mayor que cero
--   4. p_reported_at no puede ser nulo
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_register_flight_delay(
    p_flight_segment_id    uuid,
    p_delay_reason_type_id uuid,
    p_reported_at          timestamptz,
    p_delay_minutes        integer,
    p_notes                text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM flight_segment
        WHERE flight_segment_id = p_flight_segment_id
    ) THEN
        RAISE EXCEPTION 'flight_segment_id % no existe en flight_segment.', p_flight_segment_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM delay_reason_type
        WHERE delay_reason_type_id = p_delay_reason_type_id
    ) THEN
        RAISE EXCEPTION 'delay_reason_type_id % no existe en delay_reason_type.', p_delay_reason_type_id;
    END IF;

    IF p_reported_at IS NULL THEN
        RAISE EXCEPTION 'p_reported_at no puede ser nulo.';
    END IF;

    IF p_delay_minutes IS NULL OR p_delay_minutes <= 0 THEN
        RAISE EXCEPTION 'p_delay_minutes debe ser un entero positivo. Valor recibido: %', p_delay_minutes;
    END IF;

    INSERT INTO flight_delay (
        flight_segment_id,
        delay_reason_type_id,
        reported_at,
        delay_minutes,
        notes
    )
    VALUES (
        p_flight_segment_id,
        p_delay_reason_type_id,
        p_reported_at,
        p_delay_minutes,
        p_notes
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1 - CONSULTA INNER JOIN - 8 TABLAS
-- ============================================================
-- Tablas involucradas:
--   airline           - aerolinea operadora del vuelo
--   flight            - numero de vuelo y fecha de servicio
--   flight_status     - estado del vuelo
--   flight_segment    - segmento: origen, destino, tiempos
--   airport (origen)  - aeropuerto de salida
--   airport (destino) - aeropuerto de llegada
--   flight_delay      - registro de la demora
--   delay_reason_type - motivo de la demora
-- ============================================================
SELECT
    al.airline_name                         AS aerolinea,
    f.flight_number                         AS numero_vuelo,
    f.service_date                          AS fecha_servicio,
    fs_status.status_name                   AS estado_vuelo,
    fs.segment_number                       AS numero_segmento,
    ao.iata_code                            AS origen_iata,
    ao.airport_name                         AS aeropuerto_origen,
    ad.iata_code                            AS destino_iata,
    ad.airport_name                         AS aeropuerto_destino,
    fs.scheduled_departure_at               AS salida_programada,
    fs.actual_departure_at                  AS salida_real,
    fd.reported_at                          AS reporte_demora,
    fd.delay_minutes                        AS minutos_demora,
    drt.reason_name                         AS motivo_retraso,
    fd.notes                                AS observaciones
FROM flight_delay fd
INNER JOIN delay_reason_type drt
    ON drt.delay_reason_type_id = fd.delay_reason_type_id
INNER JOIN flight_segment fs
    ON fs.flight_segment_id = fd.flight_segment_id
INNER JOIN flight f
    ON f.flight_id = fs.flight_id
INNER JOIN flight_status fs_status
    ON fs_status.flight_status_id = f.flight_status_id
INNER JOIN airline al
    ON al.airline_id = f.airline_id
INNER JOIN airport ao
    ON ao.airport_id = fs.origin_airport_id
INNER JOIN airport ad
    ON ad.airport_id = fs.destination_airport_id
ORDER BY f.service_date, f.flight_number, fs.segment_number;