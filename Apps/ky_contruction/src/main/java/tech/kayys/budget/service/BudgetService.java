package tech.kayys.budget.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import tech.kayys.accounting.domain.ChartOfAccount;
import tech.kayys.accounting.repository.FinancialTransactionRepository;
import tech.kayys.budget.domain.Budget;
import tech.kayys.company.domain.Company;

@ApplicationScoped
public class BudgetService {
    
    @Inject
    BudgetRepository budgetRepo;
    
    @Inject
    FinancialTransactionRepository transactionRepo;
    
    @Transactional
    public Budget createBudget(CreateBudgetRequest request) {
        Budget budget = new Budget();
        budget.budgetYear = request.budgetYear;
        budget.budgetMonth = request.budgetMonth;
        budget.company = Company.findById(request.companyId);
        budget.account = ChartOfAccount.findById(request.accountId);
        budget.budgetAmount = request.budgetAmount;
        budget.createdAt = LocalDateTime.now();
        budget.notes = request.notes;
        
        budgetRepo.persist(budget);
        return budget;
    }
    
    @Transactional
    public void updateBudgetVariance(Long companyId, Long accountId, BigDecimal amount, LocalDate transactionDate) {
        Budget budget = budgetRepo.findByCompanyAccountAndMonth(companyId, accountId, 
                                                               transactionDate.getYear(), 
                                                               transactionDate.getMonthValue());
        
        if (budget != null) {
            budget.actualAmount = budget.actualAmount.add(amount);
            budget.variance = budget.budgetAmount.subtract(budget.actualAmount);
        }
    }
    
    public List<BudgetVarianceReport> getBudgetVarianceReport(Long companyId, Integer year) {
        List<Budget> budgets = budgetRepo.findByCompanyAndYear(companyId, year);
        
        return budgets.stream()
                .map(budget -> new BudgetVarianceReport(
                    budget.account.accountName,
                    budget.budgetMonth,
                    budget.budgetAmount,
                    budget.actualAmount,
                    budget.variance,
                    calculateVariancePercentage(budget.budgetAmount, budget.variance)
                ))
                .collect(Collectors.toList());
    }
    
    private BigDecimal calculateVariancePercentage(BigDecimal budget, BigDecimal variance) {
        if (budget.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return variance.divide(budget, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100));
    }
}