package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@ApplicationScoped
public class AuthService {

    // In production this would use a real user store + JWT library
    private static final Map<String, String> USERS = Map.of(
        "admin", "admin",
        "operator", "operator123"
    );
    private static final Map<String, String> ROLES = Map.of(
        "admin", "ADMIN",
        "operator", "OPERATOR"
    );
    // In-memory token store (use Redis/DB in production)
    private final ConcurrentHashMap<String, String> refreshTokens = new ConcurrentHashMap<>();

    public TokenResponse login(String username, String password) {
        String storedPass = USERS.get(username);
        if (storedPass == null || !storedPass.equals(password)) {
            throw new SecurityException("Invalid credentials");
        }
        return generateToken(username);
    }

    public TokenResponse refresh(String refreshToken) {
        String username = refreshTokens.get(refreshToken);
        if (username == null) {
            throw new SecurityException("Invalid refresh token");
        }
        refreshTokens.remove(refreshToken);
        return generateToken(username);
    }

    private TokenResponse generateToken(String username) {
        String token = Base64.getEncoder().encodeToString(
            (username + ":" + UUID.randomUUID() + ":" + System.currentTimeMillis()).getBytes());
        String refresh = UUID.randomUUID().toString();
        refreshTokens.put(refresh, username);
        return new TokenResponse(
            token, refresh,
            LocalDateTime.now().plusHours(8),
            username,
            ROLES.getOrDefault(username, "OPERATOR"));
    }
}
