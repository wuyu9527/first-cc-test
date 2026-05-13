package com.enterprise.module.role.service;

import com.enterprise.module.role.dto.CreateRoleRequest;
import com.enterprise.module.role.dto.RoleDto;

import java.util.List;
import java.util.UUID;

public interface RoleService {

    RoleDto create(CreateRoleRequest request);

    RoleDto findById(UUID id);

    List<RoleDto> findAll();

    RoleDto update(UUID id, CreateRoleRequest request);

    void delete(UUID id);
}
