package tech.kayys.accounting.repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.accounting.domain.FinancialTransaction;
import tech.kayys.accounting.model.TransactionStatus;

@ApplicationScoped
public class FinancialTransactionRepository implements PanacheRepository<FinancialTransaction> {
    
    public List<FinancialTransaction> findByCompanyAndDateRange(Long companyId, LocalDate startDate, LocalDate endDate) {
        return find("company.id = ?1 AND transactionDate BETWEEN ?2 AND ?3 ORDER BY transactionDate DESC",
                companyId, startDate, endDate).list();
    }
    
    public List<FinancialTransaction> findByStatus(TransactionStatus status) {
        return find("status", status).list();
    }
    
    public BigDecimal getTotalByAccountAndDateRange(Long accountId, LocalDate startDate, LocalDate endDate) {
        return find("SELECT COALESCE(SUM(t.amount), 0) FROM FinancialTransaction t " +
                   "WHERE (t.debitAccount.id = ?1 OR t.creditAccount.id = ?1) " +
                   "AND t.transactionDate BETWEEN ?2 AND ?3 AND t.status = ?4",
                accountId, startDate, endDate, TransactionStatus.POSTED)
                .project(BigDecimal.class).firstResult();
    }
}