# Ejercicio 06 Resuelto - Retrasos operativos y análisis de impacto por segmento de vuelo

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje, facturación y gestión operativa de vuelos.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

La gerencia de operaciones necesita:

1. Consultar los retrasos registrados por segmento de vuelo relacionando aerolínea, vuelo, estado, segmento, aeropuertos y motivo de demora.
2. Automatizar una acción verificable sobre el segmento afectado cada vez que se registra una demora.
3. Encapsular el registro de la demora en un procedimiento reutilizable con validaciones de integridad.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| FLIGHT OPERATIONS | `flight`, `flight_segment`, `flight_status`, `flight_delay`, `delay_reason_type` | FY101 BOG→MDE, FY305 BOG→MIA |
| AIRPORT | `airport` | BOG, MDE, MIA, MAD |
| AIRLINE | `airline` | FLY Airlines |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Segmento elegido | FY305 BOG→MIA del 2026-03-15 (sin demoras previas) | seed canónico |
| Motivo de demora | `WX` — Condiciones meteorológicas | seed canónico |
| Minutos de demora | 45 | demo |
| Efecto verificable | `flight_segment.updated_at` actualizado por trigger | DDL: campo mutable real |

### ¿Por qué el segmento FY305?

El seed canónico registra una demora existente sobre el segmento `FY101 BOG→MDE` (motivo: `CREW`, 32 minutos). El segmento `FY305 BOG→MIA` del 2026-03-15 no tiene ninguna demora previa, lo que permite demostrar el primer registro de forma limpia y verificable sin interferir con los datos existentes.

---

## 5. Demoras existentes en el seed canónico

| Vuelo | Ruta | Fecha | Motivo | Minutos | Notas |
|---|---|---|---|---|---|
| FY101 | BOG → MDE | 2026-03-12 | CREW | 32 | Ajuste final de tripulación |

---

## 6. Decisión técnica del trigger: el problema de 3FN

### El reto

El enunciado pide que el trigger sobre `flight_delay` produzca una acción verificable sobre el segmento de vuelo afectado. La primera solución intuitiva sería actualizar un campo de estado operativo en `flight_segment`. Sin embargo, el DDL no tiene esa columna derivada: el modelo preserva la **tercera forma normal (3FN)** y no almacena estados calculados en `flight_segment`.

Modificar el modelo para agregar ese campo violaría la restricción del ejercicio.

### La solución correcta

El único campo mutable de `flight_segment` sin derivar datos es `updated_at`, presente en todas las tablas del modelo. Actualizar `flight_segment.updated_at` cuando se inserta una demora es:

- **Correcto**: atributo real del DDL.
- **Verificable**: se puede comparar el valor antes y después del trigger.
- **Coherente con el negocio**: el segmento refleja que fue impactado por una demora operacional.
- **Sin romper 3FN**: no almacena ningún valor derivado.

---

## 7. Teoría base aplicada

### ¿Por qué INNER JOIN en todas las tablas?

Se usan `INNER JOIN` para las 8 tablas porque todas deben existir para que el resultado tenga sentido operacional. No existe en este dominio un caso análogo a `maintenance_provider` (que era opcional): toda demora en `flight_delay` tiene obligatoriamente un `flight_segment`, un `delay_reason_type`, y ese segmento pertenece a un `flight` con su `airline` y sus dos aeropuertos. El modelo impone estas relaciones mediante `FOREIGN KEY NOT NULL` en todos los campos involucrados.

### ¿Por qué trigger AFTER?

La inserción en `flight_delay` necesita estar confirmada antes de ejecutar el `UPDATE` en `flight_segment`. Si el trigger fuera `BEFORE`, la fila de demora aún no existiría en la tabla y el `updated_at` se actualizaría antes de que el evento operativo fuera persistido. El trigger `AFTER INSERT` garantiza el orden correcto dentro de la misma transacción.

### ¿Por qué procedimiento almacenado?

Centraliza 4 validaciones críticas: existencia del segmento, existencia del motivo de demora, obligatoriedad del timestamp de reporte y validez de los minutos de demora (deben ser positivos). Sin este procedimiento, una inserción directa en `flight_delay` podría registrar demoras con motivos inexistentes, timestamps nulos o minutos en cero o negativos, todos escenarios incoherentes con la operación.

---

## 8. Consulta resuelta con INNER JOIN

### Tablas involucradas: 8 (todos INNER JOIN)

| # | Tabla | Alias | Propósito |
|---|---|---|---|
| 1 | `flight_delay` | `fd` | Demora registrada: minutos, reporte, notas |
| 2 | `delay_reason_type` | `drt` | Motivo: CREW, WX, MX, ATC, OPS, SEC |
| 3 | `flight_segment` | `fs` | Segmento impactado: tiempos, número |
| 4 | `flight` | `f` | Vuelo: número, fecha de servicio |
| 5 | `flight_status` | `fs_status` | Estado: ARRIVED, DELAYED, SCHEDULED... |
| 6 | `airline` | `al` | Aerolínea operadora |
| 7 | `airport` (origen) | `ao` | Aeropuerto de salida del segmento |
| 8 | `airport` (destino) | `ad` | Aeropuerto de llegada del segmento |

