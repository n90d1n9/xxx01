package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ProjectTaskReport;

@ApplicationScoped
public class TaskReportRepository implements PanacheRepository<ProjectTaskReport> {
    public Uni<ProjectTaskReport> upsertByProject(ProjectTaskReport report) {
        return find("project.id", report.project.id).firstResult()
            .flatMap(existing -> {
                if (existing != null) {
                    existing.totalTasks = report.totalTasks;
                    existing.completedTasks = report.completedTasks;
                    existing.inProgressTasks = report.inProgressTasks;
                    existing.notStartedTasks = report.notStartedTasks;
                    existing.completionRate = report.completionRate;
                    existing.lastUpdated = report.lastUpdated;
                    return persist(existing);
                } else {
                    return persist(report);
                }
            });
    }
}