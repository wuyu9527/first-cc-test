package com.enterprise.module.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

import java.util.Set;

public record UpdateUserRequest(
        @Email(message = "邮箱格式不正确")
        String email,

        @Size(max = 20, message = "手机号长度不能超过20位")
        String phone,

        String status,

        Set<String> roleNames
) {}
