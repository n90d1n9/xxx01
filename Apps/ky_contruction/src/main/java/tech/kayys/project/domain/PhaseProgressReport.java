package tech.kayys.project.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import tech.kayys.construction.domain.ConstructionPhase;

import jakarta.persistence.*;

@Entity
@Table(name = "phase_progress_reports")
public class PhaseProgressReport extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id", nullable = false)
    public ConstructionPhase phase;

    @Column(name = "report_date", nullable = false)
    public LocalDate reportDate;

    @Column(name = "reporting_period_start")
    public LocalDate reportingPeriodStart;

    @Column(name = "reporting_period_end")
    public LocalDate reportingPeriodEnd;

    @Min(0) @Max(100)
    @Column(name = "physical_progress", precision = 5, scale = 2)
    public BigDecimal physicalProgress;

    @Min(0) @Max(100)
    @Column(name = "financial_progress", precision = 5, scale = 2)
    public BigDecimal financialProgress;

    @Column(name = "work_accomplished", length = 3000)
    public String workAccomplished;

    @Column(name = "work_planned_next_period", length = 3000)
    public String workPlannedNextPeriod;

    @Column(name = "issues_encountered", length = 3000)
    public String issuesEncountered;

    @Column(name = "corrective_actions", length = 3000)
    public String correctiveActions;

    @Column(name = "resource_status", length = 2000)
    public String resourceStatus;

    @Column(name = "safety_performance", length = 1000)
    public String safetyPerformance;

    @Column(name = "quality_performance", length = 1000)
    public String qualityPerformance;

    @Column(name = "weather_impact", length = 1000)
    public String weatherImpact;

    @Column(name = "workforce_count")
    public Integer workforceCount;

    @Column(name = "equipment_on_site")
    public Integer equipmentOnSite;

    @DecimalMin("0")
    @Column(name = "period_cost", precision = 15, scale = 2)
    public BigDecimal periodCost;

    @DecimalMin("0")
    @Column(name = "cumulative_cost", precision = 15, scale = 2)
    public BigDecimal cumulativeCost;

    @Column(name = "schedule_variance_days")
    public Integer scheduleVarianceDays;

    @DecimalMin("0")
    @Column(name = "cost_variance", precision = 15, scale = 2)
    public BigDecimal costVariance;

    @Column(name = "productivity_notes", length = 2000)
    public String productivityNotes;

    @Column(name = "material_deliveries", length = 1500)
    public String materialDeliveries;

    @Column(name = "prepared_by")
    public String preparedBy;

    @Column(name = "reviewed_by")
    public String reviewedBy;

    @Column(name = "approved_by")
    public String approvedBy;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public ReportStatus status = ReportStatus.DRAFT;

    @Column(name = "next_review_date")
    public LocalDate nextReviewDate;

    public enum ReportStatus {
        DRAFT("Draft"),
        SUBMITTED("Diajukan"),
        UNDER_REVIEW("Dalam Review"),
        APPROVED("Disetujui"),
        PUBLISHED("Diterbitkan"),
        ARCHIVED("Diarsipkan");

        private final String indonesianLabel;

        ReportStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }

        public String getIndonesianLabel() {
            return indonesianLabel;
        }
    }

    @PrePersist
    public void prePersist() {
        if (reportDate == null) {
            reportDate = LocalDate.now();
        }
    }

    public Double getSchedulePerformanceIndex() {
        if (scheduleVarianceDays == null || scheduleVarianceDays == 0) {
            return 1.0;
        }

        if (phase == null || phase.plannedStartDate == null || phase.plannedEndDate == null) {
            return null;
        }

        long totalDuration = java.time.temporal.ChronoUnit.DAYS.between(phase.plannedStartDate, phase.plannedEndDate);
        if (totalDuration <= 0) return 1.0;

        return Math.max(0.0, 1.0 - (double) Math.abs(scheduleVarianceDays) / totalDuration);
    }
}
