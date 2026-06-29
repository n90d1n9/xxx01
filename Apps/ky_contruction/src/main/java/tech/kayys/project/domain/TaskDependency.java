package tech.kayys.project.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;

import jakarta.persistence.*;

@Entity
@Table(name = "task_dependencies", indexes = {
        @Index(name = "idx_task_dep_project", columnList = "project_id"),
        @Index(name = "idx_task_dep_pred", columnList = "predecessor_task_id"),
        @Index(name = "idx_task_dep_succ", columnList = "successor_task_id")
})
public class TaskDependency extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id")
    public Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "predecessor_task_id", nullable = false)
    public Task predecessor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "successor_task_id", nullable = false)
    public Task successor;

    @Enumerated(EnumType.STRING)
    @Column(name = "dependency_type")
    public DependencyType type = DependencyType.FS;

    /**
     * Lag in days (positive = successor waits after predecessor constraint
     * satisfied).
     * You can change unit to hours if desired.
     */
    @Column(name = "lag")
    public long lag = 0L;

    public enum DependencyType {
        FS, SS, FF, SF
    }
}