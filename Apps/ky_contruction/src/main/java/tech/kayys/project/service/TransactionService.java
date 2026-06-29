package tech.kayys.project.service;

import java.util.List;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.repository.TransactionRepository;
import tech.kayys.risk.dto.TransactionDTO;

@ApplicationScoped
public class TransactionService {

    @Inject TransactionRepository txRepo;

public Uni<ProjectTransaction> logTransaction(TransactionDTO dto) {
        ProjectTransaction tx = new ProjectTransaction();
        tx.project = new Project();
        tx.project.id = dto.projectId();
        tx.transactionDate = dto.transactionDate();
        tx.transactionType = dto.type();
        tx.domainType = dto.domain();
        tx.amount = dto.amount();
        tx.quantity = dto.quantity();
        tx.description = dto.description();
        tx.createdBy = dto.createdBy();

        return txRepo.persist(tx).replaceWith(tx);
    }

    public Uni<List<ProjectTransaction>> findByProject(Long projectId) {
        return txRepo.list("project.id", projectId);
    }
}
