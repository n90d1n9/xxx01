package tech.kayys.risk.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.hibernate.annotations.CreationTimestamp;

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
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import tech.kayys.profile.domain.User;


@Entity
@Table(name = "risk_mitigation_actions")
public class RiskMitigationAction extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "risk_id")
    public RiskRegister risk;
    
    @Column(name = "action_id", unique = true)
    public String actionId;
    
    @Column(name = "action_description", length = 2000)
    public String actionDescription;
    
    @Enumerated(EnumType.STRING)
    public ActionType actionType;
    
    @Enumerated(EnumType.STRING)
    public ActionPriority priority = ActionPriority.MEDIUM;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_to")
    public User assignedTo;
    
    @Column(name = "estimated_cost")
    public BigDecimal estimatedCost;
    
    @Column(name = "actual_cost")
    public BigDecimal actualCost;
    
    @Column(name = "effectiveness")
    public Double effectiveness; // 0-100 percentage
    
    @Column(name = "start_date")
    public LocalDate startDate;
    
    @Column(name = "due_date")
    public LocalDate dueDate;
    
    @Column(name = "completion_date")
    public LocalDate completionDate;
    
    @Enumerated(EnumType.STRING)
    public ActionStatus status = ActionStatus.PENDING;
    
    @Column(name = "progress_percentage")
    public Integer progressPercentage = 0;
    
    @Column(name = "notes", length = 2000)
    public String notes;
    
    @OneToMany(mappedBy = "action", cascade = CascadeType.ALL)
    public List<ActionProgressUpdate> progressUpdates;
    
    @CreationTimestamp
    @Column(name = "created_date")
    public LocalDateTime createdDate;
    
    @Column(name = "created_by")
    public String createdBy;
    
    public enum ActionType {
        PREVENTIVE("Preventive"),
        DETECTIVE("Detective"),
        CORRECTIVE("Corrective"),
        COMPENSATING("Compensating"),
        DIRECTIVE("Directive");
        
        private final String label;
        ActionType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum ActionPriority {
        CRITICAL("Critical"),
        HIGH("High"),
        MEDIUM("Medium"),
        LOW("Low");
        
        private final String label;
        ActionPriority(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum ActionStatus {
        PENDING("Pending"),
        IN_PROGRESS("In Progress"),
        ON_HOLD("On Hold"),
        COMPLETED("Completed"),
        CANCELLED("Cancelled"),
        OVERDUE("Overdue");
        
        private final String label;
        ActionStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    @PreUpdate
    public void updateStatus() {
        if (dueDate != null && dueDate.isBefore(LocalDate.now()) && 
            status != ActionStatus.COMPLETED && status != ActionStatus.CANCELLED) {
            status = ActionStatus.OVERDUE;
        }
    }
}
