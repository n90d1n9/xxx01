package tech.kayys.tender.domain;

import tech.kayys.vendor.domain.Vendor;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tender_bids")
public class TenderBid extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "tender_id")
    public Tender tender;
    
    @ManyToOne
    @JoinColumn(name = "vendor_id")
    public Vendor vendor;
    
    @Column(name = "bid_amount", precision = 15, scale = 2)
    public BigDecimal bidAmount;
    
    @Column(name = "submission_date")
    public LocalDateTime submissionDate;
    
    @Column(name = "validity_date")
    public LocalDate validityDate;
    
    @Column(name = "delivery_period_days")
    public Integer deliveryPeriodDays;
    
    @Column(name = "warranty_period_months")
    public Integer warrantyPeriodMonths;
    
    @Enumerated(EnumType.STRING)
    public BidStatus status = BidStatus.SUBMITTED;
    
    @Column(name = "technical_score", precision = 5, scale = 2)
    public BigDecimal technicalScore;
    
    @Column(name = "commercial_score", precision = 5, scale = 2)
    public BigDecimal commercialScore;
    
    @Column(name = "total_score", precision = 5, scale = 2)
    public BigDecimal totalScore;
    
    @Column(name = "evaluation_notes", length = 2000)
    public String evaluationNotes;
    
    public enum BidStatus {
        SUBMITTED("Submitted"),
        UNDER_EVALUATION("Under Evaluation"),
        QUALIFIED("Qualified"),
        DISQUALIFIED("Disqualified"),
        AWARDED("Awarded"),
        NOT_AWARDED("Not Awarded");
        
        private final String label;
        BidStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
