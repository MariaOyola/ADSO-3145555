# Ejercicio 05 Resuelto - Mantenimiento de aeronaves y habilitación operativa

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje, facturación y gestión técnica de la flota.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El área técnica de la aerolínea necesita:

1. Consultar el historial de mantenimiento de las aeronaves relacionando la aeronave, su aerolínea, modelo, fabricante, tipo de intervención y proveedor responsable.
2. Automatizar una acción verificable sobre la aeronave cada vez que se registra un nuevo evento de mantenimiento.
3. Encapsular el registro del evento de mantenimiento en un procedimiento reutilizable con validaciones de integridad.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| AIRCRAFT | `aircraft`, `aircraft_model`, `aircraft_manufacturer`, `maintenance_event`, `maintenance_type`, `maintenance_provider` | HK-5500, HK-7870, N803NV |
| AIRLINE | `airline` | FLY Airlines, Nova America |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Aeronave elegida | `N803NV` (Nova America - E190-E2 - sin eventos previos) | seed canónico |
| Tipo de mantenimiento | `UNSCHED` — No programado | seed canónico |
| Proveedor | `AeroAndes MRO Bogota` — Hangar 5, Zona Industrial, Bogotá | seed canónico |
| Estado del evento | `COMPLETED` | demo |
| Efecto verificable | `aircraft.updated_at` actualizado por trigger | DDL: campo mutable real |

### ¿Por qué la aeronave N803NV?

El seed canónico registra dos eventos sobre `HK-5500` (LINE) y `HK-7870` (A_CHECK). La aeronave `N803NV` no tiene ningún evento, lo que permite demostrar el primer registro de mantenimiento de forma limpia y verificable sin interferir con los datos existentes.

---

## 5. Eventos de mantenimiento existentes en el seed canónico

| Aeronave | Tipo | Proveedor | Estado | Inicio | Fin |
|---|---|---|---|---|---|
| HK-5500 | LINE | AeroAndes MRO Bogota | COMPLETED | 2026-03-09 22:10 | 2026-03-10 01:15 |
| HK-7870 | A_CHECK | Atlantic TechOps Miami | COMPLETED | 2026-03-08 23:30 | 2026-03-09 05:45 |

---

## 6. Decisión técnica del trigger: el problema de 3FN

### El reto

El enunciado pide que el trigger sobre `maintenance_event` produzca una acción verificable sobre la aeronave asociada. La primera solución intuitiva sería actualizar un campo de estado o de "habilitación operativa" en `aircraft`. Sin embargo, el DDL no tiene esa columna: el modelo preserva la **tercera forma normal (3FN)** y no almacena estados derivados en `aircraft`.

Modificar el modelo para agregar ese campo violaría la restricción del ejercicio.

### La solución correcta

El único campo mutable de `aircraft` sin derivar datos es `updated_at`, presente en todas las tablas del modelo. Actualizar `aircraft.updated_at` cuando se inserta un evento de mantenimiento es:

- **Correcto**: atributo real del DDL.
- **Verificable**: se puede comparar el valor antes y después del trigger.
- **Coherente con el negocio**: la ficha técnica refleja que la aeronave recibió una intervención.
- **Sin romper 3FN**: no almacena ningún valor derivado.

---

## 7. Teoría base aplicada

### ¿Por qué INNER JOIN con LEFT JOIN en maintenance_provider?

Se usa `INNER JOIN` para las 6 tablas principales porque todas deben existir para que el resultado tenga sentido. `maintenance_provider` se une con `LEFT JOIN` porque el modelo permite `maintenance_event.maintenance_provider_id NULL`: un evento puede registrarse sin proveedor asignado. Usar `INNER JOIN` en `maintenance_provider` excluiría esos eventos.

### ¿Por qué trigger AFTER?

La inserción en `maintenance_event` necesita estar confirmada antes de ejecutar el `UPDATE` en `aircraft`. Si el trigger fuera `BEFORE`, la fila aún no existiría y el `updated_at` se actualizaría antes de que el evento técnico fuera persistido. El trigger `AFTER INSERT` garantiza el orden correcto dentro de la misma transacción.

### ¿Por qué procedimiento almacenado?

Centraliza 4 validaciones críticas: existencia de la aeronave, existencia del tipo de mantenimiento, existencia del proveedor (cuando se proporciona) y consistencia cronológica entre `started_at` y `completed_at`.

---

## 8. Consulta resuelta con INNER JOIN

