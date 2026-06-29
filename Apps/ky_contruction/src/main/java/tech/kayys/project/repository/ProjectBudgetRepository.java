package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheQuery;
import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ProjectBudget;

import java.math.BigDecimal;
import java.util.List;

import io.quarkus.panache.common.Sort;

@ApplicationScoped
public class ProjectBudgetRepository implements PanacheRepository<ProjectBudget> {

    public Uni<List<ProjectBudget>> findByProject(Long projectId) {
        return find("project.id", projectId).list();
    }

    public Uni<List<ProjectBudget>> findActiveBudgets(Long projectId) {
        return find("project.id = ?1 and (expiryDate is null or expiryDate >= CURRENT_DATE)", projectId).list();
    }

    public Uni<ProjectBudget> findByCategory(Long projectId, String category) {
        return find("project.id = ?1 and category = ?2", projectId, category).firstResult();
    }

    public Uni<BigDecimal> calculateTotalBudget(Long projectId) {
        return find("select sum(amount) from ProjectBudget where project.id = ?1", projectId)
                .project(BigDecimal.class)
                .firstResult();
    }

    // ---------- Advanced Pagination with Sorting & Filtering ----------

    public Uni<List<ProjectBudget>> findPagedByProject(
            Long projectId,
            int pageIndex,
            int pageSize,
            String sortBy,
            boolean asc,
            String categoryFilter,
            String keywordFilter
    ) {
        StringBuilder query = new StringBuilder("project.id = ?1");
        if (categoryFilter != null && !categoryFilter.isBlank()) {
            query.append(" and category = ?2");
        }
        if (keywordFilter != null && !keywordFilter.isBlank()) {
            query.append(" and lower(description) like ?3");
        }

        Sort sort = asc ? Sort.ascending(sortBy) : Sort.descending(sortBy);

        PanacheQuery<ProjectBudget> panacheQuery;
        if (categoryFilter != null && keywordFilter != null) {
            panacheQuery = find(query.toString(), sort, projectId, categoryFilter, "%" + keywordFilter.toLowerCase() + "%");
        } else if (categoryFilter != null) {
            panacheQuery = find(query.toString(), sort, projectId, categoryFilter);
        } else if (keywordFilter != null) {
            panacheQuery = find(query.toString(), sort, projectId, "%" + keywordFilter.toLowerCase() + "%");
        } else {
            panacheQuery = find(query.toString(), sort, projectId);
        }

        panacheQuery.page(Page.of(pageIndex, pageSize));
        return panacheQuery.list();
    }

    public Uni<Long> countByProject(
            Long projectId,
            String categoryFilter,
            String keywordFilter
    ) {
        StringBuilder query = new StringBuilder("project.id = ?1");
        if (categoryFilter != null && !categoryFilter.isBlank()) {
            query.append(" and category = ?2");
        }
        if (keywordFilter != null && !keywordFilter.isBlank()) {
            query.append(" and lower(description) like ?3");
        }

        if (categoryFilter != null && keywordFilter != null) {
            return count(query.toString(), projectId, categoryFilter, "%" + keywordFilter.toLowerCase() + "%");
        } else if (categoryFilter != null) {
            return count(query.toString(), projectId, categoryFilter);
        } else if (keywordFilter != null) {
            return count(query.toString(), projectId, "%" + keywordFilter.toLowerCase() + "%");
        } else {
            return count(query.toString(), projectId);
        }
    }
}
