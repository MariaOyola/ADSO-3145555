USE FaceIdv1;

/*
=========================
USUARIO Y SEGURIDAD
=========================
*/

INSERT INTO Usuario (nombreUsuario, apellido, fechaNacimiento, estadoCuenta)
VALUES
('Juan','Perez','2000-01-10','ACTIVA'),
('Maria','Gomez','1999-05-12','ACTIVA'),
('Carlos','Lopez','2001-03-22','ACTIVA'),
('Ana','Martinez','1998-07-30','INACTIVA'),
('Luis','Torres','2002-11-18','ACTIVA'),
('Laura','Ramirez','2000-09-05','ACTIVA'),
('Pedro','Sanchez','1997-02-14','BLOQUEADA'),
('Sofia','Diaz','2001-06-25','ACTIVA'),
('Andres','Moreno','1999-12-01','ACTIVA'),
('Valentina','Rojas','2003-04-09','ACTIVA');

INSERT INTO Credencial (id_Usuario, correo, contrasenaHash, estado)
VALUES
(1,'juan@mail.com','hash1','ACTIVO'),
(2,'maria@mail.com','hash2','ACTIVO'),
(3,'carlos@mail.com','hash3','ACTIVO'),
(4,'ana@mail.com','hash4','INACTIVO'),
(5,'luis@mail.com','hash5','ACTIVO'),
(6,'laura@mail.com','hash6','ACTIVO'),
(7,'pedro@mail.com','hash7','INACTIVO'),
(8,'sofia@mail.com','hash8','ACTIVO'),
(9,'andres@mail.com','hash9','ACTIVO'),
(10,'vale@mail.com','hash10','ACTIVO');

INSERT INTO Politicas_Contrasenas
(minLongitud, maxLongitud, requiereMayusculas, requiereNumeros, requiereSimbolos, caducidadDias)
VALUES
(8,16,1,1,1,90),(8,20,1,1,0,180),(10,25,1,1,1,60),(6,12,0,1,0,120),
(8,18,1,0,0,90),(10,20,1,1,1,30),(8,15,0,1,1,180),
(12,30,1,1,1,365),(8,16,1,0,1,90),(6,10,0,0,0,0);

INSERT INTO RecuperacionContrasena
(id_Usuario, token, fechaSolicitud, fechaExpiracion, usado, estado)
VALUES
(1,'tok1',GETDATE(),DATEADD(HOUR,1,GETDATE()),0,'ACTIVO'),
(2,'tok2',GETDATE(),DATEADD(HOUR,1,GETDATE()),1,'INACTIVO'),
(3,'tok3',GETDATE(),DATEADD(HOUR,2,GETDATE()),0,'ACTIVO'),
(4,'tok4',GETDATE(),DATEADD(HOUR,2,GETDATE()),1,'INACTIVO'),
(5,'tok5',GETDATE(),DATEADD(HOUR,1,GETDATE()),0,'ACTIVO'),
(6,'tok6',GETDATE(),DATEADD(HOUR,1,GETDATE()),0,'ACTIVO'),
(7,'tok7',GETDATE(),DATEADD(HOUR,1,GETDATE()),1,'INACTIVO'),
(8,'tok8',GETDATE(),DATEADD(HOUR,1,GETDATE()),0,'ACTIVO'),
(9,'tok9',GETDATE(),DATEADD(HOUR,1,GETDATE()),0,'ACTIVO'),
(10,'tok10',GETDATE(),DATEADD(HOUR,1,GETDATE()),0,'ACTIVO');

