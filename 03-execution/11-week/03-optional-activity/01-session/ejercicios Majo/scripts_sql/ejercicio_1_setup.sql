-- ============================================================
-- ejercicio_1_setup.sql
-- Ejercicio 01 - Flujo de check-in y trazabilidad comercial
-- Base: modelo_postgresql.sql + 00_seed_canonico.sql
--       + 01_seed_volumetrico.sql
-- ============================================================
-- RESTRICCIONES RESPETADAS:
--   * No se altera ninguna tabla, columna ni relacion del modelo
--   * Solo se usan entidades y atributos reales del DDL
--   * Los codigos y IDs son exactos del seed cargado
-- ============================================================

-- ------------------------------------------------------------
-- Limpieza previa de objetos del ejercicio
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_ai_check_in_create_boarding_pass ON check_in;
DROP FUNCTION IF EXISTS fn_ai_check_in_create_boarding_pass();
DROP PROCEDURE IF EXISTS sp_register_check_in(uuid, uuid, uuid, uuid, timestamptz);

-- ============================================================
-- REQUERIMIENTO 2
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Genera automaticamente el boarding_pass cuando se inserta
-- un nuevo registro en check_in.
--
-- Atributos usados de boarding_pass (exactos del DDL):
--   check_in_id       -> FK a check_in(check_in_id)
--   boarding_pass_code -> varchar(40) UNIQUE
--   barcode_value      -> varchar(120) UNIQUE
--   issued_at          -> timestamptz NOT NULL
--
-- Protege el UNIQUE uq_boarding_pass_check_in del modelo.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_ai_check_in_create_boarding_pass()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_boarding_pass_code varchar(40);
    v_barcode_value      varchar(120);
BEGIN
    -- Proteccion ante duplicados (constraint uq_boarding_pass_check_in)
    IF EXISTS (
        SELECT 1
        FROM boarding_pass bp
        WHERE bp.check_in_id = NEW.check_in_id
    ) THEN
        RETURN NEW;
    END IF;

    -- Construye codigos unicos a partir del UUID del check_in recien insertado
    v_boarding_pass_code := 'BP-' || replace(NEW.check_in_id::text, '-', '');
    v_barcode_value      := 'BAR-' || replace(NEW.check_in_id::text, '-', '')
                            || '-' || to_char(NEW.checked_in_at, 'YYYYMMDDHH24MISS');

    INSERT INTO boarding_pass (
        check_in_id,
        boarding_pass_code,
        barcode_value,
        issued_at
    )
    VALUES (
        NEW.check_in_id,
        left(v_boarding_pass_code, 40),
        left(v_barcode_value, 120),
        NEW.checked_in_at
    );

    RETURN NEW;
END;
$$;

-- ============================================================
-- REQUERIMIENTO 2
-- TRIGGER AFTER INSERT SOBRE check_in
-- ============================================================
-- Se dispara una vez por cada fila insertada en check_in.
-- No modifica ninguna tabla ni columna del modelo base.
-- Es compatible con la insercion que hace sp_register_check_in.
-- ============================================================

CREATE TRIGGER trg_ai_check_in_create_boarding_pass
AFTER INSERT ON check_in
FOR EACH ROW
EXECUTE FUNCTION fn_ai_check_in_create_boarding_pass();

