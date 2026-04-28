# Ejercicio 01 Resuelto - Flujo de check-in y trazabilidad comercial del pasajero

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas, separadas por dominios funcionales y conectadas mediante llaves foráneas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje y facturación.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

La aerolínea necesita:

1. Consultar qué pasajeros están asociados a reservas y tiquetes válidos para un vuelo determinado.
2. Automatizar la generación del `boarding_pass` cada vez que se registra un `check_in`.
3. Encapsular el proceso de registro del check-in en un procedimiento reutilizable.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| SALES, RESERVATION, TICKETING | `reservation`, `reservation_passenger`, `ticket`, `ticket_segment` | RES-FY-001/002/003, TKT-FY-00001/00002/00003, BB000000-* (vol) |
| FLIGHT OPERATIONS | `flight`, `flight_segment` | FY210, FY711, FY101, FY305, FY120 Q2-2026 |
| IDENTITY | `person` | Ana Garcia, Carlos Mendoza, Laura Torres + 300 vol |
| BOARDING | `check_in`, `check_in_status`, `boarding_group`, `boarding_pass` | COMPLETED, PRIORITY/A/B/C/D, BP-FY*-*-01, BP-VOL2-* |
| SECURITY | `user_account` | patricia.vargas (20000000-...-000000000002) |

---

## 5. Teoría base aplicada

### ¿Por qué INNER JOIN?

Se usa `INNER JOIN` porque el objetivo es mostrar **únicamente** los pasajeros cuyo flujo de abordaje está completo: tienen reserva, tiquete, segmento de vuelo, check-in registrado y boarding pass emitido. Cualquier pasajero sin alguno de esos eslabones queda excluido del resultado, lo cual es el comportamiento correcto para una consulta de trazabilidad operativa.

### ¿Por qué trigger AFTER?

El DDL define `boarding_pass.check_in_id` con `REFERENCES check_in(check_in_id)`. Esto significa que la FK exige que el `check_in` ya exista antes de insertar en `boarding_pass`. Un trigger `BEFORE` fallaría porque la fila del `check_in` aún no ha sido confirmada en la tabla. El trigger `AFTER INSERT` se ejecuta cuando la fila ya está persistida, lo que permite referenciarla con seguridad.

### ¿Por qué procedimiento almacenado?

El procedimiento centraliza la regla de negocio en un único punto de entrada. Sin él, cada sistema o proceso que necesite registrar un check-in debería replicar las mismas validaciones (existencia del segmento, unicidad del check-in). El procedimiento garantiza que esas reglas se apliquen siempre de la misma forma, y deja al trigger la responsabilidad de la reacción posterior automática.

---

## 6. Consulta resuelta con INNER JOIN

### Tablas involucradas: 9

```
reservation
  → reservation_passenger
      → person
      → ticket
          → ticket_segment
              → flight_segment
                  → flight
              → check_in
                  → boarding_pass
```

### Script

```sql
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
```

### Resultado con datos reales del seed canónico

| reservation_code | flight_number | service_date | segment_number | first_name | last_name | ticket_number | boarding_pass_code |
|---|---|---|---|---|---|---|---|
| RES-FY-001 | FY210 | 2026-03-10 | 1 | Ana | Garcia | TKT-FY-00001 | BP-FY210-ANA-01 |
| RES-FY-001 | FY711 | 2026-03-10 | 1 | Ana | Garcia | TKT-FY-00001 | BP-FY711-ANA-01 |
| RES-FY-002 | FY101 | 2026-03-12 | 1 | Carlos | Mendoza | TKT-FY-00002 | BP-FY101-CAR-01 |
| RES-FY-003 | FY305 | 2026-03-15 | 1 | Laura | Torres | TKT-FY-00003 | BP-FY305-LAU-01 |

Más 1100 registros del seed volumétrico con pasajeros `BP-VOL2-*` en vuelo `FY120 BOG→MDE`.

### Explicación paso a paso de cada JOIN

1. **`reservation`** → aporta `reservation_code`, el identificador comercial de la reserva.
2. **`reservation_passenger`** → conecta la reserva con la persona real mediante `reservation_id` y `person_id`.
3. **`person`** → aporta `first_name` y `last_name` del pasajero.
4. **`ticket`** → representa el documento comercial emitido, relacionado con `reservation_passenger_id`.
5. **`ticket_segment`** → vincula el tiquete con un segmento específico del itinerario mediante `ticket_id`.
6. **`flight_segment`** → conecta ese segmento con la operación aérea real: salida, llegada, aeropuertos.
7. **`flight`** → aporta `flight_number` y `service_date`.
8. **`check_in`** → confirma que el pasajero ya realizó el registro, relacionado por `ticket_segment_id`.
9. **`boarding_pass`** → prueba que el proceso se completó con el pase de abordar, relacionado por `check_in_id`.

---

## 7. Trigger resuelto

### Decisión técnica

El modelo define `boarding_pass.check_in_id NOT NULL REFERENCES check_in(check_in_id)`. Por eso el trigger debe ser `AFTER INSERT ON check_in`: solo cuando la fila del `check_in` ya existe en la tabla es posible insertar en `boarding_pass` con esa FK válida.