INSERT INTO SesionUsuario
(id_Usuario, fechaInicio, fechaFin, ipOrigen, estadoSesion)
VALUES
(1,GETDATE(),NULL,'192.168.1.1','ACTIVA'),
(2,GETDATE(),NULL,'192.168.1.2','ACTIVA'),
(3,GETDATE(),NULL,'192.168.1.3','ACTIVA'),
(4,GETDATE(),GETDATE(),'192.168.1.4','CERRADA'),
(5,GETDATE(),NULL,'192.168.1.5','ACTIVA'),
(6,GETDATE(),NULL,'192.168.1.6','ACTIVA'),
(7,GETDATE(),GETDATE(),'192.168.1.7','CERRADA'),
(8,GETDATE(),NULL,'192.168.1.8','ACTIVA'),
(9,GETDATE(),NULL,'192.168.1.9','ACTIVA'),
(10,GETDATE(),NULL,'192.168.1.10','ACTIVA');

INSERT INTO Auditoria
(id_Usuario, accion, fecha, descripcion, ipOrigen, aplicacion)
VALUES
(1,'LOGIN',GETDATE(),'Inicio sesi n','192.168.1.1','WEB'),
(2,'LOGOUT',GETDATE(),'Cierre sesi n','192.168.1.2','WEB'),
(3,'UPDATE',GETDATE(),'Actualiz  datos','192.168.1.3','WEB'),
(4,'LOGIN',GETDATE(),'Inicio sesi n','192.168.1.4','MOVIL'),
(5,'LOGIN',GETDATE(),'Inicio sesi n','192.168.1.5','WEB'),
(6,'LOGIN',GETDATE(),'Inicio sesi n','192.168.1.6','WEB'),
(7,'ERROR',GETDATE(),'Error acceso','192.168.1.7','WEB'),
(8,'LOGIN',GETDATE(),'Inicio sesi n','192.168.1.8','MOVIL'),
(9,'LOGIN',GETDATE(),'Inicio sesi n','192.168.1.9','WEB'),
(10,'LOGIN',GETDATE(),'Inicio sesi n','192.168.1.10','WEB');

INSERT INTO Log_Errores
(id_Usuario, fecha, tipoError, descripcion, ipOrigen)
VALUES
(1,GETDATE(),'AUTH','Clave incorrecta','192.168.1.1'),
(2,GETDATE(),'AUTH','Usuario inactivo','192.168.1.2'),
(3,GETDATE(),'SYS','Error sistema','192.168.1.3'),
(4,GETDATE(),'NET','Error red','192.168.1.4'),
(5,GETDATE(),'AUTH','Clave incorrecta','192.168.1.5'),
(6,GETDATE(),'SYS','Timeout','192.168.1.6'),
(7,GETDATE(),'AUTH','Bloqueado','192.168.1.7'),
(8,GETDATE(),'NET','Error red','192.168.1.8'),
(9,GETDATE(),'SYS','Error interno','192.168.1.9'),
(10,GETDATE(),'AUTH','Clave incorrecta','192.168.1.10');

INSERT INTO BitacoraSistema
(id_Usuario, accion, modulo, descripcion, fechaHora, ipOrigen, resultado)
VALUES
(1,'LOGIN','SEGURIDAD','Ingreso exitoso',GETDATE(),'192.168.1.1','EXITOSO'),
(2,'LOGIN','SEGURIDAD','Ingreso exitoso',GETDATE(),'192.168.1.2','EXITOSO'),
(3,'UPDATE','USUARIO','Cambio datos',GETDATE(),'192.168.1.3','EXITOSO'),
(4,'LOGIN','SEGURIDAD','Fallo login',GETDATE(),'192.168.1.4','FALLIDO'),
(5,'LOGIN','SEGURIDAD','Ingreso exitoso',GETDATE(),'192.168.1.5','EXITOSO'),
(6,'LOGIN','SEGURIDAD','Ingreso exitoso',GETDATE(),'192.168.1.6','EXITOSO'),
(7,'LOGIN','SEGURIDAD','Cuenta bloqueada',GETDATE(),'192.168.1.7','FALLIDO'),
(8,'LOGIN','SEGURIDAD','Ingreso exitoso',GETDATE(),'192.168.1.8','EXITOSO'),
(9,'LOGIN','SEGURIDAD','Ingreso exitoso',GETDATE(),'192.168.1.9','EXITOSO'),
(10,'LOGIN','SEGURIDAD','Ingreso exitoso',GETDATE(),'192.168.1.10','EXITOSO');

