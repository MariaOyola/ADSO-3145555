# Ejercicio 04 Resuelto - Acumulación de millas y actualización del historial de nivel

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje, facturación y gestión completa del programa de fidelización.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El programa de fidelización necesita:

1. Consultar la relación entre clientes, cuentas de fidelización, niveles activos y ventas asociadas.
2. Automatizar una acción verificable sobre la cuenta de fidelización cada vez que se registra una transacción de millas.
3. Encapsular el registro de transacciones de millas en un procedimiento reutilizable con validaciones de integridad.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| CUSTOMER AND LOYALTY | `customer`, `customer_category`, `loyalty_account`, `loyalty_program`, `loyalty_account_tier`, `loyalty_tier`, `miles_transaction` | Ana (Gold), Carlos (Bronze), Laura (Silver) |
| IDENTITY | `person` | Ana Garcia, Carlos Mendoza, Laura Torres |
| SALES / TICKETING | `sale`, `reservation` | SAL-20260305, SAL-20260310, SAL-20260312 |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Cuenta elegida | `FLY-0002-CAR` (Carlos Mendoza — Bronze) | seed canónico |
| Transacciones previas | 1 — EARN de 420 millas por FY101 BOG→MDE | seed canónico |
| Saldo previo | 420 millas | seed canónico |
| Nueva transacción | EARN 580 millas — `TKT-VOL-000001-SEG1` | demo |
| Efecto verificable | `loyalty_account.updated_at` actualizado por trigger | DDL: campo mutable real |

### ¿Por qué la cuenta FLY-0002-CAR (Carlos Mendoza)?

El seed canónico registra los siguientes saldos de millas:

| Cuenta | Cliente | Nivel | Millas acumuladas |
|---|---|---|---|
| FLY-0001-ANA | Ana Garcia | Gold | 8,200 (3,000 FY210 + 5,200 FY711) |
| FLY-0002-CAR | Carlos Mendoza | Bronze | 420 (FY101 BOG→MDE) |
| FLY-0003-LAU | Laura Torres | Silver | 1,500 (FY305 BOG→MIA) |

Carlos tiene solo 1 transacción previa y el saldo más bajo, lo que hace su cuenta la candidata más limpia para demostrar un nuevo EARN sin interferir con historial complejo. Además, el escenario es coherente con el negocio: Carlos tiene reservas volumétricas en FY120 BOG→MDE que justifican nuevas acreditaciones de millas.

---

## 5. Transacciones de millas existentes en el seed canónico

| Cuenta | Tipo | Millas | Referencia | Vuelo |
|---|---|---|---|---|
| FLY-0001-ANA | EARN | +3,000 | TKT-FY-00001-SEG1 | FY210 BOG→MIA Business J |
| FLY-0001-ANA | EARN | +5,200 | TKT-FY-00001-SEG2 | FY711 MIA→MAD Business J |
| FLY-0002-CAR | EARN | +420 | TKT-FY-00002-SEG1 | FY101 BOG→MDE Economy YB |
| FLY-0003-LAU | EARN | +1,500 | TKT-FY-00003-SEG1 | FY305 BOG→MIA Economy YF |

---

## 6. Decisión técnica del trigger: el problema de 3FN

### El reto

El enunciado pide que el trigger sobre `miles_transaction` produzca una acción verificable sobre la cuenta de fidelización o el historial de niveles. La solución intuitiva sería actualizar un campo de "saldo acumulado" o "total de millas" en `loyalty_account`. Sin embargo, el DDL no tiene esa columna derivada: el modelo preserva la **tercera forma normal (3FN)** y calcula el saldo real siempre mediante `SUM(miles_delta)` sobre `miles_transaction`. Almacenar ese saldo en `loyalty_account` crearía redundancia y posibilidades de inconsistencia.

Modificar el modelo para agregar ese campo violaría la restricción del ejercicio.

### La solución correcta

El único campo mutable de `loyalty_account` sin derivar datos es `updated_at`, presente en todas las tablas del modelo. Actualizar `loyalty_account.updated_at` cuando se inserta una transacción de millas es:

