param(
    [string]$ContainerName = "sistema-hotelero-mysql",
    [string]$RootPassword = "abcd1234",
    [string]$DatabaseName = "sistema_hotelero",
    [int]$MysqlPort = 3306,
    [switch]$UseExistingContainer
)

$ErrorActionPreference = "Stop"

$dbRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$migration = Join-Path $dbRoot "migrations\001_schema.sql"
$seed = Join-Path $dbRoot "seeds\001_reference_data.sql"
$check = Join-Path $dbRoot "checks\001_smoke_test.sql"
$composeFile = Join-Path $dbRoot "docker-compose.yml"

function Invoke-MysqlScript {
    param(
        [string]$ScriptPath,
        [string]$TargetDatabase = ""
    )

    if ($TargetDatabase -eq "") {
        Get-Content -LiteralPath $ScriptPath | docker exec -i -e "MYSQL_PWD=$RootPassword" $ContainerName mysql -uroot
        return
    }

    Get-Content -LiteralPath $ScriptPath | docker exec -i -e "MYSQL_PWD=$RootPassword" $ContainerName mysql -uroot $TargetDatabase
}

if (-not (Test-Path -LiteralPath $migration)) {
    throw "No existe la migracion: $migration"
}

if (-not $UseExistingContainer) {
    $env:MYSQL_ROOT_PASSWORD = $RootPassword
    $env:MYSQL_DATABASE = $DatabaseName
    $env:MYSQL_PORT = "$MysqlPort"
    docker compose -f $composeFile up -d
}

$status = docker inspect $ContainerName --format "{{.State.Status}}" 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($status)) {
    throw "No existe el contenedor '$ContainerName'. Usa -UseExistingContainer con un nombre valido o levanta docker-compose."
}

if ($status -ne "running") {
    docker start $ContainerName | Out-Null
}

$ready = $false
for ($attempt = 1; $attempt -le 30; $attempt++) {
    docker exec -e "MYSQL_PWD=$RootPassword" $ContainerName mysqladmin ping -h 127.0.0.1 -uroot --silent 2>$null
    if ($LASTEXITCODE -eq 0) {
        $ready = $true
        break
    }
    Start-Sleep -Seconds 2
}

if (-not $ready) {
    throw "MySQL no respondio dentro del tiempo esperado en el contenedor '$ContainerName'."
}

Invoke-MysqlScript -ScriptPath $migration
Invoke-MysqlScript -ScriptPath $seed -TargetDatabase $DatabaseName
Invoke-MysqlScript -ScriptPath $check -TargetDatabase $DatabaseName

Write-Host "Base '$DatabaseName' cargada correctamente en '$ContainerName'."
