# ADR-004 — gender_code sin NOT NULL

## Estado
Propuesto

## Fecha
2026-04-8

## Contexto
El campo gender_code en person es nullable. El CHECK limita los valores a (F, M, X) pero permite NULL. Dependiendo de las reglas de negocio, el género puede ser un campo obligatorio (ej: para emisión de documentos de viaje) o intencional mente opcional.

## Decisión
La decisión de hacerlo nullable es moderna y respetuosa de contextos donde el género no es binario ni obligatorio. Es válida si el negocio lo permite. Si el género es requerido por regulación de aviación civil, debe ser NOT NULL.
## Opciones consideradas

### Opción-Agregar a todas las tablas:

Definir como NOT NULL si es obligatorio por normativa. Mantener nullable si el sistema maneja géneros opcionales o no binarios.

## Consecuencias
- Si el genero llega a ser obligatorio por la reglas de negocio, entonces se debe definir como NOT NULL si es obligatorio por normativa.
- La Opción es definir como NOT NULL si es obligatorio por normativa. Mantener nullable si el sistema maneja géneros opcionales o no binarios.

## Referencias
- tabla : person
- atributos : genero_codeg 

