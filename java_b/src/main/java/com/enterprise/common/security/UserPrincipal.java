package com.enterprise.common.security;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;

import java.util.Collection;
import java.util.UUID;

@Getter
@AllArgsConstructor
public class UserPrincipal {

    private final UUID userId;
    private final String username;
    private final Collection<? extends GrantedAuthority> authorities;
}
