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

@Entity
@Table(name = "activity_materials")
public class ActivityMaterial extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id", nullable = false)
    public PhaseActivity activity;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "material_id", nullable = false)
    public Material material;
    
    @DecimalMin("0")
    @Column(name = "required_quantity", precision = 12, scale = 3, nullable = false)
    public BigDecimal requiredQuantity;
    
    @DecimalMin("0")
    @Column(name = "allocated_quantity", precision = 12, scale = 3)
    public BigDecimal allocatedQuantity = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "consumed_quantity", precision = 12, scale = 3)
    public BigDecimal consumedQuantity = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "unit_cost", precision = 15, scale = 2)
    public BigDecimal unitCost;
    
    @DecimalMin("0")
    @Column(name = "total_cost", precision = 15, scale = 2)
    public BigDecimal totalCost;
    
    @Column(name = "required_date")
    public LocalDate requiredDate;
    
    @Column(name = "allocated_date")
    public LocalDate allocatedDate;
    
    @Column(name = "delivery_date")
    public LocalDate deliveryDate;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public MaterialAllocationStatus status = MaterialAllocationStatus.PLANNED;
    
    @DecimalMin("0")
    @Column(name = "wastage_percentage", precision = 5, scale = 2)
    public BigDecimal wastagePercentage = new BigDecimal("5.00");
    
    @DecimalMin("0")
    @Column(name = "actual_wastage_quantity", precision = 12, scale = 3)
    public BigDecimal actualWastageQuantity = BigDecimal.ZERO;
    
    @Column(name = "storage_location")
    public String storageLocation;
    
    @Column(name = "supplier_reference")
    public String supplierReference;
    
    @Column(name = "quality_approved")
    public Boolean qualityApproved = false;
    
    @Column(name = "quality_approved_by")
    public String qualityApprovedBy;
    
    @Column(name = "quality_approval_date")
    public LocalDate qualityApprovalDate;
    
    @Column(name = "installation_notes", length = 1000)
    public String installationNotes;
    
    public enum MaterialAllocationStatus {
        PLANNED("Direncanakan", "Material requirement planned"),
        REQUESTED("Diminta", "Request submitted to procurement"),
        ALLOCATED("Dialokasikan", "Material allocated from stock"),
        ORDERED("Dipesan", "Purchase order issued"),
        DELIVERED("Dikirim", "Material delivered to site"),
        INSTALLED("Terpasang", "Material installed/used"),
        COMPLETED("Selesai", "Material usage completed");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        MaterialAllocationStatus(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    @PrePersist
    @PreUpdate
    public void calculateCosts() {
        if (requiredQuantity != null && unitCost != null) {
            // Include wastage in total cost calculation
            BigDecimal totalQuantityWithWastage = requiredQuantity;
            if (wastagePercentage != null) {
                BigDecimal wastage = requiredQuantity.multiply(wastagePercentage.divide(new BigDecimal("100")));
                totalQuantityWithWastage = requiredQuantity.add(wastage);
            }
            totalCost = totalQuantityWithWastage.multiply(unitCost);
        }
    }
    
    public BigDecimal getWastageAmount() {
        if (consumedQuantity == null || requiredQuantity == null || 
            requiredQuantity.equals(BigDecimal.ZERO)) {
            return BigDecimal.ZERO;
        }
        return consumedQuantity.subtract(requiredQuantity).max(BigDecimal.ZERO);
    }
    
    public BigDecimal getWastagePercentageActual() {
        if (consumedQuantity == null || requiredQuantity == null || 
            requiredQuantity.equals(BigDecimal.ZERO)) {
            return BigDecimal.ZERO;
        }
        return getWastageAmount().divide(requiredQuantity, 4, java.math.RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
    }
}

