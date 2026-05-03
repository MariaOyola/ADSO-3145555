$dbRoot    = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$migration = Join-Path $dbRoot "migrations\001_schema.sql"
$seed      = Join-Path $dbRoot "seeds\001_reference_data.sql"
$check     = Join-Path $dbRoot "checks\001_smoke_test.sql"