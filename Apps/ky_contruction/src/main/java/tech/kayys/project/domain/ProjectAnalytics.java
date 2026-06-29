package tech.kayys.project.domain;

import java.time.LocalDate;
import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "project_analytics")
public class ProjectAnalytics extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "analysis_date")
    public LocalDate analysisDate;
    
    @Column(name = "delay_risk_score", precision = 5, scale = 2)
    public BigDecimal delayRiskScore;
    
    @Column(name = "cost_overrun_risk_score", precision = 5, scale = 2)
    public BigDecimal costOverrunRiskScore;
    
    @Column(name = "quality_risk_score", precision = 5, scale = 2)
    public BigDecimal qualityRiskScore;
    
    @Column(name = "predicted_completion_date")
    public LocalDate predictedCompletionDate;
    
    @Column(name = "predicted_final_cost", precision = 15, scale = 2)
    public BigDecimal predictedFinalCost;
    
    @Column(name = "productivity_index", precision = 5, scale = 2)
    public BigDecimal productivityIndex;
    
    @Column(name = "resource_utilization_score", precision = 5, scale = 2)
    public BigDecimal resourceUtilizationScore;
    
    @Column(name = "recommendations", length = 2000)
    public String recommendations;
    
    @Column(name = "confidence_level", precision = 5, scale = 2)
    public BigDecimal confidenceLevel;
}
