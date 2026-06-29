package tech.kayys.budget.domain;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import tech.kayys.accounting.domain.ChartOfAccount;
import tech.kayys.company.domain.Company;

@Entity
@Table(name = "budgets")
public class Budget extends PanacheEntity {
    @NotNull
     @Column(name = "year")
    public Integer year;
    
    @NotNull
    @Column(name = "month")
    public Integer month;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
    
    @ManyToOne
    @JoinColumn(name = "account_id")
    public ChartOfAccount account;
    
    @NotNull
    public BigDecimal amount;
    
    @NotNull
    @Column(name = "actual_amount")
    public BigDecimal actualAmount = BigDecimal.ZERO;
    
    @NotNull
    @Column(name = "variance")
    public BigDecimal variance = BigDecimal.ZERO;
    
    @NotNull
    @Column(name = "created_at")
    public LocalDateTime createdAt;
    
    @Column(name = "notes")
    public String notes;
}
