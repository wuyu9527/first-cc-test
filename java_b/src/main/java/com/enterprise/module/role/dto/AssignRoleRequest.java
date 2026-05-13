package com.enterprise.module.role.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.Set;
import java.util.UUID;

public record AssignRoleRequest(
        @NotEmpty(message = "角色列表不能为空")
        Set<String> roleNames
) {}