INSERT INTO ConfiguracionUsuario
(id_Usuario, nombreConfiguracion, descripcion, notificacionesActivas, modoOscuro,
fechaActualizacion, idioma, temaDashboard, colorPrimario, colorSecundario)
VALUES
(1,'Default','Config b sica',1,1,GETDATE(),'ES','CLARO','AZUL','BLANCO'),
(2,'Default','Config b sica',1,0,GETDATE(),'ES','OSCURO','NEGRO','GRIS'),
(3,'Default','Config b sica',1,1,GETDATE(),'EN','CLARO','AZUL','BLANCO'),
(4,'Default','Config b sica',0,0,GETDATE(),'ES','CLARO','VERDE','BLANCO'),
(5,'Default','Config b sica',1,1,GETDATE(),'EN','OSCURO','NEGRO','ROJO'),
(6,'Default','Config b sica',1,1,GETDATE(),'ES','CLARO','AZUL','BLANCO'),
(7,'Default','Config b sica',0,0,GETDATE(),'ES','OSCURO','NEGRO','GRIS'),
(8,'Default','Config b sica',1,1,GETDATE(),'ZH','CLARO','ROJO','BLANCO'),
(9,'Default','Config b sica',1,1,GETDATE(),'HI','CLARO','NARANJA','BLANCO'),
(10,'Default','Config b sica',1,1,GETDATE(),'ES','OSCURO','NEGRO','AZUL');

/* 
=========================
ROLES Y PERMISOS
=========================
*/

INSERT INTO Rol (nombreRol)
VALUES ('APRENDIZ'),('INSTRUCTOR'),('ADMINISTRADOR');

INSERT INTO Permisos (nombrePermiso, descripcion)
VALUES
('VER_ASISTENCIA','Puede ver asistencia'),
('REGISTRAR_ASISTENCIA','Registrar asistencia'),
('EDITAR_USUARIOS','Editar usuarios'),
('ELIMINAR_USUARIOS','Eliminar usuarios'),
('VER_REPORTES','Ver reportes'),
('CONFIGURAR_SISTEMA','Configurar sistema'),
('VER_HORARIOS','Ver horarios'),
('EDITAR_HORARIOS','Editar horarios'),
('GESTION_AMBIENTES','Gestionar ambientes'),
('GESTION_PROGRAMAS','Gestionar programas');

INSERT INTO Usuario_Rol (id_Usuario, id_Rol, fechaAsignacion)
VALUES
(1,1,GETDATE()),(2,1,GETDATE()),(3,1,GETDATE()),
(4,2,GETDATE()),(5,2,GETDATE()),
(6,3,GETDATE()),(7,1,GETDATE()),
(8,1,GETDATE()),(9,2,GETDATE()),(10,1,GETDATE());

INSERT INTO Rol_Permiso (id_Rol, id_Permiso, fechaAsignacion)
VALUES
(1,1,GETDATE()),(1,7,GETDATE()),
(2,1,GETDATE()),(2,2,GETDATE()),(2,8,GETDATE()),
(3,1,GETDATE()),(3,2,GETDATE()),(3,3,GETDATE()),
(3,4,GETDATE()),(3,6,GETDATE());

/*
=========================
GESTI N ACAD MICA
=========================
*/

