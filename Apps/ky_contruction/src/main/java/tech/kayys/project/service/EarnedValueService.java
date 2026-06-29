package tech.kayys.project.service;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.common.WithTransaction;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.EarnedValueData;
import tech.kayys.project.domain.Project;

@ApplicationScoped
public class EarnedValueService {
    
    @WithTransaction
    public Uni<EarnedValueData> calculateEarnedValue(Long projectId, LocalDate statusDate) {
        return Project.<Project>findById(projectId)   // reactive, returns Uni<Project>
            .onItem().ifNull().failWith(() -> new IllegalArgumentException("Project not found"))
            .flatMap(project -> {
                EarnedValueData evData = new EarnedValueData();
                evData.project = project;
                evData.statusDate = statusDate;
                evData.budgetAtCompletion = project.estimatedBudget;

                // Calculate PV, EV, AC
                evData.plannedValue = calculatePlannedValue(project, statusDate);
                evData.earnedValue = calculateEarnedValue(project);
                evData.actualCost = calculateActualCost(project);

                return evData.<EarnedValueData>persist().replaceWith(evData);
            });
    }
    
    private BigDecimal calculatePlannedValue(Project project, LocalDate statusDate) {
        // PV = (Planned % Complete at Status Date) * BAC
        if (project.startDate == null || project.endDate == null) {
            return BigDecimal.ZERO;
        }
        
        long totalDays = project.startDate.until(project.endDate).getDays();
        long elapsedDays = project.startDate.until(statusDate).getDays();
        
        if (totalDays <= 0) return project.estimatedBudget;
        
        double plannedPercent = Math.min(1.0, (double) elapsedDays / totalDays);
        return project.estimatedBudget.multiply(new BigDecimal(plannedPercent));
    }
    


     private BigDecimal calculateEarnedValue(Project project) {
        double actualPercent = project.progressPercentage / 100.0;
        return project.estimatedBudget.multiply(BigDecimal.valueOf(actualPercent));
    }

    private BigDecimal calculateActualCost(Project project) {
        return project.actualCost != null ? project.actualCost : BigDecimal.ZERO;
    }
}

