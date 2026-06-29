package tech.kayys.project.model;

import io.smallrye.mutiny.Uni;
import tech.kayys.currency.service.CurrencyConversionService;
import tech.kayys.project.domain.ProjectBudget;
import tech.kayys.project.dto.ProjectBudgetDTO;

public class ProjectBudgetMapper {

    public static Uni<ProjectBudgetDTO> toDTO(ProjectBudget entity, CurrencyConversionService conversionService) {
        if (entity == null) return Uni.createFrom().nullItem();

        return entity.remainingAmount(conversionService)
                .map(remaining -> {
                    ProjectBudgetDTO dto = new ProjectBudgetDTO();
                    dto.id = entity.id;
                    dto.category = entity.category;
                    dto.amount = entity.amount;
                    dto.description = entity.description;
                    dto.startDate = entity.startDate;
                    dto.expiryDate = entity.expiryDate;

                    dto.remainingAmount = remaining;

                    if (entity.project != null) {
                        dto.projectCode = entity.project.projectCode;
                    }

                    dto.createdBy = entity.createdBy;
                    dto.updatedBy = entity.updatedBy;

                    return dto;
                });
    }
}

