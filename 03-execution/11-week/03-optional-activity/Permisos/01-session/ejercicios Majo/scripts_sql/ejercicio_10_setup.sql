-- ============================================================
-- ejercicio_10_setup.sql
-- Ejercicio 10 - Identidad de pasajeros, documentos y
-- medios de contacto
-- ============================================================

DROP TRIGGER IF EXISTS trg_ai_person_contact_touch_person ON person_contact;
DROP FUNCTION IF EXISTS fn_ai_person_contact_touch_person();
DROP PROCEDURE IF EXISTS sp_register_person_contact(uuid, uuid, varchar, boolean);

-- ============================================================
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Cada vez que se registra un nuevo medio de contacto en
-- person_contact, el trigger actualiza person.updated_at
-- para que la ficha de la persona quede marcada con el
-- timestamp del evento de identidad.
-- Esta accion es verificable, no rompe 3FN y es coherente
-- con la trazabilidad de identidad del negocio: la ficha
-- del pasajero refleja que su perfil de contacto fue
-- actualizado.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_ai_person_contact_touch_person()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE person
    SET updated_at = now()
    WHERE person_id = NEW.person_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT SOBRE person_contact
-- ============================================================
CREATE TRIGGER trg_ai_person_contact_touch_person
AFTER INSERT ON person_contact
FOR EACH ROW
EXECUTE FUNCTION fn_ai_person_contact_touch_person();

-- ============================================================
-- PROCEDIMIENTO sp_register_person_contact
-- ============================================================
-- Parametros:
--   p_person_id       : persona a la que pertenece el contacto
--   p_contact_type_id : tipo de contacto (EMAIL, MOBILE, etc.)
--   p_contact_value   : valor del contacto (direccion, numero)
--   p_is_primary      : indica si es el contacto principal
-- Validaciones internas:
--   1. person_id debe existir en person
--   2. contact_type_id debe existir en contact_type
--   3. p_contact_value no puede ser nulo ni vacio
--   4. Si p_is_primary = true, no debe existir ya otro
--      contacto principal del mismo tipo para esa persona
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_register_person_contact(
    p_person_id       uuid,
    p_contact_type_id uuid,
    p_contact_value   varchar(200),
    p_is_primary      boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM person WHERE person_id = p_person_id
    ) THEN
        RAISE EXCEPTION 'person_id % no existe en person.', p_person_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM contact_type WHERE contact_type_id = p_contact_type_id
    ) THEN
        RAISE EXCEPTION 'contact_type_id % no existe en contact_type.', p_contact_type_id;
    END IF;

    IF p_contact_value IS NULL OR trim(p_contact_value) = '' THEN
        RAISE EXCEPTION 'p_contact_value no puede ser nulo ni vacio.';
    END IF;

    IF p_is_primary = true AND EXISTS (
        SELECT 1 FROM person_contact
        WHERE person_id       = p_person_id
          AND contact_type_id = p_contact_type_id
          AND is_primary       = true
    ) THEN
        RAISE EXCEPTION 'La persona % ya tiene un contacto principal del mismo tipo. Solo puede existir uno.', p_person_id;
    END IF;

    INSERT INTO person_contact (
        person_id,
        contact_type_id,
        contact_value,
        is_primary
    )
    VALUES (
        p_person_id,
        p_contact_type_id,
        p_contact_value,
        p_is_primary
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1 - CONSULTA INNER JOIN - 8 TABLAS
-- ============================================================
-- Tablas involucradas:
--   person               - nombre, nacimiento, genero
--   person_type          - tipo: ADULT, CHILD, EMPLOYEE...
--   person_document      - documento de identidad registrado
--   document_type        - tipo: PASS, NID, DL...
--   person_contact       - medio de contacto registrado
--   contact_type         - tipo: EMAIL, MOBILE, WHATSAPP...
--   reservation_passenger - participacion en reservas
--   reservation          - reserva relacionada
-- ============================================================
SELECT
    p.first_name || ' ' || p.last_name      AS persona,
    pt.type_name                             AS tipo_persona,
    dt.type_name                             AS tipo_documento,
    pd.document_number                       AS numero_documento,
    pd.issued_on                             AS emision_documento,
    pd.expires_on                            AS vencimiento_documento,
    ct.type_name                             AS tipo_contacto,
    pc.contact_value                         AS valor_contacto,
    pc.is_primary                            AS es_principal,
    r.reservation_code                       AS reserva,
    rp.passenger_sequence_no                 AS secuencia_pasajero,
    rp.passenger_type                        AS tipo_pasajero_reserva
FROM person p
INNER JOIN person_type pt
    ON pt.person_type_id = p.person_type_id
INNER JOIN person_document pd
    ON pd.person_id = p.person_id
INNER JOIN document_type dt
    ON dt.document_type_id = pd.document_type_id
INNER JOIN person_contact pc
    ON pc.person_id = p.person_id
INNER JOIN contact_type ct
    ON ct.contact_type_id = pc.contact_type_id
INNER JOIN reservation_passenger rp
    ON rp.person_id = p.person_id
INNER JOIN reservation r
    ON r.reservation_id = rp.reservation_id
ORDER BY p.last_name, p.first_name, dt.type_name, ct.type_name;