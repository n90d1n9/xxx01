package tech.kayys.project.service;

import java.time.LocalDateTime;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.ProjectBudget;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.repository.ProjectBudgetRepository;
import tech.kayys.risk.dto.TransactionDTO;

@ApplicationScoped
public class ProjectBudgetService {

    @Inject ProjectBudgetRepository budgetRepo;

    @Inject TransactionService transactionService;

    public Uni<ProjectBudget> add(ProjectBudget budget, String createdBy) {
        return budgetRepo.persist(budget)
            .replaceWith(budget)
            .call(() -> transactionService.logTransaction(
                new TransactionDTO(
                    null,
                    budget.project.id,
                    ProjectTransaction.TransactionType.CREATE,
                    ProjectTransaction.DomainType.BUDGET,
                    budget.amount,
                    1, // default quantity
                    "Budget added",
                    createdBy,
                    LocalDateTime.now()
                )
            ));
    }

    public Uni<ProjectBudget> update(ProjectBudget budget, String updatedBy) {
        return budgetRepo.persist(budget)
            .replaceWith(budget)
            .call(() -> transactionService.logTransaction(
                new TransactionDTO(
                    null,
                    budget.project.id,
                    ProjectTransaction.TransactionType.UPDATE,
                    ProjectTransaction.DomainType.BUDGET,
                    budget.amount,
                    1,
                    "Budget updated",
                    updatedBy,
                    LocalDateTime.now()
                )
            ));
    }

    public Uni<Void> delete(Long budgetId, String deletedBy) {
        return budgetRepo.findById(budgetId)
            .onItem().ifNotNull().transformToUni(budget ->
                budgetRepo.delete(budget)
                    .call(() -> transactionService.logTransaction(
                        new TransactionDTO(
                            null,
                            budget.project.id,
                            ProjectTransaction.TransactionType.DELETE,
                            ProjectTransaction.DomainType.BUDGET,
                            budget.amount,
                            1,
                            "Budget deleted",
                            deletedBy,
                            LocalDateTime.now()
                        )
                    ))
            )
            .replaceWithVoid();
    }
}

