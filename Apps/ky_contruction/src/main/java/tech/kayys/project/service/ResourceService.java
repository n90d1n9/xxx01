package tech.kayys.project.service;

import java.time.LocalDateTime;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.ProjectResource;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.repository.ResourceRepository;
import tech.kayys.risk.dto.TransactionDTO;

@ApplicationScoped
public class ResourceService {

    @Inject ResourceRepository resourceRepo;
    @Inject TransactionService transactionService;

    public ProjectResource assign(ProjectResource resource, String assignedBy) {
        resourceRepo.persist(resource);

        transactionService.logTransaction(new TransactionDTO(
            null,
            resource.project.id,
            ProjectTransaction.TransactionType.CREATE,
            ProjectTransaction.DomainType.RESOURCE,
            null, null,
            "Resource assigned: " + resource.resourceName,
            assignedBy,
            LocalDateTime.now()
        ));

        return resource;
    }

public Uni<Void> release(Long resourceId, String releasedBy) {
    return resourceRepo.findById(resourceId)
            .flatMap(resource -> {
                if (resource == null) {
                    return Uni.createFrom().voidItem(); // nothing to release
                }
                // delete returns Uni<Boolean>, logTransaction returns Uni<ProjectTransaction>
                return resourceRepo.delete(resource)
                        .flatMap(deleted -> transactionService.logTransaction(new TransactionDTO(
                                null,
                                resource.project.id,
                                ProjectTransaction.TransactionType.DELETE,
                                ProjectTransaction.DomainType.RESOURCE,
                                null, null,
                                "Resource released: " + resource.resourceName,
                                releasedBy,
                                LocalDateTime.now()
                        )))
                        .replaceWithVoid(); // convert Uni<ProjectTransaction> to Uni<Void>
            });
}


}
