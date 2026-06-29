package tech.kayys.risk.service;


import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;
import tech.kayys.notification.service.NotificationService;
import tech.kayys.profile.domain.User;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.domain.RiskWorkflow;
import tech.kayys.risk.domain.WorkflowStep;
import tech.kayys.risk.dto.RiskCoordinate;
import tech.kayys.risk.dto.RiskHeatmapData;
import tech.kayys.risk.dto.RiskPortfolioAnalysis;
import tech.kayys.risk.dto.RiskTrendData;
import tech.kayys.risk.model.RiskLevel;


@ApplicationScoped
@Transactional
public class WorkflowService {
    
    @Inject
    NotificationService notificationService;
    
    public RiskWorkflow initiateWorkflow(Long riskId, RiskWorkflow.WorkflowType type, Long initiatorId) {
        RiskRegister risk = findById(riskId);
        User initiator = User.findById(initiatorId);
        
        RiskWorkflow workflow = new RiskWorkflow();
        workflow.risk = risk;
        workflow.workflowType = type;
        workflow.initiatedBy = initiator;
        
        // Set due date based on workflow type
        workflow.dueDate = calculateWorkflowDueDate(type);
        
        // Create workflow steps based on type
        createWorkflowSteps(workflow, type);
        
        workflow.persist();
        
        // Send notification to first assignee
        if (!workflow.steps.isEmpty()) {
            WorkflowStep firstStep = workflow.steps.get(0);
            firstStep.status = WorkflowStep.StepStatus.IN_PROGRESS;
            firstStep.startedDate = LocalDateTime.now();
            workflow.currentAssignee = firstStep.assignedTo;
            
            notificationService.sendWorkflowNotification(workflow, firstStep);
        }
        
        return workflow;
    }
    
    public boolean processWorkflowStep(Long workflowId, Long stepId, String decision, String comments, Long userId) {
        RiskWorkflow workflow = RiskWorkflow.findById(workflowId);
        WorkflowStep step = WorkflowStep.findById(stepId);
        
        if (!step.assignedTo.id.equals(userId)) {
            throw new SecurityException("User not authorized to process this step");
        }
        
        step.decision = decision;
        step.comments = comments;
        step.completedDate = LocalDateTime.now();
        step.status = WorkflowStep.StepStatus.COMPLETED;
        
        // Check if workflow should proceed to next step
        WorkflowStep nextStep = getNextStep(workflow, step);
        if (nextStep != null) {
            nextStep.status = WorkflowStep.StepStatus.IN_PROGRESS;
            nextStep.startedDate = LocalDateTime.now();
            workflow.currentAssignee = nextStep.assignedTo;
            
            notificationService.sendWorkflowNotification(workflow, nextStep);
        } else {
            // Workflow completed
            workflow.status = RiskWorkflow.WorkflowStatus.COMPLETED;
            workflow.completedDate = LocalDateTime.now();
            processWorkflowCompletion(workflow, decision);
        }
        
        return true;
    }
    
    private LocalDateTime calculateWorkflowDueDate(RiskWorkflow.WorkflowType type) {
        return switch (type) {
            case RISK_ASSESSMENT -> LocalDateTime.now().plusDays(7);
            case RISK_APPROVAL -> LocalDateTime.now().plusDays(5);
            case MITIGATION_REVIEW -> LocalDateTime.now().plusDays(10);
            case PERIODIC_REVIEW -> LocalDateTime.now().plusDays(14);
            case ESCALATION -> LocalDateTime.now().plusDays(3);
            case CLOSURE_REQUEST -> LocalDateTime.now().plusDays(5);
        };
    }
    
    private void createWorkflowSteps(RiskWorkflow workflow, RiskWorkflow.WorkflowType type) {
        switch (type) {
            case RISK_ASSESSMENT -> createRiskAssessmentSteps(workflow);
            case RISK_APPROVAL -> createRiskApprovalSteps(workflow);
            case MITIGATION_REVIEW -> createMitigationReviewSteps(workflow);
            case PERIODIC_REVIEW -> createPeriodicReviewSteps(workflow);
            case ESCALATION -> createEscalationSteps(workflow);
            case CLOSURE_REQUEST -> createClosureSteps(workflow);
        }
    }
    
    private void createRiskAssessmentSteps(RiskWorkflow workflow) {
        // Step 1: Risk Owner Assessment
        WorkflowStep step1 = new WorkflowStep();
        step1.workflow = workflow;
        step1.stepOrder = 1;
        step1.stepName = "Risk Owner Assessment";
        step1.assignedTo = workflow.risk.owner;
        
        // Step 2: Risk Manager Review
        WorkflowStep step2 = new WorkflowStep();
        step2.workflow = workflow;
        step2.stepOrder = 2;
        step2.stepName = "Risk Manager Review";
        step2.assignedTo = workflow.risk.reviewer;
        
        workflow.steps = List.of(step1, step2);
    }
    
    private void createRiskApprovalSteps(RiskWorkflow workflow) {
        // Step 1: Department Head Approval
        WorkflowStep step1 = new WorkflowStep();
        step1.workflow = workflow;
        step1.stepOrder = 1;
        step1.stepName = "Department Head Approval";
        step1.assignedTo = findDepartmentHead(workflow.risk.owner.department);
        
        // Step 2: Risk Committee Approval (for high risks)
        if (workflow.risk.getRiskLevel().ordinal() >= RiskLevel.HIGH.ordinal()) {
            WorkflowStep step2 = new WorkflowStep();
            step2.workflow = workflow;
            step2.stepOrder = 2;
            step2.stepName = "Risk Committee Approval";
            step2.assignedTo = findRiskCommitteeChair();
            workflow.steps = List.of(step1, step2);
        } else {
            workflow.steps = List.of(step1);
        }
    }
    
    private User findDepartmentHead(String department) {
        return User.<User>find("department = ?1 and role = ?2", 
                              department, User.UserRole.RISK_MANAGER)
                   .firstResult();
    }
    
    private User findRiskCommitteeChair() {
        return User.<User>find("role = ?1", User.UserRole.EXECUTIVE)
                   .firstResult();
    }
}
