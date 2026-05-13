package com.enterprise.module.order.service.impl;

import com.enterprise.common.exception.BusinessException;
import com.enterprise.common.exception.ErrorCode;
import com.enterprise.module.order.dto.CreateOrderRequest;
import com.enterprise.module.order.dto.OrderDto;
import com.enterprise.module.order.dto.OrderItemDto;
import com.enterprise.module.order.entity.Order;
import com.enterprise.module.order.entity.OrderItem;
import com.enterprise.module.order.repository.OrderRepository;
import com.enterprise.module.order.service.OrderService;
import com.enterprise.module.user.entity.User;
import com.enterprise.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public OrderDto create(UUID userId, CreateOrderRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        Order order = Order.builder()
                .orderNo(generateOrderNo())
                .user(user)
                .status(Order.OrderStatus.PENDING)
                .remark(request.remark())
                .discountAmount(BigDecimal.ZERO)
                .build();

        for (CreateOrderRequest.OrderItemRequest itemReq : request.items()) {
            // 实际项目中应查询商品信息并校验库存
            OrderItem item = OrderItem.builder()
                    .productId(itemReq.productId())
                    .productName("Product-" + itemReq.productId().toString().substring(0, 8))
                    .quantity(itemReq.quantity())
                    .unitPrice(new BigDecimal("99.99")) // 模拟定价
                    .subtotal(new BigDecimal("99.99").multiply(BigDecimal.valueOf(itemReq.quantity())))
                    .build();
            order.addItem(item);
        }
        order.recalculateAmount();

        order = orderRepository.save(order);
        return toDto(order);
    }

    @Override
    public OrderDto findById(UUID id) {
        Order order = orderRepository.findByIdWithUser(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ORDER_NOT_FOUND));
        return toDto(order);
    }

    @Override
    public Page<OrderDto> findByUserId(UUID userId, Pageable pageable) {
        return orderRepository.findByUserId(userId, pageable).map(this::toDto);
    }

    @Override
    public Page<OrderDto> findAll(Pageable pageable) {
        return orderRepository.findAllWithUser(pageable).map(this::toDto);
    }

    @Override
    @Transactional
    public OrderDto updateStatus(UUID id, String status) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ORDER_NOT_FOUND));
        try {
            Order.OrderStatus newStatus = Order.OrderStatus.valueOf(status);
            validateStatusTransition(order.getStatus(), newStatus);
            order.setStatus(newStatus);
        } catch (IllegalArgumentException e) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_INVALID, "无效的订单状态: " + status);
        }
        orderRepository.save(order);
        return toDto(order);
    }

    @Override
    @Transactional
    public void cancel(UUID id, UUID userId) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ORDER_NOT_FOUND));
        if (!order.getUser().getId().equals(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "只能取消自己的订单");
        }
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_INVALID, "只有待确认的订单才能取消");
        }
        order.setStatus(Order.OrderStatus.CANCELLED);
        orderRepository.save(order);
    }

    private void validateStatusTransition(Order.OrderStatus current, Order.OrderStatus target) {
        boolean valid = switch (current) {
            case PENDING -> target == Order.OrderStatus.CONFIRMED || target == Order.OrderStatus.CANCELLED;
            case CONFIRMED -> target == Order.OrderStatus.SHIPPED;
            case SHIPPED -> target == Order.OrderStatus.DELIVERED;
            case DELIVERED -> target == Order.OrderStatus.REFUNDED;
            default -> false;
        };
        if (!valid) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_INVALID,
                    "不允许从 " + current + " 变更为 " + target);
        }
    }

    private String generateOrderNo() {
        long timestamp = Instant.now().toEpochMilli();
        int random = ThreadLocalRandom.current().nextInt(1000, 9999);
        return "ORD" + timestamp + random;
    }

    private OrderDto toDto(Order order) {
        List<OrderItemDto> itemDtos = order.getItems().stream()
                .map(item -> new OrderItemDto(
                        item.getId(),
                        item.getProductId(),
                        item.getProductName(),
                        item.getQuantity(),
                        item.getUnitPrice(),
                        item.getSubtotal()))
                .toList();
        return new OrderDto(
                order.getId(),
                order.getOrderNo(),
                order.getUser().getId(),
                order.getUser().getUsername(),
                order.getTotalAmount(),
                order.getDiscountAmount(),
                order.getFinalAmount(),
                order.getStatus().name(),
                order.getRemark(),
                itemDtos,
                order.getCreatedAt(),
                order.getUpdatedAt()
        );
    }
}
