package tech.kayys.risk.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import tech.kayys.risk.model.RiskImpact;
import tech.kayys.risk.model.RiskProbability;

@Entity
@Table(name = "risk_assessment_history")
public class RiskAssessmentHistory extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "risk_id")
    public RiskRegister risk;
    
    @Enumerated(EnumType.STRING)
    public RiskProbability previousProbability;
    
    @Enumerated(EnumType.STRING)
    public RiskProbability newProbability;
    
    @Enumerated(EnumType.STRING)
    public RiskImpact previousImpact;
    
    @Enumerated(EnumType.STRING)
    public RiskImpact newImpact;
    
    @Column(name = "previous_score")
    public Integer previousScore;
    
    @Column(name = "new_score")
    public Integer newScore;
    
    @Column(name = "assessment_date")
    public LocalDateTime assessmentDate = LocalDateTime.now();
    
    @Column(name = "assessed_by")
    public String assessedBy;
    
    @Column(name = "reason", length = 1000)
    public String reason;
}