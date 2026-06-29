package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import io.quarkus.scheduler.Scheduled;
import org.jboss.logging.Logger;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

@ApplicationScoped
public class AlertService {

    private static final Logger LOG = Logger.getLogger(AlertService.class);
    private final CopyOnWriteArrayList<AlertDto> alerts = new CopyOnWriteArrayList<>();
    private final AtomicInteger idCounter = new AtomicInteger(100);

    public AlertService() {
        // Seed with demo alerts
        alerts.add(new AlertDto("1", "Mail Queue Threshold Exceeded",
            "Queue size has reached 487 messages (threshold: 100). Delivery may be delayed.",
            "critical", LocalDateTime.now().minusMinutes(5), false, "View Queue", "/queue"));
        alerts.add(new AlertDto("2", "TLS Certificate Expiring",
            "Certificate for mail.company.org expires in 25 days.",
            "warning", LocalDateTime.now().minusHours(1), false, "Manage TLS", "/tls"));
        alerts.add(new AlertDto("3", "High Error Rate Detected",
            "Error rate exceeded 15% in the last hour. 23 rejected connections from 45.89.12.0/24.",
            "critical", LocalDateTime.now().minusHours(2), false, "View Logs", "/logs"));
        alerts.add(new AlertDto("4", "DMARC Check Failing",
            "Domain example.com has no DMARC policy configured.",
            "warning", LocalDateTime.now().minusHours(6), true, "Check DNS", "/dns"));
        alerts.add(new AlertDto("5", "Scheduled Backup Completed",
            "Daily backup completed successfully. Size: 44.1KB.",
            "info", LocalDateTime.now().minusDays(1), true, "View Backups", "/backup"));
    }

    public List<AlertDto> getAll(boolean unreadOnly) {
        if (unreadOnly) return alerts.stream().filter(a -> !a.isRead()).toList();
        return List.copyOf(alerts);
    }

    public void markRead(String id) {
        alerts.replaceAll(a -> a.id().equals(id)
            ? new AlertDto(a.id(), a.title(), a.message(), a.severity(),
                a.createdAt(), true, a.actionLabel(), a.actionRoute())
            : a);
    }

    public void markAllRead() {
        alerts.replaceAll(a -> new AlertDto(a.id(), a.title(), a.message(), a.severity(),
            a.createdAt(), true, a.actionLabel(), a.actionRoute()));
    }

    public void delete(String id) {
        alerts.removeIf(a -> a.id().equals(id));
    }

    public void addAlert(String title, String message, String severity,
                         String actionLabel, String actionRoute) {
        alerts.add(0, new AlertDto(
            String.valueOf(idCounter.incrementAndGet()),
            title, message, severity, LocalDateTime.now(), false,
            actionLabel, actionRoute));
        // Keep only latest 200 alerts
        while (alerts.size() > 200) alerts.remove(alerts.size() - 1);
    }

    public long getUnreadCount() {
        return alerts.stream().filter(a -> !a.isRead()).count();
    }

    @Scheduled(every = "60s")
    void autoCheckThresholds() {
        // This would normally check live metrics
        LOG.debug("Checking alert thresholds...");
    }
}
