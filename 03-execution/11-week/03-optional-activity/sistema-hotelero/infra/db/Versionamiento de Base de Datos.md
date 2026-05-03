# 🏨 Sistema de Hotelería — Versionamiento de Base de Datos

> **Proyecto:** Sistema de Hotelería  
> **Módulo:** Base de datos — Migraciones, Seeds y Checks  
> **Tecnología:** MySQL 8 · Docker · PowerShell  
> **Estado:** Versión inicial `v1.0.0`

---

## 📋 Tabla de contenido

1. [¿Qué es este proyecto?](#1-qué-es-este-proyecto)
2. [¿Qué es el versionamiento de base de datos?](#2-qué-es-el-versionamiento-de-base-de-datos)
3. [Estructura del repositorio](#3-estructura-del-repositorio)
4. [Modelo de datos — Tablas y su propósito](#4-modelo-de-datos--tablas-y-su-propósito)
5. [Módulos funcionales](#5-módulos-funcionales)
6. [Requisitos previos](#6-requisitos-previos)
7. [Cómo ejecutar el proyecto paso a paso](#7-cómo-ejecutar-el-proyecto-paso-a-paso)
8. [Verificación — Checks](#8-verificación--checks)
9. [Datos de referencia incluidos (Seeds)](#9-datos-de-referencia-incluidos-seeds)
10. [Restricciones y pendientes conocidos](#10-restricciones-y-pendientes-conocidos)

---

## 1. ¿Qué es este proyecto?

El **Sistema de Hotelería** centraliza la operación hotelera conectando los siguientes módulos:

| Módulo | Qué gestiona |
|---|---|
| Parametrización | Configuración base: empresa, sedes, tipos de habitación, precios |
| Distribución | Habitaciones, catálogo, disponibilidad |
| Prestación de servicio | Reservas, check-in, estadías, check-out |
| Facturación | Pre-factura, factura, pagos parciales, detalle de compra |
| Inventario | Productos, servicios, proveedores, seguimiento de stock |
| Notificación | Alertas, promociones, fidelización, términos |
| Seguridad | Usuarios, roles, permisos, módulos, vistas |
| Mantenimiento | Mantenimiento de habitaciones, remodelaciones, dashboard operativo |

**Actores del sistema:** Cliente · Empleado de recepción · Empleado operativo · Empleado de inventario · Empleado de mantenimiento · Administrador.

---

## 2. ¿Qué es el versionamiento de base de datos?

El versionamiento de base de datos es la práctica de organizar y numerar los cambios del esquema SQL en archivos ordenados, de manera que cualquier persona pueda reproducir la base de datos desde cero ejecutando los scripts en secuencia.

Funciona así:

```
Sin versionamiento                  Con versionamiento
──────────────────                  ──────────────────
"Ejecuta este SQL que              001_schema.sql  → crea todas las tablas
 te mandé por WhatsApp"            002_nueva_tabla.sql → agrega algo nuevo
                                   003_ajuste_campo.sql → modifica algo
```

**Ventajas:**
- Cualquier desarrollador puede levantar la base de datos en minutos.
- Se sabe exactamente qué cambió y cuándo.
- Se pueden deshacer cambios si algo sale mal.
- Facilita el trabajo en equipo sin pisar el trabajo del otro.

---

## 3. Estructura del repositorio

```
sistema_hotelero/
│
├── db/
│   ├── migrations/
│   │   └── 001_schema.sql          ← Crea todas las tablas del sistema
│   │
│   ├── seeds/
│   │   └── 001_reference_data.sql  ← Inserta datos iniciales de referencia
│   │
│   ├── checks/
│   │   └── 001_smoke_test.sql      ← Verifica que la base quedó correcta
│   │
│   └── docker-compose.yml          ← Levanta el contenedor MySQL
│
├── scripts/
│   └── setup.ps1                   ← Automatiza todo el proceso (PowerShell)
│
└── README.md                       ← Este archivo
```

### ¿Para qué sirve cada carpeta?

**`migrations/`** — Contiene el esquema completo de la base de datos. Cada archivo está numerado. Si en el futuro se agrega una tabla nueva, se crea `002_nueva_funcionalidad.sql` sin tocar el archivo anterior.

**`seeds/`** — Contiene datos iniciales que el sistema necesita para funcionar: tipos de habitación, estados, métodos de pago, módulos, roles. Sin estos datos, la aplicación no podría operar.

**`checks/`** — Contiene consultas que verifican que la migración y el seed se ejecutaron correctamente. Actúa como una prueba de humo (smoke test) básica.

---

## 4. Modelo de datos — Tablas y su propósito

El sistema tiene **34 tablas**. A continuación se describe cada una agrupada por su módulo funcional.

### 🔧 Parametrización

| Tabla | Propósito |
|---|---|
| `empresa` | Datos de la empresa hotelera (NIT, razón social, contacto) |
| `informacion_legal` | Documentos legales asociados a la empresa |
| `sede` | Sedes físicas del hotel, cada una con su dirección y ciudad |
| `tipo_habitacion` | Categorías de habitación: Sencilla, Doble, Suite |
| `tipo_dia` | Clasificación de días: entre semana, fin de semana, feriado, temporada alta |
| `metodo_pago` | Formas de pago aceptadas: efectivo, tarjeta, transferencia |
| `precio` | Tarifa por tipo de habitación y tipo de día, con vigencia por fechas |

### 🏠 Distribución

| Tabla | Propósito |
|---|---|
| `habitacion` | Habitaciones físicas de cada sede con su número, piso y capacidad |
| `estado_habitacion` | Estados posibles: Disponible, Reservada, Ocupada, Limpieza, Bloqueada, Mantenimiento |
| `catalogo_habitacion` | Información comercial visible de cada habitación (título, descripción, precio base) |
| `disponibilidad_habitacion` | Registro de rangos de fechas donde una habitación no está disponible |

### 🛎️ Prestación de Servicio

| Tabla | Propósito |
|---|---|
| `cliente` | Datos del huésped: documento, nombre, contacto |
| `reserva_habitacion` | Reserva de una habitación para un cliente en un rango de fechas |
| `cancelacion_habitacion` | Registro de cancelaciones con posible penalidad |
| `estadia` | Estadía activa vinculada a una reserva confirmada |
| `check_in` | Registro del ingreso físico del cliente, hecho por un empleado |
| `check_out` | Registro de la salida del cliente con valor total de la estadía |

### 💰 Facturación

| Tabla | Propósito |
|---|---|
| `pre_factura` | Borrador de factura generado antes del check-out |
| `factura` | Factura oficial emitida al cliente |
| `detalle_compra` | Líneas de detalle de la factura (productos y servicios consumidos) |
| `pago_parcial` | Pagos realizados, que pueden estar asociados a una reserva o a una factura |

### 📦 Inventario

| Tabla | Propósito |
|---|---|
| `proveedor` | Proveedor de productos |
| `producto` | Productos con stock, precio de venta y stock mínimo de alerta |
| `servicio` | Servicios adicionales ofrecidos con su tarifa |
| `venta_producto` | Registro de productos vendidos durante una estadía |
| `venta_servicio` | Registro de servicios prestados durante una estadía |
| `seguimiento_producto` | Historial de movimientos de inventario (entradas y salidas) |
| `disponibilidad_inventario` | Estado actual de disponibilidad de productos y servicios |

### 🔔 Notificación

| Tabla | Propósito |
|---|---|
| `alerta` | Mensajes enviados a clientes o vinculados a reservas |
| `promocion` | Campañas promocionales con fechas de vigencia y canal |
| `termino_condicion` | Versiones de términos y condiciones del servicio |
| `fidelizacion_cliente` | Nivel de fidelización y puntos acumulados por cliente |

### 🔒 Seguridad

| Tabla | Propósito |
|---|---|
| `persona` | Datos base de cualquier persona que interactúa con el sistema |
| `usuario` | Credenciales de acceso vinculadas a una persona |
| `rol` | Roles del sistema: Administrador, Recepción, Mantenimiento, Inventario |
| `permiso` | Acciones permitidas por módulo |
| `usuario_rol` | Asignación de roles a usuarios |
| `rol_permiso` | Asignación de permisos a roles |
| `modulo` | Módulos funcionales del sistema con su ruta base |
| `vista` | Vistas específicas dentro de cada módulo |
| `modulo_vista` | Relación entre módulos y sus vistas |

### 🔨 Mantenimiento

| Tabla | Propósito |
|---|---|
| `mantenimiento_habitacion` | Registro de tareas de mantenimiento por habitación |
| `mantenimiento_uso` | Detalle cuando el mantenimiento es por uso regular |
| `mantenimiento_remodelacion` | Detalle cuando el mantenimiento es una remodelación con presupuesto |
| `dashboard_mantenimiento` | Resumen operativo por sede: habitaciones disponibles, ocupadas y en mantenimiento |

### Campo de auditoría en todas las tablas

Todas las tablas del sistema incluyen los siguientes campos de trazabilidad:

| Campo | Tipo | Propósito |
|---|---|---|
| `created_by` | BIGINT | ID del usuario que creó el registro |
| `created_at` | DATETIME | Fecha y hora de creación |
| `updated_by` | BIGINT | ID del usuario que hizo la última modificación |
| `updated_at` | DATETIME | Fecha y hora de la última modificación |
| `deleted_by` | BIGINT | ID del usuario que eliminó el registro (borrado lógico) |
| `deleted_at` | DATETIME | Fecha y hora del borrado lógico |
| `status` | VARCHAR(30) | Estado del registro: `ACTIVE` o `INACTIVE` |

> El borrado lógico significa que los registros **nunca se eliminan físicamente** de la base de datos. En cambio, se marca `deleted_at` con la fecha y `status` como `INACTIVE`. Esto garantiza trazabilidad completa.

---

## 5. Módulos funcionales

El flujo principal del sistema sigue esta secuencia:

```
CLIENTE consulta disponibilidad
        ↓
RECEPCIÓN crea la reserva
        ↓
RECEPCIÓN hace el check-in  →  se crea la estadía
        ↓
OPERATIVO registra consumos (productos / servicios)
        ↓
RECEPCIÓN genera pre-factura
        ↓
RECEPCIÓN hace el check-out  →  se emite la factura
        ↓
CLIENTE realiza el pago (puede ser parcial o total)
```

---

## 6. Requisitos previos

Antes de ejecutar el proyecto necesitas tener instalado lo siguiente:

| Herramienta | Versión mínima | Para qué se usa |
|---|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Cualquier versión reciente | Levantar el contenedor MySQL |
| PowerShell | 5.1 o superior (ya viene en Windows) | Ejecutar el script de automatización |
| [VS Code](https://code.visualstudio.com/) | Cualquier versión | Editor de código |
| [SQLTools (extensión de VS Code)](https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools) | Cualquier versión | Conectarse a MySQL y ejecutar consultas |
| [SQLTools MySQL Driver](https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-mysql) | Cualquier versión | Driver de conexión para SQLTools |

> ⚠️ **No necesitas instalar MySQL localmente.** El contenedor Docker provee el motor MySQL de forma aislada.

---

## 7. Cómo ejecutar el proyecto paso a paso

### Paso 1 — Clonar o descargar el repositorio

Descarga o clona el proyecto en tu equipo. La carpeta raíz debe tener la estructura mostrada en la sección 3.

### Paso 2 — Abrir Docker Desktop

Abre Docker Desktop y espera a que esté corriendo (ícono en la barra de tareas sin errores).

### Paso 3 — Abrir PowerShell como administrador

Haz clic derecho sobre el menú Inicio → "Windows PowerShell (Administrador)" o busca "PowerShell" y elige "Ejecutar como administrador".

### Paso 4 — Permitir la ejecución de scripts (solo la primera vez)

Ejecuta este comando para permitir scripts locales:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Cuando pregunte, escribe `S` y presiona Enter.

### Paso 5 — Navegar a la carpeta del proyecto

```powershell
cd "C:\ruta\donde\guardaste\el\proyecto"
```

Ejemplo:
```powershell
cd "C:\Users\TuNombre\Documents\sistema_hotelero"
```

### Paso 6 — Ejecutar el script de setup

```powershell
.\scripts\setup.ps1
```

Esto hace automáticamente:
1. Levanta el contenedor Docker con MySQL
2. Espera a que MySQL esté listo (hasta 30 intentos de 2 segundos)
3. Ejecuta `001_schema.sql` → crea todas las tablas
4. Ejecuta `001_reference_data.sql` → inserta los datos iniciales
5. Ejecuta `001_smoke_test.sql` → verifica que todo quedó bien

Si todo salió bien verás al final:
```
Base 'sistema_hotelero' cargada correctamente en 'sistema-hotelero-mysql'.
```

### Paso 7 — Conectar SQLTools en VS Code

1. Abre VS Code
2. En el panel izquierdo haz clic en el ícono de SQLTools (cilindro con un rayo)
3. Haz clic en el botón `+` para agregar una nueva conexión
4. Selecciona **MySQL** como driver
5. Usa estos datos de conexión:

| Campo | Valor |
|---|---|
| Connection Name | sistema_hotelero |
| Server | `localhost` |
| Port | `3306` |
| Database | `sistema_hotelero` |
| Username | `root` |
| Password | `abcd1234` |

6. Haz clic en **Test Connection** para verificar
7. Haz clic en **Save Connection**

### Paso 8 — Verificar la base de datos

Una vez conectado en SQLTools, abre el archivo `checks/001_smoke_test.sql` y ejecútalo. Deberías ver resultados como:

| check_name | value |
|---|---|
| tables_created | 34 |
| tables_with_complete_audit | 34 |
| estado_habitacion | 6 |
| tipo_habitacion | 3 |
| modulos | 8 |

---

## 8. Verificación — Checks

El archivo `checks/001_smoke_test.sql` contiene las siguientes verificaciones:

```sql
-- 1. Verifica cuántas tablas se crearon
SELECT 'tables_created' AS check_name, COUNT(*) AS value
FROM information_schema.tables
WHERE table_schema = 'sistema_hotelero';

-- 2. Verifica que TODAS las tablas tienen los 7 campos de auditoría
SELECT 'tables_with_complete_audit' AS check_name, COUNT(*) AS value
FROM ( ... ) audited_tables;

-- 3. Verifica datos de referencia
SELECT 'estado_habitacion' AS check_name, COUNT(*) AS value FROM estado_habitacion;
SELECT 'tipo_habitacion'   AS check_name, COUNT(*) AS value FROM tipo_habitacion;
SELECT 'modulos'           AS check_name, COUNT(*) AS value FROM modulo;

-- 4. Verifica las habitaciones de ejemplo con sus relaciones
SELECT h.numero, s.nombre AS sede, th.nombre AS tipo, eh.nombre AS estado
FROM habitacion h
JOIN sede s  ON s.id = h.sede_id
JOIN tipo_habitacion th ON th.id = h.tipo_habitacion_id
JOIN estado_habitacion eh ON eh.id = h.estado_habitacion_id;
```

---

## 9. Datos de referencia incluidos (Seeds)

El archivo `seeds/001_reference_data.sql` carga los siguientes datos iniciales:

| Entidad | Datos insertados |
|---|---|
| `empresa` | Hotel Demo · NIT 900000000-1 |
| `tipo_dia` | ENTRE_SEMANA · FIN_SEMANA · FERIADO · TEMPORADA_ALTA |
| `metodo_pago` | EFECTIVO · TARJETA · TRANSFERENCIA |
| `tipo_habitacion` | SENCILLA (cap. 1) · DOBLE (cap. 2) · SUITE (cap. 2-4) |
| `estado_habitacion` | DISPONIBLE · RESERVADA · OCUPADA · LIMPIEZA · BLOQUEADA · MANTENIMIENTO |
| `sede` | Sede Principal · Bogotá |
| `habitacion` | Habitación 101 (Sencilla) · Habitación 201 (Doble) |
| `precio` | $120.000 Sencilla · $180.000 Doble · $320.000 Suite (entre semana) |
| `modulo` | Los 8 módulos del sistema con su ruta base |
| `rol` | ADMINISTRADOR · RECEPCION · MANTENIMIENTO · INVENTARIO |
| `permiso` | GESTIONAR_RESERVA · GESTIONAR_FACTURA · GESTIONAR_INVENTARIO · GESTIONAR_MANTENIMIENTO · CONSULTAR_DASHBOARD |
| `termino_condicion` | Versión v1.0.0 vigente desde 2026-01-01 |

---

## 10. Restricciones y pendientes conocidos

Los siguientes aspectos **no están definidos aún** en la arquitectura del sistema y quedan pendientes para versiones futuras:

| Restricción | Impacto |
|---|---|
| Estados oficiales de reserva, factura y pago no definidos | El campo usa texto libre por ahora |
| Política de cancelación y penalidad sin confirmar | La tabla existe pero las reglas de negocio no están implementadas |
| Reglas de precio dinámico sin definir | Solo existe precio base por tipo de día |
| Integración con pasarela de pago pendiente | Los pagos se registran manualmente |
| Matriz de permisos por rol sin definir | Los roles y permisos existen pero no están asignados |
| Canales de notificación sin especificar | El campo `canal` es texto libre |
| Estrategia de ambientes (dev/qa/prod) sin definir | Por ahora solo existe un ambiente local |

---

## 11. El script `setup.ps1` — explicación detallada

El archivo `scripts/setup.ps1` automatiza todo el proceso de carga de la base de datos. Lo que harías manualmente en 10 pasos, el script lo hace en uno solo.

### ¿Qué hace internamente?

El script tiene 6 bloques lógicos que se ejecutan en orden:

**Bloque 1 — Parámetros de entrada**

```powershell
param(
  [string]$ContainerName = "sistema-hotelero-mysql",
  [string]$RootPassword  = "abcd1234",
  [string]$DatabaseName  = "sistema_hotelero",
  [int]   $MysqlPort     = 3306,
  [switch]$UseExistingContainer
)
```

Todos tienen valores por defecto. Si ejecutas el script sin argumentos, usa estos valores. Puedes sobreescribir cualquiera:

```powershell
.\setup.ps1 -RootPassword "otraClave" -MysqlPort 3307
```

El parámetro `-UseExistingContainer` es un switch — no recibe valor, simplemente se escribe o no. Cuando se pone, el script **no levanta Docker** y asume que el contenedor ya está corriendo.

> ⚠️ La contraseña `abcd1234` es solo para desarrollo local. Nunca uses esta contraseña en un servidor real.

---

**Bloque 2 — Construcción de rutas de archivos**

```powershell
$dbRoot    = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$migration = Join-Path $dbRoot "migrations\001_schema.sql"
$seed      = Join-Path $dbRoot "seeds\001_reference_data.sql"
$check     = Join-Path $dbRoot "checks\001_smoke_test.sql"
```

`$PSCommandPath` es la ruta completa del script en ejecución. Dos llamadas a `Split-Path -Parent` suben dos niveles de carpeta, llegando a la raíz del proyecto. Así los archivos SQL se buscan siempre en la posición correcta sin importar desde qué directorio ejecutes el script.

> ⚠️ Si cambias el script de carpeta sin respetar la estructura, las rutas se rompen.

---

**Bloque 3 — Función `Invoke-MysqlScript`**

```powershell
function Invoke-MysqlScript {
  param([string]$ScriptPath, [string]$TargetDatabase = "")

  Get-Content -LiteralPath $ScriptPath |
    docker exec -i -e "MYSQL_PWD=$RootPassword" $ContainerName mysql -uroot $TargetDatabase
}
```

Esta es la pieza central. `Get-Content` lee el archivo SQL y el pipe `|` envía ese contenido al cliente `mysql` dentro del contenedor Docker — exactamente como si lo escribieras a mano en la terminal de MySQL.

La diferencia entre llamarla con o sin `$TargetDatabase`:

| Llamada | Para qué |
|---|---|
| Sin `TargetDatabase` | La migration — porque el SQL empieza con `CREATE DATABASE`, no puede seleccionar una base antes |
| Con `TargetDatabase` | El seed y el check — el SQL empieza con `USE sistema_hotelero` |

---

**Bloque 4 — Validaciones antes de arrancar**

```powershell
if (-not (Test-Path -LiteralPath $migration)) {
    throw "No existe la migracion: $migration"
}

if (-not $UseExistingContainer) {
    $env:MYSQL_ROOT_PASSWORD = $RootPassword
    $env:MYSQL_DATABASE      = $DatabaseName
    docker compose -f $composeFile up -d
}
```

`Test-Path` verifica que el archivo de migración exista. Si no existe, `throw` detiene el script de inmediato con un mensaje claro.

Las variables `$env:` son variables de entorno que el `docker-compose.yml` lee para configurar el contenedor. El flag `-d` (detached) hace que Docker arranque en segundo plano y devuelva el control a la terminal.

---

**Bloque 5 — Espera activa: ¿está MySQL listo?**

```powershell
for ($attempt = 1; $attempt -le 30; $attempt++) {
    docker exec ... mysqladmin ping -h 127.0.0.1 -uroot --silent 2>$null
    if ($LASTEXITCODE -eq 0) { $ready = $true; break }
    Start-Sleep -Seconds 2
}
```

Docker levanta el contenedor casi instantáneamente, pero MySQL necesita entre 5 y 20 segundos para inicializarse. Si el script enviara el SQL antes de que MySQL esté listo, el comando fallaría.

`mysqladmin ping` es un comando ligero que solo pregunta "¿estás vivo?". `$LASTEXITCODE -eq 0` significa que MySQL respondió exitosamente. El `2>$null` silencia los mensajes de error mientras MySQL no está listo aún.

Tiempo máximo de espera: **30 intentos × 2 segundos = 60 segundos**.

---

**Bloque 6 — Ejecución de los 3 archivos SQL en orden**

```powershell
Invoke-MysqlScript -ScriptPath $migration
Invoke-MysqlScript -ScriptPath $seed  -TargetDatabase $DatabaseName
Invoke-MysqlScript -ScriptPath $check -TargetDatabase $DatabaseName

Write-Host "Base '$DatabaseName' cargada correctamente en '$ContainerName'."
```

Los tres se ejecutan en orden estricto. Si cualquiera falla, `$ErrorActionPreference = "Stop"` (definido al inicio del script) detiene todo de inmediato — no continúa con los siguientes.

---

### Paso a paso para ejecutar el script

**Paso 1 — Abrir Docker Desktop**

Abre Docker Desktop y espera a que esté corriendo (ícono en la barra de tareas sin errores en rojo).

**Paso 2 — Abrir PowerShell como administrador**

Clic derecho en el menú Inicio → "Windows PowerShell (Administrador)".

**Paso 3 — Permitir scripts locales (solo la primera vez)**

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Escribe `S` y presiona Enter cuando pregunte.

**Paso 4 — Ir a la carpeta raíz del proyecto**

```powershell
cd "C:\ruta\al\proyecto\sistema_hotelero"
```

**Paso 5 — Ejecutar el script**

```powershell
.\scripts\setup.ps1
```

El script muestra silencio mientras trabaja. Al terminar verás:

```
Base 'sistema_hotelero' cargada correctamente en 'sistema-hotelero-mysql'.
```

Y en la consola también aparecen los resultados del smoke test, por ejemplo:

```
check_name                    value
tables_created                34
tables_with_complete_audit    34
estado_habitacion             6
tipo_habitacion               3
modulos                       8
```

**Si el contenedor ya estaba corriendo de antes:**

```powershell
.\scripts\setup.ps1 -UseExistingContainer
```

**Si necesitas cambiar el puerto (porque el 3306 está ocupado):**

```powershell
.\scripts\setup.ps1 -MysqlPort 3307
```

---

### Errores frecuentes y cómo resolverlos

| Error | Causa probable | Solución |
|---|---|---|
| `No existe la migracion` | La estructura de carpetas no coincide | Verifica que `migrations\001_schema.sql` exista |
| `No existe el contenedor` | Docker no está corriendo | Abre Docker Desktop y espera que inicie |
| `MySQL no respondio dentro del tiempo esperado` | MySQL tardó más de 60 s | Vuelve a ejecutar con `-UseExistingContainer` cuando Docker esté listo |
| `Cannot be loaded because running scripts is disabled` | PowerShell bloquea scripts | Ejecuta el Paso 3 (Set-ExecutionPolicy) |
| `Error 1062 Duplicate entry` | Ya corriste el seed antes | Normal — los INSERT usan `ON DUPLICATE KEY UPDATE`, el seed es idempotente |

---

## Información del proyecto

| Campo | Detalle |
|---|---|
| Base de datos | `sistema_hotelero` |
| Motor | MySQL 8 |
| Contenedor | `sistema-hotelero-mysql` |
| Puerto | `3306` |
| Usuario | `root` |
| Contraseña | `abcd1234` *(solo para entorno local de desarrollo)* |
| Versión del esquema | `v1.0.0` |