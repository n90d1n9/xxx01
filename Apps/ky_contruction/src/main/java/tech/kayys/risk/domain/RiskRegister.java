package tech.kayys.risk.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import tech.kayys.profile.domain.User;
import tech.kayys.project.domain.Project;
import tech.kayys.risk.listener.RiskRegisterListener;
import tech.kayys.risk.model.MitigationStrategy;
import tech.kayys.risk.model.RegulatoryRequirement;
import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.model.RiskImpact;
import tech.kayys.risk.model.RiskLevel;
import tech.kayys.risk.model.RiskProbability;
import tech.kayys.risk.model.RiskStatus;
import tech.kayys.risk.model.RiskTrend;
import tech.kayys.risk.model.RiskType;

@Entity
@Table(name = "risk_register")
@EntityListeners(RiskRegisterListener.class)
public class RiskRegister extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "risk_id", unique = true)
    public String riskId;
    
    @Column(name = "risk_title")
    public String riskTitle;
    
    @Column(length = 5000)
    public String description;
    
    @Enumerated(EnumType.STRING)
    public RiskCategory category;
    
    @Enumerated(EnumType.STRING)
    public RiskType type;
    
    //  probability and impact with quantitative measures
    @Enumerated(EnumType.STRING)
    public RiskProbability probability;
    
    @Enumerated(EnumType.STRING)
    public RiskImpact impact;
    
    @Column(name = "quantitative_probability")
    public Double quantitativeProbability; // 0.0 to 1.0
    
    @Column(name = "financial_impact")
    public BigDecimal financialImpact;
    
    @Column(name = "risk_score")
    public Integer riskScore;
    
    @Column(name = "inherent_risk_score")
    public Integer inherentRiskScore; // Before mitigation
    
    @Column(name = "residual_risk_score")
    public Integer residualRiskScore; // After mitigation
    
    @Enumerated(EnumType.STRING)
    public RiskStatus status = RiskStatus.IDENTIFIED;
    
    @Enumerated(EnumType.STRING)
    public RiskTrend trend = RiskTrend.STABLE;
    
    // Enhanced ownership and responsibility
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    public User owner;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewer_id")
    public User reviewer;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approver_id")
    public User approver;
    
    // Enhanced dates and tracking
    @Column(name = "identified_date")
    public LocalDate identifiedDate;
    
    @Column(name = "last_assessment_date")
    public LocalDate lastAssessmentDate;
    
    @Column(name = "next_review_date")
    public LocalDate nextReviewDate;
    
    @Column(name = "target_closure_date")
    public LocalDate targetClosureDate;
    
    @Column(name = "actual_closure_date")
    public LocalDate actualClosureDate;
    
    // Enhanced mitigation
    @Column(name = "mitigation_strategy", length = 5000)
    public String mitigationStrategy;
    
    @Column(name = "contingency_plan", length = 5000)
    public String contingencyPlan;
    
    @Enumerated(EnumType.STRING)
    public MitigationStrategy mitigationApproach;
    
    // Compliance and regulatory
    @ElementCollection
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "risk_regulatory_requirements")
    public Set<RegulatoryRequirement> regulatoryRequirements = new HashSet<>();
    
    @Column(name = "compliance_notes", length = 2000)
    public String complianceNotes;
    
    // KRIs (Key Risk Indicators)
    @OneToMany(mappedBy = "risk", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<KeyRiskIndicator> keyRiskIndicators;
    
    // Relationships
    @OneToMany(mappedBy = "risk", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<RiskMitigationAction> mitigationActions;
    
    @OneToMany(mappedBy = "risk", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<RiskAssessmentHistory> assessmentHistory;
    
    @OneToMany(mappedBy = "risk", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<RiskDocument> documents;
    
    @OneToMany(mappedBy = "risk", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<RiskEscalation> escalations;
    
    // Audit trail
    @CreationTimestamp
    @Column(name = "created_date")
    public LocalDateTime createdDate;
    
    @UpdateTimestamp
    @Column(name = "updated_date")
    public LocalDateTime updatedDate;
    
    @Column(name = "created_by")
    public String createdBy;
    
    @Column(name = "updated_by")
    public String updatedBy;
    
    @Version
    public Long version;

    //  calculation methods
    @PrePersist
    @PreUpdate
    public void calculateRiskScores() {
        if (probability != null && impact != null) {
            this.riskScore = probability.getScore() * impact.getScore();
            
            // Set inherent risk score if not set
            if (this.inherentRiskScore == null) {
                this.inherentRiskScore = this.riskScore;
            }
            
            // Calculate residual risk based on mitigation effectiveness
            calculateResidualRisk();
        }
    }
    
    private void calculateResidualRisk() {
        if (mitigationActions != null && !mitigationActions.isEmpty()) {
            double mitigationEffectiveness = calculateMitigationEffectiveness();
            this.residualRiskScore = (int) Math.round(this.inherentRiskScore * (1 - mitigationEffectiveness));
        } else {
            this.residualRiskScore = this.inherentRiskScore;
        }
    }
    
    private double calculateMitigationEffectiveness() {
        if (mitigationActions == null || mitigationActions.isEmpty()) {
            return 0.0;
        }
        
        double totalEffectiveness = mitigationActions.stream()
                .filter(action -> action.status == RiskMitigationAction.ActionStatus.COMPLETED)
                .mapToDouble(action -> action.effectiveness != null ? action.effectiveness : 0.0)
                .sum();
        
        return Math.min(totalEffectiveness / 100.0, 0.9); // Max 90% mitigation
    }
    
    public RiskLevel getRiskLevel() {
        if (residualRiskScore != null) {
            if (residualRiskScore >= 20) return RiskLevel.CRITICAL;
            if (residualRiskScore >= 15) return RiskLevel.HIGH;
            if (residualRiskScore >= 10) return RiskLevel.MEDIUM;
            if (residualRiskScore >= 5) return RiskLevel.LOW;
        }
        return RiskLevel.VERY_LOW;
    }
    

}
