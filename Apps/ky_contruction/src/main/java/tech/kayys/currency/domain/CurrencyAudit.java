package tech.kayys.currency.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "currency_audit")
public class CurrencyAudit extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "currency_id", nullable = false)
    public Currency currency;

    @Column(name = "old_value", length = 500)
    public String oldValue;

    @Column(name = "new_value", length = 500)
    public String newValue;

    @Column(name = "changed_by")
    public String changedBy;

    @Column(name = "changed_date", nullable = false)
    public LocalDateTime changedDate = LocalDateTime.now();
}
