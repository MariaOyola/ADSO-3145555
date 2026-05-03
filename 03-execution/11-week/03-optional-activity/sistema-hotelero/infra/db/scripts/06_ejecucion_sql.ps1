Invoke-MysqlScript -ScriptPath $migration
Invoke-MysqlScript -ScriptPath $seed  -TargetDatabase $DatabaseName
Invoke-MysqlScript -ScriptPath $check -TargetDatabase $DatabaseName

Write-Host "Base '$DatabaseName' cargada correctamente en '$ContainerName'."