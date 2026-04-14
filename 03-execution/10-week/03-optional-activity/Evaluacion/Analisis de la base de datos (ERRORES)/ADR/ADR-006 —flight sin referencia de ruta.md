# ADR-006 — flight sin referencia de ruta maestra (origen/destino del vuelo completo)

## Estado
Propuesto

## Fecha
2026-04-8

## Contexto
La tabla flight no tiene origin_airport_id ni destination_airport_id. Para saber el itinerario completo del vuelo hay que recorrer todos sus flight_segment ordenados. Esto obliga a JOINs costosos en consultas frecuentes como "listar vuelos de BOG a MIA".

## Decisión
El diseño normalizado es correcto: el origen y destino del vuelo completo se derivan de los segmentos. Pero en la práctica de sistemas OLTP de aerolíneas, se desnormaliza intencionalmente para performance.
## Opciones consideradas

### Opción-Agregar a todas las tablas:

Agregar en flight: origin_airport_id uuid REFERENCES airport, destination_airport_id uuid REFERENCES airport, mantenidos con triggers o por lógica de aplicación.

## Consecuencias
- Esto obliga a JOINs costosos en consultas frecuentes como "listar vuelos de BOG a MIA".
- La Opción es relacionar flight: origin_airport_id uuid REFERENCES airport, destination_airport_id uuid REFERENCES airport, mantenidos con triggers o por lógica de aplicación.

## Referencias
- tabla :  flight, airport


