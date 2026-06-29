package tech.kayys.finance.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.accounting.model.AccountType;
import tech.kayys.company.domain.Company;

@Entity
@Table(name = "bank_accounts")
public class BankAccount extends PanacheEntity {
    @NotBlank
    public String accountNumber;
    
    @NotBlank
    public String accountName;
    
    @NotBlank
    public String bankName;
    
    @NotBlank
    public String bankCode; // Indonesian bank code
    
    @Enumerated(EnumType.STRING)
    public AccountType accountType; // CHECKING, SAVINGS, TIME_DEPOSIT
    
    @NotNull
    public BigDecimal balance = BigDecimal.ZERO;
    
    @NotNull
    public String currency = "IDR";
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
    
    @NotNull
    public Boolean isActive = true;
    
    public String swiftCode;
    public String branchAddress;
}

