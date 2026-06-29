package tech.kayys.project.domain;

import jakarta.persistence.*;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;

@Entity
@Table(name = "tasks")
public class Task extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;

    @Column(nullable = false)
    public String name;

    @Column(length = 1000)
    public String description;

    @Column(name = "start_date")
    public LocalDate startDate;

    @Column(name = "end_date")
    public LocalDate endDate;

    @Column(name = "duration_days")
    public Integer durationDays;

    @Enumerated(EnumType.STRING)
    public TaskStatus status = TaskStatus.PLANNED;

    public enum TaskStatus {
        PLANNED,
        IN_PROGRESS,
        COMPLETED,
        ON_HOLD,
        CANCELLED
    }
}
