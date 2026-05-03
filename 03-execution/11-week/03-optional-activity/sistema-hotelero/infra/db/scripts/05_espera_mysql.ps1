for ($attempt = 1; $attempt -le 30; $attempt++) {
    docker exec ... mysqladmin ping -h 127.0.0.1 -uroot --silent 2>$null
    if ($LASTEXITCODE -eq 0) { $ready = $true; break }
    Start-Sleep -Seconds 2
}