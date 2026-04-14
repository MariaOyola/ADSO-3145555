# ADR-005 — Índice adicional en flight_number

## Estado
Propuesto

## Fecha
2026-04-8

## Contexto
flight_number tiene un índice compuesto (airline_id, flight_number, service_date) por el UNIQUE constraint, pero no tiene un índice individual. Búsquedas por flight_number solo (sin airline_id) no usarán eficientemente ese índice compuesto.

## Decisión
El instructor asumió que las búsquedas siempre incluirán airline_id. En una aerolínea única esto es razonable. En un sistema multi-aerolínea podría ser insuficiente.
## Opciones consideradas

### Opción-Agregar a todas las tablas:

CREATE INDEX idx_flight_number ON flight(flight_number); si se prevén búsquedas por número de vuelo sin filtro de aerolínea.

## Consecuencias
- No usa induces individual
- La Opción es crear CREATE INDEX idx_flight_number ON flight(flight_number), para asi buscar por flight_number sin filtro de aerolinea. 

## Referencias
- tabla :  flight
- atributo : flight_number

