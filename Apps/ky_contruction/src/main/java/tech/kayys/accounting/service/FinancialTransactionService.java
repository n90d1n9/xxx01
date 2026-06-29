package tech.kayys.accounting.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import jakarta.validation.ValidationException;
import tech.kayys.accounting.domain.ChartOfAccount;
import tech.kayys.accounting.domain.FinancialTransaction;
import tech.kayys.accounting.model.AccountType;
import tech.kayys.accounting.model.TransactionStatus;
import tech.kayys.accounting.repository.FinancialTransactionRepository;
import tech.kayys.company.domain.Company;

@ApplicationScoped
public class FinancialTransactionService {
    
    @Inject
    FinancialTransactionRepository transactionRepo;
    
    @Inject
    ChartOfAccountRepository accountRepo;
    
    @Inject
    BudgetService budgetService;
    
    @Transactional
    public FinancialTransaction createTransaction(CreateTransactionRequest request) {
        // Validate accounts
        ChartOfAccount debitAccount = accountRepo.findById(request.debitAccountId);
        ChartOfAccount creditAccount = accountRepo.findById(request.creditAccountId);
        
        if (debitAccount == null || creditAccount == null) {
            throw new ValidationException("Invalid account IDs");
        }
        
        // Generate transaction number
        String transactionNumber = generateTransactionNumber();
        
        FinancialTransaction transaction = new FinancialTransaction();
        transaction.transactionNumber = transactionNumber;
        transaction.transactionDate = request.transactionDate;
        transaction.description = request.description;
        transaction.amount = request.amount;
        transaction.transactionType = request.transactionType;
        transaction.company = Company.findById(request.companyId);
        transaction.debitAccount = debitAccount;
        transaction.creditAccount = creditAccount;
        transaction.reference = request.reference;
        transaction.createdAt = LocalDateTime.now();
        transaction.status = TransactionStatus.PENDING;
        
        transactionRepo.persist(transaction);
        return transaction;
    }
    
    @Transactional
    public FinancialTransaction approveTransaction(Long transactionId, String approvedBy) {
        FinancialTransaction transaction = transactionRepo.findById(transactionId);
        if (transaction == null) {
            throw new EntityNotFoundException("Transaction not found");
        }
        
        transaction.status = TransactionStatus.APPROVED;
        transaction.approvedBy = approvedBy;
        transaction.approvedAt = LocalDateTime.now();
        
        return transaction;
    }
    
    @Transactional
    public FinancialTransaction postTransaction(Long transactionId) {
        FinancialTransaction transaction = transactionRepo.findById(transactionId);
        if (transaction == null) {
            throw new EntityNotFoundException("Transaction not found");
        }
        
        if (transaction.status != TransactionStatus.APPROVED) {
            throw new ValidationException("Transaction must be approved before posting");
        }
        
        transaction.status = TransactionStatus.POSTED;
        
        // Update budget variance
        budgetService.updateBudgetVariance(transaction.company.id, 
                                          transaction.debitAccount.id,
                                          transaction.amount,
                                          transaction.transactionDate);
        
        return transaction;
    }
    
    private String generateTransactionNumber() {
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        Long count = transactionRepo.count("transactionNumber LIKE ?1", dateStr + "%");
        return String.format("TXN%s%04d", dateStr, count + 1);
    }
    
    public List<FinancialTransaction> getTransactionsByCompany(Long companyId, LocalDate startDate, LocalDate endDate) {
        return transactionRepo.findByCompanyAndDateRange(companyId, startDate, endDate);
    }
    
    public FinancialSummary getFinancialSummary(Long companyId, LocalDate startDate, LocalDate endDate) {
        List<FinancialTransaction> transactions = transactionRepo.findByCompanyAndDateRange(companyId, startDate, endDate);
        
        BigDecimal totalIncome = transactions.stream()
                .filter(t -> t.creditAccount.accountType == AccountType.REVENUE)
                .map(t -> t.amount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal totalExpense = transactions.stream()
                .filter(t -> t.debitAccount.accountType == AccountType.EXPENSE)
                .map(t -> t.amount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return new FinancialSummary(totalIncome, totalExpense, totalIncome.subtract(totalExpense));
    }
}
