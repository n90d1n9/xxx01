package tech.kayys.project.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import tech.kayys.currency.domain.Currency;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "project_expenses")
public class ProjectExpense extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "budget_id", nullable = false)
    public ProjectBudget budget;

    @NotNull
    @DecimalMin("0")
    @Column(name = "amount", precision = 18, scale = 2, nullable = false)
    public BigDecimal amount;

    @Column(name = "expense_date", nullable = false)
    public LocalDate expenseDate = LocalDate.now();

    @Column(name = "category", length = 100)
    public String category;

    @Column(name = "description", length = 1000)
    public String description;

    @Column(name = "created_by", length = 100)
    public String createdBy;

    @Column(name = "created_date", nullable = false, updatable = false)
    public LocalDate createdDate = LocalDate.now();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "currency_id", nullable = false)
    public Currency currency;

    @PrePersist
    public void prePersist() {
        if (createdDate == null) {
            createdDate = LocalDate.now();
        }
    }
}
