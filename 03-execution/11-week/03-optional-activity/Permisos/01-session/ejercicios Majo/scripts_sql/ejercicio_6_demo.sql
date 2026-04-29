-- ============================================================
-- ejercicio_6_demo.sql
-- Ejercicio 06 - Retrasos operativos y analisis de impacto
-- por segmento de vuelo
-- ============================================================
-- Flujo del demo:
--   1. Segmento FY101 BOG→MDE del 2026-03-12 (con demora CREW ya existente)
--   2. Segmento FY305 BOG→MIA del 2026-03-15 (sin demora previa)
--   3. CALL sp_register_flight_delay para FY305 con motivo WX (meteorologia)
--   4. Trigger actualiza flight_segment.updated_at automaticamente
--   5. Tres validaciones confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_segment_id           uuid;
    v_flight_number        varchar(20);
    v_service_date         date;
    v_segment_updated_at   timestamptz;
    v_reason_id            uuid;
    v_delays_before        integer;
    v_origin_iata          varchar(10);
    v_destination_iata     varchar(10);
BEGIN
    -- --------------------------------------------------------
    -- Resolver el segmento FY305 BOG-MIA del 2026-03-15
    -- Este segmento NO tiene demoras previas en el seed canonico
    -- lo que permite demostrar el primer registro de forma limpia
    -- --------------------------------------------------------
    SELECT
        fs.flight_segment_id,
        f.flight_number,
        f.service_date,
        fs.updated_at,
        ao.iata_code,
        ad.iata_code
    INTO
        v_segment_id,
        v_flight_number,
        v_service_date,
        v_segment_updated_at,
        v_origin_iata,
        v_destination_iata
    FROM flight_segment fs
    JOIN flight f        ON f.flight_id          = fs.flight_id
    JOIN airline al      ON al.airline_id         = f.airline_id
    JOIN airport ao      ON ao.airport_id         = fs.origin_airport_id
    JOIN airport ad      ON ad.airport_id         = fs.destination_airport_id
    WHERE f.flight_number = 'FY305'
      AND f.service_date  = DATE '2026-03-15'
      AND al.airline_code = 'FLY';

    IF v_segment_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el segmento FY305 del 2026-03-15. Verificar seed canonico.';
    END IF;

    -- Contar demoras previas sobre este segmento
    SELECT COUNT(*)
    INTO   v_delays_before
    FROM   flight_delay fd
    WHERE  fd.flight_segment_id = v_segment_id;

    -- Resolver motivo WX (meteorologia)
    SELECT delay_reason_type_id INTO v_reason_id
    FROM   delay_reason_type
    WHERE  reason_code = 'WX';

    IF v_reason_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro delay_reason_type WX. Verificar seed canonico.';
    END IF;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial del segmento:';
    RAISE NOTICE '  flight_segment_id  : %', v_segment_id;
    RAISE NOTICE '  vuelo              : %', v_flight_number;
    RAISE NOTICE '  fecha servicio     : %', v_service_date;
    RAISE NOTICE '  ruta               : % -> %', v_origin_iata, v_destination_iata;
    RAISE NOTICE '  updated_at         : %', v_segment_updated_at;
    RAISE NOTICE '  demoras previas    : %', v_delays_before;
    RAISE NOTICE '  motivo a registrar : WX (Condiciones meteorologicas)';
    RAISE NOTICE '==========================================';

    CALL sp_register_flight_delay(
        v_segment_id,
        v_reason_id,
        TIMESTAMPTZ '2026-03-15 06:20:00-05',
        45,
        'Demora por tormenta en zona de aproximacion BOG. Condiciones mejoradas tras 45 minutos.'
    );

    RAISE NOTICE 'sp_register_flight_delay ejecutado.';
    RAISE NOTICE 'Demora WX de 45 min registrada para segmento %.', v_flight_number;
    RAISE NOTICE 'El trigger actualiza flight_segment.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Demora insertada y flight_segment.updated_at
-- ============================================================
SELECT
    f.flight_number                     AS vuelo,
    f.service_date                      AS fecha_servicio,
    ao.iata_code                        AS origen,
    ad.iata_code                        AS destino,
    fs.updated_at                       AS segmento_updated_at,
    drt.reason_name                     AS motivo_demora,
    fd.delay_minutes                    AS minutos_demora,
    fd.reported_at                      AS reporte,
    fd.notes                            AS observaciones
FROM flight_delay fd
INNER JOIN delay_reason_type drt
    ON drt.delay_reason_type_id = fd.delay_reason_type_id
INNER JOIN flight_segment fs
    ON fs.flight_segment_id = fd.flight_segment_id
INNER JOIN flight f
    ON f.flight_id = fs.flight_id
INNER JOIN airline al
    ON al.airline_id = f.airline_id
INNER JOIN airport ao
    ON ao.airport_id = fs.origin_airport_id
INNER JOIN airport ad
    ON ad.airport_id = fs.destination_airport_id
WHERE f.flight_number = 'FY305'
  AND f.service_date  = DATE '2026-03-15'
  AND al.airline_code = 'FLY'
ORDER BY fd.reported_at DESC;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa (consulta del setup)
-- Muestra todas las demoras registradas con contexto operacional
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

-- ============================================================
-- VALIDACION 3: Resumen de demoras por vuelo
-- ============================================================
SELECT
    al.airline_name                         AS aerolinea,
    f.flight_number                         AS numero_vuelo,
    f.service_date                          AS fecha_servicio,
    fs_status.status_name                   AS estado_vuelo,
    fs.updated_at                           AS ultima_modificacion_segmento,
    COUNT(fd.flight_delay_id)               AS total_demoras,
    SUM(fd.delay_minutes)                   AS total_minutos_demora,
    MAX(fd.reported_at)                     AS ultimo_reporte
FROM flight_segment fs
INNER JOIN flight f
    ON f.flight_id = fs.flight_id
INNER JOIN flight_status fs_status
    ON fs_status.flight_status_id = f.flight_status_id
INNER JOIN airline al
    ON al.airline_id = f.airline_id
LEFT JOIN flight_delay fd
    ON fd.flight_segment_id = fs.flight_segment_id
GROUP BY
    al.airline_name,
    f.flight_number,
    f.service_date,
    fs_status.status_name,
    fs.updated_at
ORDER BY f.service_date, f.flight_number;