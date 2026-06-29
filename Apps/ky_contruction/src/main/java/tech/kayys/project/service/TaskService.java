package tech.kayys.project.service;

import java.time.LocalDateTime;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.domain.Task;
import tech.kayys.project.repository.TaskRepository;
import tech.kayys.risk.dto.TransactionDTO;

@ApplicationScoped
public class TaskService {

    @Inject
    TaskRepository taskRepo;
    @Inject
    TransactionService transactionService;

    public Task create(Task task, String createdBy) {
        taskRepo.persist(task);

        transactionService.logTransaction(new TransactionDTO(
                null,
                task.project.id,
                ProjectTransaction.TransactionType.CREATE,
                ProjectTransaction.DomainType.TASK,
                null, null,
                "Task created: " + task.name,
                createdBy,
                LocalDateTime.now()));

        return task;
    }

    public void update(Task task, String updatedBy) {
        taskRepo.persist(task);

        transactionService.logTransaction(new TransactionDTO(
                null,
                task.project.id,
                ProjectTransaction.TransactionType.UPDATE,
                ProjectTransaction.DomainType.TASK,
                null, null,
                "Task updated: " + task.name,
                updatedBy,
                LocalDateTime.now()));
    }

    public Uni<Void> delete(Long taskId, String deletedBy) {
        return taskRepo.findById(taskId)
                .onItem().ifNotNull().transformToUni(task -> taskRepo.delete(task)
                        .replaceWith(
                                transactionService.logTransaction(new TransactionDTO(
                                        null,
                                        task.project.id,
                                        ProjectTransaction.TransactionType.DELETE,
                                        ProjectTransaction.DomainType.TASK,
                                        null, null,
                                        "Task deleted: " + task.name,
                                        deletedBy,
                                        LocalDateTime.now()))))
                .onItem().ifNull().failWith(new IllegalArgumentException("Task not found: " + taskId))
                .replaceWithVoid();
    }
}
