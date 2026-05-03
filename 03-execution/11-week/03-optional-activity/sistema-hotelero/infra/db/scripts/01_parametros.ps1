param(
  [string]$ContainerName = "sistema-hotelero-mysql",
  [string]$RootPassword  = "abcd1234",
  [string]$DatabaseName  = "sistema_hotelero",
  [int]   $MysqlPort     = 3306,
  [switch]$UseExistingContainer
)