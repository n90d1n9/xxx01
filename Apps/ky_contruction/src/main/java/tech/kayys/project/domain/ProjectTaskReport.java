package tech.kayys.project.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "report_project_tasks")
public class ProjectTaskReport extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;

    @Column(name = "total_tasks")
    public Integer totalTasks;

    @Column(name = "completed_tasks")
    public Integer completedTasks;

    @Column(name = "in_progress_tasks")
    public Integer inProgressTasks;

    @Column(name = "not_started_tasks")
    public Integer notStartedTasks;

    @Column(name = "completion_rate")
    public Double completionRate;

    @Column(name = "last_updated")
    public LocalDateTime lastUpdated;
}

