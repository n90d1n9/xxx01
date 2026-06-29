package tech.kayys.project.repository;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ActivityDependency;
import tech.kayys.project.domain.ScheduleActivity;

import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;

@ApplicationScoped
public class ActivityDependencyRepository implements PanacheRepository<ActivityDependency> {
    public Uni<List<ActivityDependency>> findByPredecessor(ScheduleActivity predecessor) {
        return list("predecessor", predecessor);
    }

    public Uni<List<ActivityDependency>> findByProject(Long projectId) {
        return find("predecessor.schedule.project.id = ?1", projectId).list();
    }
}
