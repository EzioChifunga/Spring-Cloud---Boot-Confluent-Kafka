package com.ecommerce.pedido.event;

public record PedidoEvent(String id, String cliente, Double valor) {
}
