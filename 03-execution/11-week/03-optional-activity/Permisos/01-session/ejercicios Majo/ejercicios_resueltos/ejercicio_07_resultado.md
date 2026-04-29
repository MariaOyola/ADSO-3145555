# Ejercicio 07 Resuelto - Asignación de asientos y registro de equipaje por segmento ticketed

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje, facturación y gestión aeroportuaria de asientos y equipaje.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El área de aeropuerto necesita:

1. Consultar de forma integrada la asignación de asientos y el equipaje registrado por pasajero y segmento, relacionando el tiquete, el segmento ticketed, el segmento operativo, la aeronave, la cabina y el equipaje.
2. Automatizar una acción verificable sobre el segmento ticketed cada vez que se registra un equipaje.
3. Encapsular el registro del equipaje en un procedimiento reutilizable con validaciones de integridad.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| SALES / TICKETING | `ticket`, `ticket_segment`, `seat_assignment`, `baggage` | TKT-FY-00001, TKT-FY-00002, TKT-FY-00003 |
| AIRCRAFT | `aircraft_seat`, `aircraft_cabin`, `cabin_class` | HK-7870 cabina J, HK-5500 cabina Y |
| FLIGHT OPERATIONS | `flight`, `flight_segment` | FY210, FY101, FY305 |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Tiquete elegido | `TKT-FY-00001` (Ana Garcia — Business J) | seed canónico |
| Segmento ticketed | Secuencia 1 — FY210 BOG→MIA | seed canónico |
| Asiento existente | HK-7870 cabina J, fila 1, columna A | seed canónico |
| Equipajes previos | 0 — ningún baggage para este ticket_segment | seed canónico |
| Etiqueta nueva | `BAG-FY210-ANA-01` | demo |
| Efecto verificable | `ticket_segment.updated_at` actualizado por trigger | DDL: campo mutable real |

### ¿Por qué el segmento ticketed de TKT-FY-00001 secuencia 1?

El seed canónico registra equipajes únicamente para `TKT-FY-00002` (Carlos — FY101 BOG→MDE) y `TKT-FY-00003` (Laura — FY305 BOG→MIA). El primer segmento ticketed de Ana (`TKT-FY-00001` secuencia 1, FY210 BOG→MIA) tiene asiento asignado pero **ningún equipaje**, lo que permite demostrar el primer registro de forma limpia y verificable sin interferir con datos existentes.

---

## 5. Equipajes existentes en el seed canónico

| Tiquete | Vuelo | Ruta | Etiqueta | Tipo | Estado | Peso |
|---|---|---|---|---|---|---|
| TKT-FY-00002 | FY101 | BOG → MDE | BAG-FY101-001 | CHECKED | CLAIMED | 22.5 kg |
| TKT-FY-00003 | FY305 | BOG → MIA | BAG-FY305-001 | CHECKED | CLAIMED | 20.0 kg |

---

## 6. Decisión técnica del trigger: el problema de 3FN

### El reto

El enunciado pide que el trigger sobre `baggage` produzca una acción verificable sobre el segmento ticketed asociado. La solución intuitiva sería actualizar un campo de estado o conteo de equipajes en `ticket_segment`. Sin embargo, el DDL no tiene esa columna derivada: el modelo preserva la **tercera forma normal (3FN)** y no almacena estados calculados en `ticket_segment`.

Modificar el modelo para agregar ese campo violaría la restricción del ejercicio.

### La solución correcta

El único campo mutable de `ticket_segment` sin derivar datos es `updated_at`, presente en todas las tablas del modelo. Actualizar `ticket_segment.updated_at` cuando se inserta un equipaje es:

- **Correcto**: atributo real del DDL.
- **Verificable**: se puede comparar el valor antes y después del trigger.
- **Coherente con el negocio**: el segmento ticketed refleja que recibió una operación aeroportuaria posterior a su creación.
- **Sin romper 3FN**: no almacena ningún valor derivado.

---

## 7. Teoría base aplicada

### ¿Por qué INNER JOIN en las 9 tablas principales y LEFT JOIN en baggage para la validación 3?

En la consulta principal del setup se usan `INNER JOIN` para las 9 tablas porque el enunciado pide mostrar tiquetes que tienen asiento **y** equipaje registrado. Todas las relaciones son obligatorias para el resultado esperado. En la validación 3 (resumen por tiquete) se usa `LEFT JOIN` sobre `baggage` deliberadamente para incluir también los segmentos que aún no tienen equipaje, lo que da una visión más completa del estado operativo antes y después del demo.

### ¿Por qué trigger AFTER sobre baggage y no sobre seat_assignment?

El enunciado permite elegir. Se elige `baggage` porque:

1. La asignación de asiento ocurre en el momento de la reserva o check-in y es un evento temprano del flujo.
2. El registro de equipaje es el evento aeroportuario más tardío antes del embarque, y su impacto sobre el segmento ticketed es el más relevante para auditoría operativa.
3. En el seed canónico, hay ticket_segments que **ya tienen** asiento pero **no tienen** equipaje, lo que permite demostrar el trigger de forma limpia en el demo.

### ¿Por qué procedimiento almacenado?

Centraliza 4 validaciones críticas: existencia del segmento ticketed, unicidad de la etiqueta de equipaje (la etiqueta es un identificador físico único en la operación), obligatoriedad del timestamp de registro y validez del peso (debe ser positivo). Sin este procedimiento, una inserción directa podría registrar etiquetas duplicadas o pesos inválidos, ambos escenarios incoherentes con la operación aeroportuaria.

---

## 8. Consulta resuelta con INNER JOIN

### Tablas involucradas: 9 (todos INNER JOIN)

