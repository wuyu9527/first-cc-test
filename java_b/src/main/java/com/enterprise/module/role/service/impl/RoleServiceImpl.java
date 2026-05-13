package com.enterprise.module.role.service.impl;

import com.enterprise.common.exception.BusinessException;
import com.enterprise.common.exception.ErrorCode;
import com.enterprise.module.role.dto.CreateRoleRequest;
import com.enterprise.module.role.dto.RoleDto;
import com.enterprise.module.role.entity.Permission;
import com.enterprise.module.role.entity.Role;
import com.enterprise.module.role.repository.PermissionRepository;
import com.enterprise.module.role.repository.RoleRepository;
import com.enterprise.module.role.repository.UserRoleRepository;
import com.enterprise.module.role.service.RoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;
    private final UserRoleRepository userRoleRepository;

    @Override
    @Transactional
    public RoleDto create(CreateRoleRequest request) {
        if (roleRepository.existsByName(request.name())) {
            throw new BusinessException(ErrorCode.ROLE_NAME_EXISTS);
        }

        Set<Permission> permissions = new HashSet<>();
        if (request.permissionNames() != null && !request.permissionNames().isEmpty()) {
            permissions = permissionRepository.findByNameIn(request.permissionNames());
        }

        Role role = Role.builder()
                .name(request.name())
                .description(request.description())
                .permissions(permissions)
                .build();
        role = roleRepository.save(role);
        return toDto(role);
    }

    @Override
    public RoleDto findById(UUID id) {
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ROLE_NOT_FOUND));
        return toDto(role);
    }

    @Override
    public List<RoleDto> findAll() {
        return roleRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public RoleDto update(UUID id, CreateRoleRequest request) {
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ROLE_NOT_FOUND));

        if (!request.name().equals(role.getName()) && roleRepository.existsByName(request.name())) {
            throw new BusinessException(ErrorCode.ROLE_NAME_EXISTS);
        }

        role.setName(request.name());
        role.setDescription(request.description());

        if (request.permissionNames() != null) {
            role.setPermissions(permissionRepository.findByNameIn(request.permissionNames()));
        }

        roleRepository.save(role);
        return toDto(role);
    }

    @Override
    @Transactional
    public void delete(UUID id) {
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ROLE_NOT_FOUND));
        // 检查是否有用户正在使用该角色
        long count = userRoleRepository.findAll().stream()
                .filter(ur -> ur.getRoles().contains(role))
                .count();
        if (count > 0) {
            throw new BusinessException(ErrorCode.ROLE_IN_USE);
        }
        roleRepository.delete(role);
    }

    private RoleDto toDto(Role role) {
        Set<String> permissionNames = role.getPermissions().stream()
                .map(Permission::getName)
                .collect(Collectors.toSet());
        return new RoleDto(role.getId(), role.getName(), role.getDescription(), permissionNames, role.getCreatedAt());
    }
}
