package com.enterprise.module.user.dto;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

public record UserDto(
        UUID id,
        String username,
        String email,
        String phone,
        String status,
        Set<String> roles,
        Instant lastLoginAt,
        Instant createdAt,
        Instant updatedAt
) {}
