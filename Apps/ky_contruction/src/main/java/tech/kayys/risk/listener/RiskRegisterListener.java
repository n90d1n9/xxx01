package tech.kayys.risk.listener;


import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.spi.CDI;
import jakarta.persistence.PostPersist;
import jakarta.persistence.PostRemove;
import jakarta.persistence.PostUpdate;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.service.TransactionService;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.dto.TransactionDTO;

import java.time.LocalDateTime;


@ApplicationScoped
public class RiskRegisterListener {

    private TransactionService transactionService() {
        // Lazy CDI lookup because JPA entity listeners are not CDI-injected directly
        return CDI.current().select(TransactionService.class).get();
    }

    @PostPersist
    public void afterCreate(RiskRegister risk) {
        logTransaction(risk, ProjectTransaction.TransactionType.CREATE,
            "Risk registered: " + risk.riskTitle, risk.createdBy);
    }

    @PostUpdate
    public void afterUpdate(RiskRegister risk) {
        logTransaction(risk, ProjectTransaction.TransactionType.UPDATE,
            "Risk updated: " + risk.riskTitle, risk.updatedBy);
    }

    @PostRemove
    public void afterDelete(RiskRegister risk) {
        logTransaction(risk, ProjectTransaction.TransactionType.DELETE,
            "Risk removed: " + risk.riskTitle, risk.updatedBy != null ? risk.updatedBy : risk.createdBy);
    }

    private void logTransaction(RiskRegister risk,
                                ProjectTransaction.TransactionType type,
                                String description,
                                String actor) {
        if (risk.project != null && risk.project.id != null) {
            transactionService().logTransaction(new TransactionDTO(
                null,
                risk.project.id,
                type,
                ProjectTransaction.DomainType.RISK,
                null,
                null,
                description,
                actor != null ? actor : "system",
                LocalDateTime.now()
            ));
        }
    }
}

