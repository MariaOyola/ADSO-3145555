# Entidades y Relaciones — Módulo 2: Estructura Institucional

> Las entidades están organizadas de mayor a menor en la jerarquía del SENA:
> **Macroregión → Microregión → Departamento → Municipio → Centro → Unidad → Asignación**

---

## Entidades

### 1. `MACROREGION`
Es el nivel más alto de la jerarquía geográfica. Representa las grandes regiones naturales de Colombia.

| Campo | Tipo | Descripción |
|---|---|---|
| `macroregion_id` | UUID (PK) | Identificador único |
| `region_name` | varchar | Nombre de la región (ej: Andina, Caribe, Pacífica) |
| `status` | varchar | Estado del registro (activo / inactivo) |

---

### 2. `MICROREGION`
Representa los departamentos o agrupaciones de departamentos dentro de una macroregión.

| Campo | Tipo | Descripción |
|---|---|---|
| `microregion_id` | UUID (PK) | Identificador único |
| `macroregion_id` | UUID (FK) | Macroregión a la que pertenece |
| `microregion_name` | varchar | Nombre de la microregión (ej: Huila) |
| `status` | varchar | Estado del registro |

---

### 3. `DEPARTMENT`
Departamento geográfico de Colombia. Pertenece a una microregión.

| Campo | Tipo | Descripción |
|---|---|---|
| `department_id` | UUID (PK) | Identificador único |
| `microregion_id` | UUID (FK) | Microregión a la que pertenece |
| `department_name` | varchar | Nombre del departamento |
| `status` | varchar | Estado del registro |

---

### 4. `MUNICIPALITY`
Municipio dentro de un departamento. Es donde se ubican físicamente las sedes.

| Campo | Tipo | Descripción |
|---|---|---|
| `municipality_id` | UUID (PK) | Identificador único |
| `department_id` | UUID (FK) | Departamento al que pertenece |
| `municipality_name` | varchar | Nombre del municipio (ej: Neiva) |
| `status` | varchar | Estado del registro |

---

### 5. `LOCATION`
Dirección física exacta de una sede o unidad institucional, con coordenadas para geolocalización.

| Campo | Tipo | Descripción |
|---|---|---|
| `location_id` | UUID (PK) | Identificador único |
| `municipality_id` | UUID (FK) | Municipio donde está ubicado |
| `address` | varchar | Dirección completa |
| `postal_code` | varchar | Código postal |
| `latitude` | decimal | Latitud geográfica |
| `longitude` | decimal | Longitud geográfica |
| `status` | varchar | Estado del registro |

---

### 6. `TRAINING_CENTER_TYPE`
Catálogo de tipos de centros de formación. Define si un centro es Industrial, Comercial, Agropecuario, etc.

| Campo | Tipo | Descripción |
|---|---|---|
| `center_type_id` | UUID (PK) | Identificador único |
| `name` | varchar | Nombre del tipo (ej: Industrial, Comercial) |
| `description` | varchar | Descripción del tipo |
| `status` | varchar | Estado del registro |

---

### 7. `TRAINING_CENTER`
Centro de formación SENA. Pertenece a una microregión y tiene un tipo definido.

| Campo | Tipo | Descripción |
|---|---|---|
| `training_center_id` | UUID (PK) | Identificador único |
| `microregion_id` | UUID (FK) | Microregión a la que pertenece |
| `center_type_id` | UUID (FK) | Tipo de centro |
| `center_code` | varchar | Código oficial del centro en el SENA |
| `center_name` | varchar | Nombre del centro |
| `status` | varchar | Estado del registro |

---

### 8. `UNIT_TYPE`
Catálogo de tipos de unidades institucionales. Define si una unidad es Sede, Tecnoacademia o Tecnoparque.

| Campo | Tipo | Descripción |
|---|---|---|
| `unit_type_id` | UUID (PK) | Identificador único |
| `name` | varchar | Nombre del tipo (ej: Sede, Tecnoacademia) |
| `description` | varchar | Descripción del tipo |
| `status` | varchar | Estado del registro |

---

### 9. `INSTITUTIONAL_UNIT`
Unidad institucional física del SENA: una sede, tecnoacademia o tecnoparque específica. Es la entidad más consumida por los demás módulos.

