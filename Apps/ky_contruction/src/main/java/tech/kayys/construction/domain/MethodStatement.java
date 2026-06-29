package tech.kayys.construction.domain;

import java.time.LocalDate;
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
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import tech.kayys.finance.domain.MethodStatementAttachment;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "method_statements")
public class MethodStatement extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id")
    public ConstructionPhase phase;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id")
    public PhaseActivity activity;
    
    @NotBlank
    @Column(name = "method_statement_number", unique = true, nullable = false)
    public String methodStatementNumber;
    
    @NotBlank
    @Column(name = "title", nullable = false)
    public String title;
    
    @Column(length = 3000)
    public String description;
    
    @Column(name = "work_scope", length = 3000, nullable = false)
    public String workScope;
    
    @Column(name = "construction_method", length = 5000, nullable = false)
    public String constructionMethod;
    
    @Column(name = "sequence_of_work", length = 3000)
    public String sequenceOfWork;
    
    @Column(name = "plant_equipment", length = 2000)
    public String plantEquipment;
    
    @Column(name = "materials", length = 2000)
    public String materials;
    
    @Column(name = "manpower_requirements", length = 1500)
    public String manpowerRequirements;
    
    @Column(name = "safety_measures", length = 3000, nullable = false)
    public String safetyMeasures;
    
    @Column(name = "quality_control", length = 2000)
    public String qualityControl;
    
    @Column(name = "environmental_considerations", length = 2000)
    public String environmentalConsiderations;
    
    @Column(name = "risk_assessment", length = 3000)
    public String riskAssessment;
    
    @Column(name = "applicable_standards", length = 1500)
    public String applicableStandards; // SNI, ASTM, BS, etc.
    
    @Column(name = "reference_drawings", length = 1000)
    public String referenceDrawings;
    
    @Column(name = "prepared_by", nullable = false)
    public String preparedBy;
    
    @Column(name = "reviewed_by")
    public String reviewedBy;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "preparation_date", nullable = false)
    public LocalDate preparationDate;
    
    @Column(name = "review_date")
    public LocalDate reviewDate;
    
    @Column(name = "approval_date")
    public LocalDate approvalDate;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public MethodStatementStatus status = MethodStatementStatus.DRAFT;
    
    @Column(name = "revision_number", nullable = false)
    public Integer revisionNumber = 0;
    
    @Column(name = "revision_reason", length = 1000)
    public String revisionReason;
    
    @OneToMany(mappedBy = "methodStatement", cascade = CascadeType.ALL)
    public List<MethodStatementAttachment> attachments;
    
    public enum MethodStatementStatus {
        DRAFT("Draft"),
        SUBMITTED("Diajukan"),
        UNDER_REVIEW("Dalam Review"),
        REVISION_REQUIRED("Perlu Revisi"),
        APPROVED("Disetujui"),
        SUPERSEDED("Digantikan");
        
        private final String indonesianLabel;
        
        MethodStatementStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
}
