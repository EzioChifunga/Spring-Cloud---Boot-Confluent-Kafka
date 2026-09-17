# Para pedido-service e notificacao-service (mas mantem o Kafka rodando).

Get-CimInstance Win32_Process -Filter "Name='java.exe'" |
    Where-Object { $_.CommandLine -like "*pedido-service*" -or $_.CommandLine -like "*notificacao-service*" } |
    ForEach-Object {
        Write-Host "Parando processo (PID $($_.ProcessId))..."
        Stop-Process -Id $_.ProcessId -Force
    }
