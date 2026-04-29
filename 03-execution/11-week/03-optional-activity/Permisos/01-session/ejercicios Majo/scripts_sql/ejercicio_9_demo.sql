-- ============================================================
-- ejercicio_9_demo.sql
-- Ejercicio 09 - Publicacion de tarifas y analisis de
-- reservas comercializadas
-- ============================================================
-- Flujo del demo:
--   1. Ruta BOG -> MDE con clase YF (Economy Flex) en COP
--      Esta combinacion NO existe en el seed canonico,
--      que solo tiene YB (Economy Basic) para BOG-MDE.
--   2. CALL sp_publish_fare para crear FLY-BOGMDE-YF-2026
--   3. Trigger actualiza airline.updated_at automaticamente
--   4. Tres validaciones confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_airline_id      uuid;
    v_airline_name    varchar(100);
    v_airline_upd     timestamptz;
    v_origin_id       uuid;
    v_destination_id  uuid;
    v_fare_class_id   uuid;
    v_currency_id     uuid;
    v_fares_before    integer;
BEGIN
    -- --------------------------------------------------------
    -- Resolver FLY Airlines
    -- --------------------------------------------------------
    SELECT
        al.airline_id,
        al.airline_name,
        al.updated_at
    INTO
        v_airline_id,
        v_airline_name,
        v_airline_upd
    FROM airline al
    WHERE al.airline_code = 'FLY';

    IF v_airline_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro la aerolínea FLY. Verificar seed canonico.';
    END IF;

    -- Contar tarifas previas de FLY Airlines
    SELECT COUNT(*)
    INTO   v_fares_before
    FROM   fare f
    WHERE  f.airline_id = v_airline_id;

    -- Resolver aeropuerto origen BOG
    SELECT airport_id INTO v_origin_id
    FROM   airport WHERE iata_code = 'BOG';

    IF v_origin_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el aeropuerto BOG. Verificar seed canonico.';
    END IF;

    -- Resolver aeropuerto destino MDE
    SELECT airport_id INTO v_destination_id
    FROM   airport WHERE iata_code = 'MDE';

    IF v_destination_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el aeropuerto MDE. Verificar seed canonico.';
    END IF;

    -- Resolver clase YF (Economy Flex)
    SELECT fare_class_id INTO v_fare_class_id
    FROM   fare_class WHERE fare_class_code = 'YF';

    IF v_fare_class_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro la clase YF. Verificar seed canonico.';
    END IF;

    -- Resolver moneda COP
    SELECT currency_id INTO v_currency_id
    FROM   currency WHERE iso_currency_code = 'COP';

    IF v_currency_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro la moneda COP. Verificar seed canonico.';
    END IF;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial de la aerolínea:';
    RAISE NOTICE '  airline_id      : %', v_airline_id;
    RAISE NOTICE '  airline_name    : %', v_airline_name;
    RAISE NOTICE '  updated_at      : %', v_airline_upd;
    RAISE NOTICE '  tarifas previas : %', v_fares_before;
    RAISE NOTICE '  nueva tarifa    : FLY-BOGMDE-YF-2026 (YF COP)';
    RAISE NOTICE '  ruta            : BOG -> MDE';
    RAISE NOTICE '==========================================';

    CALL sp_publish_fare(
        v_airline_id,
        v_origin_id,
        v_destination_id,
        v_fare_class_id,
        v_currency_id,
        'FLY-BOGMDE-YF-2026',
        420000.00,
        DATE '2026-01-01',
        DATE '2026-12-31',
        1,
        60000.00,
        100000.00
    );

    RAISE NOTICE 'sp_publish_fare ejecutado.';
    RAISE NOTICE 'Tarifa FLY-BOGMDE-YF-2026 publicada para ruta BOG-MDE.';
    RAISE NOTICE 'El trigger actualiza airline.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Tarifa insertada y airline.updated_at
