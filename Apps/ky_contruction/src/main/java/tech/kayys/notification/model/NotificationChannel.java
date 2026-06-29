package tech.kayys.notification.model;

import java.util.concurrent.CompletableFuture;


import tech.kayys.notification.service.NotificationMessage;

public interface NotificationChannel {
    boolean supports(String channelType);  // e.g. "email", "sms"
    CompletableFuture<NotificationResult> send(NotificationMessage notification);
}
