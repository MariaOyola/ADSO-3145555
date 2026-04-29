# Ejercicio 08 Resuelto - Auditoría de acceso y asignación de roles a usuarios

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje, facturación y control de acceso mediante roles y permisos.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El equipo de seguridad necesita:

1. Consultar el mapa completo de autorización: qué personas tienen qué cuentas, en qué estado, con qué roles y qué permisos heredan de esos roles.
2. Automatizar una acción verificable sobre la cuenta de usuario cada vez que se le asigna un nuevo rol.
3. Encapsular la asignación de roles en un procedimiento reutilizable con validaciones de integridad.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| SECURITY | `user_account`, `user_status`, `user_role`, `security_role`, `role_permission`, `security_permission` | diego.ramirez (SYS_ADMIN), patricia.vargas (SALES_AGENT) |
| IDENTITY | `person` | Diego Ramirez, Patricia Vargas |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Usuario elegido | `patricia.vargas` (SALES_AGENT — sin OPS_CTRL) | seed canónico |
| Rol a asignar | `OPS_CTRL` — Control operacional | seed canónico |
| Usuario asignador | `diego.ramirez` (SYS_ADMIN) | seed canónico |
| Roles previos | 1 — solo SALES_AGENT | seed canónico |
| Efecto verificable | `user_account.updated_at` actualizado por trigger | DDL: campo mutable real |

### ¿Por qué el usuario patricia.vargas?

El seed canónico registra a `diego.ramirez` con rol `SYS_ADMIN` y a `patricia.vargas` con rol `SALES_AGENT`. Patricia no tiene `OPS_CTRL`, lo que permite demostrar la asignación de un segundo rol de forma limpia y verificable sin duplicar combinaciones existentes.

---

## 5. Roles y permisos existentes en el seed canónico

### Matriz de roles activos por usuario

| Usuario | Rol | Permisos heredados |
|---|---|---|
| diego.ramirez | SYS_ADMIN | Todos los permisos del sistema (12) |
| patricia.vargas | SALES_AGENT | VIEW_CUSTOMERS, WRITE_CUSTOMERS, MANAGE_RESERVATIONS, ISSUE_TICKETS, VIEW_REPORTS |

### Permisos del rol OPS_CTRL (añadido en el demo)

| Código | Nombre |
|---|---|
| MANAGE_FLIGHTS | Administrar vuelos |
| MANAGE_AIRCRAFT | Administrar flota |
| VALIDATE_BOARDING | Validar abordaje |
| VIEW_REPORTS | Consultar reportes |

---

## 6. Decisión técnica del trigger: el problema de 3FN

### El reto

El enunciado pide que el trigger sobre `user_role` produzca una acción verificable sobre la cuenta de usuario asociada. La solución intuitiva sería actualizar un campo de "último rol asignado" o un contador de roles en `user_account`. Sin embargo, el DDL no tiene esa columna derivada: el modelo preserva la **tercera forma normal (3FN)** y no almacena estados calculados en `user_account`.

Modificar el modelo para agregar ese campo violaría la restricción del ejercicio.

### La solución correcta

El único campo mutable de `user_account` sin derivar datos es `updated_at`, presente en todas las tablas del modelo. Actualizar `user_account.updated_at` cuando se inserta un rol es:

- **Correcto**: atributo real del DDL.
- **Verificable**: se puede comparar el valor antes y después del trigger.
- **Coherente con el negocio**: la ficha de la cuenta refleja que sus privilegios de acceso fueron modificados.
- **Sin romper 3FN**: no almacena ningún valor derivado.

---

## 7. Teoría base aplicada

### ¿Por qué INNER JOIN en las 7 tablas?

Se usan `INNER JOIN` para las 7 tablas porque la consulta busca el mapa de autorización activo: solo tienen sentido los usuarios que tienen cuenta, la cuenta debe tener un estado, la cuenta debe tener al menos un rol asignado, ese rol debe tener permisos configurados y esos permisos deben existir. Si cualquiera de esas relaciones faltara, la fila no tendría valor para la auditoría de seguridad.

En la validación 3 (resumen por usuario) se mantienen `INNER JOIN` para las tablas de rol y permiso, ya que el resumen de roles sólo es útil cuando el usuario tiene al menos uno. La función de agregación `string_agg` consolida todos los roles en una sola fila por usuario.

### ¿Por qué el trigger está sobre user_role y no sobre role_permission?

El evento de negocio relevante para la auditoría de acceso es la **asignación del rol al usuario**, no la definición de permisos en el rol. `role_permission` es configuración estructural del sistema (qué puede hacer cada rol), mientras que `user_role` es la decisión operativa de conceder ese acceso a una persona concreta. El trigger sobre `user_role` captura el momento exacto en que el privilegio fue otorgado.

### ¿Por qué procedimiento almacenado?

Centraliza 4 validaciones críticas: existencia del usuario, existencia del rol, existencia del asignador (cuando se proporciona) y unicidad de la combinación usuario-rol. Sin este procedimiento, una inserción directa podría asignar el mismo rol dos veces a un usuario o referenciar roles o usuarios inexistentes, todos escenarios que comprometen la integridad del modelo de seguridad.

---

## 8. Consulta resuelta con INNER JOIN

### Tablas involucradas: 7 (todos INNER JOIN)

