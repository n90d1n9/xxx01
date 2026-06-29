package tech.kayys.construction.domain;

import java.math.BigDecimal;
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
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import tech.kayys.project.domain.ActivityDependency;

@Entity
@Table(name = "phase_activities")
public class PhaseActivity extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id", nullable = false)
    public ConstructionPhase phase;
    
    @NotBlank
    @Column(name = "activity_code", nullable = false)
    public String activityCode;
    
    @NotBlank
    @Column(name = "activity_name", nullable = false)
    public String activityName;
    
    @Column(length = 2000)
    public String description;
    
    @Min(1)
    @Column(name = "sequence_order")
    public Integer sequenceOrder;
    
    @Column(name = "planned_start_date")
    public LocalDate plannedStartDate;
    
    @Column(name = "planned_end_date")
    public LocalDate plannedEndDate;
    
    @Column(name = "actual_start_date")
    public LocalDate actualStartDate;
    
    @Column(name = "actual_end_date")
    public LocalDate actualEndDate;
    
    @Min(0)
    @Column(name = "estimated_duration_days")
    public Integer estimatedDurationDays;
    
    @Min(0)
    @Column(name = "actual_duration_days")
    public Integer actualDurationDays;
    
    @Min(0) @Max(100)
    @Column(name = "progress_percentage", precision = 5, scale = 2)
    public BigDecimal progressPercentage = BigDecimal.ZERO;
    
    @DecimalMin("0.00")
    @Column(name = "activity_budget", precision = 15, scale = 2)
    public BigDecimal activityBudget;
    
    @DecimalMin("0.00")
    @Column(name = "actual_cost", precision = 15, scale = 2)
    public BigDecimal actualCost = BigDecimal.ZERO;
    
    @Enumerated(EnumType.STRING)
    public ActivityType activityType;
    
    @Enumerated(EnumType.STRING)
    public ActivityStatus status = ActivityStatus.PLANNED;
    
    @Column(name = "responsible_person")
    public String responsiblePerson;
    
    @Column(name = "crew_size_required")
    public Integer crewSizeRequired;
    
    @Column(name = "skill_level_required")
    @Enumerated(EnumType.STRING)
    public SkillLevel skillLevelRequired;
    
    // Technical specifications
    @Column(name = "work_method", length = 2000)
    public String workMethod;
    
    @Column(name = "quality_standards", length = 1000)
    public String qualityStandards;
    
    @Column(name = "safety_requirements", length = 2000)
    public String safetyRequirements;
    
    @Column(name = "tools_equipment_required", length = 1000)
    public String toolsEquipmentRequired;
    
    @Column(name = "weather_constraints", length = 500)
    public String weatherConstraints;
    
    @OneToMany(mappedBy = "activity", cascade = CascadeType.ALL)
    public List<ActivityMaterial> materialsRequired;
    
    @OneToMany(mappedBy = "activity", cascade = CascadeType.ALL)
    public List<ActivityEquipment> equipmentRequired;
    
    @OneToMany(mappedBy = "successor", cascade = CascadeType.ALL)
    public List<ActivityDependency> predecessors;
    
    @OneToMany(mappedBy = "predecessor", cascade = CascadeType.ALL)
    public List<ActivityDependency> successors;
    
    public enum ActivityType {
        PREPARATION("Persiapan", "Preparation activities"),
        EXCAVATION("Galian", "Excavation and earthwork"),
        CONCRETE_WORK("Pekerjaan Beton", "Concrete activities"),
        STEEL_WORK("Pekerjaan Baja", "Steel structure work"),
        MASONRY("Pekerjaan Pasangan", "Masonry work"),
        FINISHING("Finishing", "Finishing activities"),
        MEP_INSTALLATION("Instalasi MEP", "MEP installation"),
        TESTING("Testing", "Testing and commissioning"),
        INSPECTION("Inspeksi", "Quality inspection"),
        CLEANUP("Pembersihan", "Cleanup activities");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        ActivityType(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum ActivityStatus {
        PLANNED("Direncanakan"),
        READY("Siap Mulai"),
        IN_PROGRESS("Sedang Berjalan"),
        SUSPENDED("Ditunda"),
        COMPLETED("Selesai"),
        CANCELLED("Dibatalkan"),
        FAILED_INSPECTION("Gagal Inspeksi");
        
        private final String indonesianLabel;
        
        ActivityStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum SkillLevel {
        UNSKILLED("Tidak Terampil"),
        SEMI_SKILLED("Semi Terampil"),
        SKILLED("Terampil"),
        HIGHLY_SKILLED("Sangat Terampil"),
        SPECIALIST("Spesialis");
        
        private final String indonesianLabel;
        
        SkillLevel(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
}