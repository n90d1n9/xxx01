package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ProjectResource;

import java.util.List;

@ApplicationScoped
public class ResourceRepository implements PanacheRepository<ProjectResource> {

    public Uni<List<ProjectResource>> findByProject(Long projectId) {
        return find("project.id", projectId).list();
    }

    public Uni<ProjectResource> findByIdReactive(Long id) {
        return findById(id); // PanacheRepository's reactive findById returns Uni<ProjectResource>
    }

    public Uni<Long> countByProject(Long projectId) {
        return count("project.id", projectId);
    }
}
