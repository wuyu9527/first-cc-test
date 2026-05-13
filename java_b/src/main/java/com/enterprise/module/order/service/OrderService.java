package com.enterprise.module.order.service;

import com.enterprise.module.order.dto.CreateOrderRequest;
import com.enterprise.module.order.dto.OrderDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface OrderService {

    OrderDto create(UUID userId, CreateOrderRequest request);

    OrderDto findById(UUID id);

    Page<OrderDto> findByUserId(UUID userId, Pageable pageable);

    Page<OrderDto> findAll(Pageable pageable);

    OrderDto updateStatus(UUID id, String status);

    void cancel(UUID id, UUID userId);
}
