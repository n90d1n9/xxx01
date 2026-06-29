package tech.kayys.vendor.domain;

import java.time.LocalDate;
import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "vendor_evaluations")
public class VendorEvaluation extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "vendor_id")
    public Vendor vendor;
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "evaluation_period_start")
    public LocalDate evaluationPeriodStart;
    
    @Column(name = "evaluation_period_end")
    public LocalDate evaluationPeriodEnd;
    
    @Column(name = "quality_score", precision = 5, scale = 2)
    public BigDecimal qualityScore;
    
    @Column(name = "timeliness_score", precision = 5, scale = 2)
    public BigDecimal timelinessScore;
    
    @Column(name = "compliance_score", precision = 5, scale = 2)
    public BigDecimal complianceScore;
    
    @Column(name = "cost_competitiveness_score", precision = 5, scale = 2)
    public BigDecimal costCompetitivenessScore;
    
    @Column(name = "overall_score", precision = 5, scale = 2)
    public BigDecimal overallScore;
    
    @Column(name = "evaluator")
    public String evaluator;
    
    @Column(name = "evaluation_date")
    public LocalDate evaluationDate;
    
    @Column(name = "comments", length = 2000)
    public String comments;
    
    @PrePersist
    @PreUpdate
    public void calculateOverallScore() {
        if (qualityScore != null && timelinessScore != null && 
            complianceScore != null && costCompetitivenessScore != null) {
            // Weighted average: Quality(40%) + Timeliness(30%) + Compliance(20%) + Cost(10%)
            overallScore = qualityScore.multiply(new BigDecimal("0.4"))
                    .add(timelinessScore.multiply(new BigDecimal("0.3")))
                    .add(complianceScore.multiply(new BigDecimal("0.2")))
                    .add(costCompetitivenessScore.multiply(new BigDecimal("0.1")));
        }
    }
}
