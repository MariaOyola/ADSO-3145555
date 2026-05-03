CREATE DATABASE IF NOT EXISTS sistema_hotelero
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_hotelero;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS modulo_vista;
DROP TABLE IF EXISTS rol_permiso;
DROP TABLE IF EXISTS usuario_rol;
DROP TABLE IF EXISTS dashboard_mantenimiento;
DROP TABLE IF EXISTS mantenimiento_remodelacion;
DROP TABLE IF EXISTS mantenimiento_uso;
DROP TABLE IF EXISTS mantenimiento_habitacion;
DROP TABLE IF EXISTS fidelizacion_cliente;
DROP TABLE IF EXISTS termino_condicion;
DROP TABLE IF EXISTS alerta;
DROP TABLE IF EXISTS promocion;
DROP TABLE IF EXISTS disponibilidad_inventario;
DROP TABLE IF EXISTS seguimiento_producto;
DROP TABLE IF EXISTS producto;
DROP TABLE IF EXISTS servicio;
DROP TABLE IF EXISTS proveedor;
DROP TABLE IF EXISTS detalle_compra;
DROP TABLE IF EXISTS pago_parcial;
DROP TABLE IF EXISTS factura;
DROP TABLE IF EXISTS pre_factura;
DROP TABLE IF EXISTS venta_servicio;
DROP TABLE IF EXISTS venta_producto;
DROP TABLE IF EXISTS check_out;
DROP TABLE IF EXISTS check_in;
DROP TABLE IF EXISTS estadia;
DROP TABLE IF EXISTS catalogo_habitacion;
DROP TABLE IF EXISTS disponibilidad_habitacion;
DROP TABLE IF EXISTS cancelacion_habitacion;
DROP TABLE IF EXISTS reserva_habitacion;
DROP TABLE IF EXISTS habitacion;
DROP TABLE IF EXISTS estado_habitacion;
DROP TABLE IF EXISTS tipo_habitacion;
DROP TABLE IF EXISTS sede;
DROP TABLE IF EXISTS metodo_pago;
DROP TABLE IF EXISTS tipo_dia;
DROP TABLE IF EXISTS empleado;
DROP TABLE IF EXISTS informacion_legal;
DROP TABLE IF EXISTS precio;
DROP TABLE IF EXISTS empresa;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS vista;
DROP TABLE IF EXISTS modulo;
DROP TABLE IF EXISTS permiso;
DROP TABLE IF EXISTS rol;
DROP TABLE IF EXISTS persona;
DROP TABLE IF EXISTS cliente;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE cliente (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo_documento VARCHAR(30) NOT NULL,
  numero_documento VARCHAR(40) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  telefono VARCHAR(40) NULL,
  correo VARCHAR(160) NULL,
  direccion VARCHAR(255) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_cliente_documento (tipo_documento, numero_documento),
  UNIQUE KEY uk_cliente_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE persona (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo_documento VARCHAR(30) NOT NULL,
  numero_documento VARCHAR(40) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  telefono VARCHAR(40) NULL,
  correo VARCHAR(160) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_persona_documento (tipo_documento, numero_documento),
  UNIQUE KEY uk_persona_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rol (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_rol_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permiso (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(120) NOT NULL,
  descripcion VARCHAR(255) NULL,
  accion VARCHAR(80) NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_permiso_nombre_accion (nombre, accion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE modulo (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255) NULL,
  ruta_base VARCHAR(160) NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_modulo_nombre (nombre),
  UNIQUE KEY uk_modulo_ruta_base (ruta_base)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE vista (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  modulo_id BIGINT UNSIGNED NOT NULL,
  nombre VARCHAR(120) NOT NULL,
  descripcion VARCHAR(255) NULL,
  ruta VARCHAR(180) NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_vista_modulo_ruta (modulo_id, ruta),
  CONSTRAINT fk_vista_modulo FOREIGN KEY (modulo_id) REFERENCES modulo (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuario (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  persona_id BIGINT UNSIGNED NOT NULL,
  username VARCHAR(80) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  ultimo_acceso DATETIME NULL,
  bloqueado TINYINT(1) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuario_persona (persona_id),
  UNIQUE KEY uk_usuario_username (username),
  CONSTRAINT fk_usuario_persona FOREIGN KEY (persona_id) REFERENCES persona (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE empresa (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(160) NOT NULL,
  nit VARCHAR(40) NOT NULL,
  razon_social VARCHAR(180) NOT NULL,
  telefono VARCHAR(40) NULL,
  correo VARCHAR(160) NULL,
  direccion VARCHAR(255) NULL,
  sitio_web VARCHAR(180) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_empresa_nit (nit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_dia (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  fecha DATE NULL,
  aplica_temporada TINYINT(1) NOT NULL DEFAULT 0,
  aplica_feriado TINYINT(1) NOT NULL DEFAULT 0,
  aplica_especial TINYINT(1) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_tipo_dia_nombre_fecha (nombre, fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE metodo_pago (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  requiere_referencia TINYINT(1) NOT NULL DEFAULT 0,
  permite_pago_parcial TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_metodo_pago_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE informacion_legal (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  tipo_documento_legal VARCHAR(80) NOT NULL,
  numero_documento_legal VARCHAR(80) NOT NULL,
  descripcion TEXT NULL,
  fecha_expedicion DATE NULL,
  fecha_vencimiento DATE NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_informacion_legal_empresa (empresa_id),
  CONSTRAINT fk_informacion_legal_empresa FOREIGN KEY (empresa_id) REFERENCES empresa (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE empleado (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  persona_id BIGINT UNSIGNED NOT NULL,
  cargo VARCHAR(100) NOT NULL,
  fecha_ingreso DATE NOT NULL,
  telefono_laboral VARCHAR(40) NULL,
  correo_laboral VARCHAR(160) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_empleado_persona (persona_id),
  UNIQUE KEY uk_empleado_correo_laboral (correo_laboral),
  CONSTRAINT fk_empleado_persona FOREIGN KEY (persona_id) REFERENCES persona (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sede (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  empresa_id BIGINT UNSIGNED NOT NULL,
  nombre VARCHAR(160) NOT NULL,
  direccion VARCHAR(255) NOT NULL,
  ciudad VARCHAR(120) NOT NULL,
  telefono VARCHAR(40) NULL,
  correo VARCHAR(160) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_sede_empresa_nombre (empresa_id, nombre),
  CONSTRAINT fk_sede_empresa FOREIGN KEY (empresa_id) REFERENCES empresa (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  capacidad_base SMALLINT UNSIGNED NOT NULL,
  capacidad_maxima SMALLINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_tipo_habitacion_nombre (nombre),
  CONSTRAINT ck_tipo_habitacion_capacidad CHECK (capacidad_maxima >= capacidad_base)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estado_habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  permite_reserva TINYINT(1) NOT NULL DEFAULT 0,
  permite_check_in TINYINT(1) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_estado_habitacion_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sede_id BIGINT UNSIGNED NOT NULL,
  tipo_habitacion_id BIGINT UNSIGNED NOT NULL,
  estado_habitacion_id BIGINT UNSIGNED NOT NULL,
  numero VARCHAR(20) NOT NULL,
  piso SMALLINT NULL,
  capacidad SMALLINT UNSIGNED NOT NULL,
  descripcion VARCHAR(255) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_habitacion_sede_numero (sede_id, numero),
  KEY ix_habitacion_tipo (tipo_habitacion_id),
  KEY ix_habitacion_estado (estado_habitacion_id),
  CONSTRAINT fk_habitacion_sede FOREIGN KEY (sede_id) REFERENCES sede (id),
  CONSTRAINT fk_habitacion_tipo FOREIGN KEY (tipo_habitacion_id) REFERENCES tipo_habitacion (id),
  CONSTRAINT fk_habitacion_estado FOREIGN KEY (estado_habitacion_id) REFERENCES estado_habitacion (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE precio (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo_habitacion_id BIGINT UNSIGNED NOT NULL,
  tipo_dia_id BIGINT UNSIGNED NOT NULL,
  valor DECIMAL(12,2) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NULL,
  condicion VARCHAR(255) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_precio_tipo_habitacion (tipo_habitacion_id),
  KEY ix_precio_tipo_dia (tipo_dia_id),
  UNIQUE KEY uk_precio_tipo_dia_inicio (tipo_habitacion_id, tipo_dia_id, fecha_inicio),
  CONSTRAINT fk_precio_tipo_habitacion FOREIGN KEY (tipo_habitacion_id) REFERENCES tipo_habitacion (id),
  CONSTRAINT fk_precio_tipo_dia FOREIGN KEY (tipo_dia_id) REFERENCES tipo_dia (id),
  CONSTRAINT ck_precio_valor CHECK (valor >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reserva_habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id BIGINT UNSIGNED NOT NULL,
  habitacion_id BIGINT UNSIGNED NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NOT NULL,
  cantidad_persona SMALLINT UNSIGNED NOT NULL,
  estado_reserva VARCHAR(40) NOT NULL DEFAULT 'PENDIENTE',
  valor_estimado DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_reserva_cliente (cliente_id),
  KEY ix_reserva_habitacion_fecha (habitacion_id, fecha_inicio, fecha_fin),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id),
  CONSTRAINT fk_reserva_habitacion FOREIGN KEY (habitacion_id) REFERENCES habitacion (id),
  CONSTRAINT ck_reserva_fechas CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cancelacion_habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  reserva_habitacion_id BIGINT UNSIGNED NOT NULL,
  motivo VARCHAR(255) NOT NULL,
  fecha_cancelacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aplica_penalidad TINYINT(1) NOT NULL DEFAULT 0,
  valor_penalidad DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_cancelacion_reserva (reserva_habitacion_id),
  CONSTRAINT fk_cancelacion_reserva FOREIGN KEY (reserva_habitacion_id) REFERENCES reserva_habitacion (id),
  CONSTRAINT ck_cancelacion_penalidad CHECK (valor_penalidad >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE disponibilidad_habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  habitacion_id BIGINT UNSIGNED NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NOT NULL,
  disponible TINYINT(1) NOT NULL DEFAULT 1,
  motivo_no_disponible VARCHAR(255) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_disponibilidad_habitacion_fecha (habitacion_id, fecha_inicio, fecha_fin),
  CONSTRAINT fk_disponibilidad_habitacion FOREIGN KEY (habitacion_id) REFERENCES habitacion (id),
  CONSTRAINT ck_disponibilidad_fechas CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE catalogo_habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  habitacion_id BIGINT UNSIGNED NOT NULL,
  titulo VARCHAR(160) NOT NULL,
  descripcion TEXT NULL,
  precio_base DECIMAL(12,2) NOT NULL DEFAULT 0,
  visible TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_catalogo_habitacion (habitacion_id),
  CONSTRAINT fk_catalogo_habitacion FOREIGN KEY (habitacion_id) REFERENCES habitacion (id),
  CONSTRAINT ck_catalogo_precio CHECK (precio_base >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estadia (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  reserva_habitacion_id BIGINT UNSIGNED NOT NULL,
  cliente_id BIGINT UNSIGNED NOT NULL,
  habitacion_id BIGINT UNSIGNED NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NULL,
  estado_estadia VARCHAR(40) NOT NULL DEFAULT 'ACTIVA',
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_estadia_reserva (reserva_habitacion_id),
  KEY ix_estadia_cliente (cliente_id),
  KEY ix_estadia_habitacion (habitacion_id),
  CONSTRAINT fk_estadia_reserva FOREIGN KEY (reserva_habitacion_id) REFERENCES reserva_habitacion (id),
  CONSTRAINT fk_estadia_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id),
  CONSTRAINT fk_estadia_habitacion FOREIGN KEY (habitacion_id) REFERENCES habitacion (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE check_in (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  reserva_habitacion_id BIGINT UNSIGNED NOT NULL,
  empleado_id BIGINT UNSIGNED NOT NULL,
  fecha_hora_ingreso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacion TEXT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_check_in_reserva (reserva_habitacion_id),
  KEY ix_check_in_empleado (empleado_id),
  CONSTRAINT fk_check_in_reserva FOREIGN KEY (reserva_habitacion_id) REFERENCES reserva_habitacion (id),
  CONSTRAINT fk_check_in_empleado FOREIGN KEY (empleado_id) REFERENCES empleado (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE check_out (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  estadia_id BIGINT UNSIGNED NOT NULL,
  empleado_id BIGINT UNSIGNED NOT NULL,
  fecha_hora_salida DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacion TEXT NULL,
  valor_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_check_out_estadia (estadia_id),
  KEY ix_check_out_empleado (empleado_id),
  CONSTRAINT fk_check_out_estadia FOREIGN KEY (estadia_id) REFERENCES estadia (id),
  CONSTRAINT fk_check_out_empleado FOREIGN KEY (empleado_id) REFERENCES empleado (id),
  CONSTRAINT ck_check_out_valor CHECK (valor_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE proveedor (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(160) NOT NULL,
  nit VARCHAR(40) NULL,
  telefono VARCHAR(40) NULL,
  correo VARCHAR(160) NULL,
  direccion VARCHAR(255) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_proveedor_nit (nit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE producto (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  proveedor_id BIGINT UNSIGNED NULL,
  nombre VARCHAR(160) NOT NULL,
  descripcion VARCHAR(255) NULL,
  valor_venta DECIMAL(12,2) NOT NULL DEFAULT 0,
  stock_actual INT NOT NULL DEFAULT 0,
  stock_minimo INT NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_producto_nombre (nombre),
  KEY ix_producto_proveedor (proveedor_id),
  CONSTRAINT fk_producto_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedor (id),
  CONSTRAINT ck_producto_valores CHECK (valor_venta >= 0 AND stock_actual >= 0 AND stock_minimo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicio (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(160) NOT NULL,
  descripcion VARCHAR(255) NULL,
  valor_venta DECIMAL(12,2) NOT NULL DEFAULT 0,
  disponible TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_servicio_nombre (nombre),
  CONSTRAINT ck_servicio_valor CHECK (valor_venta >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE venta_producto (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  estadia_id BIGINT UNSIGNED NOT NULL,
  producto_id BIGINT UNSIGNED NOT NULL,
  cantidad INT UNSIGNED NOT NULL,
  valor_unitario DECIMAL(12,2) NOT NULL,
  valor_total DECIMAL(12,2) NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_venta_producto_estadia (estadia_id),
  KEY ix_venta_producto_producto (producto_id),
  CONSTRAINT fk_venta_producto_estadia FOREIGN KEY (estadia_id) REFERENCES estadia (id),
  CONSTRAINT fk_venta_producto_producto FOREIGN KEY (producto_id) REFERENCES producto (id),
  CONSTRAINT ck_venta_producto_valores CHECK (cantidad > 0 AND valor_unitario >= 0 AND valor_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE venta_servicio (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  estadia_id BIGINT UNSIGNED NOT NULL,
  servicio_id BIGINT UNSIGNED NOT NULL,
  cantidad INT UNSIGNED NOT NULL,
  valor_unitario DECIMAL(12,2) NOT NULL,
  valor_total DECIMAL(12,2) NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_venta_servicio_estadia (estadia_id),
  KEY ix_venta_servicio_servicio (servicio_id),
  CONSTRAINT fk_venta_servicio_estadia FOREIGN KEY (estadia_id) REFERENCES estadia (id),
  CONSTRAINT fk_venta_servicio_servicio FOREIGN KEY (servicio_id) REFERENCES servicio (id),
  CONSTRAINT ck_venta_servicio_valores CHECK (cantidad > 0 AND valor_unitario >= 0 AND valor_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pre_factura (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  estadia_id BIGINT UNSIGNED NOT NULL,
  reserva_habitacion_id BIGINT UNSIGNED NOT NULL,
  cliente_id BIGINT UNSIGNED NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
  impuesto DECIMAL(12,2) NOT NULL DEFAULT 0,
  descuento DECIMAL(12,2) NOT NULL DEFAULT 0,
  total DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_pre_factura_estadia (estadia_id),
  KEY ix_pre_factura_reserva (reserva_habitacion_id),
  KEY ix_pre_factura_cliente (cliente_id),
  CONSTRAINT fk_pre_factura_estadia FOREIGN KEY (estadia_id) REFERENCES estadia (id),
  CONSTRAINT fk_pre_factura_reserva FOREIGN KEY (reserva_habitacion_id) REFERENCES reserva_habitacion (id),
  CONSTRAINT fk_pre_factura_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id),
  CONSTRAINT ck_pre_factura_valores CHECK (subtotal >= 0 AND impuesto >= 0 AND descuento >= 0 AND total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE factura (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id BIGINT UNSIGNED NOT NULL,
  estadia_id BIGINT UNSIGNED NOT NULL,
  numero_factura VARCHAR(60) NOT NULL,
  fecha_emision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
  impuesto DECIMAL(12,2) NOT NULL DEFAULT 0,
  descuento DECIMAL(12,2) NOT NULL DEFAULT 0,
  total DECIMAL(12,2) NOT NULL DEFAULT 0,
  estado_factura VARCHAR(40) NOT NULL DEFAULT 'EMITIDA',
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_factura_numero (numero_factura),
  UNIQUE KEY uk_factura_estadia (estadia_id),
  KEY ix_factura_cliente (cliente_id),
  CONSTRAINT fk_factura_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id),
  CONSTRAINT fk_factura_estadia FOREIGN KEY (estadia_id) REFERENCES estadia (id),
  CONSTRAINT ck_factura_valores CHECK (subtotal >= 0 AND impuesto >= 0 AND descuento >= 0 AND total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pago_parcial (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  reserva_habitacion_id BIGINT UNSIGNED NULL,
  factura_id BIGINT UNSIGNED NULL,
  metodo_pago_id BIGINT UNSIGNED NOT NULL,
  valor DECIMAL(12,2) NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  referencia_pago VARCHAR(120) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_pago_reserva (reserva_habitacion_id),
  KEY ix_pago_factura (factura_id),
  KEY ix_pago_metodo (metodo_pago_id),
  CONSTRAINT fk_pago_reserva FOREIGN KEY (reserva_habitacion_id) REFERENCES reserva_habitacion (id),
  CONSTRAINT fk_pago_factura FOREIGN KEY (factura_id) REFERENCES factura (id),
  CONSTRAINT fk_pago_metodo FOREIGN KEY (metodo_pago_id) REFERENCES metodo_pago (id),
  CONSTRAINT ck_pago_valor CHECK (valor > 0),
  CONSTRAINT ck_pago_origen CHECK (reserva_habitacion_id IS NOT NULL OR factura_id IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_compra (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  factura_id BIGINT UNSIGNED NOT NULL,
  producto_id BIGINT UNSIGNED NULL,
  servicio_id BIGINT UNSIGNED NULL,
  descripcion VARCHAR(255) NOT NULL,
  cantidad INT UNSIGNED NOT NULL,
  valor_unitario DECIMAL(12,2) NOT NULL,
  valor_total DECIMAL(12,2) NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_detalle_factura (factura_id),
  KEY ix_detalle_producto (producto_id),
  KEY ix_detalle_servicio (servicio_id),
  CONSTRAINT fk_detalle_factura FOREIGN KEY (factura_id) REFERENCES factura (id),
  CONSTRAINT fk_detalle_producto FOREIGN KEY (producto_id) REFERENCES producto (id),
  CONSTRAINT fk_detalle_servicio FOREIGN KEY (servicio_id) REFERENCES servicio (id),
  CONSTRAINT ck_detalle_valores CHECK (cantidad > 0 AND valor_unitario >= 0 AND valor_total >= 0),
  CONSTRAINT ck_detalle_item CHECK (producto_id IS NOT NULL OR servicio_id IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE seguimiento_producto (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  producto_id BIGINT UNSIGNED NOT NULL,
  tipo_movimiento VARCHAR(40) NOT NULL,
  cantidad INT UNSIGNED NOT NULL,
  fecha_movimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacion TEXT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_seguimiento_producto (producto_id, fecha_movimiento),
  CONSTRAINT fk_seguimiento_producto FOREIGN KEY (producto_id) REFERENCES producto (id),
  CONSTRAINT ck_seguimiento_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE disponibilidad_inventario (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  producto_id BIGINT UNSIGNED NULL,
  servicio_id BIGINT UNSIGNED NULL,
  cantidad_disponible INT NOT NULL DEFAULT 0,
  disponible TINYINT(1) NOT NULL DEFAULT 1,
  observacion VARCHAR(255) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_disponibilidad_inv_producto (producto_id),
  KEY ix_disponibilidad_inv_servicio (servicio_id),
  CONSTRAINT fk_disponibilidad_inv_producto FOREIGN KEY (producto_id) REFERENCES producto (id),
  CONSTRAINT fk_disponibilidad_inv_servicio FOREIGN KEY (servicio_id) REFERENCES servicio (id),
  CONSTRAINT ck_disponibilidad_inv_item CHECK (producto_id IS NOT NULL OR servicio_id IS NOT NULL),
  CONSTRAINT ck_disponibilidad_inv_cantidad CHECK (cantidad_disponible >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE promocion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  titulo VARCHAR(160) NOT NULL,
  descripcion TEXT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NULL,
  canal VARCHAR(60) NOT NULL,
  activa TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_promocion_fecha (fecha_inicio, fecha_fin)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE alerta (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id BIGINT UNSIGNED NULL,
  reserva_habitacion_id BIGINT UNSIGNED NULL,
  titulo VARCHAR(160) NOT NULL,
  mensaje TEXT NOT NULL,
  canal VARCHAR(60) NOT NULL,
  fecha_envio DATETIME NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_alerta_cliente (cliente_id),
  KEY ix_alerta_reserva (reserva_habitacion_id),
  CONSTRAINT fk_alerta_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id),
  CONSTRAINT fk_alerta_reserva FOREIGN KEY (reserva_habitacion_id) REFERENCES reserva_habitacion (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE termino_condicion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  titulo VARCHAR(160) NOT NULL,
  contenido TEXT NOT NULL,
  version VARCHAR(40) NOT NULL,
  fecha_vigencia DATE NOT NULL,
  obligatorio TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_termino_version (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fidelizacion_cliente (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id BIGINT UNSIGNED NOT NULL,
  nivel VARCHAR(60) NOT NULL DEFAULT 'BASICO',
  puntos INT UNSIGNED NOT NULL DEFAULT 0,
  fecha_ultima_interaccion DATETIME NULL,
  observacion TEXT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_fidelizacion_cliente (cliente_id),
  CONSTRAINT fk_fidelizacion_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mantenimiento_habitacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  habitacion_id BIGINT UNSIGNED NOT NULL,
  empleado_id BIGINT UNSIGNED NULL,
  tipo_mantenimiento VARCHAR(60) NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NULL,
  estado_mantenimiento VARCHAR(40) NOT NULL DEFAULT 'PENDIENTE',
  observacion TEXT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_mantenimiento_habitacion (habitacion_id, fecha_inicio, fecha_fin),
  KEY ix_mantenimiento_empleado (empleado_id),
  CONSTRAINT fk_mantenimiento_habitacion FOREIGN KEY (habitacion_id) REFERENCES habitacion (id),
  CONSTRAINT fk_mantenimiento_empleado FOREIGN KEY (empleado_id) REFERENCES empleado (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mantenimiento_uso (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  mantenimiento_habitacion_id BIGINT UNSIGNED NOT NULL,
  motivo_uso VARCHAR(160) NOT NULL,
  detalle_actividad TEXT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_mantenimiento_uso (mantenimiento_habitacion_id),
  CONSTRAINT fk_mantenimiento_uso_base FOREIGN KEY (mantenimiento_habitacion_id) REFERENCES mantenimiento_habitacion (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mantenimiento_remodelacion (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  mantenimiento_habitacion_id BIGINT UNSIGNED NOT NULL,
  descripcion_remodelacion TEXT NOT NULL,
  presupuesto_estimado DECIMAL(12,2) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_mantenimiento_remodelacion (mantenimiento_habitacion_id),
  CONSTRAINT fk_mantenimiento_remodelacion_base FOREIGN KEY (mantenimiento_habitacion_id) REFERENCES mantenimiento_habitacion (id),
  CONSTRAINT ck_mantenimiento_presupuesto CHECK (presupuesto_estimado IS NULL OR presupuesto_estimado >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dashboard_mantenimiento (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sede_id BIGINT UNSIGNED NOT NULL,
  total_habitacion INT UNSIGNED NOT NULL DEFAULT 0,
  habitacion_disponible INT UNSIGNED NOT NULL DEFAULT 0,
  habitacion_ocupada INT UNSIGNED NOT NULL DEFAULT 0,
  habitacion_mantenimiento INT UNSIGNED NOT NULL DEFAULT 0,
  fecha_corte DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  KEY ix_dashboard_mantenimiento_sede_fecha (sede_id, fecha_corte),
  CONSTRAINT fk_dashboard_mantenimiento_sede FOREIGN KEY (sede_id) REFERENCES sede (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuario_rol (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id BIGINT UNSIGNED NOT NULL,
  rol_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuario_rol (usuario_id, rol_id),
  CONSTRAINT fk_usuario_rol_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id),
  CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (rol_id) REFERENCES rol (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rol_permiso (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  rol_id BIGINT UNSIGNED NOT NULL,
  permiso_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_rol_permiso (rol_id, permiso_id),
  CONSTRAINT fk_rol_permiso_rol FOREIGN KEY (rol_id) REFERENCES rol (id),
  CONSTRAINT fk_rol_permiso_permiso FOREIGN KEY (permiso_id) REFERENCES permiso (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE modulo_vista (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  modulo_id BIGINT UNSIGNED NOT NULL,
  vista_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (id),
  UNIQUE KEY uk_modulo_vista (modulo_id, vista_id),
  CONSTRAINT fk_modulo_vista_modulo FOREIGN KEY (modulo_id) REFERENCES modulo (id),
  CONSTRAINT fk_modulo_vista_vista FOREIGN KEY (vista_id) REFERENCES vista (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
