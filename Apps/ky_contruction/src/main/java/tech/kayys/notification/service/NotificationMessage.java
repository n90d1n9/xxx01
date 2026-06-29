package tech.kayys.notification.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class NotificationMessage {
    public Long id;
    public String messageId;
    public NotificationType type;
    public NotificationCategory category;
    public NotificationPriority priority = NotificationPriority.NORMAL;
    public NotificationStatus status = NotificationStatus.PENDING;
    
    // Content
    public String title;
    public String message;
    public String shortMessage; // For SMS/mobile notifications
    public Map<String, Object> metadata;
    public Map<String, Object> templateData;
    
    // Recipients and Channels
    public List<String> recipients;
    public List<String> channels; // email, sms, push, webhook, etc.
    public String primaryRecipient;
    public List<String> ccRecipients;
    public List<String> bccRecipients;
    
    // Related Entities
    public Long riskId;
    public Long workflowId;
    public Long stepId;
    public Long kriId;
    public Long userId;
    public Long projectId;
    
    // Alert Specific
    public AlertType alertType;
    public String alertLevel;
    public String alertSource;
    
    // Timing and Scheduling
    public LocalDateTime timestamp = LocalDateTime.now();
    public LocalDateTime scheduledTime;
    public LocalDateTime sentTime;
    public LocalDateTime readTime;
    public LocalDateTime expiryTime;
    public String timezone = "UTC";
    
    // Template and Formatting
    public String templateId;
    public String customTemplate;
    public String locale = "en";
    public String theme = "default";
    
    // Delivery and Retry
    public Integer retryCount = 0;
    public Integer maxRetries = 3;
    public Integer retryDelayMinutes = 5;
    public String errorMessage;
    public String deliveryStatus;
    public List<DeliveryAttempt> deliveryAttempts;
    
    // Tracking and Analytics
    public String correlationId;
    public String campaignId;
    public String source;
    public Map<String, String> tags;
    public Boolean trackOpening = false;
    public Boolean trackClicking = false;
    
    // Audit and Compliance
    public String createdBy;
    public String approvedBy;
    public LocalDateTime approvalTime;
    public Boolean requiresApproval = false;
    public String approvalReason;
    
    // Constructors
    public NotificationMessage() {
        this.messageId = generateMessageId();
        this.correlationId = UUID.randomUUID().toString();
        this.metadata = new HashMap<>();
        this.templateData = new HashMap<>();
        this.recipients = new ArrayList<>();
        this.channels = new ArrayList<>();
        this.deliveryAttempts = new ArrayList<>();
        this.tags = new HashMap<>();
    }
    
    public NotificationMessage(NotificationType type, String title, String message) {
        this();
        this.type = type;
        this.title = title;
        this.message = message;
        this.category = mapTypeToCategory(type);
    }
    
    // Enums
    public enum NotificationType {
        RISK_ALERT("Risk Alert"),
        WORKFLOW("Workflow Notification"),
        KRI_BREACH("KRI Breach"),
        COMPLIANCE("Compliance Notification"),
        ESCALATION("Escalation"),
        REMINDER("Reminder"),
        SYSTEM("System Notification"),
        ANNOUNCEMENT("Announcement"),
        MAINTENANCE("Maintenance Notice");
        
        private final String label;
        NotificationType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum NotificationCategory {
        CRITICAL("Critical"),
        WARNING("Warning"),
        INFO("Information"),
        SUCCESS("Success"),
        ERROR("Error");
        
        private final String label;
        NotificationCategory(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum NotificationPriority {
        LOW(1, "Low Priority"),
        NORMAL(2, "Normal Priority"),
        HIGH(3, "High Priority"),
        CRITICAL(4, "Critical Priority"),
        EMERGENCY(5, "Emergency");
        
        private final int level;
        private final String label;
        
        NotificationPriority(int level, String label) {
            this.level = level;
            this.label = label;
        }
        
        public int getLevel() { return level; }
        public String getLabel() { return label; }
    }
    
    public enum NotificationStatus {
        DRAFT("Draft"),
        PENDING("Pending"),
        SCHEDULED("Scheduled"),
        SENDING("Sending"),
        SENT("Sent"),
        DELIVERED("Delivered"),
        READ("Read"),
        FAILED("Failed"),
        CANCELLED("Cancelled"),
        EXPIRED("Expired");
        
        private final String label;
        NotificationStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum AlertType {
        HIGH_RISK("High Risk Identified"),
        OVERDUE_ACTION("Overdue Action"),
        REVIEW_DUE("Review Due"),
        ESCALATION("Risk Escalated"),
        THRESHOLD_BREACH("Threshold Breach"),
        POLICY_VIOLATION("Policy Violation"),
        SYSTEM_ERROR("System Error");
        
        private final String label;
        AlertType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    // Supporting Classes
    public static class DeliveryAttempt {
        public LocalDateTime attemptTime;
        public String channel;
        public String status;
        public String errorMessage;
        public Integer attemptNumber;
        
        public DeliveryAttempt(String channel, String status) {
            this.attemptTime = LocalDateTime.now();
            this.channel = channel;
            this.status = status;
        }
    }
    
    // Factory Methods
    public static NotificationMessage createRiskAlert(Long riskId, String riskTitle, 
                                                    String alertMessage, AlertType alertType) {
        NotificationMessage message = new NotificationMessage(NotificationType.RISK_ALERT, 
                                                            "Risk Alert: " + riskTitle, alertMessage);
        message.riskId = riskId;
        message.alertType = alertType;
        message.category = NotificationCategory.WARNING;
        message.priority = alertType == AlertType.HIGH_RISK ? NotificationPriority.HIGH : NotificationPriority.NORMAL;
        message.channels = List.of("email", "system");
        message.templateId = "risk-alert";
        
        // Add template data
        message.templateData.put("riskId", riskId);
        message.templateData.put("riskTitle", riskTitle);
        message.templateData.put("alertType", alertType.getLabel());
        
        return message;
    }
    
    public static NotificationMessage createWorkflowNotification(Long workflowId, Long stepId, 
                                                               String stepName, String assignee) {
        NotificationMessage message = new NotificationMessage(NotificationType.WORKFLOW,
                                                            "Workflow Action Required", 
                                                            "Please process workflow step: " + stepName);
        message.workflowId = workflowId;
        message.stepId = stepId;
        message.category = NotificationCategory.INFO;
        message.priority = NotificationPriority.NORMAL;
        message.recipients = List.of(assignee);
        message.channels = List.of("email", "system");
        message.templateId = "workflow-notification";
        
        message.templateData.put("workflowId", workflowId);
        message.templateData.put("stepId", stepId);
        message.templateData.put("stepName", stepName);
        
        return message;
    }
    
    public static NotificationMessage createKRIBreach(Long kriId, String indicatorName, 
                                                    BigDecimal currentValue, BigDecimal threshold) {
        String alertMessage = String.format("KRI '%s' breached threshold: %s (limit: %s)", 
                                           indicatorName, currentValue, threshold);
        
        NotificationMessage message = new NotificationMessage(NotificationType.KRI_BREACH,
                                                            "KRI Threshold Breach", alertMessage);
        message.kriId = kriId;
        message.alertType = AlertType.THRESHOLD_BREACH;
        message.category = NotificationCategory.CRITICAL;
        message.priority = NotificationPriority.HIGH;
        message.channels = List.of("email", "sms", "system");
        message.templateId = "kri-breach";
        
        message.templateData.put("kriId", kriId);
        message.templateData.put("indicatorName", indicatorName);
        message.templateData.put("currentValue", currentValue);
        message.templateData.put("threshold", threshold);
        
        return message;
    }
    
    // Utility Methods
    public boolean isExpired() {
        return expiryTime != null && LocalDateTime.now().isAfter(expiryTime);