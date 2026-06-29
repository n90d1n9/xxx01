package tech.kayys.finance.dto;

import java.math.BigDecimal;

public class FinancialSummary {
    public BigDecimal totalIncome;
    public BigDecimal totalExpense;
    public BigDecimal netIncome;
    
    public FinancialSummary(BigDecimal totalIncome, BigDecimal totalExpense, BigDecimal netIncome) {
        this.totalIncome = totalIncome;
        this.totalExpense = totalExpense;
        this.netIncome = netIncome;
    }
}

