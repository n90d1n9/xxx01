package tech.kayys.budget.dto;

public class BudgetVarianceReport {
    public String accountName;
    public Integer month;
    public BigDecimal budgetAmount;
    public BigDecimal actualAmount;
    public BigDecimal variance;
    public BigDecimal variancePercentage;
    
    public BudgetVarianceReport(String accountName, Integer month, BigDecimal budgetAmount, 
                               BigDecimal actualAmount, BigDecimal variance, BigDecimal variancePercentage) {
        this.accountName = accountName;
        this.month = month;
        this.budgetAmount = budgetAmount;
        this.actualAmount = actualAmount;
        this.variance = variance;
        this.variancePercentage = variancePercentage;
    }
}

