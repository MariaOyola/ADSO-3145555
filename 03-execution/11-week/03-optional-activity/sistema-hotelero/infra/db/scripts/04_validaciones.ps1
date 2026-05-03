if (-not (Test-Path -LiteralPath $migration)) {
    throw "No existe la migracion: $migration"
}

if (-not $UseExistingContainer) {
    $env:MYSQL_ROOT_PASSWORD = $RootPassword
    $env:MYSQL_DATABASE      = $DatabaseName
    docker compose -f $composeFile up -d
}