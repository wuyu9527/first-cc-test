package com.enterprise.module.user.controller;

import com.enterprise.common.dto.ApiResponse;
import com.enterprise.module.role.dto.AssignRoleRequest;
import com.enterprise.module.user.dto.CreateUserRequest;
import com.enterprise.module.user.dto.UpdateUserRequest;
import com.enterprise.module.user.dto.UserDto;
import com.enterprise.module.user.service.UserService;
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
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Tag(name = "用户管理", description = "用户 CRUD 和角色分配")
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@SecurityRequirement(name = "Bearer")
public class UserController {

    private final UserService userService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "注册新用户")
    public UserDto create(@Valid @RequestBody CreateUserRequest request) {
        return userService.create(request);
    }

    @GetMapping("/{id}")
    @Operation(summary = "查询用户详情")
    public UserDto findById(@PathVariable UUID id) {
        return userService.findById(id);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "分页查询用户列表（管理员）")
    public Page<UserDto> findAll(@PageableDefault(size = 20) Pageable pageable) {
        return userService.findAll(pageable);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新用户信息")
    public UserDto update(@PathVariable UUID id, @Valid @RequestBody UpdateUserRequest request) {
        return userService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "删除用户（管理员）")
    public void delete(@PathVariable UUID id) {
        userService.delete(id);
    }

    @PutMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "分配用户角色（管理员）")
    public void assignRoles(@PathVariable UUID id, @Valid @RequestBody AssignRoleRequest request) {
        userService.assignRoles(id, request.roleNames());
    }
}
