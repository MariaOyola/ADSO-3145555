# Proyecto SENA — Trazabilidad Formativa

> Este sistema se **integra** con SOFIA Plus, no lo reemplaza.

---

## Microservicios por fase

### Fase 1 — P0 (construir primero)

| Servicio | Módulo | Para qué sirve |
|---|---|---|
| `auth-service` | Seguridad | Identidad, autenticación, roles y permisos |
| `control-plane-service` | Seguridad | Registro de proyectos, agentes, políticas y gobierno |
| `secrets-vault-service` | Seguridad | Guarda contraseñas, claves y tokens de forma segura |
| `audit-compliance-service` | Seguridad | Auditoría, trazabilidad normativa y cumplimiento |
| `workflow-service` | Coordinación | Director de orquesta: controla el orden de los pasos del proceso |
| `run-state-service` | Infraestructura | Tablero de seguimiento: dice en qué paso va cada proceso |
| `tool-gateway-service` | Infraestructura | Puerta de entrada a herramientas externas (APIs, buscadores) |
| `pdf-worker-service` | Infraestructura | Procesa PDFs: los lee, saca el texto y genera reportes |
| `artifact-store-service` | Infraestructura | Gestiona evidencias, documentos y versiones |
| `memory-service` | Infraestructura | Le da memoria a los agentes de IA entre sesiones |
| `observability-service` | Infraestructura | Monitoreo: registra errores, mide tiempos y genera alertas |
| `model-router-service` | Infraestructura | Decide qué modelo de IA usar según costo, velocidad y riesgo |
| `eval-lab-service` | Infraestructura | Evalúa evidencias automáticamente con IA |
| `scheduler-service` | Horarios | Planifica jobs, calendarios y disponibilidad |
| `institutional-structure-service` | **M2 — Mi módulo** | Regionales, centros de formación, sedes y ubicaciones |
| `actor-service` | Actores | Instructores, aprendices, coordinadores y directivos |
| `parameter-service` | Parametrización | Catálogos base, reglas configurables y tipos del sistema |
| `program-catalog-service` | Programas | Programas, diseños curriculares, competencias y RAP |
| `cohort-offering-service` | Oferta | Fichas, oferta, grupos y periodos |
| `schedule-service` | Horarios | Horarios, sesiones, asignación instructor/ambiente y conflictos |
| `attendance-trace-service` | Horarios | Asistencia, ejecución real de sesiones e incidencias |
| `formative-project-service` | Proyectos | Proyectos, entregables, hitos y diseño curricular |
| `learner-progress-service` | Oferta | Avance por aprendiz, evidencia y alertas de riesgo |
| `evidence-service` | Proyectos | Entrega, validación y versiones de evidencias |

### Fase 2 — P1 (después del MVP)

| Servicio | Módulo | Para qué sirve |
|---|---|---|
| `infrastructure-service` | Infraestructura | Ambientes, recursos e inventario físico |
| `integration-sync-service` | Coordinación | Sincronización con SOFIA Plus sin reemplazarlo |
| `notification-service` | Coordinación | Mensajes, alertas y recordatorios |
| `reporting-service` | Coordinación | Indicadores, tableros y exportables de avance |

---

## Módulo 2 — Estructura Institucional (mi módulo)

### Mis entidades

| Entidad | Qué representa |
|---|---|
| `MACROREGION` | Las grandes regiones naturales de Colombia (Andina, Caribe, Pacífica, etc.) |
| `MICROREGION` | Los departamentos dentro de cada macroregión |
| `DEPARTMENT` | Departamento geográfico |
| `MUNICIPALITY` | Municipio dentro de un departamento |
| `LOCATION` | Dirección física con coordenadas (latitud, longitud) |
| `TRAINING_CENTER` | Centro de formación SENA (Industrial, Comercial, etc.) |
| `INSTITUTIONAL_UNIT` | Sede, tecnoacademia o tecnoparque en un municipio |
| `INSTRUCTOR_ASSIGNMENT` | Asignación de un instructor a una unidad institucional |

