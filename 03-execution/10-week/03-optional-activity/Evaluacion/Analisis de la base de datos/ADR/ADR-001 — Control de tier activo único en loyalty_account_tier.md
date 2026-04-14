# ADR-001 — Control de tier activo único en loyalty_account_tier

## Estado
Propuesto

## Fecha
2026-04-12

## Contexto
La tabla `loyalty_account_tier` registra el historial de niveles 
(tiers) asignados a cada cuenta de lealtad. El constraint actual es:

UNIQUE (loyalty_account_id, assigned_at)

Esto permite que una misma cuenta tenga múltiples tiers sin fecha 
de expiración simultáneamente, siempre que tengan distinto 
`assigned_at`. No existe ninguna restricción en el motor que 
garantice que solo haya un tier vigente por cuenta en un momento dado.

## Decisión
El instructor optó por no implementar control de tier activo único 
a nivel de base de datos, delegando esa responsabilidad a la capa 
de aplicación.

## Opciones consideradas

### Opción A — Delegar a la aplicación (decisión actual)
La lógica de negocio garantiza que al asignar un nuevo tier, 
se cierra el anterior seteando `expires_at`.
-  Esquema más simple
-  Sin garantía en el motor — un bug en la app rompe la consistencia

### Opción B — Índice parcial en PostgreSQL
CREATE UNIQUE INDEX uq_loyalty_account_active_tier
ON loyalty_account_tier (loyalty_account_id)
WHERE expires_at IS NULL;

Garantiza que solo exista un tier activo (sin expiración) por cuenta.
-  Integridad garantizada en el motor
-  Sin costo en filas históricas (índice parcial)
-  Requiere que toda asignación activa tenga expires_at = NULL

## Consecuencias
- Con la decisión actual, un error en aplicación puede crear 
  múltiples tiers activos para una misma cuenta sin que la BD 
  lo detecte.
- La Opción B es la recomendada para un sistema productivo de 
  aerolínea donde la integridad de niveles de lealtad tiene 
  impacto comercial directo.

## Referencias
- Tabla: `loyalty_account_tier`
- Constraint relacionado: `uq_loyalty_account_tier_point`