### Tablas involucradas: 7 (6 INNER JOIN + 1 LEFT JOIN)

### Resultado con datos reales del seed canónico

| matricula | aerolinea | modelo | fabricante | tipo | proveedor | estado | inicio | fin |
|---|---|---|---|---|---|---|---|---|
| HK-7870 | FLY Airlines | 787-8 Dreamliner | Boeing | A-Check | Atlantic TechOps Miami | COMPLETED | 2026-03-08 23:30 | 2026-03-09 05:45 |
| HK-5500 | FLY Airlines | A320neo | Airbus | Linea | AeroAndes MRO Bogota | COMPLETED | 2026-03-09 22:10 | 2026-03-10 01:15 |

### Explicación paso a paso de cada JOIN

1. **`aircraft`** → aeronave intervenida. Punto de entrada del dominio técnico.
2. **`airline`** → aerolínea operadora. Relacionada por `airline_id`.
3. **`aircraft_model`** → modelo: nombre comercial y alcance. Relacionado por `aircraft_model_id`.
4. **`aircraft_manufacturer`** → fabricante del modelo: Airbus, Boeing, Embraer.
5. **`maintenance_event`** → evento registrado: estado, fechas, notas.
6. **`maintenance_type`** → tipo de intervención: LINE, A_CHECK, C_CHECK, ENGINE, CABIN, UNSCHED.
7. **`maintenance_provider`** *(LEFT JOIN)* → proveedor responsable. NULL cuando no hay proveedor asignado.

---

## 9. Trigger resuelto

### Acción implementada

Cada vez que se inserta un evento en `maintenance_event`, la aeronave queda marcada con el timestamp de la modificación mediante `UPDATE aircraft SET updated_at = now()`. Esto es verificable, sin romper 3FN y coherente con el negocio.

---

## 10. Procedimiento almacenado resuelto

### Parámetros de entrada

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_aircraft_id` | `maintenance_event.aircraft_id` | uuid | FK a `aircraft` |
| `p_maintenance_type_id` | `maintenance_event.maintenance_type_id` | uuid | FK a `maintenance_type` |
| `p_maintenance_provider_id` | `maintenance_event.maintenance_provider_id` | uuid | Nullable, FK a `maintenance_provider` |
| `p_status_code` | `maintenance_event.status_code` | varchar(30) | NOT NULL |
| `p_started_at` | `maintenance_event.started_at` | timestamptz | Nullable |
| `p_completed_at` | `maintenance_event.completed_at` | timestamptz | Nullable |
| `p_notes` | `maintenance_event.notes` | text | Nullable |

### Validaciones internas (4 checks)

1. `aircraft_id` debe existir en `aircraft`.
2. `maintenance_type_id` debe existir en `maintenance_type`.
3. Si se proporciona `maintenance_provider_id`, debe existir en `maintenance_provider`.
4. `completed_at` no puede ser anterior a `started_at`.

---

## 11. Script de demostración

### ¿Qué demuestra?

1. Busca `N803NV` (sin eventos previos) del seed canónico.
2. Verifica `updated_at` y cantidad de eventos antes del demo (0).
3. Resuelve `maintenance_type_id` de `UNSCHED` y `maintenance_provider_id` de `AeroAndes MRO Bogota`.
4. Invoca `sp_register_maintenance_event` con esos datos reales.
5. El procedimiento valida los 4 constraints e inserta en `maintenance_event`.
6. El trigger `AFTER INSERT` actualiza `aircraft.updated_at` automáticamente.
7. Las 3 validaciones confirman el evento, la trazabilidad completa y el resumen por aeronave.

---

## 12. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 6 INNER JOINs + 1 LEFT JOIN justificado |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 7 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON maintenance_event FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Actualiza `aircraft.updated_at` |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_5_demo.sql` con `DO $$` y 3 validaciones |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de evento con 4 validaciones |
| Existe script que invoca el procedimiento | ✅ | `CALL sp_register_maintenance_event(...)` |
| La invocación evidencia el trigger | ✅ | `aircraft.updated_at` cambia al registrar el evento |
| No se alteró la estructura base del modelo | ✅ | Solo función, trigger y procedimiento |

---

## 13. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_5_setup.sql` | Función, trigger, procedimiento y consulta INNER JOIN con 7 tablas |
| `ejercicio_5_demo.sql` | Bloque `DO $$`, invocación del procedimiento y 3 validaciones |
| `ejercicio_5_resuelto.md` | Documentación completa con decisiones técnicas y criterios |