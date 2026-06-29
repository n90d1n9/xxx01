package tech.kayys.notification.model;

import java.time.LocalDateTime;


public record NotificationResult(
    boolean success,
    String channel,                   // "email", "sms", "push"
    String message,
    Long notificationId,
    LocalDateTime timestamp
) {}