INSERT INTO Programa (nombrePrograma, codigo, nivel, estado)
VALUES
('Sistemas','SYS01','TECNICO','ACTIVO'),
('Software','SW01','TECNOLOGO','ACTIVO'),
('Redes','NET01','TECNICO','ACTIVO'),
('Datos','DATA01','TECNOLOGO','ACTIVO'),
('IA','IA01','TECNOLOGO','ACTIVO'),
('Web','WEB01','TECNICO','ACTIVO'),
('Movil','MOV01','TECNICO','ACTIVO'),
('Cloud','CLD01','TECNOLOGO','ACTIVO'),
('Ciberseguridad','SEC01','TECNOLOGO','ACTIVO'),
('Soporte','SUP01','TECNICO','ACTIVO');

INSERT INTO Ficha (id_Programa, codigoFicha, nombreFicha, estado, jornada)
VALUES
(1,'F001','Ficha 1','ACTIVO','DIURNA'),
(2,'F002','Ficha 2','ACTIVO','NOCTURNA'),
(3,'F003','Ficha 3','ACTIVO','DIURNA'),
(4,'F004','Ficha 4','ACTIVO','NOCTURNA'),
(5,'F005','Ficha 5','ACTIVO','DIURNA'),
(6,'F006','Ficha 6','ACTIVO','DIURNA'),
(7,'F007','Ficha 7','ACTIVO','NOCTURNA'),
(8,'F008','Ficha 8','ACTIVO','DIURNA'),
(9,'F009','Ficha 9','ACTIVO','NOCTURNA'),
(10,'F010','Ficha 10','ACTIVO','DIURNA');

INSERT INTO Ficha_Usuario (id_Usuario, fechaAsignacion, estado)
VALUES
(1,GETDATE(),'ACTIVO'),
(2,GETDATE(),'ACTIVO'),
(3,GETDATE(),'ACTIVO'),
(4,GETDATE(),'ACTIVO'),
(5,GETDATE(),'ACTIVO'),
(6,GETDATE(),'ACTIVO'),
(7,GETDATE(),'ACTIVO'),
(8,GETDATE(),'ACTIVO'),
(9,GETDATE(),'ACTIVO'),
(10,GETDATE(),'ACTIVO');

/*
=========================
GESTI N DE AMBIENTES
=========================
*/

INSERT INTO Ambiente (codigoAmbiente, nombreAmbiente, capacidad, estado)
VALUES
('A01','Laboratorio 1',30,'ACTIVO'),
('A02','Laboratorio 2',25,'ACTIVO'),
('A03','Sala 1',40,'ACTIVO'),
('A04','Sala 2',35,'ACTIVO'),
('A05','Auditorio',100,'ACTIVO'),
('A06','Lab Redes',20,'ACTIVO'),
('A07','Lab Software',25,'ACTIVO'),
('A08','Sala IA',20,'ACTIVO'),
('A09','Sala Cloud',20,'ACTIVO'),
('A10','Sala Seguridad',15,'ACTIVO');

INSERT INTO Ficha_Ambiente (id_Ficha, id_Ambiente, fechaAsignacion, activa)
VALUES
(1,1,GETDATE(),'SI'),
(2,2,GETDATE(),'SI'),
(3,3,GETDATE(),'SI'),
(4,4,GETDATE(),'SI'),
(5,5,GETDATE(),'SI'),
(6,6,GETDATE(),'SI'),
(7,7,GETDATE(),'SI'),
(8,8,GETDATE(),'SI'),
(9,9,GETDATE(),'SI'),
(10,10,GETDATE(),'SI');

INSERT INTO RestriccionAmbiente
(id_Ambiente, tipoRestriccion, fechaInicio, fechaFin, motivo)
VALUES
(1,'TEMPORAL','2026-01-01','2026-01-10','Mantenimiento'),
(2,'TEMPORAL','2026-01-05','2026-01-08','Limpieza'),
(3,'INDEFINIDA',NULL,NULL,'Da o'),
(4,'TEMPORAL','2026-01-03','2026-01-04','Evento'),
(5,'TEMPORAL','2026-01-07','2026-01-09','Auditor a'),
(6,'INDEFINIDA',NULL,NULL,'Reparaci n'),
(7,'TEMPORAL','2026-01-02','2026-01-05','Actualizaci n'),
(8,'TEMPORAL','2026-01-06','2026-01-07','Revisi n'),
(9,'TEMPORAL','2026-01-04','2026-01-06','Inventario'),
(10,'INDEFINIDA',NULL,NULL,'Clausura');

