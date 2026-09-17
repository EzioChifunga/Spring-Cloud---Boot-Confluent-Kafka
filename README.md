# Sistema de Pedidos e Notificações (E-commerce Express)

Projeto de exemplo com dois microserviços que se comunicam de forma assíncrona via **Kafka** (Confluent), demonstrando desacoplamento entre produtor e consumidor de eventos com **Spring Boot**.

## 🏗️ Arquitetura

```
               [ Cliente HTTP / Postman ]
                          │
                          ▼
                ┌──────────────────┐
                │  pedido-service  │  (porta 8081)
                └────────┬─────────┘
                         │ (Produz Evento)
                         ▼
             ┌────────────────────────┐
             │      Kafka Topic       │
             │   "pedidos-criados"    │
             └───────────┬────────────┘
                         │ (Consome Evento)
                         ▼
             ┌────────────────────────┐
             │  notificacao-service   │  (porta 8082)
             └────────────────────────┘
```

- **pedido-service**: expõe `POST /pedidos`, salva/valida o pedido e publica um evento `PedidoEvent` no tópico Kafka `pedidos-criados`.
- **Kafka**: atua como message broker, armazenando os eventos no tópico.
- **notificacao-service**: escuta o tópico `pedidos-criados` via `@KafkaListener` e simula o envio de uma notificação, imprimindo um log no terminal.

## 📁 Estrutura do repositório

```
.
├── docker-compose.yml          # Kafka + Zookeeper + Kafka UI (ambiente local via Docker)
├── scripts/                    # Scripts PowerShell prontos para testar sem Docker
│   ├── start-kafka.ps1         # Sobe o Kafka standalone (KRaft) e cria o tópico
│   ├── stop-kafka.ps1
│   ├── start-services.ps1      # Compila (se preciso) e sobe os 2 microserviços
│   ├── stop-services.ps1
│   └── test-pedido.ps1         # Envia um POST /pedidos de teste
├── pedido-service/             # Microserviço produtor (REST + Kafka Producer)
└── notificacao-service/        # Microserviço consumidor (Kafka Listener)
```

## ✅ Ambiente já preparado nesta máquina

Foram instalados e configurados (variáveis de ambiente `JAVA_HOME`/`MAVEN_HOME`/`PATH` a nível de usuário):

- **Java 17** (Eclipse Temurin) — `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot`
- **Maven 3.9.11** — `C:\Tools\apache-maven-3.9.11`
- **Kafka 3.7.1 standalone em modo KRaft** (sem Zookeeper, sem Docker) — `C:\Tools\kafka_2.13-3.7.1`, já formatado e com o tópico `pedidos-criados` criado
- **Docker Desktop**: instalação via `winget` pede elevação de administrador (UAC), que não pôde ser automatizada. Instale manualmente rodando `winget install Docker.DockerDesktop` (ou baixando em docker.com) se quiser usar o `docker-compose.yml`.

> Se você abriu um terminal novo, feche e abra novamente (ou rode `refreshenv`/reinicie o terminal) para carregar as variáveis de ambiente `JAVA_HOME`/`MAVEN_HOME`/`PATH` recém-configuradas.

Fluxo completo **já testado com sucesso** nesta máquina: Kafka standalone → `pedido-service` publicou o evento → `notificacao-service` consumiu e logou a notificação.

## ▶️ Como testar agora (sem Docker, usando os scripts)

```powershell
# 1. Sobe o Kafka standalone (KRaft) e cria o tópico pedidos-criados
.\scripts\start-kafka.ps1

# 2. Compila e sobe os dois microserviços em background
.\scripts\start-services.ps1

# 3. Envia um pedido de teste
.\scripts\test-pedido.ps1

# 4. Acompanhe a notificação em tempo real
Get-Content .\notificacao-service\run.log -Wait -Tail 20
```

Para parar tudo:

```powershell
.\scripts\stop-services.ps1
.\scripts\stop-kafka.ps1
```

