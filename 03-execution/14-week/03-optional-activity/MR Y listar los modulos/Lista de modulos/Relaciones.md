# Relaciones de la Base de Datos
# SENA Schedule Manager

## Gestión Académica

Centro de Formación
│
└── 1:N Sede

Sede
│
└── 1:N Bloque

Línea Tecnológica
│
└── 1:N Programa

Programa
│
├── 1:N Competencia
│
└── 1:N Ficha

Competencia
│
└── 1:N RAP

Ficha
│
└── 1:N Aprendiz

---

## Gestión de Instructores

Contrato
│
└── 1:N Instructor

Especialidad
│
└── N:M Instructor

Instructor
│
├── 1:N Disponibilidad
│
├── 1:N Asignación
│
└── 1:N Incapacidad

---

## Gestión de Ambientes

Sede
│
└── 1:N Ambiente

Bloque
│
└── 1:N Ambiente

Ambiente
│
├── N:M Equipamiento
│
├── 1:N Mantenimiento
│
└── 1:N Reserva

---

## Gestión de Horarios

Franja Horaria
│
└── 1:N Bloque Horario

Horario
│
├── N:1 Instructor
├── N:1 Ambiente
├── N:1 Ficha
├── N:1 RAP
└── N:1 Bloque Horario

Horario
│
├── 1:N Observación
│
└── 1:N Conflicto

---

## Gestión de Evaluación

Competencia
│
└── 1:N Evaluación

RAP
│
└── 1:N Evaluación

Evaluación
│
├── 1:N Evidencia
│
└── 1:N Calificación

Aprendiz
│
└── 1:N Calificación

---

## Gestión de Aprendices

Ficha
│
└── 1:N Matrícula

Aprendiz
│
├── 1:N Matrícula
├── 1:N Asistencia
└── 1:N Seguimiento

---

## Gestión de Programación

Planeación
│
└── 1:N Programación

Programación
│
├── 1:N Carga Horaria
│
└── 1:N Asignación

Asignación
│
├── N:1 Instructor
├── N:1 Ambiente
└── N:1 Ficha

---

## Gestión de Novedades

Horario
│
├── 1:N Novedad
├── 1:N Excepción
├── 1:N Incapacidad
└── 1:N Reprogramación

---

## Gestión de Calendario

Calendario
│
└── 1:N Periodo

Periodo
│
└── 1:N Semana

Calendario
│
├── 1:N Festivo
│
└── 1:N Evento

---

## Gestión Administrativa

Rol
│
└── 1:N Usuario

Rol
│
└── N:M Permiso

Usuario
│
└── 1:N Configuración

---

## Gestión de Reportes

Reporte
│
├── 1:N Indicador
│
└── 1:N Estadística