INSERT INTO ExcepcionAmbiente
(id_Ambiente, id_Ficha, fechaExcepcion, motivo, descripcion)
VALUES
(1,1,GETDATE(),'Clase especial','Uso autorizado'),
(2,2,GETDATE(),'Examen','Uso temporal'),
(3,3,GETDATE(),'Proyecto','Acceso especial'),
(4,4,GETDATE(),'Evento','Acceso controlado'),
(5,5,GETDATE(),'Capacitaci n','Uso autorizado'),
(6,6,GETDATE(),'Clase','Acceso especial'),
(7,7,GETDATE(),'Evaluaci n','Uso temporal'),
(8,8,GETDATE(),'Proyecto','Acceso especial'),
(9,9,GETDATE(),'Clase','Uso autorizado'),
(10,10,GETDATE(),'Evento','Acceso especial');

/*
=========================
GESTI N DE HORARIOS
=========================
*/

INSERT INTO Horario
(id_Ficha, diaSemana, horaInicio, horaFin, estado, fechaCreacion)
VALUES
(1,'LUNES','08:00','12:00','ACTIVO',GETDATE()),
(2,'MARTES','18:00','22:00','ACTIVO',GETDATE()),
(3,'MIERCOLES','08:00','12:00','ACTIVO',GETDATE()),
(4,'JUEVES','18:00','22:00','ACTIVO',GETDATE()),
(5,'VIERNES','08:00','12:00','ACTIVO',GETDATE()),
(6,'LUNES','14:00','18:00','ACTIVO',GETDATE()),
(7,'MARTES','14:00','18:00','ACTIVO',GETDATE()),
(8,'MIERCOLES','14:00','18:00','ACTIVO',GETDATE()),
(9,'JUEVES','08:00','12:00','ACTIVO',GETDATE()),
(10,'VIERNES','14:00','18:00','ACTIVO',GETDATE());

INSERT INTO Horario_Instructor (id_Horario, id_Usuario, activo)
VALUES
(1,4,1),(2,5,1),(3,9,1),(4,4,1),(5,5,1),
(6,9,1),(7,4,1),(8,5,1),(9,9,1),(10,4,1);

INSERT INTO Horario_Ambiente (id_Horario, id_Ambiente)
VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),
(6,6),(7,7),(8,8),(9,9),(10,10);

INSERT INTO ExcepcionHorario
(id_Horario, fecha, motivo, estado, fechaRegistro)
VALUES
(1,GETDATE(),'Festivo','ACTIVO',GETDATE()),
(2,GETDATE(),'Evento','ACTIVO',GETDATE()),
(3,GETDATE(),'Mantenimiento','ACTIVO',GETDATE()),
(4,GETDATE(),'Suspensi n','ACTIVO',GETDATE()),
(5,GETDATE(),'Cambio','ACTIVO',GETDATE()),
(6,GETDATE(),'Festivo','ACTIVO',GETDATE()),
(7,GETDATE(),'Evento','ACTIVO',GETDATE()),
(8,GETDATE(),'Mantenimiento','ACTIVO',GETDATE()),
(9,GETDATE(),'Suspensi n','ACTIVO',GETDATE()),
(10,GETDATE(),'Cambio','ACTIVO',GETDATE());

/*
=========================
RECONOCIMIENTO FACIAL
=========================
*/

