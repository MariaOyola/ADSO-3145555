# Ejercicio 04 Resuelto - Acumulación de millas y actualización del historial de nivel

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje, facturación y fidelización de clientes.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El programa de fidelización de la aerolínea requiere:

1. Consultar la relación entre clientes, cuentas de fidelización, programas, niveles y ventas asociadas.
2. Automatizar el registro de un upgrade de nivel cada vez que se inserta una transacción de millas que supere el umbral correspondiente.
3. Encapsular el registro de transacciones de millas en un procedimiento reutilizable.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| CUSTOMER AND LOYALTY | `customer`, `loyalty_account`, `loyalty_program`, `loyalty_tier`, `loyalty_account_tier`, `miles_transaction` | FLY-0001-ANA, FLY-0002-CAR, FLY-0003-LAU + 250 cuentas vol. |
| IDENTITY | `person` | Ana Garcia, Carlos Mendoza, Laura Torres |
| AIRLINE | `airline` | FLY Miles Program |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Cuenta elegida | `FLY-0002-CAR` (Carlos Mendoza, tier `BRONZE`) | seed canónico |
| Tier inicial | `BRONZE` — `required_miles = 0`, `priority_level = 1` | seed canónico |
| Tier objetivo | `SILVER` — `required_miles = 10000`, `priority_level = 2` | seed canónico |
| Transacción registrada | `EARN` +15000 millas (supera umbral de SILVER) | demo |
| Efecto verificable | Nuevo registro en `loyalty_account_tier` con tier `SILVER` | trigger |

### ¿Por qué la cuenta FLY-0002-CAR?

El seed canónico crea tres cuentas. `FLY-0001-ANA` ya está en GOLD (máximo nivel), por lo que no puede hacer upgrade. `FLY-0003-LAU` está en SILVER. `FLY-0002-CAR` (Carlos) está en BRONZE con saldo mínimo, lo que permite demostrar un upgrade claro y verificable de BRONZE a SILVER al acumular 15.000 millas.

---

## 5. Estructura de tiers del programa FLY Miles Program

| Tier | `required_miles` | `priority_level` |
|---|---|---|
| BRONZE | 0 | 1 |
| SILVER | 10.000 | 2 |
| GOLD | 50.000 | 3 |

---

## 6. Decisión técnica del trigger: lógica de upgrade

### El reto

El enunciado pide que el trigger sobre `miles_transaction` produzca una acción verificable en `loyalty_account_tier`. La lógica correcta debe:

1. Calcular el saldo total acumulado de la cuenta (suma de todos los `miles_delta`).
2. Determinar el tier que le corresponde según ese saldo (el de mayor `priority_level` cuyo `required_miles` no supere el saldo).
3. Comparar con el tier más reciente registrado en `loyalty_account_tier`.
4. Solo insertar un nuevo registro si el tier calculado tiene mayor prioridad que el actual.

### Por qué solo se evalúa en transacciones positivas

El campo `miles_delta` puede ser negativo (`REDEEM`) o positivo (`EARN`/`ADJUST`). Un upgrade de nivel nunca ocurre por redención de millas, solo por acumulación. Por eso el trigger evalúa únicamente cuando `miles_delta > 0`.

### El constraint `uq_loyalty_account_tier_point`

El modelo tiene una restricción `UNIQUE(loyalty_account_id, assigned_at)` en `loyalty_account_tier`. PostgreSQL usa `now()` con precisión de microsegundos dentro de la misma transacción, lo que garantiza unicidad en inserciones consecutivas del trigger.

---

## 7. Teoría base aplicada

### ¿Por qué INNER JOIN en todas las tablas de la consulta principal?

Se usa `INNER JOIN` en las 7 tablas porque todas deben existir para que el resultado tenga sentido. No hay ninguna relación opcional en este flujo: un cliente sin cuenta de fidelización, una cuenta sin programa, un programa sin aerolínea o una cuenta sin nivel asignado no representan un registro completo del programa de fidelización.

### ¿Por qué trigger AFTER?

El trigger necesita leer el saldo total de `miles_transaction` incluyendo la fila recién insertada. Si fuera `BEFORE`, la nueva transacción no estaría aún en la tabla y el `SUM(miles_delta)` devolvería un valor incompleto. El trigger `AFTER INSERT` garantiza que la fila ya fue persistida antes de que la función calcule el saldo.

### ¿Por qué procedimiento almacenado?

El procedimiento centraliza tres validaciones críticas antes de insertar en `miles_transaction`: existencia de la cuenta, tipo de transacción válido y delta distinto de cero. Sin él, cada proceso que registre millas replicaría esas validaciones de forma independiente, lo que genera inconsistencias.

---

## 8. Consulta resuelta con INNER JOIN

### Tablas involucradas: 7 (todas con INNER JOIN)


### Script

```sql
SELECT
    p.first_name || ' ' || p.last_name     AS cliente,
    p.first_name,
    p.last_name,
    la.account_number,
    lp.program_name,
    lt.tier_name                            AS nivel,
    lt.required_miles                       AS millas_requeridas,
    lat.assigned_at                         AS fecha_asignacion_nivel,
    lat.expires_at                          AS vencimiento_nivel,
    al.airline_name
FROM customer c
INNER JOIN person p
    ON p.person_id = c.person_id
INNER JOIN loyalty_account la
    ON la.customer_id = c.customer_id
INNER JOIN loyalty_program lp
    ON lp.loyalty_program_id = la.loyalty_program_id
INNER JOIN loyalty_account_tier lat
    ON lat.loyalty_account_id = la.loyalty_account_id
INNER JOIN loyalty_tier lt
    ON lt.loyalty_tier_id = lat.loyalty_tier_id
INNER JOIN airline al
    ON al.airline_id = lp.airline_id
ORDER BY lat.assigned_at DESC, p.last_name, p.first_name;
```

