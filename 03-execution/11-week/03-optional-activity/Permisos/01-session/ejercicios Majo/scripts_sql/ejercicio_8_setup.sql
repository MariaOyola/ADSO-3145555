-- ============================================================
-- ejercicio_8_setup.sql
-- Ejercicio 08 - Auditoria de acceso y asignacion de roles
-- a usuarios
-- ============================================================

DROP TRIGGER IF EXISTS trg_ai_user_role_touch_account ON user_role;
DROP FUNCTION IF EXISTS fn_ai_user_role_touch_account();
DROP PROCEDURE IF EXISTS sp_assign_user_role(uuid, uuid, uuid);

-- ============================================================
-- FUNCION DEL TRIGGER AFTER INSERT
-- ============================================================
-- Cada vez que se asigna un rol a un usuario en user_role,
-- el trigger actualiza user_account.updated_at para que
-- la cuenta quede marcada con el timestamp del evento
-- de seguridad.
-- Esta accion es verificable, no rompe 3FN y es coherente
-- con la trazabilidad de acceso del negocio.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_ai_user_role_touch_account()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE user_account
    SET updated_at = now()
    WHERE user_account_id = NEW.user_account_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- TRIGGER AFTER INSERT SOBRE user_role
-- ============================================================
CREATE TRIGGER trg_ai_user_role_touch_account
AFTER INSERT ON user_role
FOR EACH ROW
EXECUTE FUNCTION fn_ai_user_role_touch_account();

-- ============================================================
-- PROCEDIMIENTO sp_assign_user_role
-- ============================================================
-- Parametros:
--   p_user_account_id      : cuenta de usuario a la que se asigna el rol
--   p_security_role_id     : rol que se desea asignar
--   p_assigned_by_user_id  : cuenta del usuario que realiza la asignacion
--                            (puede ser NULL para bootstrap)
-- Validaciones internas:
--   1. user_account_id debe existir en user_account
--   2. security_role_id debe existir en security_role
--   3. Si se proporciona assigned_by_user_id, debe existir en user_account
--   4. No puede existir ya la combinacion (user_account_id, security_role_id)
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_assign_user_role(
    p_user_account_id     uuid,
    p_security_role_id    uuid,
    p_assigned_by_user_id uuid
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM user_account
        WHERE user_account_id = p_user_account_id
    ) THEN
        RAISE EXCEPTION 'user_account_id % no existe en user_account.', p_user_account_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM security_role
        WHERE security_role_id = p_security_role_id
    ) THEN
        RAISE EXCEPTION 'security_role_id % no existe en security_role.', p_security_role_id;
    END IF;

    IF p_assigned_by_user_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM user_account
        WHERE user_account_id = p_assigned_by_user_id
    ) THEN
        RAISE EXCEPTION 'assigned_by_user_id % no existe en user_account.', p_assigned_by_user_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM user_role
        WHERE user_account_id  = p_user_account_id
          AND security_role_id = p_security_role_id
    ) THEN
        RAISE EXCEPTION 'El usuario % ya tiene asignado el rol %. No se puede duplicar.',
            p_user_account_id, p_security_role_id;
    END IF;

    INSERT INTO user_role (
        user_account_id,
        security_role_id,
        assigned_at,
        assigned_by_user_id
    )
    VALUES (
        p_user_account_id,
        p_security_role_id,
        now(),
        p_assigned_by_user_id
    );
END;
$$;

-- ============================================================
-- REQUERIMIENTO 1 - CONSULTA INNER JOIN - 7 TABLAS
-- ============================================================
-- Tablas involucradas:
--   person              - nombre real de la persona
--   user_account        - cuenta de acceso al sistema
--   user_status         - estado de la cuenta (ACTIVE, LOCKED...)
--   user_role           - rol asignado a la cuenta
--   security_role       - definicion del rol (SYS_ADMIN, etc.)
--   role_permission     - relacion entre rol y permiso
--   security_permission - permiso heredado por el rol
-- ============================================================
SELECT
    p.first_name || ' ' || p.last_name      AS persona,
    ua.username                              AS usuario,
    us.status_name                           AS estado_usuario,
    sr.role_name                             AS rol_asignado,
    sr.role_code                             AS codigo_rol,
    ur.assigned_at                           AS fecha_asignacion,
    sp.permission_name                       AS permiso_asociado,
    sp.permission_code                       AS codigo_permiso,
    sp.permission_description                AS descripcion_permiso
FROM person p
INNER JOIN user_account ua
    ON ua.person_id = p.person_id
INNER JOIN user_status us
    ON us.user_status_id = ua.user_status_id
INNER JOIN user_role ur
    ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr
    ON sr.security_role_id = ur.security_role_id
INNER JOIN role_permission rp
    ON rp.security_role_id = sr.security_role_id
INNER JOIN security_permission sp
    ON sp.security_permission_id = rp.security_permission_id
ORDER BY ua.username, sr.role_name, sp.permission_name;