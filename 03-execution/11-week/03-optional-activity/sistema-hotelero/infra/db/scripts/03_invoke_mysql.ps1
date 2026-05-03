function Invoke-MysqlScript {
  param([string]$ScriptPath, [string]$TargetDatabase = "")

  Get-Content -LiteralPath $ScriptPath |
    docker exec -i -e "MYSQL_PWD=$RootPassword" $ContainerName mysql -uroot $TargetDatabase
}