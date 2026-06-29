package tech.kayys.notification.model;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public record EmailMessage(
        String notificationId,
        List<String> to,
        List<String> cc,
        List<String> bcc,
        String from,
        String subject,
        String body,                       // raw HTML body (can come from template or plain string)
        EmailPriority priority,
        List<EmailAttachment> attachments,
        String templateName,               // optional: name of template
        List<String> templateParams,        // optional: dynamic params for template
    
         String replyTo,
        
         EmailPriority priority = EmailPriority.NORMAL,
         List<EmailAttachment> attachments,
         LocalDateTime timestamp = LocalDateTime.now(),
         LocalDateTime scheduledTime,
         LocalDateTime sentDate,
         EmailStatus status = EmailStatus.PENDING,
         String templateId,
         Map<String, Object> templateData = new HashMap<>(),
         int retryCount = 0,
         String errorMessage,
         String messageId
) {
     EmailMessage {
        if (to == null || to.isEmpty()) {
            throw new IllegalArgumentException("Email must have at least one recipient");
        }
        if (priority == null) {
            priority = EmailPriority.NORMAL;
        }
    }
}
