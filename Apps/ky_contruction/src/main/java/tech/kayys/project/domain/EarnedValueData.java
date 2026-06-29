package tech.kayys.project.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "earned_value_data")
public class EarnedValueData extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "status_date")
    public LocalDate statusDate;
    
    @Column(name = "planned_value", precision = 15, scale = 2)
    public BigDecimal plannedValue; // PV - Budget Cost of Work Scheduled
    
    @Column(name = "earned_value", precision = 15, scale = 2)
    public BigDecimal earnedValue; // EV - Budget Cost of Work Performed
    
    @Column(name = "actual_cost", precision = 15, scale = 2)
    public BigDecimal actualCost; // AC - Actual Cost of Work Performed
    
    @Column(name = "budget_at_completion", precision = 15, scale = 2)
    public BigDecimal budgetAtCompletion; // BAC
    
    // Calculated fields
    @Column(name = "schedule_variance", precision = 15, scale = 2)
    public BigDecimal scheduleVariance; // SV = EV - PV
    
    @Column(name = "cost_variance", precision = 15, scale = 2)
    public BigDecimal costVariance; // CV = EV - AC
    
    @Column(name = "schedule_performance_index", precision = 5, scale = 3)
    public BigDecimal schedulePerformanceIndex; // SPI = EV / PV
    
    @Column(name = "cost_performance_index", precision = 5, scale = 3)
    public BigDecimal costPerformanceIndex; // CPI = EV / AC
    
    @Column(name = "estimate_at_completion", precision = 15, scale = 2)
    public BigDecimal estimateAtCompletion; // EAC = BAC / CPI
    
    @Column(name = "estimate_to_complete", precision = 15, scale = 2)
    public BigDecimal estimateToComplete; // ETC = EAC - AC
    
    @Column(name = "variance_at_completion", precision = 15, scale = 2)
    public BigDecimal varianceAtCompletion; // VAC = BAC - EAC
    
    @PrePersist
    @PreUpdate
    public void calculateValues() {
        if (earnedValue != null && plannedValue != null) {
            scheduleVariance = earnedValue.subtract(plannedValue);
        }
        if (earnedValue != null && actualCost != null) {
            costVariance = earnedValue.subtract(actualCost);
        }
        if (earnedValue != null && plannedValue != null && !plannedValue.equals(BigDecimal.ZERO)) {
            schedulePerformanceIndex = earnedValue.divide(plannedValue, 3, java.math.RoundingMode.HALF_UP);
        }
        if (earnedValue != null && actualCost != null && !actualCost.equals(BigDecimal.ZERO)) {
            costPerformanceIndex = earnedValue.divide(actualCost, 3, java.math.RoundingMode.HALF_UP);
        }
        if (budgetAtCompletion != null && costPerformanceIndex != null && !costPerformanceIndex.equals(BigDecimal.ZERO)) {
            estimateAtCompletion = budgetAtCompletion.divide(costPerformanceIndex, 2, java.math.RoundingMode.HALF_UP);
            estimateToComplete = estimateAtCompletion.subtract(actualCost != null ? actualCost : BigDecimal.ZERO);
            varianceAtCompletion = budgetAtCompletion.subtract(estimateAtCompletion);
        }
    }
}
