package com.enterprise.module.role.repository;

import com.enterprise.module.role.entity.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface UserRoleRepository extends JpaRepository<UserRole, UUID> {

    @Query("SELECT ur FROM UserRole ur JOIN FETCH ur.roles WHERE ur.userId = :userId")
    Optional<UserRole> findByUserIdWithRoles(@Param("userId") UUID userId);

    Optional<UserRole> findByUserId(UUID userId);

    void deleteByUserId(UUID userId);
}
