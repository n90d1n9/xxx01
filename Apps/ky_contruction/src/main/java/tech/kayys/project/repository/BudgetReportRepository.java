package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ProjectBudgetReport;

@ApplicationScoped
public class BudgetReportRepository implements PanacheRepository<ProjectBudgetReport> {
    public Uni<ProjectBudgetReport> upsertByProject(ProjectBudgetReport report) {
        return find("project.id", report.project.id).firstResult()
                .flatMap(existing -> {
                    if (existing != null) {
                        existing.plannedBudget = report.plannedBudget;
                        existing.actualSpent = report.actualSpent;
                        existing.remainingBudget = report.remainingBudget;
                        existing.lastUpdated = report.lastUpdated;
                        return persist(existing);
                    } else {
                        return persist(report);
                    }
                });
    }

/**
     * Find budget report by project id reactively.
     */
    public Uni<ProjectBudgetReport> findByProjectId(Long projectId) {
        return find("project.id", projectId).firstResult();
    }
}
