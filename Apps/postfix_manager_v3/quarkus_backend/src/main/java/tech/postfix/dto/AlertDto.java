 public record AlertDto(
            String id, String title, String message, String severity,
            LocalDateTime createdAt, boolean isRead,
            String actionLabel, String actionRoute) {}
