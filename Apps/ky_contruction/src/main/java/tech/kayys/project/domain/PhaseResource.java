package tech.kayys.project.domain;

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
import tech.kayys.construction.domain.ConstructionPhase;
import tech.kayys.construction.domain.PhaseActivity.SkillLevel;

@Entity
@Table(name = "phase_resources")
public class PhaseResource extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id", nullable = false)
    public ConstructionPhase phase;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public ResourceType resourceType;
    
    @Column(name = "resource_name", nullable = false)
    public String resourceName;
    
    @Column(name = "resource_description", length = 1000)
    public String resourceDescription;
    
    @DecimalMin("0")
    @Column(name = "required_quantity", precision = 12, scale = 3)
    public BigDecimal requiredQuantity;
    
    @DecimalMin("0")
    @Column(name = "allocated_quantity", precision = 12, scale = 3)
    public BigDecimal allocatedQuantity = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "utilized_quantity", precision = 12, scale = 3)
    public BigDecimal utilizedQuantity = BigDecimal.ZERO;
    
    @Column(name = "unit_of_measure")
    public String unitOfMeasure;
    
    @DecimalMin("0")
    @Column(name = "unit_cost", precision = 15, scale = 2)
    public BigDecimal unitCost;
    
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
    public ResourceStatus status = ResourceStatus.PLANNED;
    
    @Column(name = "supplier_vendor")
    public String supplierVendor;
    
    @Column(name = "lead_time_days")
    public Integer leadTimeDays;
    
    @Column(name = "critical_resource")
    public Boolean criticalResource = false;
    
    @Enumerated(EnumType.STRING)
    public SkillLevel skillLevelRequired; // For human resources
    
    @Column(name = "certification_required")
    public String certificationRequired;
    
    @Column(name = "resource_notes", length = 2000)
    public String resourceNotes;
    
    public enum ResourceType {
        HUMAN_RESOURCE("Sumber Daya Manusia", "Skilled and unskilled labor"),
        MATERIAL("Material", "Construction materials"),
        EQUIPMENT("Peralatan", "Construction equipment and tools"),
        VEHICLE("Kendaraan", "Transportation vehicles"),
        FACILITY("Fasilitas", "Temporary facilities"),
        SERVICE("Jasa", "Professional services"),
        SUBCONTRACTOR("Subkontraktor", "Subcontracted work");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        ResourceType(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum ResourceStatus {
        PLANNED("Direncanakan"),
        REQUESTED("Diminta"),
        ALLOCATED("Dialokasikan"),
        IN_USE("Sedang Digunakan"),
        COMPLETED("Selesai"),
        CANCELLED("Dibatalkan"),
        SHORTAGE("Kekurangan");
        
        private final String indonesianLabel;
        
        ResourceStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public BigDecimal getUtilizationPercentage() {
        if (allocatedQuantity == null || allocatedQuantity.equals(BigDecimal.ZERO)) {
            return BigDecimal.ZERO;
        }
        return utilizedQuantity.divide(allocatedQuantity, 4, java.math.RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
    }
    
    public Boolean isShortage() {
        if (requiredQuantity == null || allocatedQuantity == null) {
            return false;
        }
        return allocatedQuantity.compareTo(requiredQuantity) < 0;
    }
    
    @PrePersist
    @PreUpdate
    public void calculateTotalCost() {
        if (allocatedQuantity != null && unitCost != null) {
            totalCost = allocatedQuantity.multiply(unitCost);
        }
    }
}