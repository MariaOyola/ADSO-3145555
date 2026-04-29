-- ============================================================
-- ejercicio_10_demo.sql
-- Ejercicio 10 - Identidad de pasajeros, documentos y
-- medios de contacto
-- ============================================================
-- Flujo del demo:
--   1. Persona Carlos Mendoza (CC71234567) - seed canonico
--      Tiene EMAIL y MOBILE registrados.
--      NO tiene WHATSAPP, lo que permite un registro limpio.
--   2. CALL sp_register_person_contact para agregar WHATSAPP
--   3. Trigger actualiza person.updated_at automaticamente
--   4. Tres validaciones confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_person_id        uuid;
    v_full_name        varchar(200);
    v_person_updated   timestamptz;
    v_contact_type_id  uuid;
    v_contacts_before  integer;
    v_person_type_name varchar(100);
BEGIN
    -- --------------------------------------------------------
    -- Resolver Carlos Mendoza del seed canonico
    -- Tiene EMAIL (principal) y MOBILE pero NO tiene WHATSAPP,
    -- lo que permite demostrar el registro limpio de un nuevo
    -- tipo de contacto sin violar la restriccion de primario.
    -- --------------------------------------------------------
    SELECT
        p.person_id,
        p.first_name || ' ' || p.last_name,
        p.updated_at,
        pt.type_name
    INTO
        v_person_id,
        v_full_name,
        v_person_updated,
        v_person_type_name
    FROM person p
    JOIN person_type pt ON pt.person_type_id = p.person_type_id
    WHERE p.first_name = 'Carlos'
      AND p.last_name  = 'Mendoza';

    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro a Carlos Mendoza. Verificar seed canonico.';
    END IF;

    -- Contar contactos previos
    SELECT COUNT(*)
    INTO   v_contacts_before
    FROM   person_contact pc
    WHERE  pc.person_id = v_person_id;

    -- Resolver tipo WHATSAPP
    SELECT contact_type_id INTO v_contact_type_id
    FROM   contact_type WHERE type_code = 'WHATSAPP';

    IF v_contact_type_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el tipo de contacto WHATSAPP. Verificar seed canonico.';
    END IF;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial de la persona:';
    RAISE NOTICE '  person_id        : %', v_person_id;
    RAISE NOTICE '  nombre           : %', v_full_name;
    RAISE NOTICE '  tipo persona     : %', v_person_type_name;
    RAISE NOTICE '  updated_at       : %', v_person_updated;
    RAISE NOTICE '  contactos previos: %', v_contacts_before;
    RAISE NOTICE '  nuevo contacto   : WHATSAPP (no primario)';
    RAISE NOTICE '==========================================';

    CALL sp_register_person_contact(
        v_person_id,
        v_contact_type_id,
        '+573107654321',
        false
    );

    RAISE NOTICE 'sp_register_person_contact ejecutado.';
    RAISE NOTICE 'Contacto WHATSAPP registrado para %.',  v_full_name;
    RAISE NOTICE 'El trigger actualiza person.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Contacto insertado y person.updated_at
-- ============================================================
SELECT
    p.first_name || ' ' || p.last_name      AS persona,
    p.updated_at                             AS persona_updated_at,
    ct.type_name                             AS tipo_contacto,
    pc.contact_value                         AS valor_contacto,
    pc.is_primary                            AS es_principal
FROM person_contact pc
INNER JOIN person p       ON p.person_id        = pc.person_id
INNER JOIN contact_type ct ON ct.contact_type_id = pc.contact_type_id
WHERE p.first_name = 'Carlos'
  AND p.last_name  = 'Mendoza'
ORDER BY ct.type_name;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa identidad -> reservas
-- Ejecuta la consulta principal del setup para mostrar
-- el perfil completo de los pasajeros registrados
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

-- ============================================================
-- VALIDACION 3: Resumen de contactos por persona
-- ============================================================
SELECT
    p.first_name || ' ' || p.last_name      AS persona,
    pt.type_name                             AS tipo_persona,
    p.updated_at                             AS ultima_modificacion_persona,
    COUNT(pc.person_contact_id)              AS total_contactos,
    string_agg(
        ct.type_code || ': ' || pc.contact_value,
        ' | ' ORDER BY ct.type_code
    )                                        AS contactos
FROM person p
INNER JOIN person_type pt   ON pt.person_type_id    = p.person_type_id
INNER JOIN person_contact pc ON pc.person_id        = p.person_id
INNER JOIN contact_type ct   ON ct.contact_type_id  = pc.contact_type_id
INNER JOIN reservation_passenger rp ON rp.person_id = p.person_id
GROUP BY
    p.person_id,
    p.first_name,
    p.last_name,
    pt.type_name,
    p.updated_at
ORDER BY p.last_name, p.first_name;