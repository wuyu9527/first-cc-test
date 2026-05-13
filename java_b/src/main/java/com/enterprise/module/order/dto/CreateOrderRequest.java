package com.enterprise.module.order.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;

public record CreateOrderRequest(
        @Size(max = 500, message = "备注长度不能超过500个字符")
        String remark,

        @NotEmpty(message = "订单项不能为空")
        @Valid
        List<OrderItemRequest> items
) {

    public record OrderItemRequest(
            java.util.UUID productId,
            @jakarta.validation.constraints.NotNull(message = "数量不能为空")
            @jakarta.validation.constraints.Min(value = 1, message = "数量最小为1")
            Integer quantity
    ) {}
}
