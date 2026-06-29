package tech.kayys.finance.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import io.smallrye.mutiny.Uni;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import tech.kayys.currency.domain.Currency;

@Entity
@Table(name = "exchange_rates", uniqueConstraints = @UniqueConstraint(columnNames = { "base_currency_id",
        "target_currency_id", "valid_from" }))
public class ExchangeRate extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "base_currency_id", nullable = false)
    public Currency baseCurrency; // e.g., USD

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "target_currency_id", nullable = false)
    public Currency targetCurrency; // e.g., IDR

    @Column(nullable = false, precision = 18, scale = 6)
    public BigDecimal rate; // 1 baseCurrency = X targetCurrency

    @Column(name = "valid_from", nullable = false)
    public LocalDate validFrom;

    @Column(name = "valid_to")
    public LocalDate validTo; // optional for open-ended validity

    @Column(name = "created_at", updatable = false, nullable = false)
    public LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "last_modified_at")
    public LocalDateTime lastModifiedAt;

    @Column(name = "last_modified_by", length = 100)
    public String lastModifiedBy;

    public static Uni<ExchangeRate> findLatestRate(Currency base, Currency target) {
        return find("baseCurrency = ?1 and targetCurrency = ?2 and (validTo is null or validTo >= ?3)",
                base, target, LocalDate.now())
                .firstResult();
    }

}