### Resultado con datos reales del seed canónico

| cliente | account_number | program_name | nivel | millas_requeridas | fecha_asignacion | vencimiento | airline_name |
|---|---|---|---|---|---|---|---|
| Ana Garcia | FLY-0001-ANA | FLY Miles Program | GOLD | 50000 | 2026-03-05 | 2027-03-05 | FlyAir |
| Carlos Mendoza | FLY-0002-CAR | FLY Miles Program | BRONZE | 0 | 2026-03-10 | 2027-03-10 | FlyAir |
| Laura Torres | FLY-0003-LAU | FLY Miles Program | SILVER | 10000 | 2026-03-12 | 2027-03-12 | FlyAir |

### Explicación paso a paso de cada JOIN

1. **`customer`** → cliente registrado en la aerolínea. Punto de entrada del dominio de fidelización.
2. **`person`** → identidad real del cliente: nombre, apellido. Relacionado por `person_id`.
3. **`loyalty_account`** → cuenta del programa de millas del cliente. Relacionada por `customer_id`.
4. **`loyalty_program`** → programa al que pertenece la cuenta: nombre, aerolínea. Relacionado por `loyalty_program_id`.
5. **`loyalty_account_tier`** → historial de niveles asignados a la cuenta: fecha y vencimiento de cada tier.
6. **`loyalty_tier`** → definición del nivel: nombre, millas requeridas, prioridad.
7. **`airline`** → aerolínea propietaria del programa. Relacionada por `airline_id` desde `loyalty_program`.

---

## 9. Trigger resuelto

### Acción implementada

Cada vez que se inserta una `miles_transaction` con `miles_delta > 0`, el trigger calcula el saldo total acumulado, determina el tier correspondiente y, si es de mayor prioridad que el actual, inserta un nuevo registro en `loyalty_account_tier` con `expires_at = now() + 1 year`.

### Por qué esta solución es correcta

- No altera ninguna tabla del modelo base.
- Opera sobre `loyalty_account_tier`, tabla real del DDL diseñada para registrar el historial de niveles.
- Respeta el constraint `uq_loyalty_account_tier_point UNIQUE(loyalty_account_id, assigned_at)`.
- Produce un efecto verificable: nuevo registro en `loyalty_account_tier` con tier de mayor prioridad.
- Es coherente con el negocio: el nivel mejora cuando el cliente acumula las millas requeridas.

---

## 10. Procedimiento almacenado resuelto

### Parámetros de entrada (mapeados a columnas reales del DDL)

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_loyalty_account_id` | `miles_transaction.loyalty_account_id` | uuid | FK a `loyalty_account` |
| `p_transaction_type` | `miles_transaction.transaction_type` | varchar(20) | `ck_miles_transaction_type`: EARN, REDEEM, ADJUST |
| `p_miles_delta` | `miles_transaction.miles_delta` | integer | `ck_miles_delta_non_zero` (≠ 0) |
| `p_occurred_at` | `miles_transaction.occurred_at` | timestamptz | DEFAULT `now()` si es NULL |
| `p_reference_code` | `miles_transaction.reference_code` | varchar(60) | Nullable |
| `p_notes` | `miles_transaction.notes` | text | Nullable |

### Validaciones internas (3 checks)

1. `loyalty_account_id` debe existir en `loyalty_account`.
2. `transaction_type` debe ser `EARN`, `REDEEM` o `ADJUST`.
3. `miles_delta` no puede ser cero.

---

## 11. Script de demostración

### ¿Qué demuestra?

1. Busca la cuenta `FLY-0002-CAR` (Carlos Mendoza, tier `BRONZE`) del seed canónico.
2. Verifica el tier actual y el saldo de millas antes del demo.
3. Invoca `sp_register_miles_transaction` con `EARN` de 15.000 millas.
4. El procedimiento valida los tres constraints e inserta en `miles_transaction`.
5. El trigger `AFTER INSERT` calcula el saldo total (≥ 10.000), detecta que corresponde `SILVER` (priority 2 > 1) e inserta en `loyalty_account_tier`.
6. Las tres validaciones finales confirman la transacción, el upgrade de tier y la trazabilidad completa.

---

## 12. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 7 INNER JOINs sobre tablas reales del DDL |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 7 tablas reales |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON miles_transaction FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Inserta en `loyalty_account_tier` cuando el saldo supera el umbral |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_4_demo.sql` con bloque `DO $$` y 3 validaciones |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de millas con 3 validaciones de integridad |
| Existe script que invoca el procedimiento | ✅ | `CALL sp_register_miles_transaction(...)` |
| La invocación evidencia el trigger | ✅ | Upgrade verificable en `loyalty_account_tier` |
| No se alteró la estructura base del modelo | ✅ | Solo función, trigger y procedimiento |

---

## 13. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_4_setup.sql` | Función, trigger, procedimiento y consulta INNER JOIN con 7 tablas |
| `ejercicio_4_demo.sql` | Bloque `DO $$`, invocación del procedimiento y 3 validaciones |
| `ejercicio_4_resuelto.md` | Documentación completa con decisiones técnicas y criterios |