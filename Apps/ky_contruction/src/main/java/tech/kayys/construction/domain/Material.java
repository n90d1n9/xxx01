package tech.kayys.construction.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "materials_enhanced")
public class Material extends PanacheEntity {
    
    @Column(name = "material_code", unique = true, nullable = false)
    public String materialCode;
    
    @NotBlank
    @Column(nullable = false)
    public String name;
    
    @Column(length = 2000)
    public String description;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    public MaterialCategory category;
    
    @NotBlank
    @Column(nullable = false)
    public String unit;
    
    @DecimalMin("0")
    @Column(name = "unit_price", precision = 15, scale = 2)
    public BigDecimal unitPrice;
    
    @Column(name = "last_price_update")
    public LocalDateTime lastPriceUpdate;
    
    @Column(name = "price_valid_until")
    public LocalDate priceValidUntil;
    
    @Column(name = "supplier_primary")
    public String supplierPrimary;
    
    @Column(name = "supplier_secondary")
    public String supplierSecondary;
    
    @Column(name = "supplier_contact_primary")
    public String supplierContactPrimary;
    
    @Column(name = "supplier_contact_secondary")
    public String supplierContactSecondary;
    
    @DecimalMin("0")
    @Column(name = "current_stock", precision = 12, scale = 3)
    public BigDecimal currentStock = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "reserved_stock", precision = 12, scale = 3)
    public BigDecimal reservedStock = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "available_stock", precision = 12, scale = 3)
    public BigDecimal availableStock = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "minimum_stock", precision = 12, scale = 3)
    public BigDecimal minimumStock = BigDecimal.ZERO;
    
    @DecimalMin("0")
    @Column(name = "maximum_stock", precision = 12, scale = 3)
    public BigDecimal maximumStock;
    
    @DecimalMin("0")
    @Column(name = "reorder_point", precision = 12, scale = 3)
    public BigDecimal reorderPoint;
    
    @DecimalMin("0")
    @Column(name = "economic_order_quantity", precision = 12, scale = 3)
    public BigDecimal economicOrderQuantity;
    
    @Min(0)
    @Column(name = "lead_time_days")
    public Integer leadTimeDays;
    
    @Column(name = "quality_grade")
    public String qualityGrade;
    
    @Column(name = "brand_primary")
    public String brandPrimary;
    
    @Column(name = "brand_alternatives", length = 1000)
    public String brandAlternatives; // JSON array
    
    @Column(name = "technical_specifications", length = 3000)
    public String technicalSpecifications;
    
    @Column(name = "storage_requirements", length = 1000)
    public String storageRequirements;
    
    @Column(name = "handling_instructions", length = 1000)
    public String handlingInstructions;
    
    @Column(name = "safety_data_sheet_path")
    public String safetyDataSheetPath;
    
    @Min(0)
    @Column(name = "shelf_life_days")
    public Integer shelfLifeDays;
    
    @Column(name = "environmental_impact")
    @Enumerated(EnumType.STRING)
    public EnvironmentalImpact environmentalImpact = EnvironmentalImpact.LOW;
    
    @Column(name = "hazard_classification")
    @Enumerated(EnumType.STRING)
    public HazardClassification hazardClassification = HazardClassification.NON_HAZARDOUS;
    
    // Indonesian specific fields
    @Column(name = "sni_standard_reference")
    public String sniStandardReference;
    
    @Column(name = "local_content_percentage", precision = 5, scale = 2)
    public BigDecimal localContentPercentage; // TKDN
    
    @Column(name = "import_duty_percentage", precision = 5, scale = 2)
    public BigDecimal importDutyPercentage;
    
    @Column(name = "ppn_applicable")
    public Boolean ppnApplicable = true;
    
    @Column(name = "luxury_tax_applicable")
    public Boolean luxuryTaxApplicable = false;
    
    @Column(name = "origin_country")
    public String originCountry = "Indonesia";
    
    @Column(name = "hs_code")
    public String hsCode; // Harmonized System code for customs
    
    @Column(name = "quality_certifications", length = 1000)
    public String qualityCertifications; // JSON array of certifications
    
    @Column(name = "is_active")
    public Boolean isActive = true;
    
    @Column(name = "discontinue_date")
    public LocalDate discontinueDate;
    
    @Column(name = "replacement_material_id")
    public Long replacementMaterialId;
    
    @Column(name = "created_at")
    public LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    public LocalDateTime updatedAt;
    
    @Column(name = "last_inventory_date")
    public LocalDate lastInventoryDate;
    
    @OneToMany(mappedBy = "material", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<MaterialPriceHistory> priceHistory;
    
    @OneToMany(mappedBy = "material", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<MaterialTransaction> transactions;
    
    @OneToMany(mappedBy = "material", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<MaterialQualityCheck> qualityChecks;
    
    public enum EnvironmentalImpact {
        LOW("Rendah", "Minimal environmental impact"),
        MEDIUM("Sedang", "Moderate environmental considerations"),
        HIGH("Tinggi", "Significant environmental controls required");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        EnvironmentalImpact(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum HazardClassification {
        NON_HAZARDOUS("Tidak Berbahaya", "Non-hazardous material"),
        FLAMMABLE("Mudah Terbakar", "Flammable material"),
        TOXIC("Beracun", "Toxic material"),
        CORROSIVE("Korosif", "Corrosive material"),
        EXPLOSIVE("Mudah Meledak", "Explosive material"),
        RADIOACTIVE("Radioaktif", "Radioactive material");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        HazardClassification(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        calculateAvailableStock();
    }
    
    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
        calculateAvailableStock();
    }
    
    private void calculateAvailableStock() {
        if (currentStock != null && reservedStock != null) {
            availableStock = currentStock.subtract(reservedStock);
        }
    }
    
    public Boolean isStockLow() {
        return currentStock.compareTo(minimumStock) <= 0;
    }
    
    public Boolean needsReorder() {
        return reorderPoint != null && currentStock.compareTo(reorderPoint) <= 0;
    }
    
    public Boolean isExpiringSoon(int daysThreshold) {
        if (shelfLifeDays == null) return false;
        
        // Check if material will expire within threshold days
        LocalDate expiryDate = lastInventoryDate != null ? 
                lastInventoryDate.plusDays(shelf