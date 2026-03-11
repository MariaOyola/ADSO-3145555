USE FaceIdv1;

/*
=========================
5 CONSULTAS SENCILLAS INVOLUCRANDO UNA TABLA Y GENERANDO COLUMNAS CON OPERACIONES
=========================
*/

--Calcular años desde el registro
SELECT 
    id_Usuario,
    nombreUsuario,
    apellido,
    DATEDIFF(YEAR, fechaRegistro, GETDATE()) AS aniosRegistrado
FROM Usuario;

--Sumar intentos fallidos +1 (simulación de próximo intento)
SELECT 
    id_Credencial,
    correo,
    intentosFallidos,
    intentosFallidos + 1 AS proximoIntento
FROM Credencial;

--Duración de la sesión en minutos
SELECT 
    id_SesionUsuario,
    id_Usuario,
    DATEDIFF(MINUTE, fechaInicio, fechaFin) AS duracionMinutos
FROM SesionUsuario;

--Calcular capacidad restante suponiendo uso fijo 
SELECT 
    id_Ambiente,
    nombreAmbiente,
    capacidad,
    capacidad - 25 AS capacidadDisponible
FROM Ambiente;

--Extraer solo la fecha y la hora del evento facial 
SELECT 
    id_EventoFacial,
    id_Usuario,
    CAST(fechaHora AS DATE) AS fechaEvento,
    CAST(fechaHora AS TIME) AS horaEvento
FROM EventoFacial;

/*
=========================
5 CONSULTAS SENCILLAS INVOLUCRANDO 3 TABLAS
=========================
*/

//Mostrar usuario, correo y rol asignado
SELECT 
    u.nombreUsuario,
    u.apellido,
    c.correo,
    r.nombreRol
FROM Usuario u
JOIN Credencial c ON u.id_Usuario = c.id_Usuario
JOIN Usuario_Rol ur ON u.id_Usuario = ur.id_Usuario
JOIN Rol r ON ur.id_Rol = r.id_Rol;

--Duración de sesión y acción registrada 
SELECT 
    u.nombreUsuario,
    s.id_SesionUsuario,
    DATEDIFF(MINUTE, s.fechaInicio, s.fechaFin) AS duracionMinutos,
    a.accion
FROM Usuario u
JOIN SesionUsuario s ON u.id_Usuario = s.id_Usuario
JOIN Auditoria a ON u.id_Usuario = a.id_Usuario;

--Calcular horas de clase por horario 
SELECT 
    p.nombrePrograma,
    f.nombreFicha,
    DATEDIFF(HOUR, h.horaInicio, h.horaFin) AS horasClase
FROM Programa p
JOIN Ficha f ON p.id_Programa = f.id_Programa
JOIN Horario h ON f.id_Ficha = h.id_Ficha;

--Fecha del evento y ambiente
SELECT 
    u.nombreUsuario,
    e.tipoEvento,
    CAST(e.fechaHora AS DATE) AS fechaEvento,
    a.nombreAmbiente
FROM Usuario u
JOIN EventoFacial e ON u.id_Usuario = e.id_Usuario
JOIN Ambiente a ON e.id_Ambiente = a.id_Ambiente;

--Intentos de envío del correo
SELECT 
    u.nombreUsuario,
    n.titulo,
    e.intentos,
    e.intentos + 1 AS proximoIntento
FROM Usuario u
JOIN Notificaciones n ON u.id_Usuario = n.id_Usuario
JOIN EnvioCorreo e ON n.id_Notificacion = e.id_Notificacion;

/*
=========================
5 CONSULTAS CON FILTROS SOBRE UNA TABLA 
=========================
*/

--Usuarios con cuenta activa
SELECT 
    id_Usuario,
    nombreUsuario,
    apellido,
    estadoCuenta
FROM Usuario
WHERE estadoCuenta = 'ACTIVA';

--Credenciales con intentos fallidos mayores a 3
SELECT 
    correo,
    intentosFallidos
FROM Credencial
WHERE intentosFallidos > 3;

--Ambientes con capacidad mayor a 30
SELECT 
    nombreAmbiente,
    capacidad
FROM Ambiente
WHERE capacidad > 30;

--Sesiones iniciadas hoy
SELECT 
    id_SesionUsuario,
    id_Usuario,
    fechaInicio
FROM SesionUsuario
WHERE CAST(fechaInicio AS DATE) = CAST(GETDATE() AS DATE);

--Eventos faciales no reconocidos 
SELECT 
    id_EventoFacial,
    tipoEvento,
    resultado,
    fechaHora
