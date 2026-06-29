package tech.kayys.notification.model;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public record NotificationMessage(
    String type,                      // e.g., "RISK_ALERT", "WORKFLOW_UPDATE"
    String subject,
    String content,
    List<String> recipients,
    Map<String, Object> metadata,     // workflowId, riskScore, etc.
    LocalDateTime timestamp
) {}