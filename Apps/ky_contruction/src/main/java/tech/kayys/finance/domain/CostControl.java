package tech.kayys.finance.domain;


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
import tech.kayys.project.domain.WorkPackage;

@Entity
@Table(name = "cost_controls")
public class CostControl extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @ManyToOne
    @JoinColumn(name = "work_package_id")
    public WorkPackage workPackage;
    
    @Column(name = "cost_code")
    public String costCode;
    
    @Column(name = "cost_description")
    public String costDescription;
    
    @Column(name = "original_budget", precision = 15, scale = 2)
    public BigDecimal originalBudget;
    
    @Column(name = "approved_changes", precision = 15, scale = 2)
    public BigDecimal approvedChanges = BigDecimal.ZERO;
    
    @Column(name = "current_budget", precision = 15, scale = 2)
    public BigDecimal currentBudget;
    
    @Column(name = "committed_costs", precision = 15, scale = 2)
    public BigDecimal committedCosts = BigDecimal.ZERO;
    
    @Column(name = "actual_costs", precision = 15, scale = 2)
    public BigDecimal actualCosts = BigDecimal.ZERO;
    
    @Column(name = "forecast_final_cost", precision = 15, scale = 2)
    public BigDecimal forecastFinalCost;
    
    @Column(name = "variance", precision = 15, scale = 2)
    public BigDecimal variance;
    
    @Column(name = "status_date")
    public LocalDate statusDate;
    
    @PrePersist
    @PreUpdate
    public void calculateValues() {
        if (originalBudget != null && approvedChanges != null) {
            currentBudget = originalBudget.add(approvedChanges);
        }
        if (currentBudget != null && forecastFinalCost != null) {
            variance = currentBudget.subtract(forecastFinalCost);
        }
    }
}
