package tech.kayys.notification.model;

public record EmailResult(
        boolean success,
        String message,
        String notificationId
) {}
