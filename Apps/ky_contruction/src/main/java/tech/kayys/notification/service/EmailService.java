package tech.kayys.notification.service;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.PasswordAuthentication;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.eclipse.microprofile.reactive.messaging.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.quarkus.mailer.Mail;
import io.quarkus.mailer.Mailer;
import io.quarkus.qute.Template;
import io.quarkus.qute.TemplateInstance;
import jakarta.activation.DataHandler;
import jakarta.activation.DataSource;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.notification.model.EmailAttachment;
import tech.kayys.notification.model.EmailMessage;
import tech.kayys.notification.model.EmailPriority;
import tech.kayys.notification.model.EmailResult;
import tech.kayys.notification.model.EmailStatus;
import tech.kayys.notification.model.EmailTemplate;
import io.quarkus.qute.Engine;
import java.util.*;
import java.util.concurrent.*;


@ApplicationScoped
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    // --------------------------
    // Configuration (from MP Config)
    // --------------------------
    @ConfigProperty(name = "app.email.enabled", defaultValue = "true")
    boolean emailEnabled;

    @ConfigProperty(name = "app.email.from", defaultValue = "noreply@company.com")
    Optional<String> fromAddress;

    @ConfigProperty(name = "app.email.smtp.host")
    Optional<String> smtpHost; // kept for backwards compatibility (used only for logging / validation)

    @ConfigProperty(name = "app.email.smtp.port", defaultValue = "587")
    int smtpPort; // kept for backwards compatibility

    @ConfigProperty(name = "app.email.smtp.username")
    Optional<String> smtpUsername; // not used directly (quarkus.mailer reads config)

    @ConfigProperty(name = "app.email.smtp.password")
    Optional<String> smtpPassword;

    @ConfigProperty(name = "app.email.smtp.tls", defaultValue = "true")
    boolean smtpTls;

    @ConfigProperty(name = "app.email.template.base-url", defaultValue = "http://localhost:8080")
    String baseUrl;

    @ConfigProperty(name = "app.email.retry.max-attempts", defaultValue = "3")
    int maxRetryAttempts;

    @ConfigProperty(name = "app.email.batch.size", defaultValue = "50")
    int batchSize;

    // --------------------------
    // Dependencies
    // --------------------------
    @Inject
    Mailer mailer;

    @Inject
    Engine quteEngine; // for loading templates dynamically by name

    @Inject
    Template defaultTemplate; // inject src/main/resources/templates/default.html

    @Inject
    @Channel("email-queue")
    Emitter<EmailMessage> emailEmitter;

    // --------------------------
    // Internal State
    // --------------------------
    private final Map<String, EmailTemplate> emailTemplates = new ConcurrentHashMap<>(); // KEEP (but consider moving)
    private final ExecutorService emailExecutor = Executors.newFixedThreadPool(5); // KEEP (or move to platform executor)
    private final ScheduledExecutorService retryScheduler = Executors.newScheduledThreadPool(2); // KEEP
    private Properties smtpProperties; // legacy holder (IDEAL_REMOVE once quarkus.mailer config fully in application.properties)

    // --------------------------
    // Lifecycle
    // --------------------------
    @PostConstruct
    public void initializeEmailService() {
        // KEEP: initialization logging, load templates
        // NOTE: setupSMTPProperties kept for backward compatibility, but quarkus.mailer reads config from application.properties.
        setupSMTPProperties(); // (no-op heavy config; kept for parity)
        loadEmailTemplates(); // KEEP (could be moved to TemplateService later)
        logger.info("Email service initialized. Enabled: {}, SMTP Host: {}", emailEnabled, smtpHost.orElse("not configured"));
    }

    @PreDestroy
    public void cleanup() {
        // KEEP: graceful shutdown of executors
        emailExecutor.shutdown();
        retryScheduler.shutdown();
        try {
            if (!emailExecutor.awaitTermination(30, TimeUnit.SECONDS)) {
                emailExecutor.shutdownNow();
            }
            if (!retryScheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                retryScheduler.shutdownNow();
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    // ---------------------------------------------------
    // Primary Email Sending Methods (KEEP)
    // ---------------------------------------------------

    /**
     * KEEP
     * Entry point for sending email based on a NotificationMessage.
     * We preserve the original public API shape. Internally we build EmailMessage and send via quarkus-mailer.
     */
    public CompletableFuture<EmailResult> sendNotificationEmail(NotificationMessage notification) {
        if (!emailEnabled || !isValidConfiguration()) {
            logger.warn("Email service is disabled or not properly configured");
            return CompletableFuture.completedFuture(new EmailResult(false, "Email service not configured", notification.id));
        }

        return CompletableFuture.supplyAsync(() -> {
            try {
                EmailMessage email = createEmailFromNotification(notification);
                return sendEmailInternal(email);
            } catch (Exception e) {
                logger.error("Failed to send notification email for ID: " + notification.id, e);
                return new EmailResult(false, e.getMessage(), notification.id);
            }
        }, emailExecutor);
    }

    /**
     * KEEP (but this is orchestration/batching — SHOULD_MOVE_TO_NOTIFICATION_SERVICE if you want separation)
     * Bulk sending with batching and small pause between batches to avoid overwhelming SMTP.
     */
    public CompletableFuture<List<EmailResult>> sendBulkEmails(List<NotificationMessage> notifications) {
        if (!emailEnabled || notifications == null || notifications.isEmpty()) {
            return CompletableFuture.completedFuture(Collections.emptyList());
        }

        return CompletableFuture.supplyAsync(() -> {
            List<EmailResult> results = new ArrayList<>();

            for (int i = 0; i < notifications.size(); i += batchSize) {
                List<NotificationMessage> batch = notifications.subList(i, Math.min(i + batchSize, notifications.size()));

                List<CompletableFuture<EmailResult>> batchFutures = batch.stream()
                    .filter(this::shouldSendEmail)
                    .map(this::sendNotificationEmail)
                    .collect(Collectors.toList());

                try {
                    CompletableFuture.allOf(batchFutures.toArray(new CompletableFuture[0])).get();
                    for (CompletableFuture<EmailResult> f : batchFutures) {
                        results.add(f.get());
                    }
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    logger.error("Bulk email processing interrupted", ie);
                } catch (ExecutionException ee) {
                    logger.error("Bulk email execution error", ee);
                }

                // pause between batches
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }

            logger.info("Completed bulk email sending: {} total, {} successful",
                    results.size(), (int) results.stream().filter(r -> r.success).count());
            return results;
        }, emailExecutor);
    }

    /**
     * KEEP
     * Convenience API to send a one-off email (template rendering applied if templateId provided).
     */
    public EmailResult sendCustomEmail(String to, String subject, String body, String templateId) {
        if (!emailEnabled) {
            return new EmailResult(false, "Email service disabled", null);
        }

        EmailMessage email = new EmailMessage();
        email.to = List.of(to);
        email.from = fromAddress.orElse("noreply@company.com");
        email.subject = subject;
        email.body = (templateId != null) ? applyTemplate(body, templateId, new HashMap<>()) : body;
        email.priority = EmailPriority.NORMAL;
        email.timestamp = LocalDateTime.now();

        return sendEmailInternal(email);
    }

    /**
     * KEEP
     * Attachments-supporting convenience method.
     */
    public EmailResult sendEmailWithAttachments(String to, String subject, String body,
                                              List<EmailAttachment> attachments, String templateId) {
        if (!emailEnabled) {
            return new EmailResult(false, "Email service disabled", null);
        }

        EmailMessage email = new EmailMessage();
        email.to = List.of(to);
        email.from = fromAddress.orElse("noreply@company.com");
        email.subject = subject;
        email.body = (templateId != null) ? applyTemplate(body, templateId, new HashMap<>()) : body;
        email.attachments = attachments;
        email.priority = EmailPriority.NORMAL;

        return sendEmailInternal(email);
    }

    /**
     * KEEP: Retry scheduler using exponential backoff.
     * Note: quarkus-mailer doesn't auto-retry (unless you provide infrastructure). So keeping scheduler is fine.
     */
    public void scheduleEmailRetry(EmailMessage email, int attempt) {
        if (attempt >= maxRetryAttempts) {
            logger.warn("Max retry attempts exceeded for email to: {}", email.to);
            return;
        }

        long delayMinutes = (long) Math.pow(2, attempt);

        retryScheduler.schedule(() -> {
            logger.info("Retrying email send (attempt {}) to: {}", attempt + 1, email.to);
            EmailResult result = sendEmailInternal(email);
            if (!result.success) {
                scheduleEmailRetry(email, attempt + 1);
            }
        }, delayMinutes, TimeUnit.MINUTES);
    }


    public void registerTemplate(String templateId, EmailTemplate template) {
        emailTemplates.put(templateId, template);
        logger.info("Registered email template: {}", templateId);
    }

    public Optional<EmailTemplate> getTemplate(String templateId) {
        return Optional.ofNullable(emailTemplates.get(templateId));
    }


    public List<String> getAvailableTemplates() {
        return new ArrayList<>(emailTemplates.keySet());
    }


    private EmailResult sendEmailInternal(EmailMessage emailMessage) {
        if (!isValidConfiguration()) {
            return new EmailResult(false, "Invalid email configuration", emailMessage.notificationId);
        }

        try {
            // 1) Resolve body (Qute template or raw)
            String bodyHtml = resolveBodyForEmailMessage(emailMessage);

            // 2) Build mail
            Mail mail = Mail.withHtml(emailMessage.to.toArray(new String[0]), emailMessage.subject, bodyHtml);

            if (emailMessage.from != null) mail.setFrom(emailMessage.from);
            if (emailMessage.cc != null && !emailMessage.cc.isEmpty()) mail.setCc(emailMessage.cc.toArray(new String[0]));
            if (emailMessage.bcc != null && !emailMessage.bcc.isEmpty()) mail.setBcc(emailMessage.bcc.toArray(new String[0]));

            // Attachments using quarkus-mailer API
            if (emailMessage.attachments != null) {
                for (EmailAttachment att : emailMessage.attachments) {
                    if (att.inline) {
                        mail.addInlineAttachment(att.fileName, att.content, att.contentType, att.contentId);
                    } else {
                        mail.addAttachment(att.fileName, att.content, att.contentType);
                    }
                }
            }

            // 3) send (mailer handles IO)
            mailer.send(mail);

            emailMessage.status = EmailStatus.SENT;
            emailMessage.sentDate = LocalDateTime.now();
            logger.info("Email sent successfully to: {}", emailMessage.to);
            return new EmailResult(true, "Email sent successfully", emailMessage.notificationId);

        } catch (Exception e) {
            logger.error("Failed to send email to: " + emailMessage.to, e);
            emailMessage.status = EmailStatus.FAILED;
            emailMessage.errorMessage = e.getMessage();

            // schedule retry for transient errors
            if (isTransientError(e)) {
                scheduleEmailRetry(emailMessage, emailMessage.retryCount);
                emailMessage.retryCount++;
            }

            return new EmailResult(false, e.getMessage(), emailMessage.notificationId);
        }
    }

    /**
     * KEEP (helper to render template or return body)
     */
    private String resolveBodyForEmailMessage(EmailMessage emailMessage) {
        // prefer explicit body
        if (emailMessage.body != null && !emailMessage.body.isBlank()) {
            return emailMessage.body;
        }

        // If templateId present and registered in-memory, use our simple placeholder replacement
        if (emailMessage.templateId != null && emailTemplates.containsKey(emailMessage.templateId)) {
            EmailTemplate tpl = emailTemplates.get(emailMessage.templateId);
            // applyTemplate uses simple {{placeholder}} replacement
            return applyTemplate(tpl.getTemplate(), tpl.getId(), emailMessage.templateData);
        }

        // If templateName corresponds to a Qute template file, use Qute engine
        if (emailMessage.templateId != null) {
            // try to load qute template by name (templateId.html)
            Optional<Template> qt = quteEngine.getTemplate(emailMessage.templateId + ".html");
            if (qt.isPresent()) {
                TemplateInstance inst = qt.get().instance();
                if (emailMessage.templateData != null) {
                    emailMessage.templateData.forEach(inst::data);
                }
                // add common data
                inst.data("systemUrl", baseUrl);
                inst.data("currentYear", LocalDate.now().getYear());
                inst.data("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                return inst.render();
            }
        }

        // fallback to default Qute template (injected)
        TemplateInstance inst = defaultTemplate.instance();
        if (emailMessage.templateData != null) {
            emailMessage.templateData.forEach(inst::data);
        }
        inst.data("systemUrl", baseUrl);
        inst.data("currentYear", LocalDate.now().getYear());
        inst.data("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        inst.data("title", emailMessage.subject);
        return inst.render();
    }


    private void setupSMTPProperties() {
        smtpProperties = new Properties();
        smtpProperties.put("mail.smtp.auth", "true");
        smtpProperties.put("mail.smtp.starttls.enable", String.valueOf(smtpTls));
        smtpProperties.put("mail.smtp.host", smtpHost.orElse("localhost"));
        smtpProperties.put("mail.smtp.port", String.valueOf(smtpPort));
        smtpProperties.put("mail.smtp.ssl.protocols", "TLSv1.2");
        smtpProperties.put("mail.smtp.connectiontimeout", "10000");
        smtpProperties.put("mail.smtp.timeout", "10000");
    }


    private void loadEmailTemplates() {
        // KEEP these in memory for now; later move to TemplateService or DB
        registerTemplate("risk-alert", new EmailTemplate(
                "risk-alert",
                buildRiskAlertTemplate(),
                "🚨 Risk Alert: {{riskTitle}}",
                "High priority risk alert notification"
        ));

        registerTemplate("workflow-notification", new EmailTemplate(
                "workflow-notification",
                buildWorkflowTemplate(),
                "📋 Workflow Action Required: {{workflowType}}",
                "Workflow step action required"
        ));

        registerTemplate("kri-breach", new EmailTemplate(
                "kri-breach",
                buildKRIBreachTemplate(),
                "🚨 KRI Breach Alert: {{indicatorName}}",
                "Key Risk Indicator threshold breach"
        ));

        logger.info("Loaded {} email templates", emailTemplates.size());
    }

    // The long multi-line templates are kept as-is from your original code:
    private String buildRiskAlertTemplate() {
        return """
            <!DOCTYPE html>
            <html>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">
                <div style="max-width: 600px; margin: 0 auto; background: white;">
                    <div style="background: #dc3545; color: white; padding: 20px; text-align: center;">
                        <h1 style="margin: 0;">⚠️ Risk Management Alert</h1>
                    </div>
                    <div style="padding: 20px;">
                        <h2>High Priority Risk Identified</h2>
                        <div style="background: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 4px; margin: 15px 0;">
                            <p><strong>Risk:</strong> {{riskTitle}}</p>
                            <p><strong>Current Score:</strong> {{riskScore}}</p>
                            <p><strong>Risk Level:</strong> {{riskLevel}}</p>
                            <p><strong>Owner:</strong> {{owner}}</p>
                            <p><strong>Category:</strong> {{category}}</p>
                        </div>
                        <div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 4px; margin: 20px 0;">
                            <strong>🚨 Immediate Action Required:</strong> This risk requires immediate attention and mitigation action.
                        </div>
                        <div style="text-align: center; margin: 25px 0;">
                            <a href="{{systemUrl}}/risks/{{riskId}}" style="background: #dc3545; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold;">
                                🔍 View Risk Details
                            </a>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """;
    }

    private String buildWorkflowTemplate() {
        return """
            <!DOCTYPE html>
            <html>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">
                <div style="max-width: 600px; margin: 0 auto; background: white;">
                    <div style="background: #28a745; color: white; padding: 20px; text-align: center;">
                        <h1 style="margin: 0;">📋 Workflow Action Required</h1>
                    </div>
                    <div style="padding: 20px;">
                        <h2>{{workflowType}} - Action Needed</h2>
                        <div style="background: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 4px; margin: 15px 0;">
                            <p><strong>Workflow:</strong> {{workflowType}}</p>
                            <p><strong>Step:</strong> {{stepName}}</p>
                            <p><strong>Related Risk:</strong> {{riskTitle}}</p>
                            <p><strong>Due Date:</strong> {{dueDate}}</p>
                            <p><strong>Assigned To:</strong> {{assignedTo}}</p>
                        </div>
                        <div style="text-align: center; margin: 25px 0;">
                            <a href="{{systemUrl}}/workflows/{{workflowId}}" style="background: #28a745; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold;">
                                ✅ Process Workflow Step
                            </a>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """;
    }

    private String buildKRIBreachTemplate() {
        return """
            <!DOCTYPE html>
            <html>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">
                <div style="max-width: 600px; margin: 0 auto; background: white;">
                    <div style="background: #fd7e14; color: white; padding: 20px; text-align: center;">
                        <h1 style="margin: 0;">🚨 KRI Threshold Breach</h1>
                    </div>
                    <div style="padding: 20px;">
                        <h2>Key Risk Indicator Alert</h2>
                        <div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 4px; margin: 15px 0;">
                            <p><strong>Indicator:</strong> {{indicatorName}}</p>
                            <p><strong>Current Value:</strong> {{currentValue}} {{unit}}</p>
                            <p><strong>Threshold:</strong> {{threshold}} {{unit}}</p>
                            <p><strong>Breach Amount:</strong> {{breachAmount}} {{unit}}</p>
                            <p><strong>Related Risk:</strong> {{riskTitle}}</p>
                        </div>
                        <div style="background: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 4px; margin: 20px 0;">
                            <strong>⚡ Immediate Investigation Required:</strong> A Key Risk Indicator has breached its threshold.
                        </div>
                        <div style="text-align: center; margin: 25px 0;">
                            <a href="{{systemUrl}}/kris/{{kriId}}" style="background: #fd7e14; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold;">
                                📊 View KRI Details
                            </a>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """;
    }

    // ---------------------------------------------------
    // Utilities & Helpers (KEEP)
    // ---------------------------------------------------

    private boolean isValidConfiguration() {
        // KEEP: ensure minimal configuration (we still rely on quarkus.mailer in prod)
        return emailEnabled && fromAddress.isPresent() && smtpHost.isPresent() && smtpPort > 0;
    }

    private boolean shouldSendEmail(NotificationMessage notification) {
        // KEEP: logic that decides whether to send email for a notification
        return notification.channels != null &&
               notification.channels.contains("email") &&
               notification.recipients != null &&
               !notification.recipients.isEmpty() &&
               !isExpired(notification);
    }

    private boolean isExpired(NotificationMessage notification) {
        // KEEP: expiration logic from original
        if (notification.scheduledTime == null) return false;
        return LocalDateTime.now().isAfter(notification.scheduledTime.plusHours(24));
    }

    private boolean isTransientError(Exception e) {
        // KEEP: simple transient error heuristics (used to schedule retries)
        if (e == null || e.getMessage() == null) return false;
        String message = e.getMessage().toLowerCase();
        return message.contains("timeout") ||
               message.contains("connection") ||
               message.contains("temporary") ||
               message.contains("refused");
    }

    private EmailPriority mapPriority(NotificationMessage.NotificationPriority priority) {
        return switch (priority) {
            case LOW -> EmailPriority.LOW;
            case NORMAL -> EmailPriority.NORMAL;
            case HIGH -> EmailPriority.HIGH;
            case CRITICAL -> EmailPriority.CRITICAL;
        };
    }

    private String getBackgroundColor(NotificationMessage.NotificationPriority priority) {
        return switch (priority) {
            case LOW -> "#d1ecf1";
            case NORMAL -> "#d4edda";
            case HIGH -> "#fff3cd";
            case CRITICAL -> "#f8d7da";
        };
    }

    private String getBorderColor(NotificationMessage.NotificationPriority priority) {
        return switch (priority) {
            case LOW -> "#17a2b8";
            case NORMAL -> "#28a745";
            case HIGH -> "#ffc107";
            case CRITICAL -> "#dc3545";
        };
    }

    // ---------------------------------------------------
    // Template application (KEEP but consider moving to a TemplateService)
    // ---------------------------------------------------
    private String applyTemplate(String template, String templateId, Map<String, Object> templateData) {
        Map<String, Object> allData = new HashMap<>(templateData != null ? templateData : Map.of());

        // Add system variables
        allData.put("systemUrl", baseUrl);
        allData.put("currentYear", String.valueOf(LocalDate.now().getYear()));
        allData.put("companyName", "Enterprise Risk Management");
        allData.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));

        String result = template;
        for (Map.Entry<String, Object> entry : allData.entrySet()) {
            String placeholder = "{{" + entry.getKey() + "}}";
            String value = entry.getValue() != null ? String.valueOf(entry.getValue()) : "";
            result = result.replace(placeholder, value);
        }

        return result;
    }

    private String buildDefaultTemplate(NotificationMessage notification) {
        // KEEP: your original default template — unchanged
        return String.format("""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>%s</title>
            </head>
            <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                <div style="max-width: 600px; margin: 0 auto; background: #ffffff;">
                    <!-- Header -->
                    <div style="background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); color: white; padding: 30px 20px; text-align: center;">
                        <h1 style="margin: 0; font-size: 28px; font-weight: 300;">🔔 %s</h1>
                        <p style="margin: 10px 0 0 0; opacity: 0.9;">Enterprise Risk Management System</p>
                    </div>
                    
                    <!-- Content -->
                    <div style="padding: 30px 20px;">
                        <div style="background: %s; padding: 20px; border-radius: 8px; border-left: 5px solid %s; margin-bottom: 20px;">
                            <h2 style="margin: 0 0 15px 0; color: #333; font-size: 20px;">📋 Notification Details</h2>
                            <table style="width: 100%%; border-collapse: collapse;">
                                <tr>
                                    <td style="padding: 8px 0; font-weight: bold; width: 120px;">Message:</td>
                                    <td style="padding: 8px 0;">%s</td>
                                </tr>
                                <tr>
                                    <td style="padding: 8px 0; font-weight: bold;">Priority:</td>
                                    <td style="padding: 8px 0;"><span style="background: %s; color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px;">%s</span></td>
                                </tr>
                                <tr>
                                    <td style="padding: 8px 0; font-weight: bold;">Time:</td>
                                    <td style="padding: 8px 0;">%s</td>
                                </tr>
                                <tr>
                                    <td style="padding: 8px 0; font-weight: bold;">Category:</td>
                                    <td style="padding: 8px 0;">%s</td>
                                </tr>
                            </table>
                        </div>
                        
                        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #e9ecef;">
                            <p style="margin: 0; font-size: 16px;"><strong>⚡ Action Required:</strong></p>
                            <p style="margin: 10px 0 0 0;">Please log into the Risk Management System to review this notification and take appropriate action.</p>
                        </div>
                        
                        <!-- Action Button -->
                        <div style="text-align: center; margin: 30px 0;">
                            <a href="%s" style="display: inline-block; background: #007bff; color: white; text-decoration: none; padding: 15px 30px; border-radius: 6px; font-weight: bold; font-size: 16px;">
                                🚀 Access Risk Management System
                            </a>
                        </div>
                    </div>
                    
                    <!-- Footer -->
                    <div style="background: #f8f9fa; padding: 20px; text-align: center; border-top: 1px solid #e9ecef;">
                        <p style="margin: 0; font-size: 12px; color: #6c757d;">
                            This is an automated notification from the Enterprise Risk Management System.<br>
                            Please do not reply to this email. For support, contact your system administrator.
                        </p>
                        <p style="margin: 10px 0 0 0; font-size: 11px; color: #adb5bd;">
                            © %d Enterprise Risk Management System. All rights reserved.
                        </p>
                    </div>
                </div>
            </body>
            </html>
            """,
            notification.title,
            notification.title,
            getBackgroundColor(notification.priority),
            getBorderColor(notification.priority),
            notification.message,
            getBorderColor(notification.priority),
            notification.priority.name(),
            notification.timestamp.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")),
            notification.category != null ? notification.category.getLabel() : "System",
            baseUrl,
            LocalDate.now().getYear()
        );
    }
}
