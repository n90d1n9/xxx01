package tech.kayys.risk.service;

import java.time.LocalDateTime;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.repository.ProjectRepository;
import tech.kayys.project.service.TransactionService;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.domain.RiskTemplate;
import tech.kayys.risk.dto.TransactionDTO;
import tech.kayys.risk.repository.RiskRegisterRepository;
import tech.kayys.risk.repository.RiskTemplateRepository;
import io.smallrye.mutiny.Uni;


@ApplicationScoped
public class RiskService {

       @Inject RiskRegisterRepository riskRepo;
    @Inject RiskTemplateRepository templateRepo;
    @Inject ProjectRepository projectRepo;
    @Inject TransactionService transactionService;

        /**
     * Register a new risk directly.
     */
    public Uni<RiskRegister> register(RiskRegister risk, String createdBy) {
        return riskRepo.persist(risk)
            .replaceWith(risk)
            .call(() -> transactionService.logTransaction(new TransactionDTO(
                null,
                risk.project.id,
                ProjectTransaction.TransactionType.CREATE,
                ProjectTransaction.DomainType.RISK,
                null, null,
                "Risk registered: " + risk.riskTitle,
                createdBy,
                LocalDateTime.now()
            )));
    }

  /**
     * Update an existing risk.
     */
    public Uni<RiskRegister> update(RiskRegister risk, String updatedBy) {
        return riskRepo.persist(risk)
            .replaceWith(risk)
            .call(() -> transactionService.logTransaction(new TransactionDTO(
                null,
                risk.project.id,
                ProjectTransaction.TransactionType.UPDATE,
                ProjectTransaction.DomainType.RISK,
                null, null,
                "Risk updated: " + risk.riskTitle,
                updatedBy,
                LocalDateTime.now()
            )));
    }

/**
     * Close (delete) a risk.
     */
    public Uni<Void> close(Long riskId, String closedBy) {
        return riskRepo.findById(riskId)
            .onItem().ifNotNull().transformToUni(risk ->
                riskRepo.delete(risk)
                    .call(() -> transactionService.logTransaction(new TransactionDTO(
                        null,
                        risk.project.id,
                        ProjectTransaction.TransactionType.DELETE,
                        ProjectTransaction.DomainType.RISK,
                        null, null,
                        "Risk closed: " + risk.riskTitle,
                        closedBy,
                        LocalDateTime.now()
                    )))
            )
            .onItem().ifNull().failWith(new IllegalArgumentException("Risk not found: " + riskId))
            .replaceWithVoid();
    }

    /**
     * Create a RiskRegister entry from a RiskTemplate.
     */
    public Uni<RiskRegister> createFromTemplate(Long templateId, Long projectId, String createdBy) {
        return Uni.combine().all().unis(
                templateRepo.findById(templateId),
                projectRepo.findById(projectId)
            ).asTuple()
            .onItem().transform(tuple -> {
                RiskTemplate template = tuple.getItem1();
                Project project = tuple.getItem2();

                if (template == null) throw new IllegalArgumentException("Template not found: " + templateId);
                if (project == null) throw new IllegalArgumentException("Project not found: " + projectId);

                RiskRegister risk = new RiskRegister();
                risk.project = project;
                risk.riskId = template.code + "-" + project.id;
                risk.riskTitle = template.title;
                risk.description = template.description;
                risk.category = template.category;
                risk.type = template.type;
                risk.probability = template.defaultProbability;
                risk.impact = template.defaultImpact;
                risk.mitigationStrategy = template.mitigationSuggestion;
                risk.contingencyPlan = template.contingencySuggestion;
                risk.createdBy = createdBy;
                risk.identifiedDate = java.time.LocalDate.now();
                return risk;
            })
            .call(risk -> riskRepo.persist(risk))
            .call(risk -> transactionService.logTransaction(new TransactionDTO(
                null,
                risk.project.id,
                ProjectTransaction.TransactionType.CREATE,
                ProjectTransaction.DomainType.RISK,
                null, null,
                "Risk instantiated from template: " + risk.riskTitle,
                createdBy,
                LocalDateTime.now()
            )));
    }
}
