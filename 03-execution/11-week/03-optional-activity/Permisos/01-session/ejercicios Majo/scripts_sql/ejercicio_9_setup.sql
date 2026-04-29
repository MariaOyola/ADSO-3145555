-- ============================================================
-- ejercicio_9_setup.sql
-- Ejercicio 09 - Publicacion de tarifas y analisis de
-- reservas comercializadas
-- ============================================================

DROP TRIGGER IF EXISTS trg_ai_fare_touch_airline ON fare;
DROP FUNCTION IF EXISTS fn_ai_fare_touch_airline();
DROP PROCEDURE IF EXISTS sp_publish_fare(uuid, uuid, uuid, uuid, uuid, varchar, numeric, date, date, integer, numeric, numeric);

-- ============================================================
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Cada vez que se publica una tarifa en fare,
-- el trigger actualiza airline.updated_at para que
-- la aerolínea quede marcada con el timestamp del evento
-- tarifario.
-- Esta accion es verificable, no rompe 3FN y es coherente
-- con la trazabilidad comercial del negocio: la aerolínea
-- refleja que su catalogo tarifario fue modificado.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_ai_fare_touch_airline()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE airline
    SET updated_at = now()
    WHERE airline_id = NEW.airline_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT SOBRE fare
-- ============================================================
CREATE TRIGGER trg_ai_fare_touch_airline
AFTER INSERT ON fare
FOR EACH ROW
EXECUTE FUNCTION fn_ai_fare_touch_airline();

-- ============================================================
-- PROCEDIMIENTO sp_publish_fare
-- ============================================================
-- Parametros:
--   p_airline_id               : aerolínea que publica la tarifa
--   p_origin_airport_id        : aeropuerto de origen
--   p_destination_airport_id   : aeropuerto de destino
--   p_fare_class_id            : clase tarifaria (JF, YB, YF...)
--   p_currency_id              : moneda de la tarifa
--   p_fare_code                : codigo unico de la tarifa
--   p_base_amount              : monto base
--   p_valid_from               : inicio de vigencia
--   p_valid_to                 : fin de vigencia (puede ser NULL)
--   p_baggage_allowance_qty    : piezas de equipaje incluidas
--   p_change_penalty_amount    : penalidad por cambio
--   p_refund_penalty_amount    : penalidad por reembolso
-- Validaciones internas:
--   1. airline_id debe existir en airline
--   2. origin_airport_id debe existir en airport
--   3. destination_airport_id debe existir en airport
--   4. origin y destination no pueden ser el mismo aeropuerto
--   5. fare_class_id debe existir en fare_class
--   6. currency_id debe existir en currency
--   7. fare_code no debe estar duplicado en fare
--   8. p_base_amount debe ser mayor que cero
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_publish_fare(
    p_airline_id              uuid,
    p_origin_airport_id       uuid,
    p_destination_airport_id  uuid,
    p_fare_class_id           uuid,
    p_currency_id             uuid,
    p_fare_code               varchar(50),
    p_base_amount             numeric(12,2),
    p_valid_from              date,
    p_valid_to                date,
    p_baggage_allowance_qty   integer,
    p_change_penalty_amount   numeric(12,2),
    p_refund_penalty_amount   numeric(12,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM airline WHERE airline_id = p_airline_id
    ) THEN
        RAISE EXCEPTION 'airline_id % no existe en airline.', p_airline_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM airport WHERE airport_id = p_origin_airport_id
    ) THEN
        RAISE EXCEPTION 'origin_airport_id % no existe en airport.', p_origin_airport_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM airport WHERE airport_id = p_destination_airport_id
    ) THEN
        RAISE EXCEPTION 'destination_airport_id % no existe en airport.', p_destination_airport_id;
    END IF;

    IF p_origin_airport_id = p_destination_airport_id THEN
        RAISE EXCEPTION 'El aeropuerto de origen y destino no pueden ser el mismo.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM fare_class WHERE fare_class_id = p_fare_class_id
    ) THEN
        RAISE EXCEPTION 'fare_class_id % no existe en fare_class.', p_fare_class_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM currency WHERE currency_id = p_currency_id
    ) THEN
        RAISE EXCEPTION 'currency_id % no existe en currency.', p_currency_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM fare WHERE fare_code = p_fare_code
    ) THEN
        RAISE EXCEPTION 'fare_code % ya existe en fare. El codigo debe ser unico.', p_fare_code;
    END IF;

    IF p_base_amount IS NULL OR p_base_amount <= 0 THEN
        RAISE EXCEPTION 'p_base_amount debe ser un valor positivo. Valor recibido: %', p_base_amount;
    END IF;

    INSERT INTO fare (
        airline_id,
        origin_airport_id,
        destination_airport_id,
        fare_class_id,
        currency_id,
        fare_code,
        base_amount,
        valid_from,
        valid_to,
        baggage_allowance_qty,
        change_penalty_amount,
        refund_penalty_amount
    )
    VALUES (
        p_airline_id,
        p_origin_airport_id,
        p_destination_airport_id,
        p_fare_class_id,
        p_currency_id,
        p_fare_code,
        p_base_amount,
        p_valid_from,
        p_valid_to,
        p_baggage_allowance_qty,
        p_change_penalty_amount,
        p_refund_penalty_amount
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1 - CONSULTA INNER JOIN - 9 TABLAS
-- ============================================================
-- Tablas involucradas:
--   airline       - aerolínea propietaria de la tarifa
--   fare          - tarifa: monto, vigencia, penalidades
--   fare_class    - clase tarifaria (JF, YB, YF...)
--   airport (org) - aeropuerto de origen de la ruta
--   airport (dst) - aeropuerto de destino de la ruta
--   currency      - moneda de la tarifa
--   ticket        - tiquete emitido sobre la tarifa
--   sale          - venta que generó el tiquete
--   reservation   - reserva que originó la venta
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