INSERT INTO Dispositivo
(codigoDispositivo, ubicacion, estado, ipOrigen)
VALUES
('D01','Entrada 1','ACTIVO','10.0.0.1'),
('D02','Entrada 2','ACTIVO','10.0.0.2'),
('D03','Lab 1','ACTIVO','10.0.0.3'),
('D04','Lab 2','ACTIVO','10.0.0.4'),
('D05','Sala 1','ACTIVO','10.0.0.5'),
('D06','Sala 2','ACTIVO','10.0.0.6'),
('D07','Auditorio','ACTIVO','10.0.0.7'),
('D08','Redes','ACTIVO','10.0.0.8'),
('D09','IA','ACTIVO','10.0.0.9'),
('D10','Seguridad','ACTIVO','10.0.0.10');

INSERT INTO RostroUsuario
(id_Usuario, vectorBiometrico, fechaRegistro, estado)
VALUES
(1,0x01,GETDATE(),'ACTIVO'),
(2,0x02,GETDATE(),'ACTIVO'),
(3,0x03,GETDATE(),'ACTIVO'),
(4,0x04,GETDATE(),'PENDIENTE'),
(5,0x05,GETDATE(),'ACTIVO'),
(6,0x06,GETDATE(),'ACTIVO'),
(7,0x07,GETDATE(),'INACTIVO'),
(8,0x08,GETDATE(),'ACTIVO'),
(9,0x09,GETDATE(),'ACTIVO'),
(10,0x10,GETDATE(),'ACTIVO');

INSERT INTO EventoFacial
(id_Usuario, id_Ambiente, id_Ficha, id_Dispositivo, fechaHora,
 tipoEvento, resultado, estadoEnvio, origen)
VALUES
(1,1,1,1,GETDATE(),'ENTRADA','RECONOCIDO','ENVIADO','ONLINE'),
(2,2,2,2,GETDATE(),'ENTRADA','RECONOCIDO','ENVIADO','ONLINE'),
(3,3,3,3,GETDATE(),'ENTRADA','RECONOCIDO','ENVIADO','ONLINE'),
(4,4,4,4,GETDATE(),'ENTRADA','NO RECONOCIDO','PENDIENTE','OFFLINE'),
(5,5,5,5,GETDATE(),'DESCANSO','RECONOCIDO','ENVIADO','ONLINE'),
(6,6,6,6,GETDATE(),'ENTRADA','RECONOCIDO','ENVIADO','ONLINE'),
(7,7,7,7,GETDATE(),'ENTRADA','NO RECONOCIDO','PENDIENTE','OFFLINE'),
(8,8,8,8,GETDATE(),'SALIDA','RECONOCIDO','ENVIADO','ONLINE'),
(9,9,9,9,GETDATE(),'ENTRADA','RECONOCIDO','ENVIADO','ONLINE'),
(10,10,10,10,GETDATE(),'SALIDA','RECONOCIDO','ENVIADO','ONLINE');

INSERT INTO BitacoraBiometrica
(id_Evento, descripcion, fecha)
VALUES
(1,'Acceso correcto',GETDATE()),
(2,'Acceso correcto',GETDATE()),
(3,'Acceso correcto',GETDATE()),
(4,'Fallo reconocimiento',GETDATE()),
(5,'Pausa registrada',GETDATE()),
(6,'Acceso correcto',GETDATE()),
(7,'Fallo reconocimiento',GETDATE()),
(8,'Salida registrada',GETDATE()),
(9,'Acceso correcto',GETDATE()),
(10,'Salida registrada',GETDATE());

/*
=========================
NOTIFICACIONES
=========================
*/

INSERT INTO Notificaciones
(id_Usuario, id_Evento, tipo, titulo, mensaje, fechaHora,
 estado, canal, origenEvento, prioridad)
