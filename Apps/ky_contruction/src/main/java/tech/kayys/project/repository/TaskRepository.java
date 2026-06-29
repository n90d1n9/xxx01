package tech.kayys.project.repository;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.Task;
import tech.kayys.project.domain.Task.TaskStatus;

import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;

@ApplicationScoped
public class TaskRepository implements PanacheRepository<Task> {

    public Uni<List<Task>> findByProject(Project project) {
        return list("project", project);
    }

    public Uni<List<Task>> findByStatus(Task.TaskStatus status) {
        return list("status", status);
    }

    public Uni<Long> countByProject(Long projectId) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'countByProject'");
    }

    public Uni<Long> countByProjectAndStatus(Long projectId, TaskStatus completed) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'countByProjectAndStatus'");
    }
}
