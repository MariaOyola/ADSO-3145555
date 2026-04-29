-- ============================================================
-- ejercicio_7_demo.sql
-- Ejercicio 07 - Asignacion de asientos y registro de equipaje
-- por segmento ticketed
-- ============================================================
-- Flujo del demo:
--   1. Tiquete TKT-FY-00001 (Ana Garcia) - segmento FY210 BOG-MIA
--      ya tiene asiento asignado (J fila 1 col A) pero NO tiene
--      equipaje registrado en el seed canonico.
--   2. CALL sp_register_baggage para ese ticket_segment
--   3. Trigger actualiza ticket_segment.updated_at automaticamente
--   4. Tres validaciones confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_ticket_segment_id    uuid;
    v_ticket_number        varchar(30);
    v_flight_number        varchar(20);
    v_service_date         date;
    v_ts_updated_at        timestamptz;
    v_baggage_before       integer;
    v_seat_row             integer;
    v_seat_col             varchar(5);
    v_cabin_code           varchar(10);
BEGIN
    -- --------------------------------------------------------
    -- Resolver el ticket_segment de Ana Garcia en FY210 BOG-MIA
    -- TKT-FY-00001, secuencia 1, segmento 61000000-...-001
    -- Este ticket_segment NO tiene baggage en el seed canonico,
    -- lo que permite demostrar el primer registro de forma limpia.
    -- --------------------------------------------------------
    SELECT
        ts.ticket_segment_id,
        t.ticket_number,
        f.flight_number,
        f.service_date,
        ts.updated_at,
        acs.seat_row_number,
        acs.seat_column_code,
        acab.cabin_code
    INTO
        v_ticket_segment_id,
        v_ticket_number,
        v_flight_number,
        v_service_date,
        v_ts_updated_at,
        v_seat_row,
        v_seat_col,
        v_cabin_code
    FROM ticket_segment ts
    JOIN ticket t            ON t.ticket_id           = ts.ticket_id
    JOIN flight_segment fs   ON fs.flight_segment_id  = ts.flight_segment_id
    JOIN flight f            ON f.flight_id            = fs.flight_id
    JOIN seat_assignment sa  ON sa.ticket_segment_id  = ts.ticket_segment_id
    JOIN aircraft_seat acs   ON acs.aircraft_seat_id  = sa.aircraft_seat_id
    JOIN aircraft_cabin acab ON acab.aircraft_cabin_id = acs.aircraft_cabin_id
    WHERE t.ticket_number = 'TKT-FY-00001'
      AND ts.segment_sequence_no = 1;

    IF v_ticket_segment_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el ticket_segment de TKT-FY-00001 secuencia 1. Verificar seed canonico.';
    END IF;

    -- Contar equipajes previos sobre este ticket_segment
    SELECT COUNT(*)
    INTO   v_baggage_before
    FROM   baggage b
    WHERE  b.ticket_segment_id = v_ticket_segment_id;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial del segmento ticketed:';
    RAISE NOTICE '  ticket_segment_id  : %', v_ticket_segment_id;
    RAISE NOTICE '  tiquete            : %', v_ticket_number;
    RAISE NOTICE '  vuelo              : %', v_flight_number;
    RAISE NOTICE '  fecha servicio     : %', v_service_date;
    RAISE NOTICE '  asiento asignado   : % / fila % col %', v_cabin_code, v_seat_row, v_seat_col;
    RAISE NOTICE '  updated_at         : %', v_ts_updated_at;
    RAISE NOTICE '  equipajes previos  : %', v_baggage_before;
    RAISE NOTICE '==========================================';

    CALL sp_register_baggage(
        v_ticket_segment_id,
        'BAG-FY210-ANA-01',
        'CHECKED',
        'REGISTERED',
        23.40,
        TIMESTAMPTZ '2026-03-10 06:10:00-05'
    );

    RAISE NOTICE 'sp_register_baggage ejecutado.';
    RAISE NOTICE 'Equipaje BAG-FY210-ANA-01 registrado para tiquete %.', v_ticket_number;
    RAISE NOTICE 'El trigger actualiza ticket_segment.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Equipaje insertado y ticket_segment.updated_at
-- ============================================================
SELECT
    t.ticket_number                         AS tiquete,
    ts.segment_sequence_no                  AS secuencia,
    ts.updated_at                           AS segmento_updated_at,
    b.baggage_tag                           AS etiqueta,
    b.baggage_type                          AS tipo,
    b.baggage_status                        AS estado,
    b.weight_kg                             AS peso_kg,
    b.checked_at                            AS registrado_en
FROM baggage b
INNER JOIN ticket_segment ts ON ts.ticket_segment_id = b.ticket_segment_id
INNER JOIN ticket t          ON t.ticket_id           = ts.ticket_id
WHERE t.ticket_number = 'TKT-FY-00001'
ORDER BY ts.segment_sequence_no, b.checked_at;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa asiento + equipaje
-- Ejecuta la consulta principal del setup para mostrar
-- la fila completa ahora con el equipaje registrado
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

-- ============================================================
-- VALIDACION 3: Resumen de equipaje por tiquete y segmento
-- ============================================================
SELECT
    t.ticket_number                         AS tiquete,
    f.flight_number                         AS vuelo,
    f.service_date                          AS fecha_servicio,
    cc.class_name                           AS cabina,
    acs.seat_row_number                     AS fila,
    acs.seat_column_code                    AS columna,
    ts.updated_at                           AS ultima_modificacion_segmento,
    COUNT(b.baggage_id)                     AS total_equipajes,
    SUM(b.weight_kg)                        AS peso_total_kg,
    MAX(b.checked_at)                       AS ultimo_registro_equipaje
FROM ticket_segment ts
INNER JOIN ticket t          ON t.ticket_id            = ts.ticket_id
INNER JOIN flight_segment fs ON fs.flight_segment_id   = ts.flight_segment_id
INNER JOIN flight f          ON f.flight_id             = fs.flight_id
INNER JOIN seat_assignment sa ON sa.ticket_segment_id  = ts.ticket_segment_id
INNER JOIN aircraft_seat acs  ON acs.aircraft_seat_id  = sa.aircraft_seat_id
INNER JOIN aircraft_cabin acab ON acab.aircraft_cabin_id = acs.aircraft_cabin_id
INNER JOIN cabin_class cc    ON cc.cabin_class_id       = acab.cabin_class_id
LEFT JOIN  baggage b         ON b.ticket_segment_id     = ts.ticket_segment_id
GROUP BY
    t.ticket_number,
    f.flight_number,
    f.service_date,
    cc.class_name,
    acs.seat_row_number,
    acs.seat_column_code,
    ts.updated_at
ORDER BY t.ticket_number, f.service_date;