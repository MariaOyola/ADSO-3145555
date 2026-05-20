# C4 Model — Nivel 1: Context Diagram
## Sistema de Gestión de Horarios Académicos
**Proyecto:** PRJ-EDU-HORARIOS | **Fase:** MVP | **Fecha:** 2026-05-20

---

## Descripción general del sistema

El **Sistema de Gestión de Horarios Académicos** es una plataforma web centralizada que permite a los centros de formación programar, validar y consultar horarios académicos en tiempo real, eliminando los conflictos de cruce (instructor, ambiente, ficha) que hoy se producen por el uso manual de hojas de cálculo.

---

## Diagrama de contexto (C4 — Level 1)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SYSTEM CONTEXT                                  │
│                                                                         │
│                                                                         │
│   [Coordinador Académico] ──────────────────────────────────────────┐   │
│         (Persona)                                                   │   │
│         Programa fichas, asigna instructores                        │   │
│         y ambientes. Consulta disponibilidad.                       │   │
│                                                                     ▼   │
│                                                         ╔═══════════════╗│
│   [Instructor / Docente] ──────────────────────────────►║               ║│
│         (Persona)                                       ║   Sistema de  ║│
│         Consulta su horario asignado                    ║   Gestión de  ║│
│         y registra observaciones.                       ║   Horarios    ║│
│                                                         ║  Académicos   ║│
│   [Admin. de Ambientes] ───────────────────────────────►║               ║│
│         (Persona)                                       ║  [Web App]    ║│
│         Mantiene el inventario de salones,              ╚═══════╤═══════╝│
│         laboratorios, capacidad y recursos.                     │        │
│                                                                 │        │
│                                          (Fase 2 / fuera MVP)  │        │
│                                                                 ▼        │
│                                             [Sistema ERP Institucional]  │
│                                                   (Sistema externo)      │
│                                              Nómina, matrículas.         │
│                                             Integración NO en MVP.       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Actores del sistema

### Usuarios internos (personas)

| Actor | Rol | Interacción principal |
|---|---|---|
| **Coordinador Académico** | Usuario primario | Crea y gestiona horarios. Consulta disponibilidad de ambientes. Recibe validaciones de conflicto en tiempo real. |
| **Instructor / Docente** | Usuario secundario | Consulta su horario asignado y carga horaria semanal. Registra observaciones sobre fichas o ambientes. |
| **Admin. de Ambientes** | Usuario de soporte | Gestiona el catálogo de ambientes (salones, laboratorios, capacidad, recursos tecnológicos). |

### Sistemas externos

| Sistema | Relación | Estado en MVP |
|---|---|---|
| **ERP Institucional** (nómina / matrículas) | Integración bidireccional futura para sincronizar datos de instructores y grupos | **Fuera de alcance** — Fase 2 |
| **Sistemas de notificación** (SMS / WhatsApp / Push) | Notificar a instructores sobre cambios de horario | **Fuera de alcance** — Fase 2 |

---

## Flujos de valor principales

```
Coordinador
    │
    ├─► Registra ambientes, fichas e instructores (Catálogo)
    │
    ├─► Crea una franja horaria
    │       └─► Sistema valida triple restricción:
    │               ├─ ¿Instructor ya asignado en esa hora? → BLOQUEA
    │               ├─ ¿Ambiente ya ocupado en esa hora?   → BLOQUEA
    │               └─ ¿Ficha ya tiene clase en esa hora?  → BLOQUEA
    │                           └─► Sin conflicto → GUARDA ✓
    │
    └─► Consulta disponibilidad de ambientes por fecha y franja

Instructor
    └─► Consulta su horario semanal
    └─► Registra observación → Admin / Coordinador la gestiona

Admin. de Ambientes
    └─► CRUD de ambientes (capacidad, recursos, estado)
```

---

## Propuesta de valor del sistema (en contexto)

> **Antes (AS-IS):** Múltiples hojas de Excel compartidas por correo, revisión visual manual, reuniones de coordinación, tableros físicos en paredes. Tasa de error estimada: **5–10% de cruces** sobre el total de franjas programadas.

> **Después (TO-BE):** Plataforma única, validación automática en tiempo real, búsqueda de disponibilidad instantánea. Meta a 90 días: **0% de cruces** — es imposible técnicamente guardar un conflicto.

---

## Restricciones y decisiones de contexto

| # | Restricción / Decisión | Impacto |
|---|---|---|
| 1 | Sistema **web-responsive** — sin app móvil nativa en MVP | Reduce scope de desarrollo inicial |
| 2 | **Sin integración ERP** en MVP — datos se ingresan manualmente | Riesgo de calidad de datos base |
| 3 | **Sin notificaciones automáticas** — consulta manual por ahora | Reduce adopción si instructores no entran al sistema |
| 4 | La **triple restricción es estricta** — no hay "forzar guardado con conflicto" | Protege integridad de datos; riesgo de presión gerencial |

---

## Pregunta abierta bloqueante (impacta este nivel)

> ❓ **¿Cómo se modela una "franja horaria"?**
> ¿Bloques fijos (1h, 2h) o rangos libres inicio–fin por minuto?
> Esta decisión define cómo el motor de validación compara solapamientos y es bloqueante para la arquitectura.

---

*Siguiente nivel → [C4 Level 2: Containers] — Web UI, API, Base de Datos*