VALUES
(1,1,'AVISO','Ingreso','Ingreso registrado',GETDATE(),'NO LEIDA','INTERNA','ASISTENCIA','MEDIA'),
(2,2,'AVISO','Ingreso','Ingreso registrado',GETDATE(),'NO LEIDA','INTERNA','ASISTENCIA','MEDIA'),
(3,3,'AVISO','Ingreso','Ingreso registrado',GETDATE(),'LEIDA','EMAIL','ASISTENCIA','MEDIA'),
(4,4,'ALERTA','Error','No reconocido',GETDATE(),'NO LEIDA','AMBOS','ANOMALIA','ALTA'),
(5,5,'RECORDATORIO','Descanso','Descanso iniciado',GETDATE(),'LEIDA','INTERNA','ASISTENCIA','BAJA'),
(6,6,'AVISO','Ingreso','Ingreso registrado',GETDATE(),'NO LEIDA','EMAIL','ASISTENCIA','MEDIA'),
(7,7,'ALERTA','Error','No reconocido',GETDATE(),'NO LEIDA','AMBOS','ANOMALIA','ALTA'),
(8,8,'AVISO','Salida','Salida registrada',GETDATE(),'LEIDA','INTERNA','ASISTENCIA','MEDIA'),
(9,9,'AVISO','Ingreso','Ingreso registrado',GETDATE(),'NO LEIDA','EMAIL','ASISTENCIA','MEDIA'),
(10,10,'AVISO','Salida','Salida registrada',GETDATE(),'LEIDA','INTERNA','ASISTENCIA','MEDIA');

INSERT INTO EnvioCorreo
(id_Notificacion, correoDestino, fechaEnvio, estadoEnvio, intentos)
VALUES
(3,'carlos@mail.com',GETDATE(),'ENVIADO',1),
(4,'ana@mail.com',GETDATE(),'ENVIADO',2),
(6,'laura@mail.com',GETDATE(),'PENDIENTE',0),
(7,'pedro@mail.com',GETDATE(),'ERROR',3),
(9,'andres@mail.com',GETDATE(),'ENVIADO',1),
(1,'juan@mail.com',GETDATE(),'ENVIADO',1),
(2,'maria@mail.com',GETDATE(),'ENVIADO',1),
(5,'luis@mail.com',GETDATE(),'ENVIADO',1),
(8,'sofia@mail.com',GETDATE(),'ENVIADO',1),
(10,'vale@mail.com',GETDATE(),'ENVIADO',1);

/*
=========================
EXCUSAS
=========================
*/

INSERT INTO Excusa
(id_Usuario, fechaAusencia, mensaje, archivoPDF, fechaEnvio, estado, revisadoPor)
VALUES
(1,'2026-01-01','Cita m dica','exc1.pdf',GETDATE(),'PENDIENTE',NULL),
(2,'2026-01-02','Calamidad','exc2.pdf',GETDATE(),'APROVADA','Admin'),
(3,'2026-01-03','Enfermedad','exc3.pdf',GETDATE(),'RECHAZADA','Admin'),
(4,'2026-01-04','Viaje','exc4.pdf',GETDATE(),'PENDIENTE',NULL),
(5,'2026-01-05','Cita m dica','exc5.pdf',GETDATE(),'APROVADA','Admin'),
(6,'2026-01-06','Calamidad','exc6.pdf',GETDATE(),'PENDIENTE',NULL),
(7,'2026-01-07','Enfermedad','exc7.pdf',GETDATE(),'RECHAZADA','Admin'),
(8,'2026-01-08','Viaje','exc8.pdf',GETDATE(),'APROVADA','Admin'),
(9,'2026-01-09','Cita m dica','exc9.pdf',GETDATE(),'PENDIENTE',NULL),
(10,'2026-01-10','Calamidad','exc10.pdf',GETDATE(),'APROVADA','Admin');

/*
=========================
GESTI N LEGAL
=========================
*/

INSERT INTO TerminosCondiciones (tipo, textoTerminos)
VALUES
('GENERAL','T rminos generales'),
('BIOMETRIA','Uso de biometr a'),
('PRIVACIDAD','Pol tica privacidad'),
('ASISTENCIA','Control asistencia'),
('SISTEMA','Uso sistema'),
('SEGURIDAD','Seguridad datos'),
('ACCESO','Control acceso'),
('DATOS','Tratamiento datos'),
('LEGAL','Marco legal'),
('OTROS','Condiciones adicionales');

