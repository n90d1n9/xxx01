package tech.kayys.tender.domain;

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
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "tenders")
public class Tender extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "tender_number", unique = true)
    public String tenderNumber;
    
    @Column(name = "tender_title")
    public String tenderTitle;
    
    @Column(length = 2000)
    public String description;
    
    @Enumerated(EnumType.STRING)
    public TenderType tenderType;
    
    @Enumerated(EnumType.STRING)
    public TenderStatus status = TenderStatus.DRAFT;
    
    @Column(name = "issue_date")
    public LocalDate issueDate;
    
    @Column(name = "submission_deadline")
    public LocalDateTime submissionDeadline;
    
    @Column(name = "opening_date")
    public LocalDateTime openingDate;
    
    @Column(name = "evaluation_completion_date")
    public LocalDate evaluationCompletionDate;
    
    @Column(name = "estimated_value", precision = 15, scale = 2)
    public BigDecimal estimatedValue;
    
    @Column(name = "bid_bond_percentage", precision = 5, scale = 2)
    public BigDecimal bidBondPercentage;
    
    @Column(name = "tender_validity_days")
    public Integer tenderValidityDays;
    
    @OneToMany(mappedBy = "tender", cascade = CascadeType.ALL)
    public List<TenderBid> bids;
    
    @OneToMany(mappedBy = "tender", cascade = CascadeType.ALL)
    public List<TenderEvaluation> evaluations;
    
    public enum TenderType {
        OPEN_TENDER("Open Tender"),
        SELECTIVE_TENDER("Selective Tender"),
        NEGOTIATION("Direct Negotiation"),
        FRAMEWORK_AGREEMENT("Framework Agreement"),
        E_AUCTION("E-Auction");
        
        private final String label;
        TenderType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum TenderStatus {
        DRAFT("Draft"),
        ISSUED("Issued"),
        SUBMISSION_OPEN("Submission Open"),
        SUBMISSION_CLOSED("Submission Closed"),
        UNDER_EVALUATION("Under Evaluation"),
        AWARDED("Awarded"),
        CANCELLED("Cancelled");
        
        private final String label;
        TenderStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
