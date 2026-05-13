package com.enterprise.module.order.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record OrderDto(
        UUID id,
        String orderNo,
        UUID userId,
        String username,
        BigDecimal totalAmount,
        BigDecimal discountAmount,
        BigDecimal finalAmount,
        String status,
        String remark,
        List<OrderItemDto> items,
        Instant createdAt,
        Instant updatedAt
) {}
