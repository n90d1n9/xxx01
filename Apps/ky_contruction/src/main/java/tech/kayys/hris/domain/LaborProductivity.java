package tech.kayys.hris.domain;

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
@Table(name = "labor_productivity")
public class LaborProductivity extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @ManyToOne
    @JoinColumn(name = "work_package_id")
    public WorkPackage workPackage;
    
    @Column(name = "date")
    public LocalDate date;
    
    @Column(name = "crew_size")
    public Integer crewSize;
    
    @Column(name = "work_hours", precision = 8, scale = 2)
    public BigDecimal workHours;
    
    @Column(name = "quantity_completed", precision = 12, scale = 3)
    public BigDecimal quantityCompleted;
    
    @Column(name = "unit")
    public String unit;
    
    @Column(name = "productivity_rate", precision = 8, scale = 3)
    public BigDecimal productivityRate; // quantity per hour
    
    @Column(name = "standard_rate", precision = 8, scale = 3)
    public BigDecimal standardRate;
    
    @Column(name = "efficiency_percentage", precision = 5, scale = 2)
    public BigDecimal efficiencyPercentage;
    
    @Column(name = "supervisor")
    public String supervisor;
    
    @Column(name = "notes", length = 1000)
    public String notes;
    
    @PrePersist
    @PreUpdate
    public void calculateProductivity() {
        if (quantityCompleted != null && workHours != null && !workHours.equals(BigDecimal.ZERO)) {
            productivityRate = quantityCompleted.divide(workHours, 3, java.math.RoundingMode.HALF_UP);
        }
        if (productivityRate != null && standardRate != null && !standardRate.equals(BigDecimal.ZERO)) {
            efficiencyPercentage = productivityRate.divide(standardRate, 4, java.math.RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"));
        }
    }
}