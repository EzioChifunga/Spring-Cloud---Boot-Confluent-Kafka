# Inicia o Kafka standalone (modo KRaft, sem Zookeeper/Docker).
# Requer que o storage ja tenha sido formatado uma vez (kafka-storage.bat format).

$kafkaHome = "C:\Tools\kafka_2.13-3.7.1"
$env:JAVA_HOME = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")

Write-Host "Iniciando Kafka (KRaft) em localhost:9092..."
Start-Process -FilePath "$kafkaHome\bin\windows\kafka-server-start.bat" `
    -ArgumentList "`"$kafkaHome\config\kraft\server.properties`"" `
    -WindowStyle Hidden `
    -RedirectStandardOutput "$kafkaHome\kafka-out.log" `
    -RedirectStandardError "$kafkaHome\kafka-err.log"

Start-Sleep -Seconds 10
Write-Host "Kafka iniciado. Logs em $kafkaHome\kafka-out.log"

Write-Host "Criando topico 'pedidos-criados' (ignora erro se ja existir)..."
& "$kafkaHome\bin\windows\kafka-topics.bat" --create --topic pedidos-criados --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 2>$null
& "$kafkaHome\bin\windows\kafka-topics.bat" --list --bootstrap-server localhost:9092
