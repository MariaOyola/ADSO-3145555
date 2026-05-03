# Landing de planificacion - Sistema de hoteleria

## Objetivo de la landing
Construir una vista funcional de planificacion del proyecto basada exclusivamente en `architecture`, con:
- Resumen ejecutivo
- Priorizacion MoSCoW
- Design Thinking
- Historias de usuario con estimacion Fibonacci
- Tablero dinamico tipo Azure DevOps
- Matriz de cronograma
- Recomendaciones separadas del alcance confirmado

## Como abrirla localmente
1. Desde VS Code, abrir `docs/planning/index.html` en el navegador.
2. La landing funciona en modo archivo local (`file://`) gracias a un fallback en JavaScript.
3. Si se abre con un servidor local (por ejemplo Live Server), cargara directamente los JSON de `docs/planning/data`.

## Archivos generados
- `docs/planning/index.html`
- `docs/planning/css/styles.css`
- `docs/planning/js/app.js`
- `docs/planning/data/moscow.json`
- `docs/planning/data/design-thinking.json`
- `docs/planning/data/user-stories.json`
- `docs/planning/data/timeline.json`
- `docs/planning/README.md`

## Fuente de informacion usada
Fuente unica utilizada:
- `docs/architecture/model-data/es/01_entendimiento_necesidad_producto.md`
- `docs/architecture/model-data/es/02_posibles_funcionalidades_sistema.md`
- `docs/architecture/model-data/es/03_estructura_modulo_entidad_sin_atributo.md`
- `docs/architecture/model-data/es/04_estructura_modulo_entidad_con_atributo.md`
- `docs/architecture/model-data/es/05_id_y_auditoria.md`

## Supuestos realizados
- Se uso el nombre del proyecto como "Sistema de hoteleria" porque aparece de forma consistente en architecture.
- Se usaron roles genericos de trabajo para cronograma (Product Owner, Backend, Frontend) cuando no existe asignacion nominal en architecture.
- Algunas clasificaciones MoSCoW se marcan como "Inferido" cuando la prioridad no esta declarada literalmente en architecture.

## Informacion no encontrada en architecture
- Reglas exactas de precio dinamico.
- Estados oficiales de reserva, habitacion, factura y pago.
- Politica definitiva de cancelacion, devolucion y penalidad.
- Canales de notificacion requeridos.
- Reglas exactas de autorizacion por rol.
- Estrategia de despliegue y ambientes.

## Como funciona el tablero dinamico
- Cada tarjeta representa HU, Epica, Tarea o Riesgo.
- Campos visibles por tarjeta:
  - ID
  - Titulo
  - Prioridad
  - Estimacion Fibonacci
  - Estado
  - Tipo
- Se puede mover entre columnas con drag and drop.
- Los cambios se guardan en `localStorage` con la clave `planning_board_state_v1`.
- El boton "Restaurar tablero inicial" limpia el estado persistido y vuelve a la configuracion original.
- Filtros disponibles por prioridad, estado y tipo.
- Cada columna muestra contador de tarjetas visibles.

## Como modificar HU o cronograma desde los JSON
1. Editar `docs/planning/data/user-stories.json` para agregar o modificar historias y tarjetas extras del tablero.
2. Editar `docs/planning/data/timeline.json` para ajustar semanas, dependencias y entregables.
3. Editar `docs/planning/data/moscow.json` y `docs/planning/data/design-thinking.json` para actualizar priorizacion y fases.
4. Recargar la pagina.

Nota:
- En apertura directa de `index.html` sin servidor, algunos navegadores bloquean `fetch` de JSON por politica de seguridad. En ese caso se usa fallback local para mantener la landing funcional.
- Para forzar lectura directa de JSON, abrir la carpeta con un servidor local de desarrollo.

## Justificacion tecnica
- Se uso JavaScript vanilla.
- No se uso libreria externa para drag and drop porque la API nativa HTML5 cubre el caso requerido.
