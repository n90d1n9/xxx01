package tech.kayys.construction.domain;


import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import tech.kayys.project.domain.Project;

import java.time.LocalDate;
import java.math.BigDecimal;
import java.util.List;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;


@Entity
@Table(name = "construction_phases")
public class ConstructionPhase extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;
    
    @NotBlank
    @Column(name = "phase_code", nullable = false)
    public String phaseCode; // e.g., "PREP", "FOUND", "STRUCT", "ARCH", "MEP", "FINISH"
    
    @NotBlank
    @Column(name = "phase_name", nullable = false)
    public String phaseName;
    
    @Column(length = 2000)
    public String description;
    
    @Min(1)
    @Column(name = "phase_sequence", nullable = false)
    public Integer phaseSequence; // Sequential order
    
    @Column(name = "planned_start_date")
    public LocalDate plannedStartDate;
    
    @Column(name = "planned_end_date")
    public LocalDate plannedEndDate;
    
    @Column(name = "actual_start_date")
    public LocalDate actualStartDate;
    
    @Column(name = "actual_end_date")
    public LocalDate actualEndDate;
    
    @Min(0) @Max(100)
    @Column(name = "physical_progress_percentage", precision = 5, scale = 2)
    public BigDecimal physicalProgressPercentage = BigDecimal.ZERO;
    
    @Min(0) @Max(100)
    @Column(name = "financial_progress_percentage", precision = 5, scale = 2)
    public BigDecimal financialProgressPercentage = BigDecimal.ZERO;
    
    @DecimalMin("0.00")
    @Column(name = "phase_budget", precision = 15, scale = 2)
    public BigDecimal phaseBudget;
    
    @DecimalMin("0.00")
    @Column(name = "actual_cost", precision = 15, scale = 2)
    public BigDecimal actualCost = BigDecimal.ZERO;
    
    @DecimalMin("0.00")
    @Column(name = "committed_cost", precision = 15, scale = 2)
    public BigDecimal committedCost = BigDecimal.ZERO;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public PhaseStatus status = PhaseStatus.NOT_STARTED;
    
    @Column(name = "critical_path")
    public Boolean criticalPath = false;
    
    @Column(name = "weather_dependent")
    public Boolean weatherDependent = false;
    
    @Column(name = "requires_inspection")
    public Boolean requiresInspection = true;
    
    @Column(name = "milestone_phase")
    public Boolean milestonePhase = false;
    
    // Indonesian specific fields
    @Column(name = "sni_standards", length = 1000)
    public String sniStandards; // Applicable SNI standards
    
    @Column(name = "k3_requirements", length = 2000)
    public String k3Requirements; // Safety requirements
    
    @Column(name = "environmental_impact")
    @Enumerated(EnumType.STRING)
    public EnvironmentalImpact environmentalImpact = EnvironmentalImpact.LOW;
    
    @OneToMany(mappedBy = "phase", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<PhaseActivity> activities;
    
    @OneToMany(mappedBy = "phase", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<PhaseResource> resources;
    
    @OneToMany(mappedBy = "phase", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<PhaseDeliverable> deliverables;
    
    @OneToMany(mappedBy = "phase", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<PhaseProgressReport> progressReports;
    
    public enum PhaseStatus {
        NOT_STARTED("Belum Dimulai", "Phase not yet started"),
        PREPARING("Persiapan", "Preparing phase execution"),
        IN_PROGRESS("Sedang Berjalan", "Phase in progress"),
        ON_HOLD("Ditunda", "Phase on hold"),
        COMPLETED("Selesai", "Phase completed"),
        CANCELLED("Dibatalkan", "Phase cancelled"),
        REWORK_REQUIRED("Perlu Perbaikan", "Rework required");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        PhaseStatus(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum EnvironmentalImpact {
        LOW("Rendah", "Minimal environmental impact"),
        MEDIUM("Sedang", "Moderate environmental considerations"),
        HIGH("Tinggi", "Significant environmental controls required"),
        CRITICAL("Kritis", "Critical environmental monitoring required");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        EnvironmentalImpact(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    // Business methods
    public Double getSchedulePerformanceIndex() {
        if (plannedStartDate == null || plannedEndDate == null || physicalProgressPercentage == null) {
            return null;
        }
        
        LocalDate now = LocalDate.now();
        if (now.isBefore(plannedStartDate)) {
            return 1.0; // Not started yet
        }
        
        long totalDuration = plannedStartDate.until(plannedEndDate).getDays();
        long elapsedDuration = plannedStartDate.until(now).getDays();
        
        if (totalDuration <= 0) return 1.0;
        
        double plannedProgress = Math.min(100.0, (double) elapsedDuration / totalDuration * 100);
        double actualProgress = physicalProgressPercentage.doubleValue();
        
        return plannedProgress > 0 ? actualProgress / plannedProgress : 1.0;
    }
    
    public Double getCostPerformanceIndex() {
        if (phaseBudget == null || phaseBudget.equals(BigDecimal.ZERO) || 
            physicalProgressPercentage == null || actualCost == null) {
            return null;
        }
        
        BigDecimal earnedValue = phaseBudget.multiply(physicalProgressPercentage.divide(new BigDecimal("100")));
        return earnedValue.divide(actualCost, 4, java.math.RoundingMode.HALF_UP).doubleValue();
    }
    
    public Boolean isDelayed() {
        if (plannedEndDate == null || status == PhaseStatus.COMPLETED) {
            return false;
        }
        return LocalDate.now().isAfter(plannedEndDate) && status != PhaseStatus.COMPLETED;
    }
    
    public Long getDaysDelayed() {
        if (!isDelayed()) return 0L;
        return (long) plannedEndDate.until(LocalDate.now()).getDays();
    }
}