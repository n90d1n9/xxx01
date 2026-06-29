package tech.kayys.project.domain;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "project_transactions")
public class ProjectTransaction extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;

    @Column(name = "transaction_date", nullable = false)
    public LocalDateTime transactionDate = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = false)
    public TransactionType transactionType;

    @Enumerated(EnumType.STRING)
    @Column(name = "domain_type", nullable = false)
    public DomainType domainType;

    @Column(name = "reference_id")
    public Long referenceId; 
    // links to BudgetTransaction, Resource, Task, Risk, etc.

    @Column(name = "amount")
    public BigDecimal amount; // for budget-related

    @Column(name = "quantity")
    public Integer quantity; // for resources

    @Column(name = "description", length = 2000)
    public String description;

    @Column(name = "created_by")
    public String createdBy;

    public enum TransactionType {
        CREATE, UPDATE, DELETE, ALLOCATE, RELEASE, TRANSFER, APPROVE, REJECT, ACTUAL, COMMITTED, ADJUSTMENT
    }

    public enum DomainType {
        BUDGET, RESOURCE, TASK, RISK, DELIVERABLE, MILESTONE, ISSUE, CHANGE_REQUEST, DAILY_LOG, PROJECT, DEPENDENCY
    }
}

