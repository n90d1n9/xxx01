package tech.kayys.currency.repository;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.currency.domain.Currency;
import tech.kayys.finance.domain.ExchangeRate;

@ApplicationScoped
public class ExchangeRateRepository implements PanacheRepository<ExchangeRate> {

    public Uni<BigDecimal> findRate(Currency from, Currency to, LocalDate date) {
        return find("baseCurrency = ?1 and targetCurrency = ?2 and validFrom <= ?3 and (validTo is null or validTo >= ?3)",
                from, to, date)
            .firstResult()
            .onItem().ifNotNull().transform(rate -> rate.rate);
    }
}
