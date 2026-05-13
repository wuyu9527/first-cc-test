package com.enterprise.module.order.controller;

import com.enterprise.common.security.UserPrincipal;
import com.enterprise.module.order.dto.CreateOrderRequest;
import com.enterprise.module.order.dto.OrderDto;
import com.enterprise.module.order.dto.UpdateOrderStatusRequest;
import com.enterprise.module.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Tag(name = "订单管理", description = "订单 CRUD 和状态流转")
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
@SecurityRequirement(name = "Bearer")
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "创建订单")
    public OrderDto create(@AuthenticationPrincipal UserPrincipal principal,
                           @Valid @RequestBody CreateOrderRequest request) {
        return orderService.create(principal.getUserId(), request);
    }

    @GetMapping("/{id}")
    @Operation(summary = "查询订单详情")
    public OrderDto findById(@PathVariable UUID id) {
        return orderService.findById(id);
    }

    @GetMapping
    @Operation(summary = "查询当前用户订单")
    public Page<OrderDto> findMyOrders(@AuthenticationPrincipal UserPrincipal principal,
                                       @PageableDefault(size = 20) Pageable pageable) {
        return orderService.findByUserId(principal.getUserId(), pageable);
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "查询所有订单（管理员）")
    public Page<OrderDto> findAll(@PageableDefault(size = 20) Pageable pageable) {
        return orderService.findAll(pageable);
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "更新订单状态（管理员）")
    public OrderDto updateStatus(@PathVariable UUID id,
                                 @Valid @RequestBody UpdateOrderStatusRequest request) {
        return orderService.updateStatus(id, request.status());
    }

    @PostMapping("/{id}/cancel")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "取消订单")
    public void cancel(@PathVariable UUID id,
                       @AuthenticationPrincipal UserPrincipal principal) {
        orderService.cancel(id, principal.getUserId());
    }
}
