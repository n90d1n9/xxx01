package tech.kayys.construction.domain;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.validation.constraints.DecimalMin;
import tech.kayys.finance.domain.BoqItem;

@Entity
@Table(name = "detailed_boq_analysis")
public class DetailedBoQAnalysis extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "boq_item_id", nullable = false)
    public BoqItem boqItem;
    
    // Detailed cost breakdown
    @DecimalMin("0.00")
    @Column(name = "material_cost_percentage", precision = 5, scale = 2)
    public BigDecimal materialCostPercentage;
    
    @DecimalMin("0.00")
    @Column(name = "labor_cost_percentage", precision = 5, scale = 2)
    public BigDecimal laborCostPercentage;
    
    @DecimalMin("0.00")
    @Column(name = "equipment_cost_percentage", precision = 5, scale = 2)
    public BigDecimal equipmentCostPercentage;
    
    @DecimalMin("0.00")
    @Column(name = "subcontractor_cost_percentage", precision = 5, scale = 2)
    public BigDecimal subcontractorCostPercentage;
    
    // Productivity analysis
    @DecimalMin("0.00")
    @Column(name = "standard_productivity_rate", precision = 10, scale = 4)
    public BigDecimal standardProductivityRate; // units per hour
    
    @DecimalMin("0.00")
    @Column(name = "actual_productivity_rate", precision = 10, scale = 4)
    public BigDecimal actualProductivityRate;
    
    @DecimalMin("0.00")
    @Column(name = "productivity_factor", precision = 5, scale = 3)
    public BigDecimal productivityFactor; // actual/standard
    
    // Waste analysis
    @DecimalMin("0.00")
    @Column(name = "expected_waste_percentage", precision = 5, scale = 2)
    public BigDecimal expectedWastePercentage;
    
    @DecimalMin("0.00")
    @Column(name = "actual_waste_percentage", precision = 5, scale = 2)
    public BigDecimal actualWastePercentage;
    
    @DecimalMin("0.00")
    @Column(name = "waste_cost_impact", precision = 15, scale = 2)
    public BigDecimal wasteCostImpact;
    
    // Risk factors
    @Column(name = "complexity_factor", precision = 3, scale = 2)
    public BigDecimal complexityFactor = new BigDecimal("1.00");
    
    @Column(name = "weather_risk_factor", precision = 3, scale = 2)
    public BigDecimal weatherRiskFactor = new BigDecimal("1.00");
    
    @Column(name = "access_difficulty_factor", precision = 3, scale = 2)
    public BigDecimal accessDifficultyFactor = new BigDecimal("1.00");
    
    @Column(name = "quality_risk_factor", precision = 3, scale = 2)
    public BigDecimal qualityRiskFactor = new BigDecimal("1.00");
    
    // Indonesian specific factors
    @Column(name = "local_content_percentage", precision = 5, scale = 2)
    public BigDecimal localContentPercentage; // TKDN requirement
    
    @Column(name = "sni_compliance_cost", precision = 15, scale = 2)
    public BigDecimal sniComplianceCost;
    
    @Column(name = "k3_compliance_cost", precision = 15, scale = 2)
    public BigDecimal k3ComplianceCost;
    
    @Column(name = "environmental_compliance_cost", precision = 15, scale = 2)
    public BigDecimal environmentalComplianceCost;
    
    // Method of measurement
    @Column(name = "measurement_method", length = 1000)
    public String measurementMethod;
    
    @Column(name = "measurement_criteria", length = 2000)
    public String measurementCriteria;
    
    @Column(name = "payment_criteria", length = 1000)
    public String paymentCriteria;
    
    // Updated tracking
    @Column(name = "last_updated")
    public LocalDateTime lastUpdated;
    
    @Column(name = "updated_by")
    public String updatedBy;
    
    @PrePersist
    @PreUpdate
    public void updateTimestamp() {
        lastUpdated = LocalDateTime.now();
    }
    
    public BigDecimal calculateAdjustedUnitPrice() {
        if (boqItem == null || boqItem.unitPrice == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal basePrice = boqItem.unitPrice;
        BigDecimal adjustmentFactor = BigDecimal.ONE;
        
        if (complexityFactor != null) {
            adjustmentFactor = adjustmentFactor.multiply(complexityFactor);
        }
        if (weatherRiskFactor != null) {
            adjustmentFactor = adjustmentFactor.multiply(weatherRiskFactor);
        }
        if (accessDifficultyFactor != null) {
            adjustmentFactor = adjustmentFactor.multiply(accessDifficultyFactor);
        }
        if (qualityRiskFactor != null) {
            adjustmentFactor = adjustmentFactor.multiply(qualityRiskFactor);
        }
        
        return basePrice.multiply(adjustmentFactor);
    }
}
