# Lista de módulos y justificación técnica  
SENA Schedule Manager

---

# 1. Módulo Seguridad

## Propósito

Gestionar la autenticación, autorización y control de acceso al sistema mediante usuarios, roles y permisos.

---

## Entidades

| Entidad | Propósito |
|---|---|
| usuario | Gestiona el acceso al sistema |
| rol | Define perfiles de acceso |
| permiso | Define acciones permitidas |
| usuario_rol | Relación entre usuarios y roles |
| rol_permiso | Relación entre roles y permisos |

---

## Justificación técnica

Este módulo es transversal a toda la plataforma y centraliza el control de acceso.  
La separación entre usuario, rol y permiso permite aplicar RBAC (Role Based Access Control), evitando lógica duplicada en otros módulos.

Las relaciones muchos a muchos entre usuarios ↔ roles y roles ↔ permisos cumplen 3FN al evitar atributos multivaluados o repetidos.

La entidad usuario almacena únicamente información de autenticación y acceso, mientras que la información académica y operativa pertenece al módulo de instructores.

---

# 2. Módulo Gestión Académica

## Propósito

Administrar la estructura académica institucional compuesta por líneas de formación, programas y fichas.

---

## Entidades

| Entidad | Propósito |
|---|---|
| linea_formacion | Clasificación principal de formación |
| programa | Programa académico asociado a una línea |
| ficha | Grupo de formación operativo |

---

## Justificación técnica

La separación entre línea, programa y ficha representa correctamente la estructura académica real del SENA.

Una línea de formación puede contener múltiples programas, y un programa puede tener múltiples fichas activas.

Separar estas entidades evita redundancia y cumple normalización:

- La duración pertenece al programa.
- La cantidad de aprendices pertenece a la ficha.
- La clasificación académica pertenece a la línea.

Esto permite escalabilidad académica y evita inconsistencias de datos.

---

# 3. Módulo Gestión de Ambientes

## Propósito

Administrar ambientes de formación y sus restricciones operativas.

---

## Entidades

| Entidad | Propósito |
|---|---|
| ambiente | Espacio físico o virtual de formación |
| restriccion_ambiente | Restricciones temporales u operativas |

---

## Justificación técnica

El ambiente no solo representa un aula, sino también un recurso operativo que debe controlarse.

Las restricciones permiten gestionar:

- mantenimientos,
- bloqueos,
- indisponibilidad,
- reservas especiales.

Separar restricciones del ambiente evita almacenar múltiples estados temporales dentro de una sola entidad y mantiene consistencia operacional.

El modelo soporta validaciones futuras de disponibilidad y prevención de conflictos.

---

# 4. Módulo Gestión de Instructores

## Propósito

Gestionar la información académica y operativa de los instructores.

---

## Entidades

| Entidad | Propósito |
|---|---|
| modalidad | Tipo de formación del instructor |
| instructor | Información operativa del instructor |

---

## Justificación técnica

La entidad instructor almacena únicamente información académica y operativa relacionada con la programación.

La modalidad permite diferenciar instructores:

- presenciales,
- virtuales,
- híbridos.

Esto afecta validaciones de horarios, ambientes y asignaciones.

Separar modalidad evita atributos repetitivos y facilita parametrización futura.

La relación entre usuario e instructor mantiene desacoplada la autenticación de la operación académica.

---

# 5. Módulo Programación

## Propósito

Gestionar la planificación académica y el control de horarios.

---

## Entidades

| Entidad | Propósito |
|---|---|
| horario | Sesión programada |
| excepcion_horario | Modificaciones extraordinarias |
| conflicto_horario | Registro de conflictos detectados |

---

## Justificación técnica

Este módulo representa el núcleo del negocio.

La entidad horario centraliza la relación entre:

- instructor,
- ficha,
- ambiente.

Las excepciones permiten manejar cancelaciones, cambios o aplazamientos sin modificar el historial original.

Los conflictos registran situaciones operativas como:

- traslapes,
- duplicidad de ambientes,
- duplicidad de instructores.

La separación de estas entidades mejora trazabilidad, auditoría y mantenimiento.

---

# 6. Módulo Operaciones

## Propósito

Gestionar novedades y seguimiento operacional sobre la ejecución académica.

---

## Entidades

| Entidad | Propósito |
|---|---|
| observacion | Registro de novedades operativas |

---

## Justificación técnica

Permite mantener trazabilidad sobre situaciones ocurridas durante la ejecución de la programación.

Las observaciones pueden registrar:

- novedades académicas,
- incidencias operativas,
- seguimiento institucional,
- eventos relevantes.

Separar observaciones del horario evita sobrecargar la entidad principal y facilita consultas históricas.

---

# 7. Módulo RAP / Competencias

## Propósito

Gestionar resultados de aprendizaje y su asignación académica.

---

## Entidades

| Entidad | Propósito |
|---|---|
| resultado_aprendizaje | Catálogo de competencias y RAP |
| ficha_resultado | Relación entre ficha y RAP |

---

## Justificación técnica

Un resultado de aprendizaje puede ser utilizado en múltiples fichas, y una ficha puede contener múltiples resultados.

La entidad intermedia ficha_resultado resuelve esta relación muchos a muchos y permite almacenar atributos propios de la asignación como:

- fecha programada,
- estado,
- observaciones.

Esto cumple 3FN y evita duplicar información académica.

Además, permite trazabilidad completa del avance formativo.

---

# 8. Módulo Auditoría

## Propósito

Registrar trazabilidad de acciones realizadas dentro del sistema.

---

## Entidades

| Entidad | Propósito |
|---|---|
| auditoria | Historial de acciones sobre registros |

---

## Justificación técnica

La auditoría permite mantener evidencia operativa y trazabilidad institucional.

Registra acciones como:

- CREATE,
- UPDATE,
- DELETE.

También almacena:

- valores anteriores,
- valores nuevos,
- usuario responsable,
- fecha de ejecución.

Separar auditoría del resto de entidades evita contaminación de lógica de negocio y permite centralizar monitoreo y control institucional.

---

# Relación general entre módulos

```plaintext
SEGURIDAD
│
├── usuario
├── rol
└── permiso

GESTIÓN ACADÉMICA
│
├── linea_formacion
├── programa
└── ficha

GESTIÓN AMBIENTES
│
├── ambiente
└── restriccion_ambiente

GESTIÓN INSTRUCTORES
│
├── modalidad
└── instructor

PROGRAMACIÓN
│
├── horario
├── excepcion_horario
└── conflicto_horario

OPERACIONES
│
└── observacion

RAP / COMPETENCIAS
│
├── resultado_aprendizaje
└── ficha_resultado

AUDITORÍA
│
└── auditoria
```

---


# Principios aplicados

| Principio | Aplicación |
|---|---|
| 3FN | Eliminación de redundancia |
| Clean Architecture | Separación por capas |
| DDD Lite | Separación por dominios |
| RBAC | Control de acceso |
| Soft Delete | Eliminación lógica |
| Auditoría | Trazabilidad institucional |
| Alta cohesión | Responsabilidades claras |
| Bajo acoplamiento | Independencia entre módulos |
