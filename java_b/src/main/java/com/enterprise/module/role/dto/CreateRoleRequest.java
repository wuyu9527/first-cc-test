package com.enterprise.module.role.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.Set;

public record CreateRoleRequest(
        @NotBlank(message = "角色名称不能为空")
        @Size(min = 2, max = 50, message = "角色名称长度为2-50个字符")
        String name,

        @Size(max = 200, message = "描述长度不能超过200个字符")
        String description,

        Set<String> permissionNames
) {}
