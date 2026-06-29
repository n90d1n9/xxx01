package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import org.jboss.logging.Logger;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * JWT-style authentication service.
 *
 * Tokens are HMAC-SHA256 signed: base64(header).base64(payload).base64(signature)
 * In production replace with quarkus-smallrye-jwt or quarkus-oidc.
 */
@ApplicationScoped
public class AuthService {

    private static final Logger LOG = Logger.getLogger(AuthService.class);

    // Secret — in production inject from env / vault
    private static final String JWT_SECRET  = System.getenv()
            .getOrDefault("JWT_SECRET", "postfix-manager-secret-change-in-production-32chars!");
    private static final long   ACCESS_TTL  = 8  * 60 * 60 * 1000L; // 8 hours  ms
    private static final long   REFRESH_TTL = 30 * 24 * 60 * 60 * 1000L; // 30 days ms

    // User store — replace with DB table in production
    private static final Map<String, UserRecord> USERS = Map.of(
        "admin",    new UserRecord("admin",    hashPw("admin"),        "ADMIN"),
        "operator", new UserRecord("operator", hashPw("operator123"),  "OPERATOR"),
        "viewer",   new UserRecord("viewer",   hashPw("viewer"),       "VIEWER")
    );

    // Refresh token store: token → username (use Redis in production)
    private final ConcurrentHashMap<String, RefreshRecord> refreshStore = new ConcurrentHashMap<>();

    // ─── Public API ───────────────────────────────────────────────────────────

    public TokenResponse login(String username, String password) {
        UserRecord user = USERS.get(username);
        if (user == null || !user.passwordHash.equals(hashPw(password))) {
            LOG.warnf("Failed login attempt for user: %s", username);
            throw new SecurityException("Invalid credentials");
        }
        LOG.infof("Successful login: %s (%s)", username, user.role);
        return issueTokenPair(user);
    }

    public TokenResponse refresh(String refreshToken) {
        RefreshRecord record = refreshStore.get(refreshToken);
        if (record == null) {
            throw new SecurityException("Refresh token not found or already used");
        }
        if (System.currentTimeMillis() > record.expiresAt) {
            refreshStore.remove(refreshToken);
            throw new SecurityException("Refresh token expired — please login again");
        }
        // Rotate: old token is invalidated, new pair issued
        refreshStore.remove(refreshToken);
        UserRecord user = USERS.get(record.username);
        if (user == null) throw new SecurityException("User no longer exists");
        LOG.infof("Token refreshed for: %s", record.username);
        return issueTokenPair(user);
    }

    public void logout(String refreshToken) {
        if (refreshToken != null) refreshStore.remove(refreshToken);
    }

    public void logoutAll(String username) {
        refreshStore.entrySet().removeIf(e -> e.getValue().username.equals(username));
        LOG.infof("All sessions invalidated for: %s", username);
    }

    /**
     * Validate an access token.
     * Returns the username if valid; throws SecurityException otherwise.
     */
    public String validateAccessToken(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) throw new SecurityException("Malformed token");

            String headerPayload = parts[0] + "." + parts[1];
            String expectedSig   = hmacB64(headerPayload);
            if (!expectedSig.equals(parts[2])) throw new SecurityException("Invalid signature");

            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]));
            @SuppressWarnings("unchecked")
            Map<String, Object> payload = (Map<String, Object>) parseSimpleJson(payloadJson);
            long exp = ((Number) payload.get("exp")).longValue();
            if (System.currentTimeMillis() > exp) throw new SecurityException("Token expired");

            return (String) payload.get("sub");
        } catch (SecurityException e) {
            throw e;
        } catch (Exception e) {
            throw new SecurityException("Token validation failed: " + e.getMessage());
        }
    }

    // ─── Token generation ─────────────────────────────────────────────────────

    private TokenResponse issueTokenPair(UserRecord user) {
        long   now        = System.currentTimeMillis();
        String accessJwt  = buildJwt(user.username, user.role, now + ACCESS_TTL);
        String refreshTok = UUID.randomUUID().toString();

        refreshStore.put(refreshTok, new RefreshRecord(user.username, now + REFRESH_TTL));
        // Purge expired entries occasionally
        if (refreshStore.size() > 1000) purgeExpiredRefresh();

        return new TokenResponse(
            accessJwt, refreshTok,
            LocalDateTime.now().plusSeconds(ACCESS_TTL / 1000),
            user.username, user.role);
    }

    private String buildJwt(String username, String role, long expiresAt) {
        // Header
        String header  = b64("{\"alg\":\"HS256\",\"typ\":\"JWT\"}");
        // Payload
        String payload = b64(String.format(
            "{\"sub\":\"%s\",\"role\":\"%s\",\"iat\":%d,\"exp\":%d,\"jti\":\"%s\"}",
            username, role, System.currentTimeMillis(), expiresAt, UUID.randomUUID()));
        String sig = hmacB64(header + "." + payload);
        return header + "." + payload + "." + sig;
    }

    private String hmacB64(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(JWT_SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding()
                    .encodeToString(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException("HMAC failed", e);
        }
    }

    private static String b64(String s) {
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(s.getBytes(StandardCharsets.UTF_8));
    }

    private static String hashPw(String pw) {
        // Simple SHA-256 for demo — use BCrypt/Argon2 in production
        try {
            var md = java.security.MessageDigest.getInstance("SHA-256");
            return Base64.getEncoder().encodeToString(
                    md.digest(pw.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void purgeExpiredRefresh() {
        long now = System.currentTimeMillis();
        refreshStore.entrySet().removeIf(e -> now > e.getValue().expiresAt);
    }

    // Minimal JSON parser for our own compact payloads — avoid extra deps
    @SuppressWarnings("unchecked")
    private Map<String, Object> parseSimpleJson(String json) {
        Map<String, Object> map = new LinkedHashMap<>();
        json = json.trim().replaceAll("^\\{|\\}$", "");
        for (String kv : json.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)")) {
            String[] pair = kv.split(":", 2);
            if (pair.length == 2) {
                String key = pair[0].trim().replaceAll("\"", "");
                String val = pair[1].trim().replaceAll("\"", "");
                try { map.put(key, Long.parseLong(val)); }
                catch (NumberFormatException e) { map.put(key, val); }
            }
        }
        return map;
    }

    // ─── Records ──────────────────────────────────────────────────────────────

    record UserRecord(String username, String passwordHash, String role) {}
    record RefreshRecord(String username, long expiresAt) {}
}
