package tech.kayys.construction.domain;

import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import tech.kayys.finance.domain.BoqItem;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "technical_specifications")
public class TechnicalSpecification extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "boq_item_id")
    public BoqItem boqItem;
    
    @NotBlank
    @Column(name = "specification_code", nullable = false)
    public String specificationCode;
    
    @NotBlank
    @Column(name = "specification_title", nullable = false)
    public String specificationTitle;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public SpecificationCategory category;
    
    @Column(name = "general_description", length = 3000)
    public String generalDescription;
    
    @Column(name = "materials_and_equipment", length = 5000, nullable = false)
    public String materialsAndEquipment;
    
    @Column(name = "execution_requirements", length = 4000)
    public String executionRequirements;
    
    @Column(name = "quality_requirements", length = 3000, nullable = false)
    public String qualityRequirements;
    
    @Column(name = "testing_requirements", length = 3000)
    public String testingRequirements;
    
    @Column(name = "acceptance_criteria", length = 2000, nullable = false)
    public String acceptanceCriteria;
    
    @Column(name = "applicable_standards", length = 2000)
    public String applicableStandards;
    
    // Indonesian specific standards
    @Column(name = "sni_references", length = 1000)
    public String sniReferences;
    
    @Column(name = "local_regulations", length = 1500)
    public String localRegulations;
    
    @Column(name = "environmental_requirements", length = 2000)
    public String environmentalRequirements;
    
    @Column(name = "safety_requirements", length = 2000)
    public String safetyRequirements;
    
    @Column(name = "measurement_and_payment", length = 1500)
    public String measurementAndPayment;
    
    @Column(name = "warranty_requirements", length = 1000)
    public String warrantyRequirements;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public SpecificationStatus status = SpecificationStatus.DRAFT;
    
    @Column(name = "created_by", nullable = false)
    public String createdBy;
    
    @Column(name = "reviewed_by")
    public String reviewedBy;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "created_date", nullable = false)
    public LocalDate createdDate;
    
    @Column(name = "review_date")
    public LocalDate reviewDate;
    
    @Column(name = "approval_date")
    public LocalDate approvalDate;
    
    @Column(name = "revision_number", nullable = false)
    public Integer revisionNumber = 0;
    
    public enum SpecificationCategory {
        GENERAL("Umum", "General specifications"),
        EARTHWORK("Pekerjaan Tanah", "Earthwork specifications"),
        CONCRETE("Beton", "Concrete specifications"),
        STEEL("Baja", "Steel specifications"),
        MASONRY("Pasangan", "Masonry specifications"),
        CARPENTRY("Kayu", "Carpentry specifications"),
        ROOFING("Atap", "Roofing specifications"),
        WATERPROOFING("Kedap Air", "Waterproofing specifications"),
        FINISHING("Finishing", "Finishing specifications"),
        ELECTRICAL("Elektrikal", "Electrical specifications"),
        MECHANICAL("Mekanikal", "Mechanical specifications"),
        PLUMBING("Plumbing", "Plumbing specifications"),
        FIRE_PROTECTION("Proteksi Kebakaran", "Fire protection specifications"),
        LANDSCAPING("Landscaping", "Landscaping specifications");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        SpecificationCategory(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum SpecificationStatus {
        DRAFT("Draft"),
        UNDER_REVIEW("Dalam Review"),
        APPROVED("Disetujui"),
        SUPERSEDED("Digantikan");
        
        private final String indonesianLabel;
        
        SpecificationStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
}