- **Correcto**: atributo real del DDL.
- **Verificable**: se puede comparar el valor antes y después del trigger.
- **Coherente con el negocio**: la cuenta refleja que su historial de millas fue modificado, lo que es relevante para auditorías del programa de fidelización.
- **Sin romper 3FN**: no almacena ningún valor derivado.

---

## 7. Teoría base aplicada

### ¿Por qué la consulta usa una subconsulta IN para relacionar customer con sale?

El modelo no tiene una relación directa entre `customer` y `sale`. El camino real es: `customer` → `reservation` (vía `booked_by_customer_id`) → `sale` (vía `reservation_id`). Se usa una subconsulta `IN` en lugar de un JOIN adicional para mantener la cláusula `FROM` limpia con exactamente las 7 tablas declaradas en el enunciado, sin generar filas duplicadas por la multiplicación de registros que produciría un JOIN directo entre `sale` y las tablas de fidelización.

### ¿Por qué la validación 3 usa LEFT JOIN sobre miles_transaction?

El resumen de la validación 3 usa `LEFT JOIN` sobre `miles_transaction` deliberadamente para incluir también cuentas que aún no tienen ninguna transacción registrada. Esto da una visión completa del programa, mostrando tanto clientes activos en la acumulación como clientes con cuenta abierta pero sin movimientos. Sin el `LEFT JOIN`, una cuenta nueva sin transacciones no aparecería en el resumen, lo que generaría un reporte incompleto.

### ¿Por qué procedimiento almacenado con 5 validaciones?

La acreditación de millas es una operación financiera con impacto real para el cliente: las millas tienen valor canjeable en vuelos, upgrades y beneficios. Una transacción con cuenta inexistente, tipo inválido, delta en cero o sin referencia podría crear saldos incorrectos que son difíciles de auditar y corregir después. El procedimiento centraliza 5 validaciones que protegen la integridad del historial antes de que el movimiento quede persistido.

### ¿Por qué transaction_type valida contra una lista cerrada?

El modelo no tiene una tabla catálogo para `transaction_type` en `miles_transaction` (a diferencia de otros dominios que usan tablas de referencia). El tipo se almacena como `varchar`. El procedimiento aplica una validación explícita contra los cuatro valores que tienen sentido semántico en el programa: `EARN` (acumulación por vuelo), `REDEEM` (canje), `ADJUST` (ajuste manual) y `EXPIRE` (vencimiento). Aceptar cualquier string sin validar permitiría registrar tipos incoherentes como `'BONO'` o `'DESCUENTO'` que no tienen tratamiento definido en el modelo.

---

## 8. Consulta resuelta con INNER JOIN

### Tablas involucradas: 7 (6 INNER JOIN + subconsulta)

| # | Tabla | Propósito |
|---|---|---|
| 1 | `customer` | Cliente registrado: categoría y fecha de alta |
| 2 | `person` | Nombre real del cliente |
| 3 | `customer_category` | Categoría: Regular, Silver, Gold, Corporate |
| 4 | `loyalty_account` | Cuenta de fidelización: número y fecha de apertura |
| 5 | `loyalty_program` | Programa: FLY Miles Program |
| 6 | `loyalty_account_tier` | Nivel activo o histórico: fecha de asignación y vencimiento |
| 7 | `loyalty_tier` | Definición del nivel: Bronze, Silver, Gold y millas requeridas |
| subconsulta | `sale` + `reservation` | Ventas del cliente vía su actividad de reservas |

### Resultado con datos reales del seed canónico

| cliente | categoria | cuenta | programa | nivel | nivel_asignado_en | venta |
|---|---|---|---|---|---|---|
| Garcia Ana | Gold | FLY-0001-ANA | FLY Miles Program | Gold | 2025-01-01 | SAL-20260305-001 |
| Mendoza Carlos | Regular | FLY-0002-CAR | FLY Miles Program | Bronze | 2024-01-15 | SAL-20260310-001 |
| Torres Laura | Silver | FLY-0003-LAU | FLY Miles Program | Silver | 2024-06-01 | SAL-20260312-001 |

### Explicación paso a paso de cada JOIN