-- ============================================================
-- REQUERIMIENTO 3
-- PROCEDIMIENTO ALMACENADO sp_register_check_in
-- ============================================================
-- Encapsula el registro del check-in de un pasajero que ya
-- tiene un ticket_segment valido en el modelo.
--
-- Parametros (todos mapeados a columnas reales del DDL):
--   p_ticket_segment_id     -> check_in.ticket_segment_id
--   p_check_in_status_id    -> check_in.check_in_status_id
--   p_boarding_group_id     -> check_in.boarding_group_id (nullable)
--   p_checked_in_by_user_id -> check_in.checked_in_by_user_id (nullable)
--   p_checked_in_at         -> check_in.checked_in_at
--
-- Validaciones:
--   1. ticket_segment_id debe existir en ticket_segment
--   2. No debe existir check_in previo para ese segmento
--      (respeta UNIQUE uq_check_in_ticket_segment del modelo)
--
-- Integracion con el trigger:
--   Al insertar en check_in, el trigger AFTER INSERT genera
--   automaticamente el boarding_pass correspondiente.
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_register_check_in(
    p_ticket_segment_id     uuid,
    p_check_in_status_id    uuid,
    p_boarding_group_id     uuid,
    p_checked_in_by_user_id uuid,
    p_checked_in_at         timestamptz
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validacion 1: el ticket_segment debe existir en el modelo
    IF NOT EXISTS (
        SELECT 1 FROM ticket_segment
        WHERE ticket_segment_id = p_ticket_segment_id
    ) THEN
        RAISE EXCEPTION
            'ticket_segment_id % no existe en el modelo.',
            p_ticket_segment_id;
    END IF;

    -- Validacion 2: no puede existir check-in previo para ese segmento
    -- (la tabla check_in tiene UNIQUE uq_check_in_ticket_segment)
    IF EXISTS (
        SELECT 1 FROM check_in ci
        WHERE ci.ticket_segment_id = p_ticket_segment_id
    ) THEN
        RAISE EXCEPTION
            'Ya existe un check-in para el ticket_segment_id %.',
            p_ticket_segment_id;
    END IF;

    -- Insercion en check_in
    -- El trigger trg_ai_check_in_create_boarding_pass se activa
    -- automaticamente despues de esta insercion.
    INSERT INTO check_in (
        ticket_segment_id,
        check_in_status_id,
        boarding_group_id,
        checked_in_by_user_id,
        checked_in_at
    )
    VALUES (
        p_ticket_segment_id,
        p_check_in_status_id,
        p_boarding_group_id,
        p_checked_in_by_user_id,
        p_checked_in_at
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1
-- CONSULTA CON INNER JOIN - 9 TABLAS
-- ============================================================
-- Trazabilidad completa del pasajero por vuelo.
-- Solo muestra pasajeros con flujo completo:
-- reserva -> tiquete -> check-in -> boarding_pass
--
-- Tablas involucradas:
--   1. reservation          -> codigo comercial de la reserva
--   2. reservation_passenger -> vincula reserva con persona
--   3. person               -> nombre del pasajero
--   4. ticket               -> documento comercial emitido
--   5. ticket_segment       -> segmento del itinerario
--   6. flight_segment       -> operacion aerea real
--   7. flight               -> numero de vuelo y fecha
--   8. check_in             -> registro del check-in
--   9. boarding_pass        -> pase de abordar generado
--
-- Datos canonicos que retorna esta consulta:
--   Ana Garcia     - FY210  BOG->MIA  - BP-FY210-ANA-01
--   Ana Garcia     - FY711  MIA->MAD  - BP-FY711-ANA-01
--   Carlos Mendoza - FY101  BOG->MDE  - BP-FY101-CAR-01
--   Laura Torres   - FY305  BOG->MIA  - BP-FY305-LAU-01
--   + registros volumetricos BP-VOL2-*
-- ============================================================

SELECT
    r.reservation_code,
    f.flight_number,
    f.service_date,
    fs.segment_number,
    p.first_name,
    p.last_name,
    t.ticket_number,
    ci.checked_in_at,
    bp.boarding_pass_code
FROM reservation r
INNER JOIN reservation_passenger rp
    ON rp.reservation_id = r.reservation_id
INNER JOIN person p
    ON p.person_id = rp.person_id
INNER JOIN ticket t
    ON t.reservation_passenger_id = rp.reservation_passenger_id
INNER JOIN ticket_segment ts
    ON ts.ticket_id = t.ticket_id
INNER JOIN flight_segment fs
    ON fs.flight_segment_id = ts.flight_segment_id
INNER JOIN flight f
    ON f.flight_id = fs.flight_id
INNER JOIN check_in ci
    ON ci.ticket_segment_id = ts.ticket_segment_id
INNER JOIN boarding_pass bp
    ON bp.check_in_id = ci.check_in_id
ORDER BY ci.checked_in_at DESC, f.service_date DESC;
