package tech.kayys.project.repository;

import java.time.LocalDate;
import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.Project;

@ApplicationScoped
public class ProjectRepository implements PanacheRepository<Project> {

    /** Count results for pagination */
    public Uni<Long> countSearch(String keyword,
            Project.ProjectStatus status,
            LocalDate startDate,
            LocalDate endDate) {
        StringBuilder query = new StringBuilder("1=1");
        if (keyword != null && !keyword.isBlank()) {
            query.append(" AND (LOWER(name) LIKE ?1 OR LOWER(description) LIKE ?1)");
        }
        if (status != null) {
            query.append(" AND status = ?2");
        }
        if (startDate != null) {
            query.append(" AND startDate >= ?3");
        }
        if (endDate != null) {
            query.append(" AND endDate <= ?4");
        }

        return count(query.toString(),
                keyword != null ? "%" + keyword.toLowerCase() + "%" : null,
                status,
                startDate,
                endDate);
    }
}