| # | Tabla | Alias | Propósito |
|---|---|---|---|
| 1 | `ticket` | `t` | Número de tiquete emitido |
| 2 | `ticket_segment` | `ts` | Segmento ticketed: secuencia, fare basis |
| 3 | `flight_segment` | `fs` | Segmento operativo: ruta y tiempos |
| 4 | `flight` | `f` | Vuelo: número y fecha de servicio |
| 5 | `seat_assignment` | `sa` | Asiento asignado al segmento ticketed |
| 6 | `aircraft_seat` | `acs` | Fila y columna del asiento físico |
| 7 | `aircraft_cabin` | `acab` | Cabina de la aeronave (J, Y) |
| 8 | `cabin_class` | `cc` | Nombre de la clase: Business, Economy |
| 9 | `baggage` | `b` | Equipaje registrado para el segmento |

### Resultado esperado con datos reales del seed (después del demo)

| tiquete | secuencia | vuelo | cabina | fila | col | etiqueta | tipo | estado | peso |
|---|---|---|---|---|---|---|---|---|---|
| TKT-FY-00001 | 1 | FY210 | Business | 1 | A | BAG-FY210-ANA-01 | CHECKED | REGISTERED | 23.40 |
| TKT-FY-00002 | 1 | FY101 | Economy | 12 | A | BAG-FY101-001 | CHECKED | CLAIMED | 22.50 |
| TKT-FY-00003 | 1 | FY305 | Economy | 15 | A | BAG-FY305-001 | CHECKED | CLAIMED | 20.00 |

> Nota: TKT-FY-00001 secuencia 2 (FY711 MIA→MAD) no aparece porque ese ticket_segment tampoco tiene baggage. La consulta principal usa INNER JOIN sobre baggage, por lo que solo muestra segmentos con equipaje registrado.

### Explicación paso a paso de cada JOIN

1. **`ticket`** → punto de entrada comercial. Identifica al pasajero por su número de tiquete.
2. **`ticket_segment`** → desglosa el tiquete por segmento: cada tramo tiene su secuencia y fare basis.
3. **`flight_segment`** → conecta el segmento ticketed con el segmento operativo real (tiempos, ruta).
4. **`flight`** → vuelo al que pertenece el segmento operativo: número y fecha de servicio.
5. **`seat_assignment`** → asiento asignado al segmento ticketed específico.
6. **`aircraft_seat`** → fila y columna del asiento físico en la aeronave.
7. **`aircraft_cabin`** → cabina de la aeronave donde está el asiento (J Business, Y Economy).
8. **`cabin_class`** → nombre legible de la clase: Business, Economy, Premium Economy.
9. **`baggage`** → equipaje registrado para el segmento ticketed del pasajero.

---

## 9. Trigger resuelto

### Acción implementada

Cada vez que se inserta un registro en `baggage`, el segmento ticketed asociado queda marcado con el timestamp de la modificación mediante `UPDATE ticket_segment SET updated_at = now()`. Esto es verificable, sin romper 3FN y coherente con el negocio: el segmento ticketed refleja que recibió un evento aeroportuario posterior a su emisión.

---

## 10. Procedimiento almacenado resuelto

### Parámetros de entrada

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_ticket_segment_id` | `baggage.ticket_segment_id` | uuid | FK a `ticket_segment` |
| `p_baggage_tag` | `baggage.baggage_tag` | varchar(50) | UNIQUE en `baggage` |
| `p_baggage_type` | `baggage.baggage_type` | varchar(30) | NOT NULL |
| `p_baggage_status` | `baggage.baggage_status` | varchar(30) | NOT NULL |
| `p_weight_kg` | `baggage.weight_kg` | numeric(6,2) | > 0 |
| `p_checked_at` | `baggage.checked_at` | timestamptz | NOT NULL |

### Validaciones internas (4 checks)

1. `ticket_segment_id` debe existir en `ticket_segment`.
2. `baggage_tag` no debe estar duplicada en `baggage` (etiqueta física única).
3. `p_checked_at` no puede ser nulo.
4. `p_weight_kg` debe ser un valor positivo mayor a cero.

---

## 11. Script de demostración

### ¿Qué demuestra?

1. Resuelve el `ticket_segment_id` del tiquete `TKT-FY-00001` secuencia 1 (FY210 BOG→MIA) del seed canónico.
2. Verifica el asiento existente (HK-7870 cabina J fila 1 col A) y `updated_at` antes del evento.
3. Confirma que ese ticket_segment tiene 0 equipajes previos.
4. Invoca `sp_register_baggage` con la etiqueta `BAG-FY210-ANA-01`.
5. El procedimiento valida los 4 constraints e inserta en `baggage`.
6. El trigger `AFTER INSERT` actualiza `ticket_segment.updated_at` automáticamente.
7. Las 3 validaciones confirman el equipaje insertado, la trazabilidad completa con asiento y el resumen por tiquete.

---

## 12. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 9 INNER JOINs sobre tablas reales del modelo |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 9 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON baggage FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Actualiza `ticket_segment.updated_at` |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_7_demo.sql` con `DO $$` y 3 validaciones |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de equipaje con 4 validaciones |
| Existe script que invoca el procedimiento | ✅ | `CALL sp_register_baggage(...)` |
| La invocación evidencia el trigger | ✅ | `ticket_segment.updated_at` cambia al registrar el equipaje |
| No se alteró la estructura base del modelo | ✅ | Solo función, trigger y procedimiento |

---

## 13. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_7_setup.sql` | Función, trigger, procedimiento y consulta INNER JOIN con 9 tablas |
| `ejercicio_7_demo.sql` | Bloque `DO $$`, invocación del procedimiento y 3 validaciones |
| `ejercicio_7_resuelto.md` | Documentación completa con decisiones técnicas y criterios |