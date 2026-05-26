##  00-documentation-governance/

- reglas de como se escribe y mantiene esta documentacion 

Define cómo funciona el repositorio de documentación: quién puede editar, cómo se revisa, cómo se nombran los archivos. Es el 'reglamento interno' de la doc. Para cualquier proyecto de microservicios es importante tenerlo para que varios equipos documenten de forma coherente.

## Esencial para microservicios

-------------------------------------
##  01-project-context

- " EL POR QUE" del sistema: negocios, domineo, actores y reglas. 

Explica el problema que resuelve el sistema, los objetivos de negocio, el alcance, las restricciones y las suposiciones del proyecto. Es la base de todo: sin esto no se puede diseñar ningún microservicio correctamente. Aplica igual para una veterinaria, un hotel o un parqueadero.

## Esencial para microservicios

-----------------------------------------------------
##  02-sena-domain

Esta carpeta está nombrada específicamente para el dominio SENA (institución educativa). Contiene glosario, conceptos institucionales, actores y reglas de negocio propias de ese dominio.

Para otro proyecto (veterinaria, hotel, parqueadero), esta carpeta se RENOMBRA y se reescribe completamente. El concepto es correcto (documentar el dominio), pero el contenido es 100% específico del cliente.


##  Importante pero adaptable

----------------------------------------------------------------

##  03-product-definition

- Que contruye el sistema: Vision, MVP, personas, historial y requisitos 

Esta carpeta está nombrada específicamente para el dominio SENA (institución educativa). Contiene glosario, conceptos institucionales, actores y reglas de negocio propias de ese dominio.

Para otro proyecto (veterinaria, hotel, parqueadero), esta carpeta se RENOMBRA y se reescribe completamente. El concepto es correcto (documentar el dominio), pero el contenido es 100% específico del cliente.

##  Esencial para microservicios

-----------------------------------------------------------------
## 04-architecture

- Como esta contruido el  sistema: decisiones, C4,datos

El corazón técnico. Documenta los principios de arquitectura, el panorama general del sistema, decisiones técnicas (ADRs), atributos de calidad, estrategia de integración y despliegue. Incluye diagramas C4 (4 niveles: contexto, contenedores, componentes, código). Absolutamente esencial para microservicios.

##  Esencial para microservicios

---------------------------------------------------------------------

## 05-data-architecture

- Como esta contruido el  sistema: decisiones, C4,datos

En microservicios cada servicio tiene su propia base de datos (principio 'database per service'). Esta carpeta documenta el modelo conceptual, lógico y relacional, el diccionario de datos y cómo se migran los datos. Sin esto no se puede saber qué datos maneja cada microservicio ni cómo se relacionan.

> en  esto esta eld iagrama mer

##  Esencial para microservicios
-------------------------------------------------------------------------

##  06-api-design

- Contratos entre servivios y proteccion del sistema

En microservicios, los servicios se comunican por APIs. Esta carpeta define los estándares REST, manejo de errores, paginación, autenticación, versionado y los contratos API. Sin esto los microservicios no pueden comunicarse de forma predecible y coherente.


##  Esencial para microservicios

---------------------------------------------------------------------------

##  07-security

- Contratos entre servivios y proteccion del sistema

Documenta cómo se protege el sistema: gestión de identidades, roles y permisos, modelo de amenazas, protección de datos y auditoría. En microservicios la seguridad es más compleja porque hay muchos puntos de entrada. Este módulo es esencial para cualquier proyecto.

##  Esencial para microservicios
-------------------------------------------------------------------------
##  08-devops 

- Como se despliega y como se prueba el sistema

Documenta la estrategia de repositorios, ramas (GitFlow, trunk-based), CI/CD, ambientes (dev, staging, prod), estándares Docker y observabilidad (logs, métricas, trazas). En microservicios el CI/CD es crítico porque hay múltiples servicios que se despliegan independientemente.
##  Esencial para microservicios
------------------------------------

##   09-quality-assurance

-  Como se despliega y como se prueba el sistema

Define la estrategia de pruebas: unitarias, integración, end-to-end, rendimiento y accesibilidad. En microservicios son especialmente importantes las pruebas de integración entre servicios (consumer-driven contract testing). Las quality gates definen cuándo un servicio está listo para producción.

##  Esencial para microservicios

-------------------------------------------------------


##    10-user-experience

-   Esperiencias del usuario : Diseño, navegaciones y accesibilidad

Documenta los principios UX, arquitectura de información, modelo de navegación, wireframes, sistema de diseño y guías de accesibilidad. En microservicios con frontend propio (React, Vue, Angular) es importante.

##  Esencial para microservicios

--------------------------------------------------------

##    11-backlog  historiales de usuario y tareas

-   Esperiencias del usuario : Diseño, navegaciones y accesibilidad

Contiene las épicas (grandes funcionalidades), features (funcionalidades), historias de usuario y tareas. La matriz de trazabilidad vincula cada historia con requisitos y microservicios. Muy útil si el equipo trabaja en metodología ágil. 

##  Esencial para microservicios
------------------------------------------

##   12-microservices

-   documentacion de cada microservicio

Contiene el catálogo de todos los microservicios y una plantilla que cada servicio usa para documentarse: contexto, responsabilidades, límites, API, modelo de datos, seguridad, despliegue, pruebas y runbook. Cada microservicio nuevo que se agregue al sistema debe tener su propia subcarpeta aquí.

##  Esencial para microservicios
-----------------------------------------------------
##    13-operations

-    como se opera y enseña el sistema

Documentación operacional: runbooks (procedimientos paso a paso), gestión de incidentes, backup/restore, monitoreo y alertas, y modelo de soporte. En producción con microservicios esto es crítico porque un incidente puede involucrar múltiples servicios a la vez.

##  Importante, adaptable

-------------------------------------------------------
##    14-training-and-adoption

-    como se opera y enseña el sistema

Manual de usuario, guía del instructor, guía del administrador, onboarding y FAQ. Útil cuando el sistema tiene usuarios finales no técnicos que necesitan capacitación. En proyectos puramente técnicos (microservicios internos) puede reducirse al onboarding para desarrolladores y el FAQ.

##  Opcional según proyecto


