package tech.kayys.accounting.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import org.hibernate.resource.transaction.spi.TransactionStatus;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.company.domain.Company;
import tech.kayys.project.domain.ProjectTransaction.TransactionType;

@Entity
@Table(name = "financial_transactions")
public class FinancialTransaction extends PanacheEntity {
    @NotBlank
    public String transactionNumber;
    
    @NotNull
    public LocalDate transactionDate;
    
    @NotNull
    public LocalDateTime createdAt;
    
    @NotBlank
    public String description;
    
    @NotNull
    public BigDecimal amount;
    
    @Enumerated(EnumType.STRING)
    public TransactionType transactionType;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
    
    @ManyToOne
    @JoinColumn(name = "debit_account_id")
    public ChartOfAccount debitAccount;
    
    @ManyToOne
    @JoinColumn(name = "credit_account_id")
    public ChartOfAccount creditAccount;
    
    public String reference;
    public String approvedBy;
    public LocalDateTime approvedAt;
    
    @Enumerated(EnumType.STRING)
    public TransactionStatus status = TransactionStatus.PENDING;
}
