# Ejercicio 03 Resuelto - Facturación e integración entre venta, impuestos y detalle facturable

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje y facturación.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El área de facturación necesita:

1. Consultar la relación entre ventas, facturas, líneas facturables e impuestos aplicados.
2. Automatizar una acción sobre `invoice` cada vez que se inserta una nueva línea en `invoice_line`.
3. Encapsular el registro del detalle facturable en un procedimiento reutilizable.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| SALES | `sale`, `reservation` | SAL-20260305/10/12-001, SAL-VOL-*, SAL-VOL2-* |
| BILLING | `invoice`, `invoice_status`, `invoice_line`, `tax`, `exchange_rate` | INV-FY-2026-*, INV-VOL-*, INV-VOL2-* (1223 facturas) |
| GEOGRAPHY | `currency` | USD, COP |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Facturas elegibles | `INV-VOL2-2026-*` (status `ISSUED`) | seed volumétrico |
| Líneas existentes | 1 (tarifa base), 2 (AIRPORT_FEE), 3 (SECURITY_FEE) | seed volumétrico |
| Línea nueva | 4 — "Cargo por servicio adicional con VAT 19%" | demo |
| `tax_id` usado | `VAT_19` (19.000%) | seed canónico |
| Efecto verificable | `invoice.updated_at` actualizado por trigger | DDL: campo mutable real |

### ¿Por qué las facturas INV-VOL2-2026-*?

El seed canónico crea 3 facturas con status `PAID` (flujo cerrado). El seed volumétrico crea 1200 facturas `INV-VOL2-2026-*` con status `ISSUED` y exactamente 3 líneas cada una. La línea 4 no existe en ninguna, lo que las hace elegibles para el demo sin violar `uq_invoice_line_number`.

---

## 5. Decisión técnica del trigger: el problema de 3FN

### El reto

El enunciado pide que el trigger sobre `invoice_line` produzca "una acción verificable sobre la factura asociada". La primera solución intuitiva sería actualizar un campo `total` en `invoice`. Sin embargo, el DDL no tiene esa columna: el modelo preserva la **tercera forma normal (3FN)** y no almacena totales derivados. El comentario del DDL lo confirma explícitamente:

```sql
COMMENT ON TABLE invoice_line IS
  'Detalle facturable sin totales derivados persistidos, para preservar 3FN.';
```

Modificar el modelo para agregar ese campo violaría la restricción del ejercicio.

### La solución correcta

El único campo mutable de `invoice` sin derivar datos es `updated_at`, presente en todas las tablas del modelo como `timestamptz NOT NULL DEFAULT now()`. Actualizar `invoice.updated_at` cuando se inserta una línea es:

- **Correcto**: es un atributo real del DDL.
- **Verificable**: se puede comparar el valor antes y después del trigger.
- **Coherente con el negocio**: indica que la cabecera de la factura fue afectada por una nueva línea.
- **Sin romper 3FN**: no almacena ningún valor derivado.

---

## 6. Teoría base aplicada

### ¿Por qué INNER JOIN con LEFT JOIN en tax?

Se usa `INNER JOIN` para las 5 tablas principales (`sale`, `invoice`, `invoice_status`, `invoice_line`, `currency`) porque todas deben existir para que la consulta tenga sentido. `tax` se une con `LEFT JOIN` porque el modelo permite `invoice_line.tax_id NULL`: las líneas de tarifa base no tienen impuesto. Usar `INNER JOIN` en `tax` excluiría las líneas sin impuesto, lo que produciría un resultado incompleto e incorrecto.

### ¿Por qué trigger AFTER?

La inserción en `invoice_line` necesita estar confirmada antes de ejecutar el `UPDATE` en `invoice`. Si el trigger fuera `BEFORE`, la fila de `invoice_line` aún no existiría y la actualización de `invoice.updated_at` ocurriría antes de que el detalle facturable fuera persistido. El trigger `AFTER INSERT` garantiza que ambas operaciones ocurren en el orden correcto dentro de la misma transacción.

### ¿Por qué procedimiento almacenado?

El procedimiento centraliza 6 validaciones que cualquier proceso debe aplicar antes de insertar en `invoice_line`: existencia de la factura, rango del número de línea, unicidad dentro de la factura, cantidad positiva, precio no negativo y existencia del impuesto. Sin él, cada punto de inserción replicaría esa lógica.

---

## 7. Consulta resuelta con INNER JOIN

### Tablas involucradas: 6 (5 INNER JOIN + 1 LEFT JOIN)

```
sale
  → invoice
      → invoice_status
      → invoice_line
          → tax (LEFT JOIN: tax_id puede ser NULL)
      → currency
```

### Script

```sql
SELECT
    s.sale_code,
    inv.invoice_number,
    ist.status_code             AS estado_factura,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price,
    il.quantity * il.unit_price AS subtotal_linea,
    t.tax_code                  AS impuesto_aplicado,
    t.rate_percentage           AS porcentaje_impuesto,
    cu.iso_currency_code        AS moneda
FROM sale s
INNER JOIN invoice inv
    ON inv.sale_id = s.sale_id
INNER JOIN invoice_status ist
    ON ist.invoice_status_id = inv.invoice_status_id
INNER JOIN invoice_line il
    ON il.invoice_id = inv.invoice_id
INNER JOIN currency cu
    ON cu.currency_id = inv.currency_id
LEFT JOIN tax t
    ON t.tax_id = il.tax_id
ORDER BY s.sale_code, inv.invoice_number, il.line_number;
```

### Resultado con datos reales del seed canónico

