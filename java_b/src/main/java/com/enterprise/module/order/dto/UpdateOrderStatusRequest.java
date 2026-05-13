package com.enterprise.module.order.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateOrderStatusRequest(
        @NotBlank(message = "状态不能为空")
        String status
) {}
