# Envia um pedido de teste para o pedido-service.

$response = Invoke-RestMethod -Uri "http://localhost:8081/pedidos" -Method Post -ContentType "application/json" -Body '{"cliente": "Lucas", "valor": 150.00}'
$response | ConvertTo-Json
