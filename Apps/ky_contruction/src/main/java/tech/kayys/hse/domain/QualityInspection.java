package tech.kayys.hse.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;
import tech.kayys.report.domain.NonConformanceReport;

@Entity
@Table(name = "quality_inspections")
public class QualityInspection extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @ManyToOne
    @JoinColumn(name = "work_package_id")
    public WorkPackage workPackage;
    
    @Column(name = "inspection_number", unique = true)
    public String inspectionNumber;
    
    @Column(name = "inspection_date")
    public LocalDate inspectionDate;
    
    @Column(name = "inspection_type")
    @Enumerated(EnumType.STRING)
    public InspectionType inspectionType;
    
    @Column(name = "checklist_reference")
    public String checklistReference;
    
    @Column(name = "inspector")
    public String inspector;
    
    @Column(name = "contractor_representative")
    public String contractorRepresentative;
    
    @Column(name = "inspection_result")
    @Enumerated(EnumType.STRING)
    public InspectionResult result;
    
    @Column(name = "defects_found")
    public Integer defectsFound = 0;
    
    @Column(name = "observations", length = 2000)
    public String observations;
    
    @Column(name = "recommendations", length = 2000)
    public String recommendations;
    
    @OneToMany(mappedBy = "inspection", cascade = CascadeType.ALL)
    public List<NonConformanceReport> nonConformanceReports;
    
    public enum InspectionType {
        MATERIAL_INSPECTION("Material Inspection"),
        WORKMANSHIP_INSPECTION("Workmanship Inspection"),
        DIMENSIONAL_CHECK("Dimensional Check"),
        CONCRETE_TEST("Concrete Test"),
        STEEL_INSPECTION("Steel Inspection"),
        MEP_TESTING("MEP Testing"),
        FINAL_INSPECTION("Final Inspection");
        
        private final String label;
        InspectionType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum InspectionResult {
        PASSED("Passed"),
        PASSED_WITH_COMMENTS("Passed with Comments"),
        FAILED("Failed"),
        PENDING_RETEST("Pending Retest");
        
        private final String label;
        InspectionResult(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