### Dependencias

#### ✅ Lo que YO necesito de otros módulos

| Módulo | Qué necesito | Para qué |
|---|---|---|
| M7 Actores | `instructor_id` | Para registrar a qué instructor se asigna en `INSTRUCTOR_ASSIGNMENT` |
| M1 Seguridad | `Usuario_Sede` | M1 usa `INSTITUTIONAL_UNIT` como sede para controlar accesos |

#### 📤 Quién depende de MI módulo

| Módulo | Entidades que consumen | Por qué me necesitan |
|---|---|---|
| M3 Infraestructura | `TRAINING_CENTER`, `INSTITUTIONAL_UNIT`, `LOCATION` | Necesita saber en qué centro y unidad están los ambientes físicos |
| M7 Actores | `TRAINING_CENTER`, `INSTITUTIONAL_UNIT`, `MUNICIPALITY`, `INSTRUCTOR_ASSIGNMENT` | Necesita saber a qué unidad está asignado cada instructor |
| M8 Horarios | `TRAINING_CENTER`, `INSTITUTIONAL_UNIT`, `LOCATION` | Los horarios siempre están atados a un lugar físico |
| M1 Seguridad | `INSTITUTIONAL_UNIT` | La usa como "sede" en la tabla `Usuario_Sede` |

#### ⚪ Módulos sin relación directa conmigo

| Módulo | Razón |
|---|---|
| M4 Parametrización | Maneja catálogos genéricos, no depende de ubicaciones |
| M5 Programas de Formación | Trabaja con competencias y programas, no con lugares |
| M6 Oferta y Programas | Podría relacionarse indirectamente vía M3 o M7 |
| M9 Proyectos Formativos | Sin información suficiente aún |

---

## ¿Qué falta por hacer?

### Pendiente general del proyecto

| Qué | Estado |
|---|---|
| Implementar todos los servicios P0 | Pendiente |
| Definir contratos de API de cada servicio | Pendiente |
| Coordinar entre módulos las entidades compartidas | Pendiente |
| Activar servicios P1 después del MVP | Más adelante |

### Pendiente específico de mi módulo (M2)

| Tarea | Detalle |
|---|---|
| Implementar `institutional-structure-service` | Con todas las entidades del módulo |
| Publicar contrato de API | Endpoints que M3, M7 y M8 usarán para consultarme |
| Coordinar con M7 | Definir cómo se comparte el `instructor_id` |
| Coordinar con M1 | Confirmar cómo M1 referencia `INSTITUTIONAL_UNIT` como sede |

---

## Arquitectura de eventos

Los microservicios **no se hablan directamente entre bases de datos**. En cambio, cada servicio publica un "aviso" (evento) cuando algo importante ocurre, y los demás servicios que necesitan esa información lo escuchan y reaccionan.

### Ejemplo simple

Cuando un aprendiz sube una evidencia, `evidence-service` publica el evento `EvidenceSubmitted`. Entonces `learner-progress-service` lo escucha y actualiza el avance del aprendiz, y `notification-service` lo escucha y envía un aviso al instructor. Nadie tuvo que llamar a nadie directamente.

### Estructura obligatoria de cada evento

Todo evento que publique cualquier servicio debe tener estos campos:

| Campo | Para qué sirve | Ejemplo |
|---|---|---|
| `event_id` | Identificador único del evento | `evt-8f3a...` |
| `event_type` | Nombre del evento | `EvidenceSubmitted` |
| `occurred_at` | Cuándo ocurrió exactamente | `2025-06-14T10:30:00Z` |
| `source` | Qué servicio lo generó | `evidence-service` |
| `correlation_id` | ID para rastrear todo el flujo de principio a fin | `corr-2b91...` |
| `data` | La información del evento en detalle | `{ aprendiz_id, evidencia_id... }` |

Además, para trazabilidad completa se agrega: `run_id`, `actor_id` y `source_service`.

