-- ============================================================
-- ejercicio_8_demo.sql
-- Ejercicio 08 - Auditoria de acceso y asignacion de roles
-- a usuarios
-- ============================================================
-- Flujo del demo:
--   1. Usuario patricia.vargas (SALES_AGENT) - sin rol OPS_CTRL
--   2. Usuario asignador: diego.ramirez (SYS_ADMIN)
--   3. CALL sp_assign_user_role para asignar OPS_CTRL a patricia.vargas
--   4. Trigger actualiza user_account.updated_at automaticamente
--   5. Tres validaciones confirman el resultado
-- ============================================================

DO $$
DECLARE
    v_user_id          uuid;
    v_username         varchar(100);
    v_user_updated_at  timestamptz;
    v_role_id          uuid;
    v_assigner_id      uuid;
    v_roles_before     integer;
    v_status_name      varchar(100);
BEGIN
    -- --------------------------------------------------------
    -- Resolver patricia.vargas (SALES_AGENT en el seed)
    -- No tiene OPS_CTRL asignado, lo que permite demostrar
    -- la asignacion de forma limpia sin duplicar roles.
    -- --------------------------------------------------------
    SELECT
        ua.user_account_id,
        ua.username,
        ua.updated_at,
        us.status_name
    INTO
        v_user_id,
        v_username,
        v_user_updated_at,
        v_status_name
    FROM user_account ua
    JOIN user_status us ON us.user_status_id = ua.user_status_id
    WHERE ua.username = 'patricia.vargas';

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'No existe el usuario patricia.vargas. Verificar seed canonico.';
    END IF;

    -- Contar roles previos de la cuenta
    SELECT COUNT(*)
    INTO   v_roles_before
    FROM   user_role ur
    WHERE  ur.user_account_id = v_user_id;

    -- Resolver el rol OPS_CTRL
    SELECT security_role_id INTO v_role_id
    FROM   security_role
    WHERE  role_code = 'OPS_CTRL';

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el rol OPS_CTRL. Verificar seed canonico.';
    END IF;

    -- Resolver el usuario asignador: diego.ramirez (SYS_ADMIN)
    SELECT user_account_id INTO v_assigner_id
    FROM   user_account
    WHERE  username = 'diego.ramirez';

    IF v_assigner_id IS NULL THEN
        RAISE EXCEPTION 'No se encontro el usuario diego.ramirez. Verificar seed canonico.';
    END IF;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Estado inicial de la cuenta:';
    RAISE NOTICE '  user_account_id : %', v_user_id;
    RAISE NOTICE '  username        : %', v_username;
    RAISE NOTICE '  estado          : %', v_status_name;
    RAISE NOTICE '  updated_at      : %', v_user_updated_at;
    RAISE NOTICE '  roles previos   : %', v_roles_before;
    RAISE NOTICE '  rol a asignar   : OPS_CTRL (Control operacional)';
    RAISE NOTICE '  asignado por    : diego.ramirez (SYS_ADMIN)';
    RAISE NOTICE '==========================================';

    CALL sp_assign_user_role(
        v_user_id,
        v_role_id,
        v_assigner_id
    );

    RAISE NOTICE 'sp_assign_user_role ejecutado.';
    RAISE NOTICE 'Rol OPS_CTRL asignado a %.', v_username;
    RAISE NOTICE 'El trigger actualiza user_account.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Rol insertado y user_account.updated_at
-- ============================================================
SELECT
    ua.username                              AS usuario,
    ua.updated_at                            AS cuenta_updated_at,
    sr.role_name                             AS rol_asignado,
    sr.role_code                             AS codigo_rol,
    ur.assigned_at                           AS fecha_asignacion,
    assigner.username                        AS asignado_por
FROM user_role ur
INNER JOIN user_account ua
    ON ua.user_account_id = ur.user_account_id
INNER JOIN security_role sr
    ON sr.security_role_id = ur.security_role_id
LEFT JOIN user_account assigner
    ON assigner.user_account_id = ur.assigned_by_user_id
WHERE ua.username = 'patricia.vargas'
ORDER BY ur.assigned_at;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa persona -> permisos
-- Ejecuta la consulta principal del setup para mostrar
-- la matriz completa de acceso tras la asignacion
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

-- ============================================================
-- VALIDACION 3: Resumen de acceso por usuario
-- ============================================================
SELECT
    p.first_name || ' ' || p.last_name      AS persona,
    ua.username                              AS usuario,
    us.status_name                           AS estado,
    ua.updated_at                            AS ultima_modificacion_cuenta,
    COUNT(DISTINCT ur.security_role_id)      AS total_roles,
    COUNT(DISTINCT rp.security_permission_id) AS total_permisos,
    string_agg(DISTINCT sr.role_code, ', ' ORDER BY sr.role_code) AS roles
FROM user_account ua
INNER JOIN user_status us
    ON us.user_status_id = ua.user_status_id
INNER JOIN person p
    ON p.person_id = ua.person_id
INNER JOIN user_role ur
    ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr
    ON sr.security_role_id = ur.security_role_id
INNER JOIN role_permission rp
    ON rp.security_role_id = sr.security_role_id
GROUP BY
    p.first_name, p.last_name,
    ua.username,
    us.status_name,
    ua.updated_at
ORDER BY ua.username;