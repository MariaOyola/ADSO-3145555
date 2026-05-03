USE sistema_hotelero;

SELECT 'tables_created' AS check_name, COUNT(*) AS value
FROM information_schema.tables
WHERE table_schema = 'sistema_hotelero';

SELECT 'tables_with_complete_audit' AS check_name, COUNT(*) AS value
FROM (
  SELECT table_name
  FROM information_schema.columns
  WHERE table_schema = 'sistema_hotelero'
    AND column_name IN ('created_by', 'created_at', 'updated_by', 'updated_at', 'deleted_by', 'deleted_at', 'status')
  GROUP BY table_name
  HAVING COUNT(DISTINCT column_name) = 7
) audited_tables;

SELECT 'estado_habitacion' AS check_name, COUNT(*) AS value FROM estado_habitacion;
SELECT 'tipo_habitacion' AS check_name, COUNT(*) AS value FROM tipo_habitacion;
SELECT 'modulos' AS check_name, COUNT(*) AS value FROM modulo;

SELECT
  h.numero,
  s.nombre AS sede,
  th.nombre AS tipo_habitacion,
  eh.nombre AS estado_habitacion
FROM habitacion h
JOIN sede s ON s.id = h.sede_id
JOIN tipo_habitacion th ON th.id = h.tipo_habitacion_id
JOIN estado_habitacion eh ON eh.id = h.estado_habitacion_id
ORDER BY h.numero;
