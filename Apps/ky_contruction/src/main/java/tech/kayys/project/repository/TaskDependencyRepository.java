package tech.kayys.project.repository;


import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.TaskDependency;

import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;

@ApplicationScoped
public class TaskDependencyRepository implements PanacheRepository<TaskDependency> {

public Uni<List<TaskDependency>> findBySuccessor(long successorId) {
return list("successor.id", successorId);
}

public Uni<List<TaskDependency>> findByPredecessor(long predecessorId) {
return list("predecessor.id", predecessorId);
}

public Uni<List<TaskDependency>> findByProject(long projectId) {
return list("project.id", projectId);
}
}