| # | Tabla | Propósito |
|---|---|---|
| 1 | `person` | Nombre real de la persona asociada a la cuenta |
| 2 | `user_account` | Cuenta de acceso: username y estado |
| 3 | `user_status` | Estado legible: ACTIVE, LOCKED, SUSPENDED... |
| 4 | `user_role` | Rol asignado: fecha de asignación |
| 5 | `security_role` | Definición del rol: código y nombre |
| 6 | `role_permission` | Relación entre el rol y sus permisos |
| 7 | `security_permission` | Permiso heredado: código, nombre y descripción |

### Resultado con datos reales del seed (antes del demo)

| persona | usuario | estado | rol | fecha_asignacion | permiso |
|---|---|---|---|---|---|
| Diego Ramirez | diego.ramirez | Activo | Administrador del sistema | 2026-01-02 | (12 permisos) |
| Patricia Vargas | patricia.vargas | Activo | Agente comercial | 2026-01-05 | VIEW_CUSTOMERS |
| Patricia Vargas | patricia.vargas | Activo | Agente comercial | 2026-01-05 | WRITE_CUSTOMERS |
| Patricia Vargas | patricia.vargas | Activo | Agente comercial | 2026-01-05 | MANAGE_RESERVATIONS |
| Patricia Vargas | patricia.vargas | Activo | Agente comercial | 2026-01-05 | ISSUE_TICKETS |
| Patricia Vargas | patricia.vargas | Activo | Agente comercial | 2026-01-05 | VIEW_REPORTS |

### Resultado tras ejecutar el demo (después del CALL)

Patricia Vargas aparece ahora con dos bloques de filas: uno por `SALES_AGENT` (5 permisos) y uno por `OPS_CTRL` (4 permisos), totalizando 9 permisos distintos. El campo `user_account.updated_at` refleja el timestamp del trigger.

### Explicación paso a paso de cada JOIN

1. **`person`** → nombre real de la persona. La cuenta por sí sola solo tiene un username; la auditoría de seguridad requiere la identidad real.
2. **`user_account`** → cuenta de acceso al sistema. Punto de entrada de la consulta.
3. **`user_status`** → estado legible de la cuenta. Crítico para auditoría: una cuenta LOCKED o SUSPENDED no debería tener actividad reciente de asignación.
4. **`user_role`** → asignación concreta de rol a usuario. Contiene la fecha de asignación y quién la realizó.
5. **`security_role`** → definición del rol: su código operativo y nombre descriptivo.
6. **`role_permission`** → tabla de unión que conecta el rol con sus permisos. Sin ella no es posible saber qué puede hacer el rol.
7. **`security_permission`** → permiso específico: código, nombre y descripción. Es el nivel más granular de la matriz de autorización.

---

## 9. Trigger resuelto

### Acción implementada

Cada vez que se inserta un registro en `user_role`, la cuenta de usuario asociada queda marcada con el timestamp de la modificación mediante `UPDATE user_account SET updated_at = now()`. Esto es verificable, sin romper 3FN y coherente con el negocio: la ficha de la cuenta refleja que sus privilegios de acceso fueron modificados en ese instante.

---

## 10. Procedimiento almacenado resuelto

### Parámetros de entrada

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_user_account_id` | `user_role.user_account_id` | uuid | FK a `user_account` |
| `p_security_role_id` | `user_role.security_role_id` | uuid | FK a `security_role` |
| `p_assigned_by_user_id` | `user_role.assigned_by_user_id` | uuid | Nullable, FK a `user_account` |

### Validaciones internas (4 checks)

1. `user_account_id` debe existir en `user_account`.
2. `security_role_id` debe existir en `security_role`.
3. Si se proporciona `assigned_by_user_id`, debe existir en `user_account`.
4. La combinación `(user_account_id, security_role_id)` no puede existir ya en `user_role`.

---

## 11. Script de demostración

### ¿Qué demuestra?

1. Resuelve `patricia.vargas` del seed canónico y verifica su `updated_at` inicial.
2. Confirma que tiene 1 rol previo (SALES_AGENT) y ningún OPS_CTRL.
3. Resuelve el `security_role_id` de `OPS_CTRL` y el `user_account_id` de `diego.ramirez`.
4. Invoca `sp_assign_user_role` con esos datos reales.
5. El procedimiento valida los 4 constraints e inserta en `user_role`.
6. El trigger `AFTER INSERT` actualiza `user_account.updated_at` automáticamente.
7. Las 3 validaciones confirman el rol insertado, la matriz de permisos expandida y el resumen por usuario con `string_agg` de roles.

---

## 12. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 7 INNER JOINs sobre tablas reales del modelo |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 7 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON user_role FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Actualiza `user_account.updated_at` |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_8_demo.sql` con `DO $$` y 3 validaciones |
| El procedimiento encapsula una operación útil del negocio | ✅ | Asignación de rol con 4 validaciones |
| Existe script que invoca el procedimiento | ✅ | `CALL sp_assign_user_role(...)` |
| La invocación evidencia el trigger | ✅ | `user_account.updated_at` cambia al asignar el rol |
| No se alteró la estructura base del modelo | ✅ | Solo función, trigger y procedimiento |

---

## 13. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_8_setup.sql` | Función, trigger, procedimiento y consulta INNER JOIN con 7 tablas |
| `ejercicio_8_demo.sql` | Bloque `DO $$`, invocación del procedimiento y 3 validaciones |
| `ejercicio_8_resuelto.md` | Documentación completa con decisiones técnicas y criterios |