### Resultado con datos reales del seed canónico (antes del demo)

| aerolinea | numero_vuelo | fecha_servicio | estado_vuelo | segmento | origen | destino | minutos | motivo |
|---|---|---|---|---|---|---|---|---|
| FLY Airlines | FY101 | 2026-03-12 | Arribado | 1 | BOG | MDE | 32 | Disponibilidad de tripulación |

### Resultado tras ejecutar el demo (después del CALL)

| aerolinea | numero_vuelo | fecha_servicio | estado_vuelo | segmento | origen | destino | minutos | motivo |
|---|---|---|---|---|---|---|---|---|
| FLY Airlines | FY101 | 2026-03-12 | Arribado | 1 | BOG | MDE | 32 | Disponibilidad de tripulación |
| FLY Airlines | FY305 | 2026-03-15 | Arribado | 1 | BOG | MIA | 45 | Condiciones meteorológicas |

### Explicación paso a paso de cada JOIN

1. **`flight_delay`** → punto de entrada. Contiene los registros de demora: cuántos minutos, cuándo se reportó y notas.
2. **`delay_reason_type`** → clasificación del motivo: CREW, WX, MX, ATC, OPS, SEC. Requerido para el análisis de causa raíz.
3. **`flight_segment`** → segmento afectado: identifica la ruta exacta (origen-destino) y los tiempos programados vs reales.
4. **`flight`** → vuelo al que pertenece el segmento: número de vuelo y fecha de servicio.
5. **`flight_status`** → estado operativo del vuelo al momento de la consulta.
6. **`airline`** → aerolínea que opera el vuelo. Necesaria para reportes multi-aerolínea.
7. **`airport` (origen)** → aeropuerto de salida del segmento. Se usa alias `ao` para diferenciarlo del destino.
8. **`airport` (destino)** → aeropuerto de llegada del segmento. Se usa alias `ad`. El mismo self-join sobre `airport` es el patrón estándar para rutas origen-destino.

---

## 9. Trigger resuelto

### Acción implementada

Cada vez que se inserta un registro en `flight_delay`, el segmento de vuelo afectado queda marcado con el timestamp de la modificación mediante `UPDATE flight_segment SET updated_at = now()`. Esto es verificable, sin romper 3FN y coherente con el negocio: el segmento refleja que fue tocado por un evento operativo posterior a su creación.

---

## 10. Procedimiento almacenado resuelto

### Parámetros de entrada

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_flight_segment_id` | `flight_delay.flight_segment_id` | uuid | FK a `flight_segment` |
| `p_delay_reason_type_id` | `flight_delay.delay_reason_type_id` | uuid | FK a `delay_reason_type` |
| `p_reported_at` | `flight_delay.reported_at` | timestamptz | NOT NULL |
| `p_delay_minutes` | `flight_delay.delay_minutes` | integer | > 0 |
| `p_notes` | `flight_delay.notes` | text | Nullable |

### Validaciones internas (4 checks)

1. `flight_segment_id` debe existir en `flight_segment`.
2. `delay_reason_type_id` debe existir en `delay_reason_type`.
3. `p_reported_at` no puede ser nulo.
4. `p_delay_minutes` debe ser un entero positivo mayor a cero.

---

## 11. Script de demostración

### ¿Qué demuestra?

1. Resuelve el segmento `FY305 BOG→MIA` del 2026-03-15 del seed canónico.
2. Verifica `updated_at` y cantidad de demoras previas (0).
3. Resuelve el `delay_reason_type_id` del motivo `WX`.
4. Invoca `sp_register_flight_delay` con esos datos reales.
5. El procedimiento valida los 4 constraints e inserta en `flight_delay`.
6. El trigger `AFTER INSERT` actualiza `flight_segment.updated_at` automáticamente.
7. Las 3 validaciones confirman la demora registrada, la trazabilidad completa y el resumen por vuelo.

---

## 12. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 8 INNER JOINs sobre tablas reales del modelo |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 8 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON flight_delay FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Actualiza `flight_segment.updated_at` |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_6_demo.sql` con `DO $$` y 3 validaciones |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de demora con 4 validaciones |
| Existe script que invoca el procedimiento | ✅ | `CALL sp_register_flight_delay(...)` |
| La invocación evidencia el trigger | ✅ | `flight_segment.updated_at` cambia al registrar la demora |
| No se alteró la estructura base del modelo | ✅ | Solo función, trigger y procedimiento |

---

## 13. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_6_setup.sql` | Función, trigger, procedimiento y consulta INNER JOIN con 8 tablas |
| `ejercicio_6_demo.sql` | Bloque `DO $$`, invocación del procedimiento y 3 validaciones |
| `ejercicio_6_resuelto.md` | Documentación completa con decisiones técnicas y criterios |