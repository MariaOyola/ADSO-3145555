-- ============================================================
-- ejercicio_5_demo.sql
-- Ejercicio 05 - Mantenimiento de aeronaves y habilitacion
-- operativa
-- ============================================================
-- Flujo del demo:
--   1. Aeronave N803NV (Nova America - sin eventos previos)
--   2. Tipo: UNSCHED | Proveedor: AeroAndes MRO Bogota
--   3. CALL sp_register_maintenance_event
--   4. Trigger actualiza aircraft.updated_at automaticamente
--   5. Tres validaciones confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_aircraft_id          uuid;
    v_registration_number  varchar(20);
    v_airline_name         varchar(100);
    v_aircraft_updated_at  timestamptz;
    v_type_id              uuid;
    v_provider_id          uuid;
    v_events_before        integer;
BEGIN
    SELECT
        a.aircraft_id,
        a.registration_number,
        al.airline_name,
        a.updated_at
    INTO
        v_aircraft_id,
        v_registration_number,
        v_airline_name,
        v_aircraft_updated_at
    FROM aircraft a
    INNER JOIN airline al ON al.airline_id = a.airline_id
    WHERE a.registration_number = 'N803NV';

    IF v_aircraft_id IS NULL THEN
        RAISE EXCEPTION 'No existe la aeronave N803NV. Verificar que el seed canonico fue cargado.';
    END IF;

    SELECT COUNT(*)
    INTO   v_events_before
    FROM   maintenance_event me
    WHERE  me.aircraft_id = v_aircraft_id;

    SELECT maintenance_type_id INTO v_type_id
    FROM   maintenance_type WHERE type_code = 'UNSCHED';

    IF v_type_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro maintenance_type UNSCHED. Verificar seed canonico.';
    END IF;

    SELECT maintenance_provider_id INTO v_provider_id
    FROM   maintenance_provider WHERE provider_name = 'AeroAndes MRO Bogota';

    IF v_provider_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro proveedor AeroAndes MRO Bogota. Verificar seed canonico.';
    END IF;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial de la aeronave:';
    RAISE NOTICE '  aircraft_id         : %', v_aircraft_id;
    RAISE NOTICE '  registration_number : %', v_registration_number;
    RAISE NOTICE '  aerolinea           : %', v_airline_name;
    RAISE NOTICE '  updated_at          : %', v_aircraft_updated_at;
    RAISE NOTICE '  eventos previos     : %', v_events_before;
    RAISE NOTICE '  tipo mantenimiento  : UNSCHED (No programado)';
    RAISE NOTICE '  proveedor           : AeroAndes MRO Bogota';
    RAISE NOTICE '==========================================';

    CALL sp_register_maintenance_event(
        v_aircraft_id,
        v_type_id,
        v_provider_id,
        'COMPLETED',
        TIMESTAMPTZ '2026-03-19 08:00:00-05',
        TIMESTAMPTZ '2026-03-19 14:30:00-05',
        'Revision no programada por alerta de sensor de motor. Resultado: sin novedad.'
    );

    RAISE NOTICE 'sp_register_maintenance_event ejecutado.';
    RAISE NOTICE 'Evento UNSCHED registrado para aeronave %.', v_registration_number;
    RAISE NOTICE 'El trigger actualiza aircraft.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Evento insertado y aircraft.updated_at
-- ============================================================
SELECT
    a.registration_number           AS matricula,
    a.updated_at                    AS aeronave_updated_at,
    mt.type_name                    AS tipo_mantenimiento,
    mp.provider_name                AS proveedor,
    me.status_code                  AS estado,
    me.started_at                   AS inicio,
    me.completed_at                 AS finalizacion,
    me.notes                        AS observaciones
FROM maintenance_event me
INNER JOIN aircraft a       ON a.aircraft_id              = me.aircraft_id
INNER JOIN maintenance_type mt ON mt.maintenance_type_id  = me.maintenance_type_id
LEFT JOIN maintenance_provider mp ON mp.maintenance_provider_id = me.maintenance_provider_id
WHERE a.registration_number = 'N803NV'
ORDER BY me.started_at DESC;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa
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
    EXTRACT(EPOCH FROM (me.completed_at - me.started_at)) / 3600
                                    AS duracion_horas,
    me.notes                        AS observaciones
FROM aircraft a
INNER JOIN airline al              ON al.airline_id              = a.airline_id
INNER JOIN aircraft_model am       ON am.aircraft_model_id       = a.aircraft_model_id
INNER JOIN aircraft_manufacturer amf ON amf.aircraft_manufacturer_id = am.aircraft_manufacturer_id
INNER JOIN maintenance_event me    ON me.aircraft_id             = a.aircraft_id
INNER JOIN maintenance_type mt     ON mt.maintenance_type_id     = me.maintenance_type_id
LEFT JOIN maintenance_provider mp  ON mp.maintenance_provider_id = me.maintenance_provider_id
ORDER BY a.registration_number, me.started_at DESC;

-- ============================================================
-- VALIDACION 3: Resumen por aeronave
-- ============================================================
SELECT
    a.registration_number           AS matricula,
    al.airline_name                 AS aerolinea,
    a.updated_at                    AS ultima_modificacion_aeronave,
    COUNT(me.maintenance_event_id)  AS total_eventos,
    MAX(me.started_at)              AS ultimo_inicio,
    MAX(me.completed_at)            AS ultima_finalizacion
FROM aircraft a
INNER JOIN airline al ON al.airline_id = a.airline_id
LEFT JOIN maintenance_event me ON me.aircraft_id = a.aircraft_id
GROUP BY a.aircraft_id, a.registration_number, al.airline_name, a.updated_at
ORDER BY a.registration_number;