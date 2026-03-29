DELETE FROM status
WHERE name IN (
    'activo',
    'inactivo',
    'eliminado',
    'pendiente',
    'preparado',
    'entregado',
    'cancelado',
    'pagado',
    'anulado',
    'bloqueado'
);
