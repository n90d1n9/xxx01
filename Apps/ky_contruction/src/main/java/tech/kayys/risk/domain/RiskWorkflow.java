package tech.kayys.risk.domain;

import java.time.LocalDateTime;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import tech.kayys.profile.domain.User;

@Entity
@Table(name = "risk_workflows")
public class RiskWorkflow extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "risk_id")
    public RiskRegister risk;
    
    @Enumerated(EnumType.STRING)
    public WorkflowType workflowType;
    
    @Enumerated(EnumType.STRING)
    public WorkflowStatus status = WorkflowStatus.PENDING;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "initiated_by")
    public User initiatedBy;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_assignee")
    public User currentAssignee;
    
    @Column(name = "workflow_data", columnDefinition = "TEXT")
    public String workflowData; // JSON data for workflow state
    
    @Column(name = "initiated_date")
    public LocalDateTime initiatedDate = LocalDateTime.now();
    
    @Column(name = "due_date")
    public LocalDateTime dueDate;
    
    @Column(name = "completed_date")
    public LocalDateTime completedDate;
    
    @Column(name = "comments", length = 2000)
    public String comments;
    
    @OneToMany(mappedBy = "workflow", cascade = CascadeType.ALL)
    public List<WorkflowStep> steps;
    
    public enum WorkflowType {
        RISK_ASSESSMENT("Risk Assessment"),
        RISK_APPROVAL("Risk Approval"),
        MITIGATION_REVIEW("Mitigation Review"),
        PERIODIC_REVIEW("Periodic Review"),
        ESCALATION("Escalation"),
        CLOSURE_REQUEST("Closure Request");
        
        private final String label;
        WorkflowType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum WorkflowStatus {
        PENDING("Pending"),
        IN_PROGRESS("In Progress"),
        APPROVED("Approved"),
        REJECTED("Rejected"),
        ESCALATED("Escalated"),
        COMPLETED("Completed"),
        CANCELLED("Cancelled");
        
        private final String label;
        WorkflowStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}