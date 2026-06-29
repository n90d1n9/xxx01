package tech.kayys.notification.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.profile.domain.User;
import tech.kayys.risk.domain.KeyRiskIndicator;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.domain.RiskWorkflow;
import tech.kayys.risk.domain.WorkflowStep;

@ApplicationScoped
public class NotificationService {
    
    @Inject
    @Channel("risk-notifications")
    Emitter<NotificationMessage> notificationEmitter;
    
    @Inject
    EmailService emailService;
    
    public void sendRiskAlert(RiskRegister risk, AlertType alertType) {
        NotificationMessage message = new NotificationMessage();
        message.type = NotificationType.RISK_ALERT;
        message.riskId = risk.id;
        message.alertType = alertType;
        message.message = buildAlertMessage(risk, alertType);
        message.recipients = determineRecipients(risk, alertType);
        message.timestamp = LocalDateTime.now();
        
        // Send to message queue
        notificationEmitter.send(message);
        
        // Send email notifications
        emailService.sendRiskAlertEmail(message);
    }
    
    public void sendWorkflowNotification(RiskWorkflow workflow, WorkflowStep step) {
        NotificationMessage message = new NotificationMessage();
        message.type = NotificationType.WORKFLOW;
        message.workflowId = workflow.id;
        message.stepId = step.id;
        message.message = "Workflow step '" + step.stepName + "' requires your attention";
        message.recipients = List.of(step.assignedTo.email);
        message.timestamp = LocalDateTime.now();
        
        notificationEmitter.send(message);
        emailService.sendWorkflowNotification(message);
    }
    
    public void sendKRIBreach(KeyRiskIndicator kri, BigDecimal breachValue) {
        NotificationMessage message = new NotificationMessage();
        message.type = NotificationType.KRI_BREACH;
        message.kriId = kri.id;
        message.riskId = kri.risk.id;
        message.message = String.format("KRI '%s' has breached threshold: %s %s", 
                                       kri.indicatorName, breachValue, kri.unitOfMeasure);
        message.recipients = List.of(kri.risk.owner.email, kri.responsibleParty);
        message.timestamp = LocalDateTime.now();
        
        notificationEmitter.send(message);
        emailService.sendKRIBreachEmail(message);
    }
    
    private String buildAlertMessage(RiskRegister risk, AlertType alertType) {
        return switch (alertType) {
            case HIGH_RISK -> String.format("High risk identified: %s (Score: %d)", 
                                           risk.riskTitle, risk.residualRiskScore);
            case OVERDUE_ACTION -> String.format("Overdue mitigation action for risk: %s", 
                                                risk.riskTitle);
            case REVIEW_DUE -> String.format("Risk review due: %s", risk.riskTitle);
            case ESCALATION -> String.format("Risk escalated: %s", risk.riskTitle);
        };
    }
    
    private List<String> determineRecipients(RiskRegister risk, AlertType alertType) {
        List<String> recipients = new ArrayList<>();
        recipients.add(risk.owner.email);
        
        if (risk.reviewer != null) {
            recipients.add(risk.reviewer.email);
        }
        
        if (alertType == AlertType.HIGH_RISK || alertType == AlertType.ESCALATION) {
            // Add executives for high risks
            List<String> executives = User.<User>find("role = ?1", User.UserRole.EXECUTIVE)
                    .stream()
                    .map(u -> u.email)
                    .collect(Collectors.toList());
            recipients.addAll(executives);
        }
        
        return recipients.stream().distinct().collect(Collectors.toList());
    }
    
    public enum AlertType {
        HIGH_RISK,
        OVERDUE_ACTION,
        REVIEW_DUE,
        ESCALATION
    }
    
    public enum NotificationType {
        RISK_ALERT,
        WORKFLOW,
        KRI_BREACH,
        SYSTEM
    }
}