package com.enterprise.module.auth.service;

import com.enterprise.common.exception.BusinessException;
import com.enterprise.common.exception.ErrorCode;
import com.enterprise.common.security.JwtTokenProvider;
import com.enterprise.module.auth.dto.LoginRequest;
import com.enterprise.module.auth.dto.LoginResponse;
import com.enterprise.module.role.entity.Role;
import com.enterprise.module.role.entity.UserRole;
import com.enterprise.module.role.repository.UserRoleRepository;
import com.enterprise.module.user.dto.UserDto;
import com.enterprise.module.user.entity.User;
import com.enterprise.module.user.repository.UserRepository;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserRoleRepository userRoleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Value("${jwt.access-expiration:3600000}")
    private long accessExpiration;

    @Value("${jwt.refresh-expiration:604800000}")
    private long refreshExpiration;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findActiveByUsername(request.username())
                .orElseThrow(() -> new BusinessException(ErrorCode.LOGIN_FAILED));

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new BusinessException(ErrorCode.LOGIN_FAILED);
        }

        // 更新最后登录时间
        user.setLastLoginAt(Instant.now());
        userRepository.save(user);

        List<String> roles = userRoleRepository.findByUserIdWithRoles(user.getId())
                .map(ur -> ur.getRoles().stream().map(Role::getName).collect(Collectors.toList()))
                .orElse(List.of());

        String accessToken = jwtTokenProvider.generateAccessToken(user.getId(), user.getUsername(), roles);
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        return LoginResponse.of(accessToken, refreshToken, accessExpiration);
    }

    @Transactional
    public LoginResponse refresh(String refreshToken) {
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "refreshToken 无效或已过期");
        }
        Claims claims = jwtTokenProvider.parseToken(refreshToken);
        UUID userId = UUID.fromString(claims.getSubject());

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        List<String> roles = userRoleRepository.findByUserIdWithRoles(userId)
                .map(ur -> ur.getRoles().stream().map(Role::getName).collect(Collectors.toList()))
                .orElse(List.of());

        String newAccessToken = jwtTokenProvider.generateAccessToken(userId, user.getUsername(), roles);
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(userId);

        return LoginResponse.of(newAccessToken, newRefreshToken, accessExpiration);
    }

    @Transactional(readOnly = true)
    public UserDto me(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        Set<String> roles = userRoleRepository.findByUserIdWithRoles(userId)
                .map(ur -> ur.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                .orElse(Set.of());

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