| sale_code | invoice_number | estado | line_number | line_description | quantity | unit_price | subtotal | impuesto | % | moneda |
|---|---|---|---|---|---|---|---|---|---|---|
| SAL-20260305-001 | INV-FY-2026-0001 | PAID | 1 | Tarifa base Business JF BOG-MAD | 1.00 | 2450.00 | 2450.00 | — | — | USD |
| SAL-20260305-001 | INV-FY-2026-0001 | PAID | 2 | Tasa aeroportuaria 12 % | 1.00 | 294.00 | 294.00 | AIRPORT_FEE | 12.000 | USD |
| SAL-20260305-001 | INV-FY-2026-0001 | PAID | 3 | Tasa de seguridad 4 % | 1.00 | 98.00 | 98.00 | SECURITY_FEE | 4.000 | USD |
| SAL-20260310-001 | INV-FY-2026-0002 | PAID | 1 | Tarifa base Economy YB BOG-MDE | 1.00 | 310000.00 | 310000.00 | — | — | COP |
| SAL-20260310-001 | INV-FY-2026-0002 | PAID | 2 | Tasa aeroportuaria 12 % | 1.00 | 37200.00 | 37200.00 | AIRPORT_FEE | 12.000 | COP |

### Explicación paso a paso de cada JOIN

1. **`sale`** → aporta `sale_code`, origen comercial de la factura.
2. **`invoice`** → factura emitida para esa venta, relacionada por `sale_id`. Aporta `invoice_number` y `updated_at`.
3. **`invoice_status`** → estado actual de la factura: `ISSUED`, `PAID`, `VOID`, etc.
4. **`invoice_line`** → cada línea del detalle facturable: descripción, cantidad y precio unitario.
5. **`currency`** → moneda de la factura: `USD`, `COP`.
6. **`tax`** *(LEFT JOIN)* → impuesto aplicado en la línea: `AIRPORT_FEE`, `SECURITY_FEE`, `VAT_19`. NULL para líneas de tarifa base.

---

## 8. Trigger resuelto

### Acción implementada

```sql
UPDATE invoice
SET updated_at = now()
WHERE invoice_id = NEW.invoice_id;
```

Cada vez que se inserta una línea en `invoice_line`, la factura padre queda marcada con el timestamp de la modificación. Esto es:

- Verificable: se puede consultar `invoice.updated_at` antes y después.
- Sin romper 3FN: no almacena totales derivados.
- Coherente con el negocio: la cabecera refleja que su detalle fue modificado.

### Por qué esta solución es correcta

- No altera ninguna tabla del modelo.
- Usa `updated_at`, atributo real presente en todas las tablas del DDL.
- Respeta la restricción de no almacenar datos derivados (`COMMENT ON TABLE invoice_line`).
- Produce un efecto verificable en una tabla real del modelo.

---

## 9. Procedimiento almacenado resuelto

### Parámetros de entrada (mapeados a columnas reales del DDL)

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_invoice_id` | `invoice_line.invoice_id` | uuid | FK a `invoice` |
| `p_tax_id` | `invoice_line.tax_id` | uuid | Nullable, FK a `tax` |
| `p_line_number` | `invoice_line.line_number` | integer | `ck_invoice_line_number` (> 0) |
| `p_line_description` | `invoice_line.line_description` | varchar(200) | NOT NULL |
| `p_quantity` | `invoice_line.quantity` | numeric(12,2) | `ck_invoice_line_quantity` (> 0) |
| `p_unit_price` | `invoice_line.unit_price` | numeric(12,2) | `ck_invoice_line_unit_price` (>= 0) |

### Validaciones internas (6 checks)

1. `invoice_id` debe existir en `invoice`.
2. `line_number` debe ser mayor que cero (`ck_invoice_line_number`).
3. No debe existir ya esa línea en esa factura (`uq_invoice_line_number`).
4. `quantity` debe ser mayor que cero (`ck_invoice_line_quantity`).
5. `unit_price` debe ser >= 0 (`ck_invoice_line_unit_price`).
6. Si se proporciona `tax_id`, debe existir en `tax`.

---

## 10. Script de demostración

### ¿Qué demuestra?

1. Busca una factura `INV-VOL2-2026-*` con status `ISSUED` del seed volumétrico.
2. Calcula el siguiente número de línea disponible (4, ya que 1/2/3 existen).
3. Resuelve el `tax_id` de `VAT_19` del seed canónico.
4. Invoca `sp_register_invoice_line` con esos datos reales.
5. El procedimiento valida todos los constraints e inserta en `invoice_line`.
6. El trigger `AFTER INSERT` actualiza `invoice.updated_at` automáticamente.
7. Las validaciones finales confirman que la línea existe y que `updated_at` cambió.

---

## 11. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 5 INNER JOINs + 1 LEFT JOIN justificado |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 6 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON invoice_line FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Actualiza `invoice.updated_at` |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_3_demo.sql` |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de línea con 6 validaciones |
| Existe script que invoca el procedimiento | ✅ | `ejercicio_3_demo.sql` con `CALL sp_register_invoice_line(...)` |
| La invocación del procedimiento evidencia el trigger | ✅ | `invoice.updated_at` cambia al agregar la línea |
| No se alteró la estructura base del modelo | ✅ | Solo se crearon función, trigger y procedimiento |

---

## 12. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_3_setup.sql` | Función `fn_ai_invoice_line_touch_invoice`, trigger `trg_ai_invoice_line_touch_invoice`, procedimiento `sp_register_invoice_line` y consulta INNER JOIN con 6 tablas |
| `ejercicio_3_demo.sql` | Bloque `DO $$` con datos reales del seed, invocación de `sp_register_invoice_line` y dos consultas de validación |
| `ejercicio_3_resuelto.md` | Documentación completa con análisis de 3FN, datos reales, decisiones técnicas y tabla de criterios |