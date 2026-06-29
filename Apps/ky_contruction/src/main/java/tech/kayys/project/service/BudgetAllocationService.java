package tech.kayys.project.service;

import java.math.BigDecimal;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.budget.domain.Budget;
import tech.kayys.project.domain.ProjectBudget;

@ApplicationScoped
public class BudgetAllocationService {

    @SuppressWarnings("unchecked")
    public BigDecimal getAllocated(Budget budget) {
        List<ProjectBudget> projectBudgets = (List<ProjectBudget>) ProjectBudget.find("budget", budget).list();

        return projectBudgets.stream()
                .map(pb -> pb.amount != null ? pb.amount : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public BigDecimal getRemaining(Budget budget) {
        return budget.amount.subtract(getAllocated(budget)).max(BigDecimal.ZERO);
    }
}
