package com.enterprise.module.role.dto;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

public record RoleDto(
        UUID id,
        String name,
        String description,
        Set<String> permissions,
        Instant createdAt
) {}
