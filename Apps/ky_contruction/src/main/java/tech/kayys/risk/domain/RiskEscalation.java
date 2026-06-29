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
@Table(name = "risk_escalations")
public class RiskEscalation extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "risk_id")
    public RiskRegister risk;
    
    @Enumerated(EnumType.STRING)
    public EscalationType escalationType;
    
    @Enumerated(EnumType.STRING)
    public EscalationLevel escalationLevel;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "escalated_by")
    public User escalatedBy;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "escalated_to")
    public User escalatedTo;
    
    @Column(name = "reason", length = 2000)
    public String reason;
    
    @Column(name = "escalation_date")
    public LocalDateTime escalationDate = LocalDateTime.now();
    
    @Column(name = "resolution_required_by")
    public LocalDateTime resolutionRequiredBy;
    
    @Column(name = "resolved_date")
    public LocalDateTime resolvedDate;
    
    @Column(name = "resolution", length = 2000)
    public String resolution;
    
    @Enumerated(EnumType.STRING)
    public EscalationStatus status = EscalationStatus.OPEN;
    
    public enum EscalationType {
        RISK_BREACH("Risk Threshold Breach"),
        OVERDUE_ACTION("Overdue Mitigation Action"),
        HIGH_IMPACT("High Impact Risk"),
        REGULATORY("Regulatory Concern"),
        BOARD_ATTENTION("Board Attention Required");
        
        private final String label;
        EscalationType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum EscalationLevel {
        MANAGER("Manager"),
        DIRECTOR("Director"),
        EXECUTIVE("Executive"),
        BOARD("Board");
        
        private final String label;
        EscalationLevel(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum EscalationStatus {
        OPEN("Open"),
        ACKNOWLEDGED("Acknowledged"),
        RESOLVED("Resolved"),
        CLOSED("Closed");
        
        private final String label;
        EscalationStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
