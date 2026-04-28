# Ejercicio 02 Resuelto - Control de pagos y trazabilidad de transacciones financieras

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje y facturación.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El área financiera necesita:

1. Una vista consolidada del ciclo de pago de una venta, incluyendo sus transacciones y la moneda operativa.
2. Automatizar la generación de un `refund` cuando se registra una transacción de tipo `REFUND` en `payment_transaction`.
3. Encapsular el registro de transacciones financieras en un procedimiento reutilizable.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| SALES, RESERVATION | `sale`, `reservation` | SAL-20260305-001/002/003, SAL-VOL-*, SAL-VOL2-*, RES-FY-001/002/003 |
| PAYMENT | `payment`, `payment_status`, `payment_method`, `payment_transaction`, `refund` | PAY-20260305/10/12-001, PAY-VOL2-* (1200), TXN-VOL2-* |
| BILLING | `invoice` | INV-FY-2026-0001/0002/0003, INV-VOL2-* |
| GEOGRAPHY | `currency` | USD, COP, EUR |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Pagos elegibles | `PAY-VOL2-000121` a `PAY-VOL2-000300` | seed volumétrico: CAPTURED sin refund |
| `payment_status` | `CAPTURED` | seed canónico `payment_status` |
| `transaction_type` | `REFUND` | check `ck_payment_transaction_type` del DDL |
| Monto | `359600.00 COP` | tarifa BOG-MDE del seed |

### ¿Por qué los pagos PAY-VOL2-000121 a 000300?

El seed volumétrico crea 1200 pagos `PAY-VOL2-*`. Solo los seq 1..300 tienen status `CAPTURED`. De esos, los seq 1..120 ya tienen `refund` registrado (`RFD-VOL2-*`). Los seq 121..300 son `CAPTURED` sin `refund`, lo que los hace elegibles para el demo sin necesidad de crear datos adicionales.

---

## 5. Teoría base aplicada

### ¿Por qué INNER JOIN?

Se usa `INNER JOIN` porque el objetivo es mostrar únicamente las ventas que tienen pago registrado, con su método, estado y transacciones financieras procesadas. Una venta sin pago o un pago sin transacciones quedaría excluido, lo cual es el comportamiento correcto para una consulta de auditoría financiera.

### ¿Por qué trigger AFTER?

El DDL define `refund.payment_id NOT NULL REFERENCES payment(payment_id)`. Al insertar en `payment_transaction`, la fila ya está confirmada y su `payment_id` existe en `payment`. El trigger `AFTER INSERT` puede leer `NEW.payment_id` y usarlo como FK válida en la inserción del `refund`. Un trigger `BEFORE` no garantizaría que la transacción haya sido persistida.

### ¿Por qué procedimiento almacenado?

El procedimiento centraliza tres responsabilidades: validar que el pago existe, validar que el tipo de transacción es permitido por el constraint `ck_payment_transaction_type`, y construir una referencia única para `transaction_reference`. Sin el procedimiento, cualquier proceso que registre transacciones debe replicar esas validaciones.

---

## 6. Consulta resuelta con INNER JOIN

### Tablas involucradas: 7

```
sale
  → reservation
  → payment
      → payment_status
      → payment_method
      → payment_transaction
      → currency
```

### Script

```sql
SELECT
    s.sale_code,
    r.reservation_code,
    p.payment_reference,
    ps.status_code              AS estado_pago,
    pm.method_code              AS metodo_pago,
    pt.transaction_reference,
    pt.transaction_type,
    pt.transaction_amount       AS monto_procesado,
    cu.iso_currency_code        AS moneda
FROM sale s
INNER JOIN reservation r
    ON r.reservation_id = s.reservation_id
INNER JOIN payment p
    ON p.sale_id = s.sale_id
INNER JOIN payment_status ps
    ON ps.payment_status_id = p.payment_status_id
INNER JOIN payment_method pm
    ON pm.payment_method_id = p.payment_method_id
INNER JOIN payment_transaction pt
    ON pt.payment_id = p.payment_id
INNER JOIN currency cu
    ON cu.currency_id = p.currency_id
ORDER BY s.sale_code, pt.processed_at;
```

