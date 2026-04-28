-- ============================================================
-- ejercicio_3_demo.sql
-- Ejercicio 03 - Facturacion e integracion entre venta,
-- impuestos y detalle facturable
-- ============================================================
-- Demuestra el flujo completo usando datos reales del seed:
--
--   SEED CANONICO (00_seed_canonico.sql)
--   - Facturas canonicas con status PAID (lineas completas):
--       INV-FY-2026-0001  USD  (Ana   - RES-FY-001) 3 lineas
--       INV-FY-2026-0002  COP  (Carlos - RES-FY-002) 3 lineas
--       INV-FY-2026-0003  USD  (Laura  - RES-FY-003) 3 lineas
--   - Tax reales:
--       AIRPORT_FEE  -> 12.000 %
--       SECURITY_FEE ->  4.000 %
--       VAT_19       -> 19.000 %
--   - invoice_status reales:
--       ISSUED, OVERDUE, PAID, PARTIAL, VOID
--
--   SEED VOLUMETRICO (01_seed_volumetrico.sql)
--   - INV-VOL-2026-*   (20 facturas, status ISSUED, 3 lineas c/u)
--   - INV-VOL2-2026-*  (1200 facturas, status ISSUED, 3 lineas c/u)
--     Cada factura tiene lineas 1, 2 y 3. Solo se puede agregar
--     la linea 4 (nueva) sin violar uq_invoice_line_number.
--
-- Flujo del demo:
--   1. Busca una factura ISSUED del seed volumetrico
--   2. Resuelve el tax_id de VAT_19 (19%) del seed canonico
--   3. Invoca sp_register_invoice_line para agregar linea 4
--   4. El trigger actualiza invoice.updated_at automaticamente
--   5. La consulta de validacion confirma el resultado completo
-- ============================================================

DO $$
DECLARE
    v_invoice_id        uuid;
    v_invoice_number    varchar(40);
    v_sale_code         varchar(30);
    v_invoice_updated   timestamptz;
    v_tax_id            uuid;
    v_next_line         integer;
