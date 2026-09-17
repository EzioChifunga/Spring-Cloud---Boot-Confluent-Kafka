package com.ecommerce.notificacao.listener;

import com.ecommerce.notificacao.event.PedidoEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class NotificacaoListener {

    private static final Logger log = LoggerFactory.getLogger(NotificacaoListener.class);

    @KafkaListener(topics = "pedidos-criados", groupId = "grupo-notificacao")
    public void processarNotificacao(PedidoEvent pedido) {
        log.info("==================================================");
        log.info("📧 NOTIFICACAO: Pedido recebido para {}", pedido.cliente());
        log.info("🆔 Pedido ID: {}", pedido.id());
        log.info("💰 Valor Total: R$ {}", String.format("%.2f", pedido.valor()));
        log.info("==================================================");
    }
}
