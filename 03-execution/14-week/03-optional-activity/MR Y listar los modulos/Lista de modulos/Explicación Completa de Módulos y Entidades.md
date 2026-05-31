# SENA Schedule Manager
# Explicación de Módulos y Entidades

---

# 1. GESTIÓN ACADÉMICA

Este módulo define toda la estructura formativa del SENA.

Permite conocer:

- Qué programas existen.
- Qué competencias tiene cada programa.
- Qué RAP se deben desarrollar.
- Qué fichas están asociadas.
- Qué aprendices pertenecen a cada ficha.

## Entidades

### Centro de Formación

Representa el centro SENA.

Ejemplo:

- Centro de la Industria, la Empresa y los Servicios

---

### Sede

Ubicación física donde se desarrolla la formación.

Ejemplo:

- Industria
- Comercio
- Surcolombiana

---

### Línea Tecnológica

Agrupa programas similares.

Ejemplo:

- Tecnología
- Salud
- Agroindustria

---

### Programa

Programa de formación.

Ejemplo:

- ADSO
- Multimedia
- Redes

---

### Competencia

Capacidades que el aprendiz debe desarrollar.

Ejemplo:

- Desarrollar software según requerimientos.

---

### RAP

Resultado de Aprendizaje.

Ejemplo:

- Construir componentes de software.

---

### Ficha

Grupo académico.

Ejemplo:

- 3145555
- 3145556

---

### Aprendiz

Persona matriculada en una ficha.

---

# 2. GESTIÓN DE INSTRUCTORES

Administra toda la información relacionada con los instructores.

Permite:

- Saber quién dicta formación.
- Su disponibilidad.
- Tipo de contratación.
- Especialidades.

## Entidades

### Instructor

Información general del instructor.

---

### Contrato

Define su tipo de vinculación.

Ejemplos:

- Planta
- Contratista

---

### Especialidad

Área de conocimiento.

Ejemplos:

- Desarrollo de Software
- Redes
- Bases de Datos

---

### Disponibilidad

Horarios disponibles.

Ejemplo:

Lunes a Viernes

07:00 - 18:00

---

### Asignaciones

Relación entre instructor y actividades programadas.

---

# 3. GESTIÓN DE AMBIENTES

Administra los espacios físicos.

Permite evitar conflictos de uso.

## Entidades

### Ambiente

Lugar donde se realiza la formación.

Ejemplo:

- Aula A101
- Laboratorio Redes

---

### Bloque

Zona física dentro de una sede.

Ejemplo:

- Bloque A
- Bloque B

---

### Equipamiento

Recursos disponibles.

Ejemplo:

- Computadores
- Video Beam
- Router

---

### Mantenimiento

Controla ambientes fuera de servicio.

Ejemplo:

- Reparación eléctrica
- Cambio de equipos

---

### Reservas

Apartado temporal de ambientes.

---

# 4. GESTIÓN DE HORARIOS

Es el núcleo del sistema.

Su objetivo principal es evitar choques entre:

- Instructores
- Ambientes
- Fichas

## Entidades

### Horario

Representa una clase programada.

---

### Bloque Horario

Unidad de tiempo programable.

Ejemplo:

- 6:00 - 8:00

---

### Franja Horaria

Agrupación de bloques.

Ejemplo:

- Mañana
- Tarde
- Noche

---

### Conflictos

Registro de inconsistencias detectadas.

Ejemplo:

- Instructor duplicado
- Ambiente ocupado

---

### Observaciones

Notas relacionadas con horarios.

---

# 5. GESTIÓN DE EVALUACIÓN

Permite realizar seguimiento académico.

## Entidades

### Competencia

Competencias evaluadas.

---

### RAP

Resultados de aprendizaje evaluados.

---

### Evaluaciones

Actividades evaluativas.

Ejemplo:

- Taller
- Proyecto
- Examen

---

### Evidencias

Productos entregados.

Ejemplo:

- Documento
- Aplicación
- Informe

---

### Calificaciones

Resultado obtenido por el aprendiz.

---

# 6. GESTIÓN DE APRENDICES

Permite administrar la información estudiantil.

## Entidades

### Aprendiz

Estudiante SENA.

---

### Matrícula

Vinculación del aprendiz a una ficha.

---

### Asistencia

Registro de presencia.

---

### Seguimiento

Observaciones académicas y disciplinarias.

---

# 7. GESTIÓN DE PROGRAMACIÓN

Planifica la distribución académica.

## Entidades

### Planeación

Organización general de la formación.

---

### Carga Horaria

Cantidad de horas asignadas.

---

### Asignaciones

Relación entre recursos y actividades.

---

### Programación

Resultado final de la planeación.

---

# 8. GESTIÓN DE NOVEDADES

Permite controlar situaciones excepcionales.

## Entidades

### Novedades

Eventos no previstos.

---

### Excepciones

Cambios temporales autorizados.

---

### Incapacidades

Ausencias justificadas.

---

### Reprogramaciones

Cambios en horarios establecidos.

---

# 9. GESTIÓN DE CALENDARIO

Gestiona la dimensión temporal del sistema.

## Entidades

### Calendario

Calendario institucional.

---

### Periodos

Trimestres o etapas académicas.

---

### Semanas

Organización semanal.

---

### Festivos

Días no laborables.

---

### Eventos

Actividades institucionales.

---

# 10. GESTIÓN ADMINISTRATIVA

Controla acceso y configuración.

## Entidades

### Usuarios

Personas con acceso al sistema.

---

### Roles

Tipos de usuario.

Ejemplos:

- Administrador
- Coordinador
- Instructor

---

### Permisos

Acciones permitidas.

---

### Configuraciones

Parámetros globales del sistema.

---

# 11. GESTIÓN DE REPORTES

Permite obtener información para la toma de decisiones.

## Entidades

### Reportes

Informes generados.

---

### Indicadores

Métricas del sistema.

Ejemplos:

- Ocupación de ambientes
- Horas asignadas

---

### Estadísticas

Información consolidada para análisis y mejora continua.

---

# Objetivo General de la Base de Datos

La finalidad principal de este modelo es garantizar una correcta programación académica, evitando conflictos de horarios entre instructores, fichas y ambientes, permitiendo además gestionar recursos físicos, actividades académicas, evaluaciones y seguimiento institucional dentro de una arquitectura modular preparada para evolucionar hacia microservicios.