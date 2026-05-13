package com.enterprise.module.role.repository;

import com.enterprise.module.role.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public interface RoleRepository extends JpaRepository<Role, UUID> {

    Optional<Role> findByName(String name);

    boolean existsByName(String name);

    @Query("SELECT r FROM Role r JOIN FETCH r.permissions WHERE r.name IN :names")
    Set<Role> findByNameInWithPermissions(@Param("names") Set<String> names);

    @Query("SELECT r.name FROM Role r")
    Set<String> findAllRoleNames();
}
