package tech.kayys.construction.service;


import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.finance.domain.DailyLogActivity;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.repository.DailyLogActivityRepository;
import tech.kayys.project.service.TransactionService;
import tech.kayys.risk.dto.TransactionDTO;

import java.time.LocalDateTime;


@ApplicationScoped
public class DailyLogActivityService {

    @Inject
    DailyLogActivityRepository activityRepo;

    @Inject
    TransactionService transactionService;

    public Uni<DailyLogActivity> addActivity(DailyLogActivity activity, String createdBy) {
        return activityRepo.persist(activity)
            .call(() -> transactionService.logTransaction(new TransactionDTO(
                null,
                activity.dailyLog.project.id,
                ProjectTransaction.TransactionType.CREATE,
                ProjectTransaction.DomainType.DAILY_LOG,
                null, null,
                "Activity added: " + activity.activityName,
                createdBy,
                LocalDateTime.now()
            )))
            .replaceWith(activity);
    }

    public Uni<DailyLogActivity> updateActivity(DailyLogActivity activity, String updatedBy) {
        return activityRepo.persist(activity)
            .call(() -> transactionService.logTransaction(new TransactionDTO(
                null,
                activity.dailyLog.project.id,
                ProjectTransaction.TransactionType.UPDATE,
                ProjectTransaction.DomainType.DAILY_LOG,
                null, null,
                "Activity updated: " + activity.activityName,
                updatedBy,
                LocalDateTime.now()
            )))
            .replaceWith(activity);
    }

    public Uni<Void> deleteActivity(Long activityId, String deletedBy) {
        return activityRepo.findById(activityId)
            .onItem().ifNotNull().transformToUni(activity ->
                activityRepo.delete(activity)
                    .call(() -> transactionService.logTransaction(new TransactionDTO(
                        null,
                        activity.dailyLog.project.id,
                        ProjectTransaction.TransactionType.DELETE,
                        ProjectTransaction.DomainType.DAILY_LOG,
                        null, null,
                        "Activity deleted: " + activity.activityName,
                        deletedBy,
                        LocalDateTime.now()
                    )))
            );
    }
}
