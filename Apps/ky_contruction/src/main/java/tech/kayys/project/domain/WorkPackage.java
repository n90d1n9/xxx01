package tech.kayys.project.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "work_packages")
public class WorkPackage extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;

    @Column(name = "code", unique = true, nullable = false)
    @NotBlank
    public String code;

    @Column(name = "name", nullable = false)
    @NotBlank
    public String name;

    @Column(name = "description", length = 3000)
    public String description;

    @Column(name = "start_date")
    public LocalDate startDate;

    @Column(name = "end_date")
    public LocalDate endDate;

    @Column(name = "planned_duration")
    public Integer plannedDuration;

    @Column(name = "actual_duration")
    public Integer actualDuration;

    @Column(name = "planned_cost", precision = 15, scale = 2)
    public BigDecimal plannedCost;

    @Column(name = "actual_cost", precision = 15, scale = 2)
    public BigDecimal actualCost;

    @Column(name = "percent_complete", precision = 5, scale = 2)
    public BigDecimal percentComplete = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public WorkPackageStatus status = WorkPackageStatus.PLANNED;

    @OneToMany(mappedBy = "workPackage", cascade = CascadeType.ALL, orphanRemoval = true)
    public List<ScheduleActivity> activities;

    @OneToMany(mappedBy = "workPackage", cascade = CascadeType.ALL, orphanRemoval = true)
    public List<WorkPackageDocument> documents;

    public enum WorkPackageStatus {
        PLANNED,
        IN_PROGRESS,
        COMPLETED,
        ON_HOLD,
        CANCELLED
    }
}
