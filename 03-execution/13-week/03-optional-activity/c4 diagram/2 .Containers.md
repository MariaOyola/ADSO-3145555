# C4 Model — Nivel 2: Containers Diagram
## Sistema de Gestión de Horarios Académicos
**Proyecto:** PRJ-EDU-HORARIOS | **Fase:** MVP | **Fecha:** 2026-05-20

---

## Descripción general

El sistema se compone de **tres contenedores** principales que se comunican entre sí: una interfaz web que usan los actores, una API que centraliza toda la lógica de negocio (incluido el motor de validación), y una base de datos relacional que persiste el estado.

---

## Diagrama de contenedores (C4 — Level 2)

```
┌──────────────────────────────────────────────────────────────────────────┐
│               Sistema de Gestión de Horarios Académicos                  │
│                                                                          │
│                                                                          │
│   [Coordinador]  [Instructor]  [Admin. Ambientes]                        │
│         │              │               │                                 │
│         └──────────────┴───────────────┘                                 │
│                         │  HTTPS / Browser                               │
│                         ▼                                                │
│         ┌───────────────────────────────┐                                │
│         │          Web UI               │                                │
│         │   (Aplicación web responsiva) │                                │
│         │                               │                                │
│         │  · React / Vue SPA            │                                │
│         │  · Formularios de horarios    │                                │
│         │  · Buscador de disponibilidad │                                │
│         │  · Vista de carga horaria     │                                │
│         │  · Módulo de observaciones    │                                │
│         └───────────────┬───────────────┘                                │
│                         │  JSON / REST (HTTP)                            │
│                         ▼                                                │
│         ┌───────────────────────────────┐                                │
│         │             API               │                                │
│         │    (Backend / Servidor de     │                                │
│         │      lógica de negocio)       │                                │
│         │                               │                                │
│         │  · Motor de validación        │                                │
│         │    (triple restricción)       │                                │
│         │  · CRUD Ambientes             │                                │
│         │  · CRUD Fichas / Grupos       │                                │
│         │  · CRUD Instructores          │                                │
│         │  · Gestión de Horarios        │                                │
│         │  · Reportes de carga horaria  │                                │
│         │  · Gestión de Observaciones   │                                │
│         └───────────────┬───────────────┘                                │
│                         │  SQL / ORM                                     │
│                         ▼                                                │
│         ┌───────────────────────────────┐                                │
│         │           Database            │                                │
│         │   (Base de datos relacional)  │                                │
│         │                               │                                │
│         │  · Ambientes                  │                                │
│         │  · Instructores               │                                │
│         │  · Fichas (Grupos)            │                                │
│         │  · Horarios / Franjas         │                                │
│         │  · Observaciones              │                                │
│         └───────────────────────────────┘                                │
│                                                                          │
│                              (Fuera del sistema — Fase 2)                │
│                         ┌────────────────────────┐                       │
│                         │   ERP Institucional     │                      │
│                         │  (Sistema externo)      │                      │
│                         └────────────────────────┘                       │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Descripción de cada contenedor

### 1. Web UI — Interfaz web responsiva

| Atributo | Detalle |
|---|---|
| **Tipo** | Single Page Application (SPA) |
| **Tecnología sugerida** | React o Vue.js |
| **Acceso** | Navegador web (desktop y móvil responsivo) |
| **Usuarios directos** | Coordinador Académico, Instructor, Admin. de Ambientes |
| **Responsabilidad** | Presentar la interfaz de usuario. Enviar peticiones a la API. No contiene lógica de negocio. |

**Vistas principales del MVP:**

| Vista | Actor principal |
|---|---|
| Formulario de creación / edición de horarios | Coordinador |
| Buscador de disponibilidad de ambientes | Coordinador |
| Dashboard de carga horaria por instructor | Coordinador |
| Vista personal de horario semanal | Instructor |
| Módulo de registro y seguimiento de observaciones | Instructor / Coordinador |
| CRUD de ambientes y recursos | Admin. de Ambientes |

---

### 2. API — Backend / Lógica de negocio

| Atributo | Detalle |
|---|---|
| **Tipo** | API RESTful |
| **Tecnología sugerida** | Node.js (Express / Fastify) o Python (FastAPI / Django REST) |
| **Protocolo** | HTTPS — JSON |
| **Responsabilidad** | Toda la lógica de negocio del sistema. Es la única capa que escribe en la base de datos. |

**Módulos internos de la API:**

| Módulo | Responsabilidad |
|---|---|
| **Motor de validación** | Verifica la triple restricción antes de cada asignación: instructor libre, ambiente libre, ficha sin clase en esa franja. Es el núcleo del sistema. |
| **Gestión de Horarios** | Crear, editar, eliminar y consultar franjas horarias. |
| **Catálogo — Ambientes** | CRUD de salones, laboratorios, capacidad y recursos. |
| **Catálogo — Instructores** | CRUD de instructores y disponibilidad. |
| **Catálogo — Fichas** | CRUD de grupos/fichas de formación. |
| **Disponibilidad** | Endpoint de búsqueda de ambientes libres por fecha y franja. |
| **Reportes** | Consulta de carga horaria acumulada por instructor. |
| **Observaciones** | CRUD de observaciones vinculadas a instructor, ficha o ambiente, con estado abierta/resuelta. |

**Regla crítica del motor de validación:**

```
POST /horarios
    │
    ├─► ¿Instructor X ya tiene asignación en [fecha, hora_inicio, hora_fin]? → 409 Conflict
    ├─► ¿Ambiente Y ya tiene asignación en [fecha, hora_inicio, hora_fin]?   → 409 Conflict
    └─► ¿Ficha Z ya tiene clase en [fecha, hora_inicio, hora_fin]?           → 409 Conflict
                        │
                        └─► Sin conflictos → 201 Created ✓