-- ============================================================
SELECT
    al.airline_name                         AS aerolinea,
    al.updated_at                           AS aerolinea_updated_at,
    f.fare_code                             AS codigo_tarifa,
    fc.fare_class_code                      AS clase,
    ao.iata_code                            AS origen,
    ad.iata_code                            AS destino,
    cu.iso_currency_code                    AS moneda,
    f.base_amount                           AS monto_base,
    f.valid_from                            AS vigencia_desde,
    f.valid_to                              AS vigencia_hasta,
    f.baggage_allowance_qty                 AS equipaje,
    f.change_penalty_amount                 AS penalidad_cambio,
    f.refund_penalty_amount                 AS penalidad_reembolso
FROM fare f
INNER JOIN airline al   ON al.airline_id          = f.airline_id
INNER JOIN fare_class fc ON fc.fare_class_id       = f.fare_class_id
INNER JOIN airport ao   ON ao.airport_id           = f.origin_airport_id
INNER JOIN airport ad   ON ad.airport_id           = f.destination_airport_id
INNER JOIN currency cu  ON cu.currency_id          = f.currency_id
WHERE al.airline_code = 'FLY'
ORDER BY f.fare_code;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa tarifa -> tiquetes
-- Ejecuta la consulta principal del setup para mostrar
-- las tarifas actualmente comercializadas con sus tiquetes
-- ============================================================
SELECT
    al.airline_name                         AS aerolinea,
    f.fare_code                             AS codigo_tarifa,
    fc.fare_class_code                      AS codigo_clase,
    fc.fare_class_name                      AS clase_tarifaria,
    ao.iata_code                            AS origen_iata,
    ao.airport_name                         AS aeropuerto_origen,
    ad.iata_code                            AS destino_iata,
    ad.airport_name                         AS aeropuerto_destino,
    cu.iso_currency_code                    AS moneda,
    f.base_amount                           AS monto_base,
    f.valid_from                            AS vigencia_desde,
    f.valid_to                              AS vigencia_hasta,
    f.baggage_allowance_qty                 AS equipaje_incluido,
    r.reservation_code                      AS reserva,
    s.sale_code                             AS venta,
    t.ticket_number                         AS tiquete,
    t.issued_at                             AS emision_tiquete
FROM fare f
INNER JOIN airline al
    ON al.airline_id = f.airline_id
INNER JOIN fare_class fc
    ON fc.fare_class_id = f.fare_class_id
INNER JOIN airport ao
    ON ao.airport_id = f.origin_airport_id
INNER JOIN airport ad
    ON ad.airport_id = f.destination_airport_id
INNER JOIN currency cu
    ON cu.currency_id = f.currency_id
INNER JOIN ticket t
    ON t.fare_id = f.fare_id
INNER JOIN sale s
    ON s.sale_id = t.sale_id
INNER JOIN reservation r
    ON r.reservation_id = s.reservation_id
ORDER BY al.airline_name, f.fare_code, t.issued_at;

-- ============================================================
-- VALIDACION 3: Resumen de tarifas por ruta con conteo de
-- tiquetes emitidos
-- ============================================================
SELECT
    al.airline_name                         AS aerolinea,
    al.updated_at                           AS ultima_modificacion_aerolinea,
    f.fare_code                             AS codigo_tarifa,
    fc.fare_class_code                      AS clase,
    ao.iata_code                            AS origen,
    ad.iata_code                            AS destino,
    cu.iso_currency_code                    AS moneda,
    f.base_amount                           AS monto_base,
    COUNT(t.ticket_id)                      AS total_tiquetes_emitidos,
    MIN(t.issued_at)                        AS primera_emision,
    MAX(t.issued_at)                        AS ultima_emision
FROM fare f
INNER JOIN airline al    ON al.airline_id          = f.airline_id
INNER JOIN fare_class fc ON fc.fare_class_id        = f.fare_class_id
INNER JOIN airport ao    ON ao.airport_id           = f.origin_airport_id
INNER JOIN airport ad    ON ad.airport_id           = f.destination_airport_id
INNER JOIN currency cu   ON cu.currency_id          = f.currency_id
LEFT JOIN  ticket t      ON t.fare_id               = f.fare_id
GROUP BY
    al.airline_name,
    al.updated_at,
    f.fare_code,
    fc.fare_class_code,
    ao.iata_code,
    ad.iata_code,
    cu.iso_currency_code,
    f.base_amount
ORDER BY al.airline_name, ao.iata_code, ad.iata_code, fc.fare_class_code;