| Campo | Tipo | Descripción |
|---|---|---|
| `unit_id` | UUID (PK) | Identificador único |
| `training_center_id` | UUID (FK) | Centro de formación al que pertenece |
| `location_id` | UUID (FK) | Ubicación física de la unidad |
| `unit_type_id` | UUID (FK) | Tipo de unidad |
| `unit_name` | varchar | Nombre de la unidad |
| `phone` | varchar | Teléfono de contacto |
| `status` | varchar | Estado del registro |

---

### 10. `INSTRUCTOR_ASSIGNMENT`
Registro de la asignación de un instructor a una unidad institucional en un período de tiempo.

| Campo | Tipo | Descripción |
|---|---|---|
| `assignment_id` | UUID (PK) | Identificador único |
| `instructor_id` | UUID (FK) | Instructor asignado — viene de M7 |
| `unit_id` | UUID (FK) | Unidad a la que se asigna |
| `start_date` | date | Fecha de inicio de la asignación |
| `end_date` | date | Fecha de fin de la asignación |
| `status` | varchar | Estado del registro |

---

## Relaciones entre entidades

```
MACROREGION
    └── MICROREGION (una macroregión tiene muchas microregiones)
            ├── DEPARTMENT (una microregión tiene muchos departamentos)
            │       └── MUNICIPALITY (un departamento tiene muchos municipios)
            │               └── LOCATION (un municipio tiene muchas ubicaciones)
            │                       └── INSTITUTIONAL_UNIT
            │
            └── TRAINING_CENTER (una microregión tiene muchos centros)
                    └── INSTITUTIONAL_UNIT (un centro tiene muchas unidades)
                            └── INSTRUCTOR_ASSIGNMENT (una unidad tiene muchas asignaciones)

TRAINING_CENTER_TYPE ──► TRAINING_CENTER
UNIT_TYPE            ──► INSTITUTIONAL_UNIT
```

### Detalle de cada relación

| Relación | Tipo | Descripción |
|---|---|---|
| `MACROREGION` → `MICROREGION` | 1 a muchos | Una región natural agrupa varias microregiones |
| `MICROREGION` → `DEPARTMENT` | 1 a muchos | Una microregión agrupa varios departamentos |
| `DEPARTMENT` → `MUNICIPALITY` | 1 a muchos | Un departamento tiene varios municipios |
| `MUNICIPALITY` → `LOCATION` | 1 a muchos | En un municipio puede haber varias ubicaciones físicas |
| `MICROREGION` → `TRAINING_CENTER` | 1 a muchos | Una microregión puede tener varios centros de formación |
| `TRAINING_CENTER_TYPE` → `TRAINING_CENTER` | 1 a muchos | Un tipo clasifica varios centros |
| `TRAINING_CENTER` → `INSTITUTIONAL_UNIT` | 1 a muchos | Un centro tiene varias unidades (sedes, tecnoacademias) |
| `UNIT_TYPE` → `INSTITUTIONAL_UNIT` | 1 a muchos | Un tipo clasifica varias unidades |
| `LOCATION` → `INSTITUTIONAL_UNIT` | 1 a 1 | Cada unidad tiene una ubicación física |
| `INSTITUTIONAL_UNIT` → `INSTRUCTOR_ASSIGNMENT` | 1 a muchos | A una unidad se pueden asignar varios instructores |

---

## Dependencias externas

| Campo | Viene de | Módulo |
|---|---|---|
| `instructor_id` en `INSTRUCTOR_ASSIGNMENT` | Entidad `INSTRUCTOR` | M7 — Actores |
| `INSTITUTIONAL_UNIT` como sede | Tabla `Usuario_Sede` | M1 — Seguridad |

---

## Quién consume mis entidades

| Módulo | Entidades que usa |
|---|---|
| M1 Seguridad | `INSTITUTIONAL_UNIT` (como sede de usuario) |
| M3 Infraestructura | `TRAINING_CENTER`, `INSTITUTIONAL_UNIT`, `LOCATION` |
| M7 Actores | `TRAINING_CENTER`, `INSTITUTIONAL_UNIT`, `MUNICIPALITY`, `INSTRUCTOR_ASSIGNMENT` |
| M8 Horarios | `TRAINING_CENTER`, `INSTITUTIONAL_UNIT`, `LOCATION` |