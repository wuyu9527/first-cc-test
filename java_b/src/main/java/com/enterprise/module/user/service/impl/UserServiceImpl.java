package com.enterprise.module.user.service.impl;

import com.enterprise.common.exception.BusinessException;
import com.enterprise.common.exception.ErrorCode;
import com.enterprise.module.role.entity.Role;
import com.enterprise.module.role.entity.UserRole;
import com.enterprise.module.role.repository.RoleRepository;
import com.enterprise.module.role.repository.UserRoleRepository;
import com.enterprise.module.user.dto.CreateUserRequest;
import com.enterprise.module.user.dto.UpdateUserRequest;
import com.enterprise.module.user.dto.UserDto;
import com.enterprise.module.user.entity.User;
import com.enterprise.module.user.repository.UserRepository;
import com.enterprise.module.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final UserRoleRepository userRoleRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public UserDto create(CreateUserRequest request) {
        if (userRepository.existsByUsername(request.username())) {
            throw new BusinessException(ErrorCode.USERNAME_EXISTS);
        }
        if (userRepository.existsByEmail(request.email())) {
            throw new BusinessException(ErrorCode.EMAIL_EXISTS);
        }

        User user = User.builder()
                .username(request.username())
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .phone(request.phone())
                .status(User.UserStatus.ACTIVE)
                .build();
        user = userRepository.save(user);

        // 默认分配 USER 角色
        Role defaultRole = roleRepository.findByName("USER")
                .orElseGet(() -> {
                    Role r = new Role();
                    r.setName("USER");
                    r.setDescription("普通用户");
                    return roleRepository.save(r);
                });

        UserRole userRole = UserRole.builder()
                .userId(user.getId())
                .roles(Set.of(defaultRole))
                .build();
        userRoleRepository.save(userRole);

        return toDto(user, Set.of("USER"));
    }

    @Override
    public UserDto findById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
        Set<String> roles = userRoleRepository.findByUserIdWithRoles(id)
                .map(ur -> ur.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                .orElse(Set.of());
        return toDto(user, roles);
    }

    @Override
    public Page<UserDto> findAll(Pageable pageable) {
        return userRepository.findAll(pageable)
                .map(user -> {
                    Set<String> roles = userRoleRepository.findByUserIdWithRoles(user.getId())
                            .map(ur -> ur.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                            .orElse(Set.of());
                    return toDto(user, roles);
                });
    }

    @Override
    @Transactional
    public UserDto update(UUID id, UpdateUserRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        if (request.email() != null && !request.email().equals(user.getEmail())) {
            if (userRepository.existsByEmail(request.email())) {
                throw new BusinessException(ErrorCode.EMAIL_EXISTS);
            }
            user.setEmail(request.email());
        }
        if (request.phone() != null) {
            user.setPhone(request.phone());
        }
        if (request.status() != null) {
            user.setStatus(User.UserStatus.valueOf(request.status()));
        }
        userRepository.save(user);

        Set<String> roles = new HashSet<>();
        if (request.roleNames() != null && !request.roleNames().isEmpty()) {
            assignRoles(id, request.roleNames());
            roles.addAll(request.roleNames());
        } else {
            roles = userRoleRepository.findByUserIdWithRoles(id)
                    .map(ur -> ur.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                    .orElse(Set.of());
        }

        return toDto(user, roles);
    }

    @Override
    @Transactional
    public void delete(UUID id) {
        if (!userRepository.existsById(id)) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        userRoleRepository.deleteByUserId(id);
        userRepository.deleteById(id);
    }

    @Override
    @Transactional
    public void assignRoles(UUID userId, Set<String> roleNames) {
        Set<Role> roles = roleRepository.findByNameInWithPermissions(roleNames);
        if (roles.size() != roleNames.size()) {
            throw new BusinessException(ErrorCode.ROLE_NOT_FOUND, "部分角色不存在");
        }
        UserRole userRole = userRoleRepository.findByUserId(userId)
                .orElse(UserRole.builder().userId(userId).build());
        userRole.setRoles(roles);
        userRoleRepository.save(userRole);
    }

    private UserDto toDto(User user, Set<String> roles) {
        return new UserDto(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getPhone(),
                user.getStatus().name(),
                roles,
                user.getLastLoginAt(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