### ¿Por qué es importante el `correlation_id`?

Es como un número de radicado. Si algo falla, puedes buscarlo y ver exactamente qué pasó en cada servicio durante ese flujo, en qué orden y qué salió mal.

### Eventos del sistema y qué los dispara

| Evento | Lo publica | Cuándo ocurre |
|---|---|---|
| `SchedulePlanned` | `schedule-service` | Cuando se crea un nuevo horario |
| `ScheduleChanged` | `schedule-service` | Cuando se modifica un horario existente |
| `TrainingSessionExecuted` | `attendance-trace-service` | Cuando una sesión de formación se ejecuta |
| `AttendanceTraceRegistered` | `attendance-trace-service` | Cuando se registra la asistencia de un aprendiz |
| `EvidenceSubmitted` | `evidence-service` | Cuando un aprendiz entrega una evidencia |
| `EvidenceValidated` | `evidence-service` | Cuando un instructor valida una evidencia |
| `LearnerProgressUpdated` | `learner-progress-service` | Cuando el avance de un aprendiz cambia |
| `FormativeProjectMilestoneReached` | `formative-project-service` | Cuando un proyecto formativo alcanza un hito |
| `PdfGenerationRequested` | Cualquier servicio | Cuando se solicita generar un PDF |
| `PdfGenerated` | `pdf-worker-service` | Cuando el PDF queda listo |
| `WorkflowTransitioned` | `workflow-service` | Cuando un flujo pasa de un paso al siguiente |
| `PolicyViolationDetected` | `control-plane-service` | Cuando se detecta una violación de política |
| `AuditEvidenceRegistered` | `audit-compliance-service` | Cuando se registra una evidencia de auditoría |

### Eventos que afectan directamente a mi módulo (M2)

Mi módulo no publica muchos eventos porque es base de datos de referencia, pero sí puede publicar:

| Evento (propuesto) | Cuándo ocurre |
|---|---|
| `InstitutionalUnitCreated` | Cuando se crea una nueva sede o unidad |
| `TrainingCenterUpdated` | Cuando cambia información de un centro de formación |
| `InstructorAssigned` | Cuando se asigna un instructor a una unidad |

Y escucha eventos de M7 para saber cuándo un instructor queda disponible para ser asignado.

---

## Preguntas abiertas — relacionadas con mi módulo (M2)

### 🔴 Urgentes — bloquean mi trabajo ahora

Estas preguntas hay que responderlas antes de avanzar porque sin su respuesta no se puede diseñar bien el módulo.

| # | Pregunta en simple | Por qué bloquea |
|---|---|---|
| 1 | ¿Los datos de regionales y centros de formación los cargo yo manualmente o los traigo desde SOFIA Plus? | Si vienen de SOFIA Plus, mis entidades cambian completamente. No puedo diseñar `TRAINING_CENTER` sin saber esto |
| 2 | ¿Qué sedes y centros hay que registrar en la primera versión? ¿Solo Huila o todo el país? | Define cuántos datos cargo y qué tan compleja es mi estructura desde el inicio |
| 3 | ¿Cómo se conecta mi módulo con SOFIA Plus? ¿Con API, archivos, sincronización automática? | Determina si necesito `integration-sync-service` desde el MVP o puedo cargarlo a mano |

### 🟡 Importantes — responder pronto pero no bloquean hoy

Estas preguntas hay que resolverlas antes de terminar el módulo, pero no impiden empezar.

| # | Pregunta en simple | Por qué importa |
|---|---|---|
| 4 | ¿Los horarios los crea el sistema o los trae desde afuera? | M8 depende de mis entidades de ubicación; si los horarios vienen de afuera cambia cómo los expongo |
| 5 | ¿Quién puede ver la información de qué instructor está en qué sede? | Afecta los permisos que M1 aplica sobre `INSTRUCTOR_ASSIGNMENT` |
| 6 | ¿El sistema debe funcionar sin internet en alguna sede? | Si hay sedes sin conexión, `LOCATION` y la sincronización cambian |

