package com.enterprise.module.auth.controller;

import com.enterprise.common.security.UserPrincipal;
import com.enterprise.module.auth.dto.LoginRequest;
import com.enterprise.module.auth.dto.LoginResponse;
import com.enterprise.module.auth.dto.RefreshRequest;
import com.enterprise.module.auth.service.AuthService;
import com.enterprise.module.user.dto.UserDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "认证管理", description = "登录、注册和 Token 刷新")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    @Operation(summary = "刷新 Token")
    public LoginResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return authService.refresh(request.refreshToken());
    }

    @GetMapping("/me")
    @Operation(summary = "获取当前用户信息")
    @SecurityRequirement(name = "Bearer")
    public UserDto me(@AuthenticationPrincipal UserPrincipal principal) {
        return authService.me(principal.getUserId());
    }
}
