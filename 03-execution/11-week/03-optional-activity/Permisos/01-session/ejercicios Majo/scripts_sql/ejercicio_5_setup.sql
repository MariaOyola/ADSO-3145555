-- ============================================================
-- EJERCICIO 05 - SETUP
-- Mantenimiento de aeronaves
-- ============================================================

SET client_min_messages TO warning;

-- ============================================================
-- 1. CONSULTA (INNER JOIN >= 5 TABLAS)
-- ============================================================

-- Vista reutilizable para analisis de mantenimiento
CREATE OR REPLACE VIEW vw_aircraft_maintenance_overview AS
SELECT
    a.registration_number              AS aircraft,
    al.airline_code                    AS airline,
    am.model_name                      AS model,
    mf.manufacturer_name               AS manufacturer,
    mt.type_name                       AS maintenance_type,
    mp.provider_name                   AS provider,
    me.status                          AS maintenance_status,
    me.start_date                      AS start_date,
    me.end_date                        AS end_date
FROM public.maintenance_event me
INNER JOIN public.aircraft a
    ON a.aircraft_id = me.aircraft_id
INNER JOIN public.airline al
    ON al.airline_id = a.airline_id
INNER JOIN public.aircraft_model am
    ON am.aircraft_model_id = a.aircraft_model_id
INNER JOIN public.aircraft_manufacturer mf
    ON mf.aircraft_manufacturer_id = am.aircraft_manufacturer_id
INNER JOIN public.maintenance_type mt
    ON mt.maintenance_type_id = me.maintenance_type_id
INNER JOIN public.maintenance_provider mp
    ON mp.maintenance_provider_id = me.maintenance_provider_id;


-- ============================================================
-- 2. TABLA AUXILIAR PARA TRAZABILIDAD (PERMITIDO)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.aircraft_maintenance_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_id UUID NOT NULL,
    maintenance_event_id UUID NOT NULL,
    event_status TEXT,
    logged_at TIMESTAMPTZ DEFAULT now()
);


-- ============================================================
-- 3. FUNCION DEL TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION fn_log_maintenance_event()
RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO public.aircraft_maintenance_log (
        aircraft_id,
        maintenance_event_id,
        event_status,
        logged_at
    )
    VALUES (
        NEW.aircraft_id,
        NEW.maintenance_event_id,
        NEW.status,
        now()
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 4. TRIGGER AFTER
-- ============================================================

DROP TRIGGER IF EXISTS trg_after_maintenance_event ON public.maintenance_event;

CREATE TRIGGER trg_after_maintenance_event
AFTER INSERT OR UPDATE
ON public.maintenance_event
FOR EACH ROW
EXECUTE FUNCTION fn_log_maintenance_event();


-- ============================================================
-- 5. PROCEDIMIENTO ALMACENADO
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_register_maintenance_event(
    p_aircraft_id UUID,
    p_maintenance_type_id UUID,
    p_provider_id UUID,
    p_status TEXT,
    p_start_date TIMESTAMPTZ,
    p_end_date TIMESTAMPTZ,
    p_notes TEXT
)
LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO public.maintenance_event (
        maintenance_event_id,
        aircraft_id,
        maintenance_type_id,
        maintenance_provider_id,
        status,
        start_date,
        end_date,
        notes
    )
    VALUES (
        gen_random_uuid(),
        p_aircraft_id,
        p_maintenance_type_id,
        p_provider_id,
        p_status,
        p_start_date,
        p_end_date,
        p_notes
    );
END;
$$;