> 💡 Os logs usam emojis; se aparecerem como `?` no console, rode `chcp 65001` antes (ou use o Windows Terminal), para garantir UTF-8.

## ▶️ Como rodar (Kafka local via Docker, alternativa)

1. Suba o Kafka local:

   ```bash
   docker compose up -d
   ```

   Isso inicia Zookeeper, Kafka (`localhost:9092`) e o **Kafka UI** em `http://localhost:8080` (equivalente local ao dashboard da Confluent Cloud, útil para ver as mensagens trafegando em tempo real).

2. Rode o `pedido-service` (em um terminal):

   ```bash
   cd pedido-service
   mvn spring-boot:run
   ```

3. Rode o `notificacao-service` (em outro terminal):

   ```bash
   cd notificacao-service
   mvn spring-boot:run
   ```

4. Envie um pedido via Postman/cURL:

   ```bash
   curl -X POST http://localhost:8081/pedidos \
     -H "Content-Type: application/json" \
     -d "{\"cliente\": \"Lucas\", \"valor\": 150.00}"
   ```

5. Observe:
   - O log do `notificacao-service` mostrando a notificação processada instantaneamente.
   - As mensagens chegando no tópico `pedidos-criados` pelo Kafka UI (`http://localhost:8080`).

## ☁️ Usando Confluent Cloud (em vez do Kafka local)

1. Crie uma conta gratuita em [confluent.cloud](https://confluent.cloud) e um cluster básico (leva poucos minutos e o plano gratuito dá créditos iniciais).
2. Crie o tópico `pedidos-criados` (ou deixe o auto-create ligado).
3. Gere uma **API Key/Secret** para o cluster.
4. Em **cada** serviço (`pedido-service/src/main/resources/application.yml` e `notificacao-service/src/main/resources/application.yml`), comente o bloco "Kafka LOCAL" e descomente/preencha o bloco "CONFLUENT CLOUD":

   ```yaml
   spring:
     kafka:
       bootstrap-servers: <SEU_CLUSTER>.confluent.cloud:9092
       properties:
         security.protocol: SASL_SSL
         sasl.mechanism: PLAIN
         sasl.jaas.config: 'org.apache.kafka.common.security.plain.PlainLoginModule required username="<SUA_API_KEY>" password="<SUA_API_SECRET>";'
   ```

5. Não é mais necessário rodar `docker compose up` — o Kafka já está na nuvem. Basta rodar os dois serviços normalmente.
6. Durante a demonstração, abra o painel da Confluent Cloud para mostrar as mensagens/gráficos de tráfego em tempo real no tópico.

> ⚠️ Nunca commite API Key/Secret reais no `application.yml`. Para uso real, prefira variáveis de ambiente (`${KAFKA_API_KEY}`, `${KAFKA_API_SECRET}`).

## 🌐 Endpoints

### `POST /pedidos` (pedido-service, porta 8081)

Cria um pedido e publica o evento no Kafka.

**Request:**
```json
{
  "cliente": "Lucas",
  "valor": 150.00
}
```

**Response (200):**
```json
{
  "id": "3f2a1c9e-...-...",
  "cliente": "Lucas",
  "valor": 150.00
}
```

## 🎯 Roteiro sugerido para apresentação

1. **Introdução (2 min)** — Monolito vs. microserviços; por que usar Kafka (comunicação assíncrona, desacoplamento, resiliência).
2. **Arquitetura (2 min)** — Mostre o diagrama acima e o painel do Kafka UI (ou Confluent Cloud) com o tópico criado.
3. **Demonstração prática (3-5 min)**:
   - Faça um `POST` em `pedido-service` pelo Postman.
   - Mostre o log do `notificacao-service` reagindo instantaneamente.
   - Mostre as mensagens entrando no tópico em tempo real pelo Kafka UI/Confluent Cloud.

## 🛠️ Tecnologias

- Spring Boot 3 (Web, Validation)
- Spring Kafka
- Apache Kafka / Confluent Platform (local via Docker ou Confluent Cloud)
- Kafka UI (visualização local dos tópicos, opcional)
