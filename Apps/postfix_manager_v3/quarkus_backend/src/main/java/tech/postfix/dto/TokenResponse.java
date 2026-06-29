

public record TokenResponse(String token, String refreshToken,
            LocalDateTime expiresAt, String username, String role) {}