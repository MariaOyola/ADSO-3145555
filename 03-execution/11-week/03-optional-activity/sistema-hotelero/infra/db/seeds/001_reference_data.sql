USE sistema_hotelero;

INSERT INTO empresa (nombre, nit, razon_social, telefono, correo, direccion, sitio_web)
VALUES ('Hotel Demo', '900000000-1', 'Hotel Demo S.A.S.', '3000000000', 'contacto@hoteldemo.local', 'Direccion principal', 'https://hoteldemo.local')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

INSERT INTO tipo_dia (nombre, descripcion, aplica_temporada, aplica_feriado, aplica_especial)
VALUES
  ('ENTRE_SEMANA', 'Dia operativo regular entre semana', 0, 0, 0),
  ('FIN_SEMANA', 'Dia de fin de semana', 0, 0, 0),
  ('FERIADO', 'Dia feriado', 0, 1, 0),
  ('TEMPORADA_ALTA', 'Dia con regla de temporada alta', 1, 0, 0)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO metodo_pago (nombre, descripcion, requiere_referencia, permite_pago_parcial)
VALUES
  ('EFECTIVO', 'Pago en efectivo', 0, 1),
  ('TARJETA', 'Pago con tarjeta debito o credito', 1, 1),
  ('TRANSFERENCIA', 'Pago por transferencia bancaria', 1, 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO tipo_habitacion (nombre, descripcion, capacidad_base, capacidad_maxima)
VALUES
  ('SENCILLA', 'Habitacion para una persona', 1, 1),
  ('DOBLE', 'Habitacion para dos personas', 2, 2),
  ('SUITE', 'Habitacion premium con mayor capacidad y comodidades', 2, 4)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO estado_habitacion (nombre, descripcion, permite_reserva, permite_check_in)
VALUES
  ('DISPONIBLE', 'Disponible para reserva y check in', 1, 1),
  ('RESERVADA', 'Reservada para un cliente', 0, 1),
  ('OCUPADA', 'Actualmente ocupada', 0, 0),
  ('LIMPIEZA', 'Pendiente o en proceso de limpieza', 0, 0),
  ('BLOQUEADA', 'Bloqueada por decision operativa', 0, 0),
  ('MANTENIMIENTO', 'No disponible por mantenimiento', 0, 0)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO sede (empresa_id, nombre, direccion, ciudad, telefono, correo)
SELECT e.id, 'Sede Principal', 'Direccion principal', 'Bogota', '3000000000', 'sede.principal@hoteldemo.local'
FROM empresa e
WHERE e.nit = '900000000-1'
ON DUPLICATE KEY UPDATE direccion = VALUES(direccion);

INSERT INTO habitacion (sede_id, tipo_habitacion_id, estado_habitacion_id, numero, piso, capacidad, descripcion)
SELECT s.id, th.id, eh.id, '101', 1, 1, 'Habitacion sencilla de referencia'
FROM sede s
JOIN empresa e ON e.id = s.empresa_id
JOIN tipo_habitacion th ON th.nombre = 'SENCILLA'
JOIN estado_habitacion eh ON eh.nombre = 'DISPONIBLE'
WHERE e.nit = '900000000-1' AND s.nombre = 'Sede Principal'
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO habitacion (sede_id, tipo_habitacion_id, estado_habitacion_id, numero, piso, capacidad, descripcion)
SELECT s.id, th.id, eh.id, '201', 2, 2, 'Habitacion doble de referencia'
FROM sede s
JOIN empresa e ON e.id = s.empresa_id
JOIN tipo_habitacion th ON th.nombre = 'DOBLE'
JOIN estado_habitacion eh ON eh.nombre = 'DISPONIBLE'
WHERE e.nit = '900000000-1' AND s.nombre = 'Sede Principal'
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO precio (tipo_habitacion_id, tipo_dia_id, valor, fecha_inicio, fecha_fin, condicion)
SELECT th.id, td.id,
  CASE th.nombre
    WHEN 'SENCILLA' THEN 120000
    WHEN 'DOBLE' THEN 180000
    ELSE 320000
  END,
  '2026-01-01',
  NULL,
  'Precio base inicial pendiente de reglas dinamicas definitivas'
FROM tipo_habitacion th
CROSS JOIN tipo_dia td
WHERE td.nombre = 'ENTRE_SEMANA'
ON DUPLICATE KEY UPDATE
  valor = VALUES(valor),
  condicion = VALUES(condicion);

INSERT INTO modulo (nombre, descripcion, ruta_base)
VALUES
  ('PARAMETRIZACION', 'Configuracion base del negocio hotelero', '/parametrizacion'),
  ('DISTRIBUCION', 'Estructura fisica y comercial del hotel', '/distribucion'),
  ('PRESTACION_SERVICIO', 'Reserva, disponibilidad, check in, estadia y check out', '/prestacion-servicio'),
  ('FACTURACION', 'Pre facturacion, pagos, factura y detalle de compra', '/facturacion'),
  ('INVENTARIO', 'Productos, servicios, proveedores y disponibilidad', '/inventario'),
  ('NOTIFICACION', 'Promociones, alertas, terminos y fidelizacion', '/notificacion'),
  ('SEGURIDAD', 'Usuarios, roles, permisos, modulos y vistas', '/seguridad'),
  ('MANTENIMIENTO', 'Mantenimiento y disponibilidad operativa de habitaciones', '/mantenimiento')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO rol (nombre, descripcion)
VALUES
  ('ADMINISTRADOR', 'Acceso administrativo general'),
  ('RECEPCION', 'Gestion de reservas, check in y check out'),
  ('MANTENIMIENTO', 'Gestion operativa de mantenimiento'),
  ('INVENTARIO', 'Gestion de productos, servicios y proveedores')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO permiso (nombre, descripcion, accion)
VALUES
  ('GESTIONAR_RESERVA', 'Crear, actualizar y consultar reservas', 'WRITE'),
  ('GESTIONAR_FACTURA', 'Emitir y consultar facturas', 'WRITE'),
  ('GESTIONAR_INVENTARIO', 'Administrar productos, servicios y disponibilidad', 'WRITE'),
  ('GESTIONAR_MANTENIMIENTO', 'Administrar mantenimiento de habitaciones', 'WRITE'),
  ('CONSULTAR_DASHBOARD', 'Consultar informacion operativa', 'READ')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO termino_condicion (titulo, contenido, version, fecha_vigencia, obligatorio)
VALUES ('Terminos base de reserva', 'Condiciones iniciales pendientes de aprobacion legal.', 'v1.0.0', '2026-01-01', 1)
ON DUPLICATE KEY UPDATE contenido = VALUES(contenido);
