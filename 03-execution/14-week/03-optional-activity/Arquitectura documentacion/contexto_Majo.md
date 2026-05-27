## La estructura actual documenta muy bien cada microservicio por dentro (sección 12). Pero no documenta lo que pasa entre servicios ni alrededor de ellos. Imagínalo así

----------------------------

#  15 Event Catalog — Catálogo de eventos

Event Catalog — Catálogo de eventos
Documenta todos los mensajes que los servicios se envían entre sí de forma asíncrona (sin esperar respuesta inmediata).


> Analogía: Imagina que los microservicios son personas trabajando en oficinas separadas. Pueden llamarse directamente (eso es la API REST, sección 06). Pero también pueden dejar notas en un tablero de mensajes para que otros las lean cuando puedan. El catálogo de eventos documenta exactamente qué notas existen, quién las deja y quién las lee.

 ### event-catalog-overview.md
Lista todos los eventos del sistema en una tabla: nombre del evento, quién lo publica (producer), quién lo consume (consumer), y a través de qué canal (Kafka topic, RabbitMQ queue, etc.).

Ejemplo para un sistema de hotel:

# -- Event catalog
| Evento | Producer | Consumer(s) | Canal |
|--------|----------|-------------|-------|
| reserva.creada | reservas-svc | pagos-svc, notif-svc | topic:reservas |
| pago.confirmado | pagos-svc | reservas-svc, email-svc | topic:pagos |
| habitacion.liberada | habitaciones-svc | reservas-svc | topic:habitaciones |

Sin esto, cuando un nuevo desarrollador llega al proyecto no sabe qué eventos existen ni quién reacciona a qué.
------------------------

# --Events/reserva.creada.md

Cada evento tiene su propio archivo que documenta exactamente qué datos viajan en el mensaje (el payload), cuándo se dispara y qué significa.

# Event: reserva.creada
Versión: 1.2
Producer: reservas-service
Canal: kafka:topic/reservas

## Payload
{
  "reservaId": "uuid",
  "clienteId": "uuid",
  "fechaEntrada": "ISO8601",
  "total": "decimal"
}

Esto es el equivalente del OpenAPI pero para mensajes asíncronos. Sin esto dos equipos pueden publicar y consumir eventos con payloads incompatibles.

---------------------------
# --messaging-standards.md

Define las reglas globales de mensajería: cómo se nombran los topics o queues, formato de los mensajes (JSON, Avro, Protobuf), política de reintentos, manejo de dead-letter queues (mensajes que fallaron).

Ejemplo de convención de nombres:

# Naming conventions
Topics: {dominio}.{entidad}.{evento}
✓ hotel.reserva.creada
✓ hotel.pago.confirmado
✗ NuevaReserva (no válido)

Retries: 3 intentos, backoff exponencial
DLQ: {topic}.dead-letter

------------------------

#  16 · Comunicación entre servicios

Documenta la infraestructura que conecta los microservicios entre sí: cómo se encuentran, cómo se protegen y qué pasa cuando uno falla.

>Analogía: La sección 12 documenta cada apartamento del edificio. Pero nadie documentó los pasillos, el ascensor, ni qué pasa cuando hay un corte de luz. Eso es esta sección: la infraestructura compartida entre servicios que no pertenece a ninguno en particular.

--------------------------

# -- service-discovery.md

En microservicios los servicios no tienen una IP fija. Se levantan y caen dinámicamente. El service discovery es el mecanismo por el que un servicio encuentra a otro en tiempo real.

Este archivo documenta qué herramienta se usa (Kubernetes DNS, Consul, Eureka) y cómo se registran y descubren los servicios.

# Service discovery
Estrategia: Kubernetes DNS
Patrón: client-side discovery

## Convención de nombres
reservas-svc.default.svc.cluster.local
pagos-svc.default.svc.cluster.local

## Health checks
Endpoint: GET /health
Intervalo: 10s, timeout: 3s

----------------------

# -- circuit-breaker-policy.md

Un circuit breaker es como un fusible eléctrico. Si el servicio de pagos empieza a fallar, en lugar de que todos los demás servicios queden esperando indefinidamente, el circuit breaker "corta el circuito" y devuelve un error inmediato.

Este archivo documenta cuándo se activa, cuánto tiempo espera antes de reintentar y cómo se comporta el sistema mientras el circuit breaker está abierto.

# Circuit breaker policy
Librería: Resilience4j / Hystrix

Umbral de apertura: 50% errores en 10s
Tiempo en abierto: 30 segundos
Half-open: 3 requests de prueba

## Fallback por servicio
pagos-svc → encolar para reintento
notif-svc → log + continuar sin notif.
------------------------
# -- api-gateway.md

El API Gateway es la puerta de entrada al sistema. Todos los clientes externos (apps móviles, frontend web, sistemas externos) llaman a un solo punto, y el gateway enruta la petición al microservicio correcto.

Este archivo documenta qué gateway se usa, qué rutas existen, dónde se aplica autenticación y cómo se hace el rate limiting.

# API Gateway
Herramienta: Kong / AWS API GW / Nginx

## Routing
/api/reservas/* → reservas-svc:8080
/api/pagos/* → pagos-svc:8081
/api/usuarios/* → usuarios-svc:8082

Auth: JWT validado en el gateway
Rate limit: 100 req/min por usuario

-----------------------------------------

# -- inter-service-communication.md

Documenta cuándo un servicio debe llamar a otro por REST (síncrono) y cuándo debe usar eventos (asíncrono). Esta decisión impacta directamente el rendimiento y la resiliencia del sistema.

# Cuándo usar cada patrón

Síncrono (REST):
→ Necesitas respuesta inmediata
→ Validar datos antes de continuar
→ Ej: verificar stock antes de comprar

Asíncrono (eventos):
→ No necesitas esperar respuesta
→ Múltiples servicios reaccionan
→ Ej: notificar al crear una reserva

-----------------------------------
#  17 · Gestión de configuración y secrets

Documenta cómo se maneja la configuración de cada servicio en cada ambiente, y cómo se protegen las credenciales y datos sensibles.

>Analogía: Cada microservicio necesita una llave para abrir su base de datos, otra para conectarse al servicio de email, otra para el API de pagos. ¿Dónde viven esas llaves? ¿Quién las cambia? ¿Qué pasa si alguien las ve? Esta sección documenta exactamente eso.

--------------------------------

# --config-strategy.md

Define cómo se gestiona la configuración en todos los ambientes (dev, staging, prod). Documenta si se usa un config server centralizado (Spring Cloud Config, AWS Parameter Store, Consul) o variables de entorno por servicio.

# Configuration strategy
Herramienta: AWS Parameter Store
Patrón: config por ambiente

## Jerarquía
/app/{env}/{servicio}/{clave}

/app/prod/reservas-svc/db_host
/app/dev/reservas-svc/db_host
/app/prod/pagos-svc/stripe_key

--------------------------------

# -- secrets-management.md

Los secrets son las contraseñas, API keys, certificados y tokens que los servicios necesitan para funcionar. Este archivo documenta dónde viven esas credenciales, quién puede accederlas y cómo se rotan.

Por qué es crítico: Si un developer sube por accidente una API key a GitHub, el sistema queda expuesto. Esta documentación evita eso definiendo reglas claras.

# Secrets management
Herramienta: HashiCorp Vault / AWS Secrets Manager

## Reglas obligatorias
✓ Nunca en código fuente
✓ Nunca en variables de entorno en texto plano en prod
✓ Rotación automática cada 90 días
✓ Acceso por rol, no por persona

------------------------------------
