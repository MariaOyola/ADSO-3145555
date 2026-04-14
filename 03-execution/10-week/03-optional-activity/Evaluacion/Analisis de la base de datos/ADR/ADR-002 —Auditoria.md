# ADR-002 — Sin campos de auditoria: created_by, update_by, deleted_at

## Estado
Propuesto

## Fecha
2026-04-8

## Contexto
El esquema tiene created_at y updated_at en todas las tablas, pero omite created_by, updated_by (quién hizo el cambio) y deleted_at (para soft delete). 

## Decisión
El instructor decidió no incluirlos, lo cual es una decisión de diseño válida si la auditoría se maneja en capa de aplicación o con triggers separados. Pero en producción es una carencia importante.

## Opciones consideradas

### Opción-Agregar a todas las tablas:

created_by uuid REFERENCES user_account, updated_by uuid REFERENCES user_account, deleted_at timestamptz (para soft delete).

## Consecuencias
- En un sistema de aerolínea con implicaciones legales y de cumplimiento, la trazabilidad de quién modificó qué es crítica.
- La Opción de agregar estos campos de auditoria permiten que se sepa la trazabilidad de quien hizo la acción y ( crear, actualizar). 

## Referencias
-  created_by, updated_by, deleted_at ( es las tablas que lo necesiten).
