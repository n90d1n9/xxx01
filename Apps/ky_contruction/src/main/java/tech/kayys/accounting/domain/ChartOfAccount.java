package tech.kayys.accounting.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.accounting.model.AccountCategory;
import tech.kayys.accounting.model.AccountType;
import tech.kayys.company.domain.Company;

@Entity
@Table(name = "chart_of_accounts")
public class ChartOfAccount extends PanacheEntity {
    @NotBlank
    @Column(unique = true)
    public String accountCode;
    
    @NotBlank
    public String accountName;
    
    @Enumerated(EnumType.STRING)
    public AccountType accountType;
    
    @Enumerated(EnumType.STRING)
    public AccountCategory category;
    
    public Long parentAccountId;
    
    @NotNull
    public Boolean isActive = true;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
}