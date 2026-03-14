CREATE DATABASE FaceId;
USE FaceId;

/* =========================
   USUARIO Y SEGURIDAD
========================= */

CREATE TABLE Usuario (
    id_Usuario INT IDENTITY PRIMARY KEY,
    nombreUsuario VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fechaNacimiento DATE,
    estadoCuenta VARCHAR(20) CHECK (estadoCuenta IN ('ACTIVA','INACTIVA')),
    fechaRegistro DATETIME DEFAULT GETDATE()
);

CREATE TABLE Credencial (
    id_Credencial INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    correo VARCHAR(150) UNIQUE NOT NULL,
    contrasenaHash VARCHAR(255) NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    intentosFallidos INT DEFAULT 0,
    fechaCreacion DATETIME DEFAULT GETDATE(),
    ultimaModificacion DATETIME,
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Politicas_Contrasenas (
    id_politica INT IDENTITY PRIMARY KEY,
    minLongitud INT,
    maxLongitud INT,
    requiereMayusculas BIT,
    requiereNumeros BIT,
    requiereSimbolos BIT,
    caducidadDias INT
);

CREATE TABLE RecuperacionContrasena (
    id_RecuperacionContrasena INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    token VARCHAR(255),
    fechaSolicitud DATETIME,
    fechaExpiracion DATETIME,
    usado BIT,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE SesionUsuario (
    id_SesionUsuario INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    fechaInicio DATETIME,
    fechaFin DATETIME,
    ipOrigen VARCHAR(50),
    estadoSesion VARCHAR(20) CHECK (estadoSesion IN ('ACTIVO','INACTIVO'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Auditoria (
    id_Auditoria INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    accion VARCHAR(100),
    fecha DATETIME,
    descripcion VARCHAR(255),
    ipOrigen VARCHAR(50),
    aplicacion VARCHAR(100),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Log_Errores (
    id_Error INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    fecha DATETIME,
    tipoError VARCHAR(100),
    descripcion VARCHAR(255),
    ipOrigen VARCHAR(50),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE BitacoraSistema (
    id_BitacoraSistema INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    accion VARCHAR(100),
    modulo VARCHAR(100),
    descripcion TEXT,
    fechaHora DATETIME,
    ipOrigen VARCHAR(50),
    resultado VARCHAR(20) CHECK (resultado IN ('EXITOSO','FALLIDO')),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE ConfiguracionUsuario (
    id_ConfiguracionUsuario INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    nombreConfiguracion VARCHAR(100),
    descripcion VARCHAR(255),
    notificacionesActivas BIT,
    modoOscuro BIT,
    fechaActualizacion DATETIME,
    idioma VARCHAR(20) CHECK (idioma IN ('ES','EN','ZH', 'HI')),
    temaDashboard VARCHAR(50),
    colorPrimario VARCHAR(50),
    colorSecundario VARCHAR(50),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

/* =========================
   ROLES Y PERMISOS
========================= */

CREATE TABLE Rol (
    id_Rol INT IDENTITY PRIMARY KEY,
    nombreRol VARCHAR(20) CHECK (nombreRol IN ('APRENDIZ','INSTRUCTOR','ADMINISTRADOR'))
);

CREATE TABLE Permisos (
    id_Permiso INT IDENTITY PRIMARY KEY,
    nombrePermiso VARCHAR(100),
    descripcion VARCHAR(255)
);

CREATE TABLE Usuario_Rol (
    id_Usuario INT,
    id_Rol INT,
    fechaAsignacion DATE,
    PRIMARY KEY (id_Usuario, id_Rol),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Rol) REFERENCES Rol(id_Rol)
);

CREATE TABLE Rol_Permiso (
    id_Rol INT,
    id_Permiso INT,
    fechaAsignacion DATE,
    PRIMARY KEY (id_Rol, id_Permiso),
    FOREIGN KEY (id_Rol) REFERENCES Rol(id_Rol),
    FOREIGN KEY (id_Permiso) REFERENCES Permisos(id_Permiso)
);

/* =========================
   GESTION ACADEMICA
========================= */

CREATE TABLE Programa (
    id_Programa INT IDENTITY PRIMARY KEY,
    nombrePrograma VARCHAR(100),
    codigo VARCHAR(50),
    nivel VARCHAR(20) CHECK (nivel IN ('TECNICO','TECNOLOGO')),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE Ficha (
    id_Ficha INT IDENTITY PRIMARY KEY,
    id_Programa INT,
    codigoFicha VARCHAR(50),
    nombreFicha VARCHAR(100),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    jornada VARCHAR(50),
    FOREIGN KEY (id_Programa) REFERENCES Programa(id_Programa)
);

CREATE TABLE Ficha_Usuario (
    id_Ficha INT IDENTITY(1,1) PRIMARY KEY,
    id_Usuario INT NOT NULL,
    fechaAsignacion DATE NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

/* =========================
   GESTION DE AMBIENTES
========================= */

CREATE TABLE Ambiente (
    id_Ambiente INT IDENTITY PRIMARY KEY,
    codigoAmbiente VARCHAR(50),
    nombreAmbiente VARCHAR(100),
    capacidad INT,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE Ficha_Ambiente (
    id_Ficha INT,
    id_Ambiente INT,
    fechaAsignacion DATE,
    activa VARCHAR(10),
    PRIMARY KEY (id_Ficha, id_Ambiente),
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE RestriccionAmbiente (
    id_Restriccion INT IDENTITY PRIMARY KEY,
    id_Ambiente INT,
    tipoRestriccion VARCHAR(20) CHECK (tipoRestriccion IN ('TEMPORAL','INDEFINIDA')),
    fechaInicio DATE,
    fechaFin DATE,
    motivo VARCHAR(255),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE ExcepcionAmbiente (
    id_Excepcion INT IDENTITY PRIMARY KEY,
    id_Ambiente INT,
    id_Ficha INT,
    fechaExcepcion DATE,
    motivo VARCHAR(255),
    descripcion TEXT,
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente),
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha)
);

/* =========================
   GESTION DE HORARIOS
========================= */

CREATE TABLE Horario (
    id_Horario INT IDENTITY PRIMARY KEY,
    id_Ficha INT,
    diaSemana VARCHAR(20),
    horaInicio TIME,
    horaFin TIME,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    fechaCreacion DATE,
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha)
);

CREATE TABLE Horario_Instructor (
    id_HorarioInstructor INT IDENTITY PRIMARY KEY,
    id_Horario INT,
    id_Usuario INT,
    activo VARCHAR,
    FOREIGN KEY (id_Horario) REFERENCES Horario(id_Horario),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Horario_Ambiente (
    id_Horario INT,
    id_Ambiente INT,
    PRIMARY KEY (id_Horario, id_Ambiente),
    FOREIGN KEY (id_Horario) REFERENCES Horario(id_Horario),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE ExcepcionHorario (
    id_ExcepcionHorario INT IDENTITY PRIMARY KEY,
    id_Horario INT,
    fecha DATE,
    motivo VARCHAR(255),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    fechaRegistro DATE,
    FOREIGN KEY (id_Horario) REFERENCES Horario(id_Horario)
);

/* =========================
   RECONOCIMIENTO FACIAL
========================= */

CREATE TABLE Dispositivo (
    id_Dispositivo INT IDENTITY PRIMARY KEY,
    codigoDispositivo VARCHAR(50),
    ubicacion VARCHAR(100),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    ipOrigen VARCHAR(50)
);

CREATE TABLE RostroUsuario (
    id_RostroUsuario INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    vectorBiometrico VARBINARY(MAX),
    fechaRegistro DATETIME,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','PENDIENTE','INACTIVO'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE EventoFacial (
    id_EventoFacial INT IDENTITY PRIMARY KEY,
    id_Usuario INT NULL,
    id_Ambiente INT,
    id_Ficha INT NULL,
    id_Dispositivo INT,
    fechaHora DATETIME,
    tipoEvento VARCHAR(20) CHECK (tipoEvento IN ('ENTRADA','DESCANSO','SALIDA')),
    resultado VARCHAR(20) CHECK (resultado IN ('RECONOCIDO','NO RECONOCIDO')),
    estadoEnvio VARCHAR(20) CHECK (estadoEnvio IN ('PENDIENTE','ENVIADO')),
    origen VARCHAR(20) CHECK (origen IN ('ONLINE','OFFLINE'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente),
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha),
    FOREIGN KEY (id_Dispositivo) REFERENCES Dispositivo(id_Dispositivo)
);

CREATE TABLE BitacoraBiometrica (
    id_Bitacora INT IDENTITY PRIMARY KEY,
    id_Evento INT,
    descripcion TEXT,
    fecha DATETIME,
    FOREIGN KEY (id_Evento) REFERENCES EventoFacial(id_EventoFacial)
);

/* =========================
   NOTIFICACIONES
========================= */

CREATE TABLE Notificaciones (
    id_Notificacion INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    id_Evento INT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('ALERTA','AVISO','RECORDATORIO')),
    titulo VARCHAR(100),
    mensaje VARCHAR(255),
    fechaHora DATETIME,
    estado VARCHAR(20) CHECK (estado IN ('LEIDA','NO LEIDA')),
    canal VARCHAR(20) CHECK (canal IN ('INTERNA','EMAIL','AMBOS')),
    origenEvento VARCHAR(20) CHECK (estado IN ('ASISTENCIA','ANOMALIA','HORARIO', 'SISTEMA')),
    prioridad VARCHAR(20),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Evento) REFERENCES EventoFacial(id_EventoFacial)
);

CREATE TABLE EnvioCorreo (
    id_EnvioCorreo INT IDENTITY PRIMARY KEY,
    id_Notificacion INT,
    correoDestino VARCHAR(150),
    fechaEnvio DATETIME,
    estadoEnvio VARCHAR(20) CHECK (estadoEnvio IN ('ENVIADO','PENDIENTE','ERROR')),
    intentos INT,
    FOREIGN KEY (id_Notificacion) REFERENCES Notificaciones(id_Notificacion)
);

/* =========================
   EXCUSAS
========================= */

CREATE TABLE Excusa (
    id_Excusa INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    fechaAusencia DATE,
    mensaje VARCHAR(255),
    archivoPDF VARCHAR(255),
    fechaEnvio DATETIME,
    estado VARCHAR(20) CHECK (estado IN ('PENDIENTE','APROVADA', 'RECHAZADA')),
    revisadoPor VARCHAR(100),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

/* =========================
   GESTION LEGAL
========================= */
CREATE TABLE TerminosCondiciones (
    id_Terminos INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    textoTerminos TEXT NOT NULL
);

CREATE TABLE AceptacionTerminos (
    id_Aceptacion INT IDENTITY(1,1) PRIMARY KEY,
    id_Usuario INT NOT NULL,
    id_Terminos INT NOT NULL,
    aceptado VARCHAR(10) NOT NULL,
    fechaAceptacion DATETIME NOT NULL,
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Terminos) REFERENCES TerminosCondiciones(id_Terminos)
);

CREATE TABLE Acudiente (
    id_Acudiente INT IDENTITY(1,1) PRIMARY KEY,
    nombreCompleto VARCHAR(150) NOT NULL,
    documentoIdentidad VARCHAR(50) NOT NULL
);

CREATE TABLE Consentimiento (
    id_Consentimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_Usuario INT NOT NULL,
    id_Acudiente INT NULL,
    menorEdad BIT NOT NULL,
    consentimientoAdulto BIT NOT NULL,
    fechaAceptacion DATETIME NOT NULL,
    validadoAdmin BIT NOT NULL,
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Acudiente) REFERENCES Acudiente(id_Acudiente)
);

 -- eliminar las tablas

DROP TABLE EnvioCorreo;
DROP TABLE Notificaciones;
DROP TABLE BitacoraBiometrica;
DROP TABLE EventoFacial;
DROP TABLE RostroUsuario;
DROP TABLE Dispositivo;

DROP TABLE ExcepcionHorario;
DROP TABLE Horario_Ambiente;
DROP TABLE Horario_Instructor;
DROP TABLE Horario;

DROP TABLE ExcepcionAmbiente;
DROP TABLE RestriccionAmbiente;
DROP TABLE Ficha_Ambiente;
DROP TABLE Ambiente;

DROP TABLE Ficha_Usuario;
DROP TABLE Ficha;
DROP TABLE Programa;

DROP TABLE Rol_Permiso;
DROP TABLE Usuario_Rol;
DROP TABLE Permisos;
DROP TABLE Rol;

DROP TABLE ConfiguracionUsuario;
DROP TABLE BitacoraSistema;
DROP TABLE Log_Errores;
DROP TABLE Auditoria;
DROP TABLE SesionUsuario;
DROP TABLE RecuperacionContrasena;
DROP TABLE Politicas_Contrasenas;
DROP TABLE Credencial;
DROP TABLE Usuario;


-- vaciar tablas

TRUNCATE TABLE Usuario;
TRUNCATE TABLE Credencial;
TRUNCATE TABLE Politicas_Contrasenas;
TRUNCATE TABLE RecuperacionContrasena;
TRUNCATE TABLE SesionUsuario;
TRUNCATE TABLE Auditoria;
TRUNCATE TABLE Log_Errores;
TRUNCATE TABLE BitacoraSistema;
TRUNCATE TABLE ConfiguracionUsuario;

TRUNCATE TABLE Rol;
TRUNCATE TABLE Permisos;
TRUNCATE TABLE Usuario_Rol;
TRUNCATE TABLE Rol_Permiso;

TRUNCATE TABLE Programa;
TRUNCATE TABLE Ficha;
TRUNCATE TABLE Ficha_Usuario;

TRUNCATE TABLE Ambiente;
TRUNCATE TABLE Ficha_Ambiente;
TRUNCATE TABLE RestriccionAmbiente;
TRUNCATE TABLE ExcepcionAmbiente;

TRUNCATE TABLE Horario;
TRUNCATE TABLE Horario_Instructor;
TRUNCATE TABLE Horario_Ambiente;
TRUNCATE TABLE ExcepcionHorario;

TRUNCATE TABLE Dispositivo;
TRUNCATE TABLE RostroUsuario;
TRUNCATE TABLE EventoFacial;
TRUNCATE TABLE BitacoraBiometrica;

TRUNCATE TABLE Notificaciones;
TRUNCATE TABLE EnvioCorreo;

TRUNCATE TABLE Excusa;

TRUNCATE TABLE TerminosCondiciones;
TRUNCATE TABLE AceptacionTerminos;
TRUNCATE TABLE Acudiente;
TRUNCATE TABLE Consentimiento;

--  Alterara

ALTER TABLE Usuario
ADD telefono VARCHAR(20);

ALTER TABLE Usuario
ALTER COLUMN nombreUsuario VARCHAR(150);

ALTER TABLE Usuario
DROP COLUMN telefono;

ALTER TABLE Credencial
ADD CONSTRAINT FK_Credencial_Usuario
FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario);


/* =========================
5 VISTAS
========================= */

--Usuarios con sus credenciales activas
CREATE VIEW vw_UsuariosCredencialesActivas AS
SELECT 
    u.id_Usuario,
    u.nombreUsuario,
    u.apellido,
    c.correo,
    c.estado
FROM Usuario u
JOIN Credencial c ON u.id_Usuario = c.id_Usuario
WHERE c.estado = 'ACTIVO';

--Horarios activos por ficha y programa
CREATE VIEW vw_HorariosActivos AS
SELECT 
    p.nombrePrograma,
    f.nombreFicha,
    h.diaSemana,
    h.horaInicio,
    h.horaFin
FROM Programa p
JOIN Ficha f ON p.id_Programa = f.id_Programa
JOIN Horario h ON f.id_Ficha = h.id_Ficha
WHERE h.estado = 'ACTIVO';

--Eventos faciales reconocidos
CREATE VIEW vw_EventosFacialesReconocidos AS
SELECT 
    e.id_EventoFacial,
    u.nombreUsuario,
    a.nombreAmbiente,
    e.tipoEvento,
    e.fechaHora
FROM EventoFacial e
JOIN Usuario u ON e.id_Usuario = u.id_Usuario
JOIN Ambiente a ON e.id_Ambiente = a.id_Ambiente
WHERE e.resultado = 'RECONOCIDO';

--Excusas pendientes con información del usuario
CREATE VIEW vw_ExcusasPendientes AS
SELECT 
    u.nombreUsuario,
    u.apellido,
    ex.fechaAusencia,
    ex.mensaje,
    ex.estado
FROM Excusa ex
JOIN Usuario u ON ex.id_Usuario = u.id_Usuario
WHERE ex.estado = 'PENDIENTE';

--Notificaciones no leidas 
CREATE VIEW vw_NotificacionesNoLeidas AS
SELECT 
    u.nombreUsuario,
    n.titulo,
    n.tipo,
    n.fechaHora
FROM Notificaciones n
JOIN Usuario u ON n.id_Usuario = u.id_Usuario
WHERE n.estado = 'NO LEIDA';

/* =========================
5 PROCEDIMIENTOS ALMACENADOS INVOLUCRANDO 3 TABLAS 
========================= */

--Obtener usuarios activos con su correo y rol
CREATE PROCEDURE sp_UsuariosActivosConRol
AS
BEGIN
    SELECT 
        u.id_Usuario,
        u.nombreUsuario,
        u.apellido,
        c.correo,
        r.nombreRol
    FROM Usuario u
    JOIN Credencial c ON u.id_Usuario = c.id_Usuario
    JOIN Usuario_Rol ur ON u.id_Usuario = ur.id_Usuario
    JOIN Rol r ON ur.id_Rol = r.id_Rol
    WHERE u.estadoCuenta = 'ACTIVA';
END;

--Listar eventos faciales reconocidos por ambiente
CREATE PROCEDURE sp_EventosReconocidosPorAmbiente
    @idAmbiente INT
AS
BEGIN
    SELECT 
        e.id_EventoFacial,
        u.nombreUsuario,
        e.tipoEvento,
        e.fechaHora
    FROM EventoFacial e
    JOIN Usuario u ON e.id_Usuario = u.id_Usuario
    JOIN Ambiente a ON e.id_Ambiente = a.id_Ambiente
    WHERE e.resultado = 'RECONOCIDO'
      AND a.id_Ambiente = @idAmbiente;
END;

--Obtener horarios activos de una ficha con su programa
CREATE PROCEDURE sp_HorariosActivosPorFicha
    @idFicha INT
AS
BEGIN
    SELECT 
        p.nombrePrograma,
        f.nombreFicha,
        h.diaSemana,
        h.horaInicio,
        h.horaFin
    FROM Horario h
    JOIN Ficha f ON h.id_Ficha = f.id_Ficha
    JOIN Programa p ON f.id_Programa = p.id_Programa
    WHERE h.estado = 'ACTIVO'
      AND f.id_Ficha = @idFicha;
END;

--Listar notificaciones no leídas por usuario
CREATE PROCEDURE sp_NotificacionesNoLeidasUsuario
    @idUsuario INT
AS
BEGIN
    SELECT 
        n.titulo,
        n.tipo,
        e.tipoEvento,
        n.fechaHora
    FROM Notificaciones n
    JOIN Usuario u ON n.id_Usuario = u.id_Usuario
    JOIN EventoFacial e ON n.id_Evento = e.id_EventoFacial
    WHERE u.id_Usuario = @idUsuario
      AND n.estado = 'NO LEIDA';
END;

--Consultar excusas por estado con datos del usuario
CREATE PROCEDURE sp_ExcusasPorEstado
    @estadoExcusa VARCHAR(20)
AS
BEGIN
    SELECT 
        u.nombreUsuario,
        u.apellido,
        ex.fechaAusencia,
        ex.mensaje,
        ex.estado
    FROM Excusa ex
    JOIN Usuario u ON ex.id_Usuario = u.id_Usuario
    JOIN Ficha_Usuario fu ON u.id_Usuario = fu.id_Usuario
    WHERE ex.estado = @estadoExcusa;
END;


/* =========================
5 TRIGGERS 
========================= */

--Actualizar estado del usuario cuando se bloquea la credencial
CREATE TRIGGER trg_BloquearUsuarioPorCredencial
ON Credencial
AFTER UPDATE
AS
BEGIN
    UPDATE u
    SET u.estadoCuenta = 'BLOQUEADA'
    FROM Usuario u
    JOIN inserted i ON u.id_Usuario = i.id_Usuario
    WHERE i.intentosFallidos >= 3;
END;

--Registrar auditoría cuando se inserta una sesión 
CREATE TRIGGER trg_AuditoriaInicioSesion
ON SesionUsuario
AFTER INSERT
AS
BEGIN
    INSERT INTO Auditoria (id_Usuario, accion, fecha, descripcion, ipOrigen)
    SELECT 
        i.id_Usuario,
        'INICIO SESION',
        GETDATE(),
        'Inicio de sesión del usuario',
        i.ipOrigen
    FROM inserted i;
END;

--Actualizar fecha de mofificación de la credencial
CREATE TRIGGER trg_FechaModificacionCredencial
ON Credencial
AFTER UPDATE
AS
BEGIN
    UPDATE c
    SET ultimaModificacion = GETDATE()
    FROM Credencial c
    JOIN inserted i ON c.id_Credencial = i.id_Credencial;
END;

--Registrar bitácora cuando ocurre un evento facial
CREATE TRIGGER trg_BitacoraEventoFacial
ON EventoFacial
AFTER INSERT
AS
BEGIN
    INSERT INTO BitacoraBiometrica (id_Evento, descripcion, fecha)
    SELECT 
        i.id_EventoFacial,
        'Evento facial registrado',
        GETDATE()
    FROM inserted i;
END;

--Marcar notificación como crítica si el evento no es reconocido 
CREATE TRIGGER trg_NotificacionEventoNoReconocido
ON EventoFacial
AFTER INSERT
AS
BEGIN
    INSERT INTO Notificaciones (
        id_Usuario,
        id_Evento,
        tipo,
        titulo,
        mensaje,
        fechaHora,
        estado,
        canal,
        prioridad
    )
    SELECT 
        i.id_Usuario,
        i.id_EventoFacial,
        'ALERTA',
        'Evento no reconocido',
        'Se detectó un evento facial no reconocido',
        GETDATE(),
        'NO LEIDA',
        'INTERNA',
        'ALTA'
    FROM inserted i
    WHERE i.resultado = 'NO RECONOCIDO';
END;


