package tech.kayys.project.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import tech.kayys.budget.domain.Budget;
import tech.kayys.currency.domain.Currency;
import tech.kayys.currency.service.CurrencyConversionService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Entity
@Table(name = "project_budgets")
public class ProjectBudget extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "budget_id", nullable = false)
    public Budget budget;

    @NotNull
    @DecimalMin("0")
    @Column(name = "amount", precision = 18, scale = 2, nullable = false)
    public BigDecimal amount;

    @Column(name = "category", length = 100)
    public String category;

    @Column(name = "description", length = 1000)
    public String description;

    @Column(name = "effective_date")
    public LocalDate effectiveDate;

    @Column(name = "expiry_date")
    public LocalDate expiryDate;

    @Column(name = "start_date")
    public LocalDate startDate;

    @Column(name = "created_by", length = 100)
    public String createdBy;

    @Column(name = "created_date", nullable = false, updatable = false)
    public LocalDate createdDate = LocalDate.now();

    @Column(name = "last_modified_by", length = 100)
    public String lastModifiedBy;

    @Column(name = "last_modified_date")
    public LocalDate lastModifiedDate;

    @Column(name = "updated_by", length = 100)
    public String updatedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "currency_id", nullable = false)
    public Currency currency;

    @PrePersist
    public void prePersist() {
        if (createdDate == null) {
            createdDate = LocalDate.now();
        }
    }

    @PreUpdate
    public void preUpdate() {
        lastModifiedDate = LocalDate.now();
    }

    @OneToMany(mappedBy = "budget", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    public List<ProjectExpense> expenses = new ArrayList<>();

    public Uni<BigDecimal> remainingAmount(CurrencyConversionService conversionService) {
        if (expenses == null || expenses.isEmpty()) {
            return Uni.createFrom().item(amount);
        }

        return Multi.createFrom().iterable(expenses)
                .onItem().transformToUniAndMerge(exp -> {
                    BigDecimal expAmount = exp.amount != null ? exp.amount : BigDecimal.ZERO;
                    LocalDate date = exp.expenseDate != null ? exp.expenseDate : LocalDate.now();
                    return conversionService.convert(expAmount, exp.currency, this.currency, date);
                })
                .collect().with(Collectors.reducing(BigDecimal.ZERO, BigDecimal::add))
                .map(totalSpent -> amount.subtract(totalSpent).max(BigDecimal.ZERO));
    }

}
