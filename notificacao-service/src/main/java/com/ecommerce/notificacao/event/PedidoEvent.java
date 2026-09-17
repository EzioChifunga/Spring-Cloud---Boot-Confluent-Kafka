package com.ecommerce.notificacao.event;

public record PedidoEvent(String id, String cliente, Double valor) {
}
