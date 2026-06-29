package tech.kayys.project.domain;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "report_project_budget")
public class ProjectBudgetReport extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;

    @Column(name = "planned_budget")
    public BigDecimal plannedBudget;

    @Column(name = "actual_spent")
    public BigDecimal actualSpent;

    @Column(name = "remaining_budget")
    public BigDecimal remainingBudget;

    @Column(name = "last_updated")
    public LocalDateTime lastUpdated;
}