INSERT INTO AceptacionTerminos
(id_Usuario, id_Terminos, aceptado, fechaAceptacion)
VALUES
(1,1,'SI',GETDATE()),(2,2,'SI',GETDATE()),(3,3,'SI',GETDATE()),
(4,4,'SI',GETDATE()),(5,5,'SI',GETDATE()),(6,6,'SI',GETDATE()),
(7,7,'SI',GETDATE()),(8,8,'SI',GETDATE()),(9,9,'SI',GETDATE()),(10,10,'SI',GETDATE());

INSERT INTO Acudiente (nombreCompleto, documentoIdentidad)
VALUES
('Carlos Perez','1001'),
('Ana Gomez','1002'),
('Luis Lopez','1003'),
('Maria Torres','1004'),
('Pedro Ramirez','1005'),
('Laura Diaz','1006'),
('Jose Moreno','1007'),
('Claudia Rojas','1008'),
('Jorge Castro','1009'),
('Diana Vega','1010');

INSERT INTO Consentimiento
(id_Usuario, id_Acudiente, menorEdad, consentimientoAdulto, fechaAceptacion, validadoAdmin)
VALUES
(1,NULL,0,1,GETDATE(),1),
(2,NULL,0,1,GETDATE(),1),
(3,1,1,0,GETDATE(),1),
(4,2,1,0,GETDATE(),1),
(5,NULL,0,1,GETDATE(),1),
(6,NULL,0,1,GETDATE(),1),
(7,3,1,0,GETDATE(),1),
(8,NULL,0,1,GETDATE(),1),
(9,NULL,0,1,GETDATE(),1),
(10,4,1,0,GETDATE(),1);


-- Actualizar

UPDATE Usuario
SET estadoCuenta = 'INACTIVA'
WHERE id_Usuario = 3;

UPDATE Usuario
SET apellido = 'Rodriguez'
WHERE id_Usuario = 2;

UPDATE Credencial
SET estado = 'INACTIVO'
WHERE id_Usuario = 7;


UPDATE SesionUsuario
SET estadoSesion = 'INACTIVA',
    fechaFin = GETDATE()
WHERE id_Usuario = 1;


UPDATE ConfiguracionUsuario
SET modoOscuro = 0,
    idioma = 'EN'
WHERE id_Usuario = 3;


UPDATE Programa
SET estado = 'INACTIVO'
WHERE id_Programa = 6;


UPDATE Ambiente
SET capacidad = 50
WHERE id_Ambiente = 5;

UPDATE Horario
SET horaInicio = '09:00',
    horaFin = '13:00'
WHERE id_Horario = 1;

UPDATE EventoFacial
SET resultado = 'RECONOCIDO',
    estadoEnvio = 'ENVIADO'
WHERE id_EventoFacial = 4;

UPDATE Notificaciones
SET estado = 'LEIDA'
WHERE id_Usuario = 1;

UPDATE Excusa
SET estado = 'APROVADA',
    revisadoPor = 'Administrador'
WHERE id_Excusa = 1;


--- Eliminar registros

DELETE FROM Usuario
WHERE id_Usuario = 10;

DELETE FROM Credencial
WHERE id_Usuario = 10;

DELETE FROM SesionUsuario
WHERE id_Usuario = 7;

DELETE FROM Auditoria
WHERE accion = 'ERROR';

DELETE FROM Log_Errores
WHERE tipoError = 'NET';


DELETE FROM Horario
WHERE id_Horario = 10;

DELETE FROM EventoFacial
WHERE resultado = 'NO RECONOCIDO';

DELETE FROM Notificaciones
WHERE estado = 'LEIDA';

DELETE FROM Excusa
WHERE estado = 'RECHAZADA';


