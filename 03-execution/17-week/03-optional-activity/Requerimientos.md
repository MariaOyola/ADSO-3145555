# Requerimientos — Módulo 2: Estructura Institucional SENA

---

## Requerimientos No Funcionales (RNF)

Son las reglas de **cómo debe comportarse** el sistema, no qué hace sino cómo lo hace.

| Código | En simple |
|---|---|
| RNF-001 | Cada usuario solo puede ver y hacer lo que le corresponde según su rol |
| RNF-002 | Todo lo importante queda registrado: quién lo hizo, cuándo y qué cambió |
| RNF-003 | Cada microservicio tiene su propia base de datos, nadie toca la del otro |
| RNF-004 | Toda acción lleva un ID de rastreo para saber de dónde vino y a dónde fue |
| RNF-005 | El sistema registra errores, tiempos y actividad para detectar problemas |
| RNF-006 | Los datos personales (instructores, aprendices) están protegidos por ley |
| RNF-007 | Cuando se exporta un documento, queda registro de quién lo pidió y cuándo |
| RNF-008 | Cada servicio publica cómo funciona su API para que otros sepan cómo usarlo |
| RNF-009 | Cada microservicio tiene pruebas que verifican que su contrato se cumple |
| RNF-010 | El sistema se puede instalar localmente y en servidores de forma reproducible |

---

## Reglas del ecosistema agéntico

Son las **reglas de diseño** que todo el equipo debe respetar al construir el sistema.

| # | Regla | Por qué existe |
|---|---|---|
| 1 | No construir una nueva plataforma SOFIA Plus | SOFIA Plus ya existe; este sistema lo complementa |
| 2 | No mezclar fronteras de microservicios | Cada servicio hace una sola cosa y no invade el espacio del otro |
| 3 | No inventar campos, tablas ni reglas no confirmadas | Todo debe venir de una fuente oficial o del product owner |
| 4 | Antes de implementar, definir contrato, eventos y dependencias | Evita construir algo que luego no encaja con los demás |
| 5 | Los servicios solo se comunican por API o eventos | Nunca por acceso directo a bases de datos ajenas |
| 6 | El PDF worker solo renderiza, no contiene lógica de negocio | La lógica va en el servicio dueño del dato |
| 7 | El workflow-service no es dueño de datos, solo orquesta | Los datos viven en el servicio de dominio correspondiente |
| 8 | El scheduler-service no reemplaza al schedule-service | Scheduler ejecuta jobs en el tiempo; schedule gestiona horarios académicos |
| 9 | El tool-gateway-service no puede saltarse políticas | Toda herramienta externa pasa por sus reglas de seguridad |
| 10 | Todo agente debe dejar evidencia verificable de sus decisiones | Para auditoría y trazabilidad del sistema |

---

## Requerimientos Funcionales del proyecto

Son **qué debe hacer** el sistema. Los marcados con ★ pertenecen al Módulo 2.

| Código | Qué hace | Módulo |
|---|---|---|
| **RF-001** ★ | Gestionar regionales, centros, sedes y ambientes | **M2 — Tu módulo** |
| RF-002 | Gestionar instructores, aprendices, coordinadores y directivos | M7 Actores |
| RF-003 | Gestionar programas de formación y diseño curricular | M5 Programas |
| RF-004 | Relacionar competencias, RAP, evidencias y proyectos | M5 / M9 |
| RF-005 | Gestionar fichas y oferta formativa | M6 Oferta |
| RF-006 | Programar horarios por ficha, instructor, ambiente y periodo | M8 Horarios |
| RF-007 | Detectar conflictos de horario, ambiente e instructor | M8 Horarios |
| RF-008 | Registrar ejecución real de sesiones | M8 Horarios |
| RF-009 | Registrar asistencia, novedades e incidencias | M8 Horarios |
| RF-010 | Gestionar proyectos formativos, entregables e hitos | M9 Proyectos |
| RF-011 | Medir avance por aprendiz, ficha, RAP y evidencia | M6 / M9 |
| RF-012 | Generar reportes y documentos PDF | Infraestructura |
| RF-013 | Enviar notificaciones y alertas | Coordinación |
| RF-014 | Exponer eventos para integración y auditoría | Todos |
| RF-015 | Proveer tablero runtime de avance y desviaciones | Coordinación |

---

## RF-001 — Detalle completo (Mi módulo M2)

> ⚠️ Este es el único requerimiento funcional que pertenece directamente al Módulo 2.
> Sin embargo, **RF-006, RF-007 y RF-008 dependen de mis datos** para funcionar
> (los horarios siempre están atados a un lugar físico que yo gestiono).

---

| RF 1.1 | |
|---|---|
| **Versión** | 1.0 – (25/11/2025) |
| **Actor** | Administrador |
| **Fuentes** | Ley 119 de 1994 — Funciones del SENA |
| **Objetivos asociados** | Registrar y mantener la jerarquía institucional del SENA: regionales, centros de formación, sedes y ambientes. |
| **Descripción** | - Registrar macroregiones y microregiones del país. - Registrar centros de formación con tipo y código oficial. - Registrar unidades institucionales: sedes, tecnoacademias y tecnoparques. - Registrar ubicaciones con dirección y coordenadas geográficas. |
| **Precondición** | - El usuario debe tener rol Administrador. - Los catálogos de tipo de centro y tipo de unidad deben existir (M4). |

| **Secuencia Normal** | Pasos | Actor | Acción | Sistema |
|---|---|---|---|---|
| | 1 | Administrador | Selecciona el nivel a registrar (regional, centro o sede) | Muestra el formulario correspondiente |
| | 2 | Administrador | Ingresa los datos del registro | Valida que no existan duplicados |
| | 3 | Sistema | — | Guarda el registro |
| | 4 | Sistema | — | Confirma la creación y muestra el registro guardado |

| **Escenario Alternativo** | Pasos | Actor | Acción | Sistema |
|---|---|---|---|---|
| | 1 | Sistema | Registro duplicado | Mensaje: "Ya existe un registro con ese nombre o código" |
| | 2 | Sistema | Datos incompletos | Resalta los campos obligatorios faltantes |

| **Postcondiciones** | El registro queda disponible para ser consumido por M3, M7 y M8 vía API. |
|---|---|
| **Criterios de aceptación** | - Debe registrar la jerarquía completa: macroregión → microregión → centro → unidad. - No debe permitir duplicados por nombre o código. - Debe registrar quién creó o modificó cada registro y cuándo. - Los datos deben quedar expuestos vía API para otros módulos. |