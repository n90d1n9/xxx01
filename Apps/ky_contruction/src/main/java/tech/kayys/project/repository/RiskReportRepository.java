package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.risk.domain.ProjectRiskReport;

@ApplicationScoped
public class RiskReportRepository implements PanacheRepository<ProjectRiskReport> {

    public Uni<ProjectRiskReport> upsertByProject(ProjectRiskReport report) {
        return find("project.id", report.project.id).firstResult()
            .flatMap(existing -> {
                if (existing != null) {
                    // update fields in existing
                    existing.openRisks = report.openRisks;
                    existing.highRisks = report.highRisks;
                    existing.lastUpdated = report.lastUpdated;
                    return persist(existing);
                } else {
                    return persist(report);
                }
            });
    }
}

