package com.ecommerce.pedido.controller;

import com.ecommerce.pedido.event.PedidoEvent;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/pedidos")
public class PedidoController {

    private static final Logger log = LoggerFactory.getLogger(PedidoController.class);
    private static final String TOPICO_PEDIDOS_CRIADOS = "pedidos-criados";

    private final KafkaTemplate<String, PedidoEvent> kafkaTemplate;

    public PedidoController(KafkaTemplate<String, PedidoEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @PostMapping
    public ResponseEntity<PedidoEvent> criarPedido(@Valid @RequestBody PedidoRequest request) {
        PedidoEvent pedido = new PedidoEvent(UUID.randomUUID().toString(), request.cliente(), request.valor());

        kafkaTemplate.send(TOPICO_PEDIDOS_CRIADOS, pedido.id(), pedido);
        log.info("Pedido {} publicado no topico '{}' para o cliente {}", pedido.id(), TOPICO_PEDIDOS_CRIADOS, pedido.cliente());

        return ResponseEntity.ok(pedido);
    }
}