### Lógica implementada

- Verifica si ya existe un `boarding_pass` para el `check_in_id` recién insertado (protege `uq_boarding_pass_check_in`).
- Construye `boarding_pass_code` como `'BP-' + UUID sin guiones` → máximo 37 caracteres, dentro del `varchar(40)` del DDL.
- Construye `barcode_value` como `'BAR-' + UUID + timestamp` → dentro del `varchar(120)` del DDL.
- Inserta en `boarding_pass` usando solo los atributos definidos en el DDL: `check_in_id`, `boarding_pass_code`, `barcode_value`, `issued_at`.

### Por qué esta solución es correcta

- No altera ninguna tabla del modelo.
- Respeta `uq_boarding_pass_check_in` (un solo pase por check-in).
- Respeta `uq_boarding_pass_code` y `uq_boarding_pass_barcode` (valores únicos).
- Se alinea con el flujo del negocio: primero check-in, luego pase de abordar.

---

## 8. Procedimiento almacenado resuelto

### Parámetros de entrada (mapeados a columnas reales del DDL)

| Parámetro | Columna del DDL | Tipo | Notas |
|---|---|---|---|
| `p_ticket_segment_id` | `check_in.ticket_segment_id` | uuid | FK a `ticket_segment` |
| `p_check_in_status_id` | `check_in.check_in_status_id` | uuid | FK a `check_in_status` |
| `p_boarding_group_id` | `check_in.boarding_group_id` | uuid | Nullable, FK a `boarding_group` |
| `p_checked_in_by_user_id` | `check_in.checked_in_by_user_id` | uuid | Nullable, FK a `user_account` |
| `p_checked_in_at` | `check_in.checked_in_at` | timestamptz | Momento del check-in |

### Validaciones internas

1. Verifica que `ticket_segment_id` exista en `ticket_segment`.
2. Verifica que no exista un `check_in` previo para ese segmento (respeta `uq_check_in_ticket_segment`).

### Integración con el trigger

Al insertar en `check_in`, el trigger `trg_ai_check_in_create_boarding_pass` se dispara automáticamente. El procedimiento no necesita insertar en `boarding_pass` porque el trigger lo hace. Esta separación de responsabilidades permite que el procedimiento sea reutilizable independientemente de si el trigger está activo o no.

---

## 9. Script de demostración

### Datos reales usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| `ticket_segment_id` | BB000000-...-000000001101 a BB000000-...-000000001200 | seed volumétrico seq 1101..1200 (sin check-in) |
| `check_in_status` | `COMPLETED` | seed canónico `check_in_status` |
| `boarding_group` | `PRIORITY` (sequence_no = 1) | seed canónico `boarding_group` |
| `user_account` | `patricia.vargas` (20000000-...-000000000002) | seed canónico `user_account` |

### ¿Por qué esos ticket_segments?

El seed volumétrico crea 1200 `ticket_segment` con prefijo `BB000000-*` (seq 1 a 1200), pero solo inserta `check_in` para los seq 1 a 1100. Los seq 1101 a 1200 quedan sin check-in, lo que los hace elegibles para el demo sin necesidad de crear datos adicionales.

### ¿Qué demuestra el script?

1. Selecciona un `ticket_segment` real del modelo sin check-in previo.
2. Resuelve `check_in_status_id` buscando el código `COMPLETED` en la tabla real.
3. Toma el `boarding_group` de menor `sequence_no` (PRIORITY).
4. Usa `patricia.vargas`, el usuario operativo del seed canónico.
5. Invoca `sp_register_check_in` con esos identificadores reales.
6. El procedimiento inserta en `check_in`.
7. El trigger `AFTER INSERT` genera automáticamente el `boarding_pass`.
8. La consulta de validación confirma con `INNER JOIN` que el `boarding_pass` existe.

---

## 10. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 8 INNER JOINs en la consulta principal |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 9 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON check_in FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Inserta en `boarding_pass` del modelo |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_1_demo.sql` |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro completo del check-in con validaciones |
| Existe script que invoca el procedimiento | ✅ | `ejercicio_1_demo.sql` con `CALL sp_register_check_in(...)` |
| La invocación del procedimiento evidencia el funcionamiento del trigger | ✅ | El boarding_pass se genera automáticamente al llamar el SP |
| No se alteró la estructura base del modelo | ✅ | Solo se crearon función, trigger y procedimiento |

---

## 11. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_1_setup.sql` | Función `fn_ai_check_in_create_boarding_pass`, trigger `trg_ai_check_in_create_boarding_pass`, procedimiento `sp_register_check_in` y consulta INNER JOIN con 9 tablas |
| `ejercicio_1_demo.sql` | Bloque `DO $$` con datos reales del seed, invocación de `sp_register_check_in` y consulta de validación |
| `ejercicio_1_resuelto.md` | Documentación completa con teoría, datos reales, decisiones técnicas y tabla de criterios |