FROM EventoFacial
WHERE resultado = 'NO RECONOCIDO';

/*
=========================
5 CONSULTAS CON FILTROS INVOLUCRANDO 4 TABLAS 
=========================
*/

--Usuarios activos con rol y correo
SELECT 
    u.nombreUsuario,
    u.apellido,
    c.correo,
    r.nombreRol
FROM Usuario u
JOIN Credencial c ON u.id_Usuario = c.id_Usuario
JOIN Usuario_Rol ur ON u.id_Usuario = ur.id_Usuario
JOIN Rol r ON ur.id_Rol = r.id_Rol
WHERE u.estadoCuenta = 'ACTIVA';

--Eventos faciales reconocidos en ambientes activos
SELECT 
    e.id_EventoFacial,
    u.nombreUsuario,
    a.nombreAmbiente,
    e.fechaHora
FROM EventoFacial e
JOIN Usuario u ON e.id_Usuario = u.id_Usuario
JOIN Ambiente a ON e.id_Ambiente = a.id_Ambiente
JOIN Dispositivo d ON e.id_Dispositivo = d.id_Dispositivo
WHERE e.resultado = 'RECONOCIDO'
  AND a.estado = 'ACTIVO';

--Horarios activos por ficha y programa
SELECT 
    p.nombrePrograma,
    f.nombreFicha,
    h.diaSemana,
    h.horaInicio,
    h.horaFin
FROM Programa p
JOIN Ficha f ON p.id_Programa = f.id_Programa
JOIN Horario h ON f.id_Ficha = h.id_Ficha
JOIN Horario_Instructor hi ON h.id_Horario = hi.id_Horario
WHERE h.estado = 'ACTIVO'
  AND hi.activo = 1;

--Notificaciones no leidas con usuario y evento
SELECT 
    u.nombreUsuario,
    n.titulo,
    n.tipo,
    e.tipoEvento
FROM Notificaciones n
JOIN Usuario u ON n.id_Usuario = u.id_Usuario
JOIN EventoFacial e ON n.id_Evento = e.id_EventoFacial
JOIN Ambiente a ON e.id_Ambiente = a.id_Ambiente
WHERE n.estado = 'NO LEIDA';

--Excusas pendientes con información del usuario
SELECT 
    u.nombreUsuario,
    u.apellido,
    ex.fechaAusencia,
    ex.estado
FROM Excusa ex
JOIN Usuario u ON ex.id_Usuario = u.id_Usuario
JOIN Ficha_Usuario fu ON u.id_Usuario = fu.id_Usuario
JOIN Ficha f ON fu.id_Ficha = f.id_Ficha
WHERE ex.estado = 'PENDIENTE';

/*
=========================
5 CONSULTAS CON SUBCONSULTAS Y FILTROS INVOLUCRANDO 3 TABLAS  
=========================
*/

--Usuarios con rol administrador y cuenta activa
SELECT 
    u.nombreUsuario,
    u.apellido
FROM Usuario u
WHERE u.estadoCuenta = 'ACTIVA'
AND u.id_Usuario IN (
    SELECT ur.id_Usuario
    FROM Usuario_Rol ur
    WHERE ur.id_Rol = (
        SELECT r.id_Rol
        FROM Rol r
        WHERE r.nombreRol = 'ADMINISTRADOR'
    )
);

--Eventos faciales reconocidos en ambientes activos
SELECT 
    e.id_EventoFacial,
    e.fechaHora,
    e.tipoEvento
FROM EventoFacial e
WHERE e.resultado = 'RECONOCIDO'
AND e.id_Ambiente IN (
    SELECT a.id_Ambiente
    FROM Ambiente a
    WHERE a.estado = 'ACTIVO'
);

--Usuarios que tienen credenciales activas
SELECT 
    u.nombreUsuario,
    u.apellido
FROM Usuario u
WHERE u.id_Usuario IN (
    SELECT c.id_Usuario
    FROM Credencial c
    WHERE c.estado = 'ACTIVO'
);

--Fichas que pertenecen a programas activos
SELECT 
    f.nombreFicha,
    f.codigoFicha
FROM Ficha f
WHERE f.id_Programa IN (
    SELECT p.id_Programa
    FROM Programa p
    WHERE p.estado = 'ACTIVO'
);

--Usuarios con excusas pendientes
SELECT 
    u.nombreUsuario,
    u.apellido
FROM Usuario u
WHERE u.id_Usuario IN (
    SELECT e.id_Usuario
    FROM Excusa e
    WHERE e.estado = 'PENDIENTE'
);

 

