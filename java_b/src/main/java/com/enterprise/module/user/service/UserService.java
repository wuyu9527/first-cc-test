package com.enterprise.module.user.service;

import com.enterprise.module.user.dto.CreateUserRequest;
import com.enterprise.module.user.dto.UpdateUserRequest;
import com.enterprise.module.user.dto.UserDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface UserService {

    UserDto create(CreateUserRequest request);

    UserDto findById(UUID id);

    Page<UserDto> findAll(Pageable pageable);

    UserDto update(UUID id, UpdateUserRequest request);

    void delete(UUID id);

    void assignRoles(UUID userId, java.util.Set<String> roleNames);
}
