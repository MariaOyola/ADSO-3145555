-- ============================================================
-- ejercicio_5_setup.sql
-- Ejercicio 05 - Mantenimiento de aeronaves y habilitacion
-- operativa
-- ============================================================

DROP TRIGGER IF EXISTS trg_ai_maintenance_event_touch_aircraft ON maintenance_event;
DROP FUNCTION IF EXISTS fn_ai_maintenance_event_touch_aircraft();
DROP PROCEDURE IF EXISTS sp_register_maintenance_event(uuid, uuid, uuid, varchar, timestamptz, timestamptz, text);

-- ============================================================
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
CREATE OR REPLACE FUNCTION fn_ai_maintenance_event_touch_aircraft()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE aircraft
    SET updated_at = now()
    WHERE aircraft_id = NEW.aircraft_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT SOBRE maintenance_event
-- ============================================================
CREATE TRIGGER trg_ai_maintenance_event_touch_aircraft
AFTER INSERT ON maintenance_event
FOR EACH ROW
EXECUTE FUNCTION fn_ai_maintenance_event_touch_aircraft();

-- ============================================================
-- PROCEDIMIENTO sp_register_maintenance_event
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_register_maintenance_event(
    p_aircraft_id             uuid,
    p_maintenance_type_id     uuid,
    p_maintenance_provider_id uuid,
    p_status_code             varchar(30),
    p_started_at              timestamptz,
    p_completed_at            timestamptz,
    p_notes                   text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM aircraft WHERE aircraft_id = p_aircraft_id) THEN
        RAISE EXCEPTION 'aircraft_id % no existe en el modelo.', p_aircraft_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM maintenance_type WHERE maintenance_type_id = p_maintenance_type_id) THEN
        RAISE EXCEPTION 'maintenance_type_id % no existe en maintenance_type.', p_maintenance_type_id;
    END IF;

    IF p_maintenance_provider_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM maintenance_provider WHERE maintenance_provider_id = p_maintenance_provider_id
    ) THEN
        RAISE EXCEPTION 'maintenance_provider_id % no existe en maintenance_provider.', p_maintenance_provider_id;
    END IF;

    IF p_started_at IS NOT NULL AND p_completed_at IS NOT NULL AND p_completed_at < p_started_at THEN
        RAISE EXCEPTION 'completed_at (%) no puede ser anterior a started_at (%).', p_completed_at, p_started_at;
    END IF;

    INSERT INTO maintenance_event (
        aircraft_id, maintenance_type_id, maintenance_provider_id,
        status_code, started_at, completed_at, notes
    )
    VALUES (
        p_aircraft_id, p_maintenance_type_id, p_maintenance_provider_id,
        p_status_code, p_started_at, p_completed_at, p_notes
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1 - CONSULTA INNER JOIN - 7 TABLAS
-- ============================================================
SELECT
    a.registration_number           AS matricula,
    al.airline_name                 AS aerolinea,
    am.model_name                   AS modelo,
    amf.manufacturer_name           AS fabricante,
    mt.type_name                    AS tipo_mantenimiento,
    mp.provider_name                AS proveedor,
    me.status_code                  AS estado_evento,
    me.started_at                   AS inicio,
    me.completed_at                 AS finalizacion,
    me.notes                        AS observaciones
FROM aircraft a
INNER JOIN airline al
    ON al.airline_id = a.airline_id
INNER JOIN aircraft_model am
    ON am.aircraft_model_id = a.aircraft_model_id
INNER JOIN aircraft_manufacturer amf
    ON amf.aircraft_manufacturer_id = am.aircraft_manufacturer_id
INNER JOIN maintenance_event me
    ON me.aircraft_id = a.aircraft_id
INNER JOIN maintenance_type mt
    ON mt.maintenance_type_id = me.maintenance_type_id
LEFT JOIN maintenance_provider mp
    ON mp.maintenance_provider_id = me.maintenance_provider_id
ORDER BY me.started_at DESC, a.registration_number;