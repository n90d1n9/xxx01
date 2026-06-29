package tech.kayys.report.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "non_conformance_reports")
public class NonConformanceReport extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "inspection_id")
    public QualityInspection inspection;
    
    @Column(name = "ncr_number", unique = true)
    public String ncrNumber;
    
    @Column(name = "issue_date")
    public LocalDate issueDate;
    
    @Column(name = "defect_description", length = 2000)
    public String defectDescription;
    
    @Column(name = "defect_location")
    public String defectLocation;
    
    @Enumerated(EnumType.STRING)
    public NCRSeverity severity;
    
    @Column(name = "proposed_correction", length = 2000)
    public String proposedCorrection;
    
    @Column(name = "target_completion_date")
    public LocalDate targetCompletionDate;
    
    @Column(name = "actual_completion_date")
    public LocalDate actualCompletionDate;
    
    @Column(name = "corrective_action_taken", length = 2000)
    public String correctiveActionTaken;
    
    @Enumerated(EnumType.STRING)
    public NCRStatus status = NCRStatus.OPEN;
    
    @Column(name = "closed_by")
    public String closedBy;
    
    @Column(name = "close_date")
    public LocalDate closeDate;
    
    public enum NCRSeverity {
        MINOR("Minor"),
        MAJOR("Major"),
        CRITICAL("Critical");
        
        private final String label;
        NCRSeverity(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum NCRStatus {
        OPEN("Open"),
        IN_PROGRESS("In Progress"),
        PENDING_VERIFICATION("Pending Verification"),
        CLOSED("Closed"),
        CANCELLED("Cancelled");
        
        private final String label;
        NCRStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
