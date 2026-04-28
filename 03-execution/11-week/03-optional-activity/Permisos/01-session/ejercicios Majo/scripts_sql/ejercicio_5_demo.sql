-- ============================================================
-- DEMO EJERCICIO 05
-- ============================================================

BEGIN;

-- ============================================================
-- 1. OBTENER IDS REALES DEL MODELO
-- ============================================================

-- Aeronave existente del seed
SELECT aircraft_id
INTO TEMP TABLE tmp_aircraft
FROM public.aircraft
WHERE registration_number = 'HK-5500'
LIMIT 1;

-- Tipo de mantenimiento
SELECT maintenance_type_id
INTO TEMP TABLE tmp_type
FROM public.maintenance_type
LIMIT 1;

-- Proveedor
SELECT maintenance_provider_id
INTO TEMP TABLE tmp_provider
FROM public.maintenance_provider
LIMIT 1;


-- ============================================================
-- 2. EJECUTAR PROCEDIMIENTO (DISPARA TRIGGER)
-- ============================================================

CALL sp_register_maintenance_event(
    (SELECT aircraft_id FROM tmp_aircraft),
    (SELECT maintenance_type_id FROM tmp_type),
    (SELECT maintenance_provider_id FROM tmp_provider),
    'COMPLETED',
    now() - INTERVAL '2 days',
    now(),
    'Mantenimiento correctivo demo'
);


-- ============================================================
-- 3. VALIDAR EVENTO INSERTADO
-- ============================================================

SELECT *
FROM public.maintenance_event
ORDER BY start_date DESC
LIMIT 5;


-- ============================================================
-- 4. VALIDAR TRIGGER (LOG)
-- ============================================================

SELECT *
FROM public.aircraft_maintenance_log
ORDER BY logged_at DESC
LIMIT 5;


-- ============================================================
-- 5. VALIDAR CONSULTA (VIEW)
-- ============================================================

SELECT *
FROM vw_aircraft_maintenance_overview
LIMIT 10;

COMMIT;