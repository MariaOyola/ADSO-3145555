# 📍 ¿Por qué la Ubicación es crítica en el Sistema de Horarios?
## Módulo: Estructura Institucional SENA — Regla de Negocio

---

## 🧩 El problema real

Imagina el siguiente escenario con un instructor real:

```
👨‍🏫 Carlos Sarasty — Instructor de Programación

  06:00 - 09:00  →  Sede Neiva Norte   (Calle 15, Neiva)
  09:00 - 12:00  →  Sede Campo Alegre  (a 45 min de distancia)
```

> **¿Es físicamente posible asignar ese horario?**
> ❌ **No.** El instructor termina a las 09:00 en Neiva Norte
> y a las 09:00 ya debería estar en Campo Alegre.
> El desplazamiento requiere ~45 minutos que no existen en el horario.

---

## 🗺️ ¿Cómo lo resuelve el sistema con la ubicación?

Gracias a que el módulo de **Estructura Institucional** almacena las
**coordenadas GPS (latitud y longitud)** de cada sede, el módulo de
Horarios puede ejecutar la siguiente validación automática:

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   Sede A (lat, lng)  ──►  Distancia  ──►  Tiempo        │
│   Sede B (lat, lng)         entre          estimado     │
│                             sedes          de viaje     │
│                               │                         │
│                               ▼                         │
│         ¿El lapso entre clases es suficiente?           │
│                                                         │
│              SÍ ✅  →  Horario se programa              │
│              NO ❌  →  Conflicto de ubicación           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## ⚠️ Los 3 tipos de conflicto en el módulo de Horarios

Antes del análisis de ubicación, solo se conocían 2 conflictos clásicos.
Con este módulo aparece un **tercero, el conflicto geográfico**:

| # | Tipo de Conflicto | Descripción | Ejemplo |
|---|---|---|---|
| 1 | **Instructor duplicado** | Mismo instructor asignado a dos clases al mismo tiempo | Carlos a las 08:00 en A101 y en B201 |
| 2 | **Ambiente ocupado** | Mismo salón con dos grupos al mismo tiempo | Aula A101 con ficha 3145555 y 3145556 |
| 3 | **Conflicto geográfico** ⬅️ *nuevo* | Instructor en dos sedes sin tiempo suficiente para desplazarse | Carlos termina en Neiva a las 09:00 y debe estar en Campo Alegre a las 09:00 |

---

## 🔗 ¿Por qué le importa a este módulo específicamente?

Aunque el **módulo de Horarios** es quien detecta y registra el conflicto,
**los datos que necesita para hacerlo vienen del módulo de Estructura Institucional.**

```
📦 Este módulo provee:
├── 🌐 Latitud y longitud de cada Sede
├── 🏙️  Ciudad y departamento  (¿misma ciudad o diferente?)
└── 🏷️  Nombre de la sede      (para mostrarlo en el mensaje de error)

⚙️ El módulo de Horarios usa eso para:
└── 📐 Calcular si el tiempo entre clases alcanza para el desplazamiento
```

> **Sin coordenadas en la tabla `Sede`, el módulo de Horarios
> no puede detectar el conflicto geográfico.**

---

## 📏 La regla de negocio formal

> 💡 **Regla de Negocio — Conflicto Geográfico:**
>
> *Si un instructor tiene dos clases asignadas en sedes distintas,
> debe existir un **lapso mínimo de tiempo** entre el fin de la primera
> clase y el inicio de la segunda, proporcional a la distancia
> entre ambas sedes.*

### ¿Qué implica esto para el diseño de la tabla `Sede`?

```sql
-- Atributos que DEBEN existir en la entidad Sede
-- para soportar esta regla de negocio:

Sede {
  id              -- Identificador único
  nombre          -- "Neiva Norte", "Campo Alegre"
  centro_id       -- Centro de Formación al que pertenece
  direccion       -- Dirección física exacta
  ciudad          -- Ciudad
  departamento    -- Departamento
  latitud         -- ✅ Coordenada GPS — dato FUNCIONAL
  longitud        -- ✅ Coordenada GPS — dato FUNCIONAL
  horario_atencion
  estado          -- Activo / Inactivo
}
```

> ⚠️ **Las coordenadas GPS no son un dato decorativo.**
> Son un dato **funcional y crítico** para que el sistema de
> horarios pueda validar la viabilidad física de una asignación.

---

## 📌 Conclusión

| Pregunta | Respuesta |
|---|---|
| ¿Por qué guardar coordenadas en Sede? | Para que Horarios calcule tiempo de desplazamiento entre sedes |
| ¿Quién detecta el conflicto? | El módulo de Horarios |
| ¿Quién provee los datos para detectarlo? | El módulo de Estructura Institucional (este módulo) |
| ¿Es un dato opcional? | ❌ No. Sin él, el conflicto geográfico no se puede validar |

---

*Documento generado como parte del análisis del módulo*
*2 — Estructura Institucional SENA | SENA Schedule Manager*