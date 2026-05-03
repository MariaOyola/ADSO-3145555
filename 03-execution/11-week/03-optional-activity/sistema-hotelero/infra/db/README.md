# Infraestructura de base de datos

Base fisica inicial para MySQL 8 del sistema hotelero, construida desde la documentacion en `docs/architecture/model-data`.

## Estructura

- `migrations/001_schema.sql`: crea la base `sistema_hotelero`, tablas, relaciones e indices.
- `seeds/001_reference_data.sql`: carga catalogos minimos para operar la primera version.
- `checks/001_smoke_test.sql`: consultas de validacion rapida despues de cargar la base.
- `docker-compose.yml`: define el contenedor MySQL 8 del sistema hotelero.
- `scripts/load-database.ps1`: levanta o reutiliza el contenedor y carga migracion, seeds y validacion.

## Flujo recomendado

Crear el contenedor `sistema-hotelero-mysql` y cargar la base:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File infra/db/scripts/load-database.ps1
```

Reutilizar un contenedor MySQL existente:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File infra/db/scripts/load-database.ps1 -ContainerName db-mysql -RootPassword abcd1234 -DatabaseName sistema_hotelero -UseExistingContainer
```

## Carga en MySQL Docker

Ejecutar desde la raiz del repositorio:

```powershell
docker exec -i <mysql-container> mysql -uroot -p<password> < infra/db/migrations/001_schema.sql
docker exec -i <mysql-container> mysql -uroot -p<password> sistema_hotelero < infra/db/seeds/001_reference_data.sql
docker exec -i <mysql-container> mysql -uroot -p<password> sistema_hotelero < infra/db/checks/001_smoke_test.sql
```

Si MySQL esta publicado en `localhost:3306`:

```powershell
mysql -h 127.0.0.1 -P 3306 -uroot -p < infra/db/migrations/001_schema.sql
mysql -h 127.0.0.1 -P 3306 -uroot -p sistema_hotelero < infra/db/seeds/001_reference_data.sql
mysql -h 127.0.0.1 -P 3306 -uroot -p sistema_hotelero < infra/db/checks/001_smoke_test.sql
```

## Decisiones iniciales

- Identificador: `BIGINT UNSIGNED AUTO_INCREMENT`, siguiendo la recomendacion documental.
- Auditoria: todas las tablas tienen `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted_by`, `deleted_at` y `status`.
- Eliminacion logica: se soporta con `deleted_at`, `deleted_by` y `status`.
- Charset: `utf8mb4` y collation `utf8mb4_unicode_ci`.
- Valores pendientes por confirmar se modelan como `VARCHAR` para no bloquear el avance: estados de reserva, factura, pago, mantenimiento y reglas de precio dinamico.