BEGIN
    -- --------------------------------------------------------
    -- PASO 1: Obtener una factura ISSUED del seed volumetrico
    -- --------------------------------------------------------
    -- Las facturas INV-VOL2-2026-* tienen status ISSUED y
    -- exactamente 3 lineas (1, 2, 3). La linea 4 no existe
    -- en ninguna, por lo que es seguro agregarla aqui.
    -- Se usa una factura del seed volumetrico para no
    -- interferir con las 3 facturas canonicas PAID.
    -- --------------------------------------------------------
    SELECT
        inv.invoice_id,
        inv.invoice_number,
        s.sale_code,
        inv.updated_at
    INTO
        v_invoice_id,
        v_invoice_number,
        v_sale_code,
        v_invoice_updated
    FROM invoice inv
    JOIN invoice_status ist
        ON ist.invoice_status_id = inv.invoice_status_id
    JOIN sale s
        ON s.sale_id = inv.sale_id
    WHERE ist.status_code = 'ISSUED'
      AND inv.invoice_number LIKE 'INV-VOL2-%'
    ORDER BY inv.created_at
    LIMIT 1;

    IF v_invoice_id IS NULL THEN
        RAISE EXCEPTION
            'No existe factura ISSUED disponible. '
            'Verificar que el seed volumetrico fue cargado.';
    END IF;

    -- --------------------------------------------------------
    -- PASO 2: Resolver el proximo numero de linea disponible
    -- --------------------------------------------------------
    -- Las facturas vol2 tienen lineas 1, 2 y 3.
    -- La siguiente es la 4.
    -- --------------------------------------------------------
    SELECT COALESCE(MAX(il.line_number), 0) + 1
    INTO   v_next_line
    FROM   invoice_line il
    WHERE  il.invoice_id = v_invoice_id;

    -- --------------------------------------------------------
    -- PASO 3: Resolver el tax_id de VAT_19 del seed canonico
    -- --------------------------------------------------------
    -- Tax real del seed canonico:
    --   tax_code = 'VAT_19'  rate_percentage = 19.000
    -- Este impuesto existe en el seed pero no ha sido usado
    -- en ninguna linea de factura del seed canonico ni vol.
    -- --------------------------------------------------------
    SELECT tax_id
    INTO   v_tax_id
    FROM   tax
    WHERE  tax_code = 'VAT_19';

    IF v_tax_id IS NULL THEN
        RAISE EXCEPTION
            'No se encontro tax con codigo VAT_19. '
            'Verificar que el seed canonico fue cargado.';
    END IF;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Datos seleccionados para el demo:';
    RAISE NOTICE '  invoice_id     : %', v_invoice_id;
    RAISE NOTICE '  invoice_number : %', v_invoice_number;
    RAISE NOTICE '  sale_code      : %', v_sale_code;
    RAISE NOTICE '  updated_at     : %', v_invoice_updated;
    RAISE NOTICE '  next_line_no   : %', v_next_line;
    RAISE NOTICE '  tax            : VAT_19 (19%%)';
    RAISE NOTICE '==========================================';

    -- --------------------------------------------------------
    -- PASO 4: Invocar el procedimiento almacenado
    -- --------------------------------------------------------
    -- sp_register_invoice_line inserta en invoice_line.
    -- El trigger AFTER INSERT actualiza invoice.updated_at
    -- automaticamente, dejando evidencia de la modificacion.
    --
    -- Linea que se agrega:
    --   Linea 4: Cargo por servicio adicional con VAT_19
    --   Cantidad: 1 | Precio unitario: 15000.00 COP
    -- --------------------------------------------------------
    CALL sp_register_invoice_line(
        v_invoice_id,           -- invoice_line.invoice_id
        v_tax_id,               -- invoice_line.tax_id (VAT_19)
        v_next_line,            -- invoice_line.line_number (4)
        'Cargo por servicio adicional con VAT 19%',
        1.00,                   -- invoice_line.quantity
        15000.00                -- invoice_line.unit_price
    );

    RAISE NOTICE 'sp_register_invoice_line ejecutado.';
    RAISE NOTICE 'Linea % agregada a factura %.',
        v_next_line, v_invoice_number;
    RAISE NOTICE 'El trigger actualiza invoice.updated_at.';
    RAISE NOTICE '==========================================';
END;
$$;

-- ============================================================
-- VALIDACION 1: Confirmar la linea insertada y que
-- invoice.updated_at fue actualizado por el trigger
-- ============================================================

SELECT
    inv.invoice_number,
    inv.updated_at                      AS factura_updated_at,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price,
    il.quantity * il.unit_price         AS subtotal,
    t.tax_code,
    t.rate_percentage
FROM invoice inv
INNER JOIN invoice_line il
    ON il.invoice_id = inv.invoice_id
LEFT JOIN tax t
    ON t.tax_id = il.tax_id
WHERE inv.invoice_number LIKE 'INV-VOL2-%'
  AND il.line_number = 4
ORDER BY inv.updated_at DESC
LIMIT 5;

-- ============================================================
-- VALIDACION 2: Trazabilidad completa venta -> factura ->
-- lineas -> impuesto de la factura recien modificada
-- ============================================================

SELECT
    s.sale_code,
    inv.invoice_number,
    ist.status_code                     AS estado_factura,
    cu.iso_currency_code                AS moneda,
    inv.updated_at                      AS ultima_modificacion,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price,
    il.quantity * il.unit_price         AS subtotal_linea,
    t.tax_code                          AS impuesto,
    t.rate_percentage                   AS porcentaje
FROM invoice inv
INNER JOIN invoice_status ist
    ON ist.invoice_status_id = inv.invoice_status_id
INNER JOIN invoice_line il
    ON il.invoice_id = inv.invoice_id
INNER JOIN sale s
    ON s.sale_id = inv.sale_id
INNER JOIN currency cu
    ON cu.currency_id = inv.currency_id
LEFT JOIN tax t
    ON t.tax_id = il.tax_id
WHERE inv.invoice_number LIKE 'INV-VOL2-%'
  AND EXISTS (
      SELECT 1 FROM invoice_line il2
      WHERE il2.invoice_id  = inv.invoice_id
        AND il2.line_number = 4
  )
ORDER BY il.line_number;