```

> ⚠️ No existe endpoint para "forzar guardado ignorando conflicto". Esta restricción es intencional y protege la integridad del sistema.

---

### 3. Database — Base de datos relacional

| Atributo | Detalle |
|---|---|
| **Tipo** | Base de datos relacional |
| **Tecnología sugerida** | PostgreSQL |
| **Acceso** | Solo desde la API — nunca directo desde el Web UI |
| **Responsabilidad** | Persistir el estado de todos los catálogos y horarios. Soporte para consultas de solapamiento temporal eficientes. |

**Entidades principales del MVP:**

| Tabla | Campos clave |
|---|---|
| `ambientes` | id, nombre, capacidad, tipo (salón/lab), recursos, estado |
| `instructores` | id, nombre, tipo_contrato, horas_max_semana, estado |
| `fichas` | id, codigo, nombre_programa, jornada, estado |
| `horarios` | id, ficha_id, instructor_id, ambiente_id, fecha, hora_inicio, hora_fin |
| `observaciones` | id, tipo_entidad, entidad_id, descripcion, estado, fecha_reporte |

> ❓ **Pregunta abierta bloqueante:** La estructura de `horarios.hora_inicio` y `horarios.hora_fin` depende de si las franjas son bloques fijos o rangos libres. Esta decisión no está resuelta y es bloqueante para el diseño del esquema.

---

## Comunicación entre contenedores

| Origen | Destino | Protocolo | Sentido |
|---|---|---|---|
| Web UI | API | HTTPS / REST / JSON | Web UI → API |
| API | Database | SQL (via ORM) | API → Database |
| API | ERP Institucional | HTTP (Fase 2) | API ↔ ERP — **fuera de MVP** |

---

## Decisiones de arquitectura en este nivel

| # | Decisión | Justificación |
|---|---|---|
| 1 | La lógica de validación vive **solo en la API**, nunca en el frontend | Garantiza que ningún cliente externo pueda saltarse la validación |
| 2 | La base de datos es accesible **solo desde la API** | Seguridad y consistencia de datos |
| 3 | API RESTful stateless | Facilita escalabilidad futura y separación clara de responsabilidades |
| 4 | Una sola base de datos relacional en MVP | Suficiente para el volumen inicial; simplifica operación y despliegue |

---

*Nivel anterior → [C4 Level 1: Context]*
*Siguiente nivel → [C4 Level 3: Components] — Motor de validación, CRUD, AUTH*