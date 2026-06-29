 public record AccessRuleDto(
            String pattern, String action, String listType, String matchType,
            String reason, LocalDateTime createdAt, LocalDateTime expiresAt,
            boolean isActive) {}
