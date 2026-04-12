# ADR-003 — person sin unicidad natural ni obligación de documento

## Estado
Propuesto

## Fecha
2026-04-8

## Contexto
La tabla person no tiene ninguna clave natural única. Dos registros con idéntico nombre, fecha de nacimiento y género son indistinguibles en la BD. La unicidad real depende de person_document, pero no hay constraint que exija que toda persona tenga al menos un documento.

## Decisión
El instructor asume que la unicidad se garantiza mediante la combinación con person_document. Esto es aceptable en diseño relacional puro, pero riesgoso en implementación real sin validación en capa de aplicación.

## Opciones consideradas

### Opción-Agregar a todas las tablas:

Agregar CHECK o trigger que valide existencia de al menos un documento, o un índice único parcial sobre (first_name, last_name, birth_date) para personas con datos completos.

## Consecuencias
- La unicidad real depende de person_document, pero no hay constraint que exija que toda persona tenga al menos un documento.
- La Opción de agregar CHECK o trigger para identificar un unico parcial de personas con datos completos osea identificarlos como unicos. 

## Referencias
- tabla : person
- atributos : first_name, last_name, birth_date