1. **`customer`** → punto de entrada del dominio de fidelización. Conecta la persona con la aerolínea y su categoría comercial.
2. **`person`** → nombre real del cliente. Necesario para los reportes de servicio al cliente y comunicaciones del programa.
3. **`customer_category`** → clasificación comercial del cliente. Determina qué beneficios y tarifas especiales aplican.
4. **`loyalty_account`** → cuenta del programa de fidelización. Contiene el número de cuenta y la fecha de apertura.
5. **`loyalty_program`** → programa al que pertenece la cuenta. Permite reportes multi-programa si la aerolínea opera más de uno.
6. **`loyalty_account_tier`** → nivel asignado a la cuenta: fecha de asignación y vencimiento. Una cuenta puede tener historial de niveles.
7. **`loyalty_tier`** → definición del nivel: nombre, código y millas requeridas para alcanzarlo. Cierra el ciclo del programa.

---

## 9. Trigger resuelto

### Acción implementada

Cada vez que se inserta un registro en `miles_transaction`, la cuenta de fidelización asociada queda marcada con el timestamp de la modificación mediante `UPDATE loyalty_account SET updated_at = now()`. Esto es verificable, sin romper 3FN y coherente con el negocio: la cuenta refleja que su historial de millas fue actualizado, lo que permite detectar cuentas activas vs inactivas en el programa.

---

## 10. Procedimiento almacenado resuelto

### Parámetros de entrada

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_loyalty_account_id` | `miles_transaction.loyalty_account_id` | uuid | FK a `loyalty_account` |
| `p_transaction_type` | `miles_transaction.transaction_type` | varchar(20) | IN ('EARN','REDEEM','ADJUST','EXPIRE') |
| `p_miles_delta` | `miles_transaction.miles_delta` | integer | ≠ 0 |
| `p_occurred_at` | `miles_transaction.occurred_at` | timestamptz | NOT NULL |
| `p_reference_code` | `miles_transaction.reference_code` | varchar(100) | NOT NULL, no vacío |
| `p_notes` | `miles_transaction.notes` | text | Nullable |

### Validaciones internas (5 checks)

1. `loyalty_account_id` debe existir en `loyalty_account`.
2. `transaction_type` debe ser uno de: `EARN`, `REDEEM`, `ADJUST`, `EXPIRE`.
3. `p_miles_delta` no puede ser cero ni nulo.
4. `p_occurred_at` no puede ser nulo.
5. `p_reference_code` no puede ser nulo ni vacío.

---

## 11. Script de demostración

### ¿Qué demuestra?

1. Resuelve la cuenta `FLY-0002-CAR` (Carlos Mendoza — Bronze) del seed canónico.
2. Verifica `loyalty_account.updated_at`, saldo previo (420 millas) y cantidad de transacciones (1).
3. Invoca `sp_register_miles_transaction` con un EARN de 580 millas referenciando un vuelo volumétrico.
4. El procedimiento valida los 5 constraints e inserta en `miles_transaction`.
5. El trigger `AFTER INSERT` actualiza `loyalty_account.updated_at` automáticamente.
6. Las 3 validaciones confirman la transacción insertada, la trazabilidad completa cliente → nivel → ventas, y el resumen con saldo calculado en tiempo real mediante `SUM(miles_delta)`.

---

## 12. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 6 INNER JOINs + subconsulta sobre tablas reales del modelo |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 7 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON miles_transaction FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Actualiza `loyalty_account.updated_at` |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_4_demo.sql` con `DO $$` y 3 validaciones |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de transacción de millas con 5 validaciones |
| Existe script que invoca el procedimiento | ✅ | `CALL sp_register_miles_transaction(...)` |
| La invocación evidencia el trigger | ✅ | `loyalty_account.updated_at` cambia al registrar la transacción |
| No se alteró la estructura base del modelo | ✅ | Solo función, trigger y procedimiento |

---

## 13. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_4_setup.sql` | Función, trigger, procedimiento y consulta INNER JOIN con 7 tablas |
| `ejercicio_4_demo.sql` | Bloque `DO $$`, invocación del procedimiento y 3 validaciones |
| `ejercicio_4_resuelto.md` | Documentación completa con decisiones técnicas y criterios |