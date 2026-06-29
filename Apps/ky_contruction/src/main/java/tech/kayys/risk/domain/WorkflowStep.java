package tech.kayys.risk.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import tech.kayys.profile.domain.User;

@Entity
@Table(name = "workflow_steps")
public class WorkflowStep extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workflow_id")
    public RiskWorkflow workflow;
    
    @Column(name = "step_order")
    public Integer stepOrder;
    
    @Column(name = "step_name")
    public String stepName;
    
    @Enumerated(EnumType.STRING)
    public StepStatus status = StepStatus.PENDING;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_to")
    public User assignedTo;
    
    @Column(name = "started_date")
    public LocalDateTime startedDate;
    
    @Column(name = "completed_date")
    public LocalDateTime completedDate;
    
    @Column(name = "comments", length = 2000)
    public String comments;
    
    @Column(name = "decision")
    public String decision;
    
    public enum StepStatus {
        PENDING("Pending"),
        IN_PROGRESS("In Progress"),
        COMPLETED("Completed"),
        SKIPPED("Skipped");
        
        private final String label;
        StepStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
