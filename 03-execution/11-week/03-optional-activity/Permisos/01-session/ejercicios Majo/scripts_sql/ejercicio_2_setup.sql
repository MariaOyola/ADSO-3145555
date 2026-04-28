-- ============================================================
-- ejercicio_2_demo.sql
-- Ejercicio 02 - Control de pagos y trazabilidad de
-- transacciones financieras
-- ============================================================
-- Demuestra el flujo completo usando datos reales del seed:
--
--   SEED CANONICO (00_seed_canonico.sql)
--   - Pagos canonicos con status CAPTURED (ya conciliados):
--       PAY-20260305-001  USD 2842.00  (Ana   - RES-FY-001)
--       PAY-20260310-001  COP 359600   (Carlos - RES-FY-002)
--       PAY-20260312-001  USD 719.20   (Laura  - RES-FY-003)
--   - payment_transaction types disponibles:
--       AUTH, CAPTURE, VOID, REFUND, REVERSAL
--   - payment_status reales:
--       AUTHORIZED, CAPTURED, CANCELLED, FAILED, PENDING, REFUNDED
--
--   SEED VOLUMETRICO (01_seed_volumetrico.sql)
--   - Pagos PAY-VOL2-* (1200 registros, COP 359600)
--     * seq 1..300   -> status CAPTURED
--     * seq 1..120   -> tienen refund RFD-VOL2-* ya registrado
--     * seq 121..300 -> CAPTURED sin refund -> elegibles para demo
--     * seq 301..1200 -> AUTHORIZED sin refund
--
-- Flujo del demo:
--   1. Busca un pago CAPTURED sin refund previo (elegible)
--   2. Invoca sp_register_payment_transaction con tipo REFUND
--   3. El trigger genera automaticamente el refund en la tabla refund
--   4. La consulta de validacion confirma el resultado completo
-- ============================================================
 
DO $$
DECLARE
    v_payment_id            uuid;
    v_payment_reference     varchar(40);
    v_sale_code             varchar(30);
BEGIN
    -- --------------------------------------------------------
    -- PASO 1: Obtener un pago CAPTURED sin refund previo
    -- --------------------------------------------------------
    -- El seed volumetrico tiene pagos PAY-VOL2-* seq 121..300
    -- con status CAPTURED pero sin refund registrado.
    -- Son los elegibles para este demo.
    -- Se usa LEFT JOIN para confirmar que r.refund_id IS NULL.
    -- --------------------------------------------------------
    SELECT
        p.payment_id,
        p.payment_reference,
        s.sale_code
    INTO
        v_payment_id,
        v_payment_reference,
        v_sale_code
    FROM payment p
    JOIN sale s ON s.sale_id = p.sale_id
    JOIN payment_status ps ON ps.payment_status_id = p.payment_status_id
    LEFT JOIN refund r ON r.payment_id = p.payment_id
    WHERE ps.status_code = 'CAPTURED'
      AND r.refund_id IS NULL
    ORDER BY p.created_at
    LIMIT 1;
 
    -- --------------------------------------------------------
    -- Validacion previa a la ejecucion
    -- --------------------------------------------------------
    IF v_payment_id IS NULL THEN
        RAISE EXCEPTION
            'No existe pago CAPTURED sin refund disponible. '
            'Verificar que el seed volumetrico fue cargado.';
    END IF;
 
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Pago seleccionado para el demo:';
    RAISE NOTICE '  payment_id        : %', v_payment_id;
    RAISE NOTICE '  payment_reference : %', v_payment_reference;
    RAISE NOTICE '  sale_code         : %', v_sale_code;
    RAISE NOTICE '==========================================';
 
    -- --------------------------------------------------------
    -- PASO 2: Invocar el procedimiento almacenado
    -- --------------------------------------------------------
    -- sp_register_payment_transaction inserta en
    -- payment_transaction con tipo REFUND.
    -- El trigger AFTER INSERT detecta el tipo REFUND y genera
    -- automaticamente el registro en refund.
    --
    -- Parametros usados:
    --   p_payment_id         -> payment_id real del seed
    --   p_transaction_type   -> 'REFUND' (activa el trigger)
    --   p_transaction_amount -> monto real del pago: 359600.00
    --   p_processed_at       -> ahora
    --   p_provider_message   -> mensaje del proveedor
    -- --------------------------------------------------------
    CALL sp_register_payment_transaction(
        v_payment_id,
        'REFUND',
        359600.00,
        now(),
        'Reembolso procesado por solicitud del cliente. Demo ejercicio 02.'
    );
 
    RAISE NOTICE 'sp_register_payment_transaction ejecutado.';
    RAISE NOTICE 'Tipo: REFUND | Monto: 359600.00 COP';
    RAISE NOTICE 'El trigger genera el refund automaticamente.';
    RAISE NOTICE '==========================================';
END;
$$;
 
-- ============================================================
-- VALIDACION 1: Confirmar la payment_transaction registrada
-- y el refund generado automaticamente por el trigger
-- ============================================================
 
SELECT
    pt.transaction_reference,
    pt.transaction_type,
    pt.transaction_amount,
    pt.processed_at,
    pt.provider_message,
    r.refund_reference,
    r.amount                    AS monto_refund,
    r.requested_at,
    r.processed_at              AS refund_procesado_at,
    r.refund_reason
FROM payment_transaction pt
INNER JOIN refund r
    ON r.payment_id = pt.payment_id
   AND r.refund_reference LIKE 'RFD-AUTO-%'
WHERE pt.transaction_type = 'REFUND'
  AND pt.transaction_reference LIKE 'TXN-REFUND-%'
ORDER BY pt.processed_at DESC
LIMIT 5;
 
-- ============================================================
-- VALIDACION 2: Trazabilidad completa venta -> pago ->
-- transaccion -> refund del registro recien creado
-- ============================================================
 
SELECT
    s.sale_code,
    r_res.reservation_code,
    p.payment_reference,
    ps.status_code              AS estado_pago,
    pm.method_code              AS metodo_pago,
    cu.iso_currency_code        AS moneda,
    pt.transaction_reference,
    pt.transaction_type,
    pt.transaction_amount,
    rf.refund_reference,
    rf.amount                   AS monto_devuelto,
    rf.refund_reason
FROM payment_transaction pt
INNER JOIN payment p
    ON p.payment_id = pt.payment_id
INNER JOIN payment_status ps
    ON ps.payment_status_id = p.payment_status_id
INNER JOIN payment_method pm
    ON pm.payment_method_id = p.payment_method_id
INNER JOIN currency cu
    ON cu.currency_id = p.currency_id
INNER JOIN sale s
    ON s.sale_id = p.sale_id
INNER JOIN reservation r_res
    ON r_res.reservation_id = s.reservation_id
INNER JOIN refund rf
    ON rf.payment_id = p.payment_id
   AND rf.refund_reference LIKE 'RFD-AUTO-%'
WHERE pt.transaction_type = 'REFUND'
  AND pt.transaction_reference LIKE 'TXN-REFUND-%'
ORDER BY pt.processed_at DESC
LIMIT 5;