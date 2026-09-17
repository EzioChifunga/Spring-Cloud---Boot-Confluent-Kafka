# Compila (se necessario) e inicia pedido-service e notificacao-service em background.
# Pre-requisito: Kafka rodando (rode start-kafka.ps1 antes, ou docker compose up -d).

$root = Split-Path -Parent $PSScriptRoot
$env:JAVA_HOME = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
$env:MAVEN_HOME = [Environment]::GetEnvironmentVariable("MAVEN_HOME", "User")
$env:Path = "$env:JAVA_HOME\bin;$env:MAVEN_HOME\bin;" + $env:Path
$java = "$env:JAVA_HOME\bin\java.exe"

foreach ($svc in @("pedido-service", "notificacao-service")) {
    $jar = Get-ChildItem "$root\$svc\target\$svc-*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $jar) {
        Write-Host "Compilando $svc..."
        Push-Location "$root\$svc"
        & "$env:MAVEN_HOME\bin\mvn.cmd" -q -DskipTests package
        Pop-Location
        $jar = Get-ChildItem "$root\$svc\target\$svc-*.jar" | Select-Object -First 1
    }

    Write-Host "Iniciando $svc..."
    Start-Process -FilePath $java -ArgumentList "-Dfile.encoding=UTF-8", "-jar", "`"$($jar.FullName)`"" `
        -WindowStyle Hidden `
        -RedirectStandardOutput "$root\$svc\run.log" `
        -RedirectStandardError "$root\$svc\run-err.log"
}

Write-Host "Aguardando servicos subirem..."
Start-Sleep -Seconds 15
Write-Host "pedido-service:      http://localhost:8081/pedidos"
Write-Host "notificacao-service: logs em notificacao-service\run.log"
Write-Host "Use 'Get-Content notificacao-service\run.log -Wait' para acompanhar os eventos em tempo real."
