package com.enterprise.module.role.controller;

import com.enterprise.module.role.dto.CreateRoleRequest;
import com.enterprise.module.role.dto.RoleDto;
import com.enterprise.module.role.service.RoleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@Tag(name = "角色管理", description = "角色和权限管理（管理员）")
@RestController
@RequestMapping("/api/v1/roles")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@SecurityRequirement(name = "Bearer")
public class RoleController {

    private final RoleService roleService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "创建角色")
    public RoleDto create(@Valid @RequestBody CreateRoleRequest request) {
        return roleService.create(request);
    }

    @GetMapping("/{id}")
    @Operation(summary = "查询角色详情")
    public RoleDto findById(@PathVariable UUID id) {
        return roleService.findById(id);
    }

    @GetMapping
    @Operation(summary = "查询所有角色")
    public List<RoleDto> findAll() {
        return roleService.findAll();
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新角色")
    public RoleDto update(@PathVariable UUID id, @Valid @RequestBody CreateRoleRequest request) {
        return roleService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "删除角色")
    public void delete(@PathVariable UUID id) {
        roleService.delete(id);
    }
}