### ⚪ Pueden esperar — no afectan el MVP

| # | Pregunta en simple | Por qué puede esperar |
|---|---|---|
| 7 | ¿Qué reglas internas del SENA no están escritas en ningún documento? | Solo importa cuando se quieran agregar validaciones avanzadas, no en el MVP |

---

## Normativa aplicable a mi módulo (M2)

Toda regla institucional debe estar trazada a una fuente. No se inventan reglas.

| Norma | Qué regula | Relación con M2 |
|---|---|---|
| Ley 119 de 1994 | Naturaleza, misión y funciones del SENA | Define la estructura organizacional que modelo (regionales, centros) |
| Estatuto de Formación Profesional Integral | Organización de la formación en el SENA | Base para jerarquía: macroregión → centro → unidad |
| Manual de Diseño Curricular SENA | Estructura académica | Referencia para relacionar centros con programas |
| Ley 1581 de 2012 + Decreto 1377 de 2013 | Protección de datos personales | Aplica a datos de ubicación e instructores asignados |
| Ley 594 de 2000 | Gestión documental | Aplica si el módulo genera o almacena documentos institucionales |
| Ley 1712 de 2014 | Transparencia y acceso a información pública | Aplica si datos de sedes o centros son públicos |

> **Regla de oro:** No inventar reglas internas del SENA. Toda decisión de diseño debe quedar trazada a una fuente normativa, documento institucional o decisión explícita del product owner.


---

## Contexto del proyecto

**Nombre:** `PRJ-SENA-TRAZABILIDAD-FORMACION`

El proyecto busca construir una plataforma por microservicios para controlar horarios y hacer seguimiento preciso de la formación SENA. Esto incluye fichas, aprendices, proyectos formativos, entregables y su relación con programas y diseño curricular.

### Principios base

| Principio | Qué significa en la práctica |
|---|---|
| Microservicios con fronteras estrictas | Cada servicio tiene su propia base de datos y no toca la de los demás |
| Separación de dominios | Lo académico (SENA) va separado del motor de IA y plataforma |
| Trazabilidad verificable | Todo lo que pasa en el sistema queda registrado y se puede auditar |
| Evidencia exportable | Los reportes, actas y PDFs se pueden descargar y compartir |
| Integración sin reemplazo | Se conecta con SOFIA Plus pero no lo sustituye |
| Alineación normativa | Todo cumple con las leyes colombianas aplicables |

---

## Alcance del proyecto

### ✅ Lo que SÍ hace el sistema

| # | Qué hace |
|---|---|
| 1 | Controla horarios programados y su ejecución real |
| 2 | Registra con precisión cada sesión de formación que ocurre |
| 3 | Gestiona el avance de fichas y aprendices en tiempo real |
| 4 | Relaciona proyectos formativos con programas, competencias, RAP y evidencias |
| 5 | Identifica dependencias entre proyectos formativos |
| 6 | Genera reportes, actas y PDFs de forma automática y asincrónica |
| 7 | Expone eventos y contratos claros por cada microservicio |
| 8 | Permite evaluación con IA y trazabilidad del proceso de construcción |

### ❌ Lo que NO hace el sistema

| # | Qué NO hace | Por qué |
|---|---|---|
| 1 | Reemplazar SOFIA Plus | SOFIA Plus sigue siendo la fuente institucional oficial |
| 2 | Crear fuente maestra sin autorización | Solo el product owner puede autorizar eso |
| 3 | Mezclar todo en un solo servicio | Cada dominio tiene su propio microservicio |
| 4 | Usar prompts de IA como mecanismo de seguridad | La seguridad se maneja con políticas reales, no con instrucciones de texto |
| 5 | Ejecutar acciones destructivas sin aprobación | Toda acción de riesgo requiere política y aprobación humana |
| 6 | Inventar reglas internas del SENA | Solo se implementa lo que está confirmado por una fuente oficial |