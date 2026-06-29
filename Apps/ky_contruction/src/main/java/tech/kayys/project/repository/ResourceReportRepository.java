package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ProjectResourceReport;

@ApplicationScoped
public class ResourceReportRepository implements PanacheRepository<ProjectResourceReport> {
    public Uni<ProjectResourceReport> upsertByProject(ProjectResourceReport report) {
        return find("project.id", report.project.id).firstResult()
            .flatMap(existing -> {
                if (existing != null) {
                    existing.allocatedQuantity = report.allocatedQuantity;
                    existing.inUse = report.inUse;
                    existing.lastUpdated = report.lastUpdated;
                    return persist(existing);
                } else {
                    return persist(report);
                }
            });
    }
}
