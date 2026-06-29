package tech.kayys.risk.service;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.service.TransactionService;
import tech.kayys.risk.domain.RiskDocument;
import tech.kayys.risk.dto.TransactionDTO;
import tech.kayys.risk.repository.RiskDocumentRepository;

import java.time.LocalDateTime;

@ApplicationScoped
public class RiskDocumentService {

    @Inject
    RiskDocumentRepository documentRepo;

    @Inject
    TransactionService transactionService;

    public Uni<RiskDocument> upload(RiskDocument doc, String uploadedBy) {
        return documentRepo.persist(doc)
            .invoke(saved -> transactionService.logTransaction(new TransactionDTO(
                null,
                saved.risk.project.id,
                ProjectTransaction.TransactionType.CREATE,
                ProjectTransaction.DomainType.RISK,
                null,
                null,
                "Risk document uploaded: " + saved.fileName,
                uploadedBy,
                LocalDateTime.now()
            )));
    }

    public Uni<Void> archive(Long documentId, String archivedBy) {
        return documentRepo.findById(documentId)
            .onItem().ifNotNull().invoke(doc -> {
                doc.status = RiskDocument.DocumentStatus.ARCHIVED;
                transactionService.logTransaction(new TransactionDTO(
                    null,
                    doc.risk.project.id,
                    ProjectTransaction.TransactionType.UPDATE,
                    ProjectTransaction.DomainType.RISK,
                    null,
                    null,
                    "Risk document archived: " + doc.fileName,
                    archivedBy,
                    LocalDateTime.now()
                ));
            })
            .replaceWithVoid();
    }

    public Uni<Void> delete(Long documentId, String deletedBy) {
        return documentRepo.findById(documentId)
            .onItem().ifNotNull().transformToUni(doc -> documentRepo.delete(doc)
                .invoke(() -> transactionService.logTransaction(new TransactionDTO(
                    null,
                    doc.risk.project.id,
                    ProjectTransaction.TransactionType.DELETE,
                    ProjectTransaction.DomainType.RISK,
                    null,
                    null,
                    "Risk document deleted: " + doc.fileName,
                    deletedBy,
                    LocalDateTime.now()
                )))
            )
            .replaceWithVoid();
    }
}
