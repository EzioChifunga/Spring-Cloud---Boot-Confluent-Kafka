# Para o processo do Kafka standalone (KRaft).

Get-CimInstance Win32_Process -Filter "Name='java.exe'" |
    Where-Object { $_.CommandLine -like "*kafka.Kafka*" -or $_.CommandLine -like "*kraft*server.properties*" } |
    ForEach-Object {
        Write-Host "Parando Kafka (PID $($_.ProcessId))..."
        Stop-Process -Id $_.ProcessId -Force
    }
