package tech.kayys.contract.domain;

import java.time.LocalDate;
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
@Table(name = "contract_claims")
public class ContractClaim extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "contract_id")
    public Contract contract;
    
    @Column(name = "claim_number", unique = true)
    public String claimNumber;
    
    @Column(name = "claim_title")
    public String claimTitle;
    
    @Column(length = 2000)
    public String description;
    
    @Enumerated(EnumType.STRING)
    public ClaimType claimType;
    
    @Enumerated(EnumType.STRING)
    public ClaimStatus status = ClaimStatus.SUBMITTED;
    
    @Column(name = "claimed_amount", precision = 15, scale = 2)
    public BigDecimal claimedAmount;
    
    @Column(name = "time_extension_days")
    public Integer timeExtensionDays;
    
    @Column(name = "submitted_date")
    public LocalDate submittedDate;
    
    @Column(name = "response_due_date")
    public LocalDate responseDueDate;
    
    @Column(name = "contractor_position", length = 2000)
    public String contractorPosition;
    
    @Column(name = "owner_response", length = 2000)
    public String ownerResponse;
    
    @Column(name = "agreed_amount", precision = 15, scale = 2)
    public BigDecimal agreedAmount;
    
    @Column(name = "agreed_time_extension")
    public Integer agreedTimeExtension;
    
    @Column(name = "settlement_date")
    public LocalDate settlementDate;
    
    public enum ClaimType {
        VARIATION_ORDER("Variation Order"),
        TIME_EXTENSION("Time Extension"),
        COMPENSATION_EVENT("Compensation Event"),
        FORCE_MAJEURE("Force Majeure"),
        ADDITIONAL_COST("Additional Cost"),
        DISPUTE("Dispute");
        
        private final String label;
        ClaimType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum ClaimStatus {
        SUBMITTED("Diajukan"),
        UNDER_REVIEW("Dalam Review"),
        NEGOTIATING("Negosiasi"),
        AGREED("Disepakati"),
        REJECTED("Ditolak"),
        ARBITRATION("Arbitrase");
        
        private final String label;
        ClaimStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
