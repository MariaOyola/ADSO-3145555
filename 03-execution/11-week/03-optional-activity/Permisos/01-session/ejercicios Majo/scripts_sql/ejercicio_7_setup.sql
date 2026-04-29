-- ============================================================
-- ejercicio_7_setup.sql
-- Ejercicio 07 - Asignacion de asientos y registro de equipaje
-- por segmento ticketed
-- ============================================================

DROP TRIGGER IF EXISTS trg_ai_baggage_touch_ticket_segment ON baggage;
DROP FUNCTION IF EXISTS fn_ai_baggage_touch_ticket_segment();
DROP PROCEDURE IF EXISTS sp_register_baggage(uuid, varchar, varchar, varchar, numeric, timestamptz);

-- ============================================================
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Cada vez que se registra un equipaje en baggage,
-- el trigger actualiza ticket_segment.updated_at para que
-- el segmento ticketed quede marcado con el timestamp
-- del evento de equipaje.
-- Esta accion es verificable, no rompe 3FN y es coherente
-- con la trazabilidad aeroportuaria del negocio.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_ai_baggage_touch_ticket_segment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ticket_segment
    SET updated_at = now()
    WHERE ticket_segment_id = NEW.ticket_segment_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT SOBRE baggage
-- ============================================================
CREATE TRIGGER trg_ai_baggage_touch_ticket_segment
AFTER INSERT ON baggage
FOR EACH ROW
EXECUTE FUNCTION fn_ai_baggage_touch_ticket_segment();

-- ============================================================
-- PROCEDIMIENTO sp_register_baggage
-- ============================================================
-- Parametros:
--   p_ticket_segment_id : segmento ticketed al que pertenece
--   p_baggage_tag       : etiqueta unica del equipaje
--   p_baggage_type      : tipo (CHECKED, CARRY_ON, etc.)
--   p_baggage_status    : estado inicial (REGISTERED, etc.)
--   p_weight_kg         : peso en kg
--   p_checked_at        : fecha y hora del registro
-- Validaciones internas:
--   1. ticket_segment_id debe existir en ticket_segment
--   2. baggage_tag no debe estar duplicada en baggage
--   3. p_weight_kg debe ser mayor que cero
--   4. p_checked_at no puede ser nulo
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_register_baggage(
    p_ticket_segment_id uuid,
    p_baggage_tag       varchar(50),
    p_baggage_type      varchar(30),
    p_baggage_status    varchar(30),
    p_weight_kg         numeric(6,2),
    p_checked_at        timestamptz
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ticket_segment
        WHERE ticket_segment_id = p_ticket_segment_id
    ) THEN
        RAISE EXCEPTION 'ticket_segment_id % no existe en ticket_segment.', p_ticket_segment_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM baggage
        WHERE baggage_tag = p_baggage_tag
    ) THEN
        RAISE EXCEPTION 'baggage_tag % ya existe en baggage. La etiqueta debe ser unica.', p_baggage_tag;
    END IF;

    IF p_checked_at IS NULL THEN
        RAISE EXCEPTION 'p_checked_at no puede ser nulo.';
    END IF;

    IF p_weight_kg IS NULL OR p_weight_kg <= 0 THEN
        RAISE EXCEPTION 'p_weight_kg debe ser un valor positivo. Valor recibido: %', p_weight_kg;
    END IF;

    INSERT INTO baggage (
        ticket_segment_id,
        baggage_tag,
        baggage_type,
        baggage_status,
        weight_kg,
        checked_at
    )
    VALUES (
        p_ticket_segment_id,
        p_baggage_tag,
        p_baggage_type,
        p_baggage_status,
        p_weight_kg,
        p_checked_at
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1 - CONSULTA INNER JOIN - 9 TABLAS
-- ============================================================
-- Tablas involucradas:
--   ticket          - numero de tiquete emitido
--   ticket_segment  - segmento ticketed: secuencia y fare basis
--   flight_segment  - segmento operativo: tiempos y ruta
--   flight          - vuelo: numero y fecha de servicio
--   seat_assignment - asiento asignado al segmento ticketed
--   aircraft_seat   - fila y columna del asiento fisico
--   aircraft_cabin  - cabina de la aeronave (J, Y, etc.)
--   cabin_class     - clase de cabina (Business, Economy...)
--   baggage         - equipaje registrado para el segmento
-- ============================================================
SELECT
    t.ticket_number                         AS numero_tiquete,
    ts.segment_sequence_no                  AS secuencia_segmento,
    ts.fare_basis_code                      AS base_tarifaria,
    f.flight_number                         AS numero_vuelo,
    f.service_date                          AS fecha_servicio,
    cc.class_name                           AS cabina,
    acab.cabin_code                         AS codigo_cabina,
    acs.seat_row_number                     AS fila_asiento,
    acs.seat_column_code                    AS columna_asiento,
    sa.assignment_source                    AS fuente_asignacion,
    sa.assigned_at                          AS asignado_en,
    b.baggage_tag                           AS etiqueta_equipaje,
    b.baggage_type                          AS tipo_equipaje,
    b.baggage_status                        AS estado_equipaje,
    b.weight_kg                             AS peso_kg,
    b.checked_at                            AS registro_equipaje
FROM ticket t
INNER JOIN ticket_segment ts
    ON ts.ticket_id = t.ticket_id
INNER JOIN flight_segment fs
    ON fs.flight_segment_id = ts.flight_segment_id
INNER JOIN flight f
    ON f.flight_id = fs.flight_id
INNER JOIN seat_assignment sa
    ON sa.ticket_segment_id = ts.ticket_segment_id
INNER JOIN aircraft_seat acs
    ON acs.aircraft_seat_id = sa.aircraft_seat_id
INNER JOIN aircraft_cabin acab
    ON acab.aircraft_cabin_id = acs.aircraft_cabin_id
INNER JOIN cabin_class cc
    ON cc.cabin_class_id = acab.cabin_class_id
INNER JOIN baggage b
    ON b.ticket_segment_id = ts.ticket_segment_id
ORDER BY t.ticket_number, ts.segment_sequence_no;