### Resultado con datos reales del seed canónico

| sale_code | reservation_code | payment_reference | estado_pago | metodo_pago | transaction_reference | transaction_type | monto_procesado | moneda |
|---|---|---|---|---|---|---|---|---|
| SAL-20260305-001 | RES-FY-001 | PAY-20260305-001 | CAPTURED | CREDIT_CARD | TXN-20260305-AUTH-001 | AUTH | 2842.00 | USD |
| SAL-20260305-001 | RES-FY-001 | PAY-20260305-001 | CAPTURED | CREDIT_CARD | TXN-20260305-CAP-001 | CAPTURE | 2842.00 | USD |
| SAL-20260310-001 | RES-FY-002 | PAY-20260310-001 | CAPTURED | DEBIT_CARD | TXN-20260310-CAP-001 | CAPTURE | 359600.00 | COP |
| SAL-20260312-001 | RES-FY-003 | PAY-20260312-001 | CAPTURED | CREDIT_CARD | TXN-20260312-AUTH-001 | AUTH | 719.20 | USD |
| SAL-20260312-001 | RES-FY-003 | PAY-20260312-001 | CAPTURED | CREDIT_CARD | TXN-20260312-CAP-001 | CAPTURE | 719.20 | USD |

Más los registros volumétricos `TXN-VOL2-AUTH-*`, `TXN-VOL2-CAP-*` y `TXN-VOL2-RFD-*`.

### Explicación paso a paso de cada JOIN

1. **`sale`** → aporta `sale_code`, el código comercial de la venta.
2. **`reservation`** → conecta la venta con su reserva mediante `reservation_id`, aporta `reservation_code`.
3. **`payment`** → pago registrado para esa venta, relacionado por `sale_id`.
4. **`payment_status`** → estado actual del pago: `AUTHORIZED`, `CAPTURED`, `REFUNDED`, etc.
5. **`payment_method`** → método utilizado: `CREDIT_CARD`, `DEBIT_CARD`, `WALLET`, etc.
6. **`payment_transaction`** → cada movimiento financiero del pago: `AUTH`, `CAPTURE`, `REFUND`.
7. **`currency`** → moneda de la operación: `USD`, `COP`, `EUR`.

---

## 7. Trigger resuelto

### Decisión técnica

Se eligió `AFTER INSERT ON payment_transaction` porque:
- La acción que debe desencadenar el `refund` es el registro de una transacción de tipo `REFUND`.
- El DDL define `refund.payment_id NOT NULL REFERENCES payment(payment_id)`, por lo que el `payment_id` debe existir antes de insertar en `refund`, lo cual ya está garantizado cuando llega el `AFTER INSERT`.
- No se modifica ningún dato existente, solo se genera evidencia nueva en `refund`.

### Lógica implementada

- Evalúa `NEW.transaction_type`. Si no es `REFUND`, retorna sin hacer nada.
- Construye `refund_reference` único como `'RFD-AUTO-' + primeros 8 chars del UUID + fecha`. Queda dentro del `varchar(40)` del DDL.
- Protege `uq_refund_reference` verificando que no exista ese código antes de insertar.
- Inserta en `refund` usando solo atributos del DDL: `payment_id`, `refund_reference`, `amount`, `requested_at`, `processed_at`, `refund_reason`.
- Respeta `ck_refund_amount` (amount > 0) y `ck_refund_dates` (processed_at >= requested_at).

### Por qué esta solución es correcta

- No altera ninguna tabla del modelo.
- Solo actúa ante transacciones `REFUND`, sin interferir con `AUTH`, `CAPTURE`, `VOID` o `REVERSAL`.
- Respeta todos los constraints de `refund` definidos en el DDL.
- Genera trazabilidad automática sin requerir intervención manual.

