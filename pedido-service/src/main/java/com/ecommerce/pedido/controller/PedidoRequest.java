package com.ecommerce.pedido.controller;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record PedidoRequest(
        @NotBlank(message = "cliente e obrigatorio") String cliente,
        @NotNull(message = "valor e obrigatorio") @Positive(message = "valor deve ser positivo") Double valor
) {
}
