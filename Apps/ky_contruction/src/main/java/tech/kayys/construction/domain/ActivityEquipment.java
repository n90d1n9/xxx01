package tech.kayys.construction.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

@Entity
@Table(name = "activity_equipment")
public class ActivityEquipment extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id", nullable = false)
    public PhaseActivity activity;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_id", nullable = false)
    public Equipment equipment;
    
    @DecimalMin("0")
    @Column(name = "required_hours", precision = 8, scale = 2)
    public BigDecimal requiredHours;
    
    @DecimalMin("0")
    @Column(name = "allocated_hours", precision = 8, scale = 2)
    public BigDecimal allocatedHours = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "actual_hours", precision = 8, scale = 2)
    public BigDecimal actualHours = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "hourly_rate", precision = 15, scale = 2)
    public BigDecimal hourlyRate;
    
    @DecimalMin("0")
    @Column(name = "total_cost", precision = 15, scale = 2)
    public BigDecimal totalCost;
    
    @Column(name = "required_from_date")
    public LocalDate requiredFromDate;
    
    @Column(name = "required_to_date")
    public LocalDate requiredToDate;
    
    @Column(name = "allocated_from_date")
    public LocalDate allocatedFromDate;
    
    @Column(name = "allocated_to_date")
    public LocalDate allocatedToDate;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public EquipmentAllocationStatus status = EquipmentAllocationStatus.PLANNED;
    
    @Column(name = "operator_required")
    public Boolean operatorRequired = true;
    
    @Column(name = "operator_name")
    public String operatorName;
    
    @Column(name = "operator_certification")
    public String operatorCertification;
    
    @DecimalMin("0")
    @Column(name = "fuel_consumption_liters", precision = 8, scale = 2)
    public BigDecimal fuelConsumptionLiters;
    
    @DecimalMin("0")
    @Column(name = "maintenance_cost", precision = 15, scale = 2)
    public BigDecimal maintenanceCost = BigDecimal.ZERO;
    
    @Column(name = "working_location")
    public String workingLocation;
    
    @Column(name = "efficiency_rating")
    @Min(1) @Max(5)
    public Integer efficiencyRating; // 1-5 scale
    
    @Column(name = "breakdown_hours", precision = 8, scale = 2)
    public BigDecimal breakdownHours = BigDecimal.ZERO;
    
    @Column(name = "idle_hours", precision = 8, scale = 2)
    public BigDecimal idleHours = BigDecimal.ZERO;
    
    @Column(name = "performance_notes", length = 2000)
    public String performanceNotes;
    
    public enum EquipmentAllocationStatus {
        PLANNED("Direncanakan", "Equipment requirement planned"),
        REQUESTED("Diminta", "Equipment request submitted"),
        ALLOCATED("Dialokasikan", "Equipment allocated"),
        ON_SITE("Di Site", "Equipment arrived on site"),
        ACTIVE("Aktif", "Equipment actively working"),
        STANDBY("Standby", "Equipment on standby"),
        MAINTENANCE("Maintenance", "Equipment under maintenance"),
        COMPLETED("Selesai", "Equipment work completed"),
        RELEASED("Dilepas", "Equipment released from activity");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        EquipmentAllocationStatus(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    @PrePersist
    @PreUpdate
    public void calculateCosts() {
        if (allocatedHours != null && hourlyRate != null) {
            totalCost = allocatedHours.multiply(hourlyRate).add(
                    maintenanceCost != null ? maintenanceCost : BigDecimal.ZERO);
        }
    }
    
    public BigDecimal getUtilizationRate() {
        if (allocatedHours == null || allocatedHours.equals(BigDecimal.ZERO)) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal workingHours = actualHours != null ? actualHours : BigDecimal.ZERO;
        BigDecimal nonWorkingHours = (breakdownHours != null ? breakdownHours : BigDecimal.ZERO)
                .add(idleHours != null ? idleHours : BigDecimal.ZERO);
        BigDecimal totalAvailableHours = workingHours.add(nonWorkingHours);
        
        if (totalAvailableHours.equals(BigDecimal.ZERO)) {
            return BigDecimal.ZERO;
        }
        
        return workingHours.divide(totalAvailableHours, 4, java.math.RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
    }
    
    public BigDecimal getEfficiencyRate() {
        if (requiredHours == null || requiredHours.equals(BigDecimal.ZERO) || actualHours == null) {
            return BigDecimal.ZERO;
        }
        
        return requiredHours.divide(actualHours, 4, java.math.RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
    }
}