---

## 8. Procedimiento almacenado resuelto

### Parámetros de entrada (mapeados a columnas reales del DDL)

| Parámetro | Columna del DDL | Tipo | Notas |
|---|---|---|---|
| `p_payment_id` | `payment_transaction.payment_id` | uuid | FK a `payment` |
| `p_transaction_type` | `payment_transaction.transaction_type` | varchar(20) | AUTH, CAPTURE, VOID, REFUND, REVERSAL |
| `p_transaction_amount` | `payment_transaction.transaction_amount` | numeric(12,2) | Debe ser > 0 |
| `p_processed_at` | `payment_transaction.processed_at` | timestamptz | Momento del procesamiento |
| `p_provider_message` | `payment_transaction.provider_message` | text | Nullable |

### Validaciones internas

1. `payment_id` debe existir en `payment`.
2. `transaction_type` debe ser uno de los valores del constraint `ck_payment_transaction_type`: `AUTH`, `CAPTURE`, `VOID`, `REFUND`, `REVERSAL`.
3. `transaction_amount` debe ser mayor que cero (constraint `ck_payment_transaction_amount`).

### Construcción de `transaction_reference`

El DDL define `transaction_reference varchar(60) UNIQUE`. El procedimiento genera: `'TXN-' + tipo + '-' + primeros 8 chars del payment_id + timestamp en microsegundos`. Esto garantiza unicidad incluso con múltiples transacciones del mismo tipo sobre el mismo pago.

### Integración con el trigger

Cuando `p_transaction_type = 'REFUND'`, la inserción en `payment_transaction` activa automáticamente el trigger `trg_ai_payment_transaction_create_refund`, que genera el registro en `refund`. El procedimiento no necesita insertar en `refund` directamente.

---

## 9. Script de demostración

### ¿Qué demuestra?

1. Busca un pago `CAPTURED` sin `refund` previo en los datos reales del seed.
2. Invoca `sp_register_payment_transaction` con tipo `REFUND` y los datos del pago seleccionado.
3. El procedimiento valida el pago, construye la referencia única e inserta en `payment_transaction`.
4. El trigger `AFTER INSERT` detecta `transaction_type = 'REFUND'` y genera automáticamente el `refund`.
5. La validación final con `INNER JOIN` confirma que tanto la `payment_transaction` como el `refund` quedaron registrados.

### Consultas de validación incluidas

**Validación 1:** Muestra la `payment_transaction` de tipo `REFUND` recién insertada y el `refund` generado por el trigger, vinculados por `payment_id`.

**Validación 2:** Trazabilidad completa `sale → reservation → payment → payment_transaction → refund`, con todos los campos relevantes del negocio.

---

## 10. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 6 INNER JOINs en la consulta principal |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 7 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON payment_transaction FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Inserta en `refund` del modelo |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_2_demo.sql` |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de transacción con validaciones de tipo y monto |
| Existe script que invoca el procedimiento | ✅ | `ejercicio_2_demo.sql` con `CALL sp_register_payment_transaction(...)` |
| La invocación del procedimiento evidencia el trigger | ✅ | El refund se genera automáticamente al registrar REFUND |
| No se alteró la estructura base del modelo | ✅ | Solo se crearon función, trigger y procedimiento |

---

## 11. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_2_setup.sql` | Función `fn_ai_payment_transaction_create_refund`, trigger `trg_ai_payment_transaction_create_refund`, procedimiento `sp_register_payment_transaction` y consulta INNER JOIN con 7 tablas |
| `ejercicio_2_demo.sql` | Bloque `DO $$` con datos reales del seed, invocación de `sp_register_payment_transaction` y dos consultas de validación |
| `ejercicio_2_resuelto.md` | Documentación completa con teoría, datos reales, decisiones técnicas y tabla de criterios |