package tech.kayys.currency.service;

import java.time.LocalDateTime;
import java.util.List;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.currency.domain.Currency;
import tech.kayys.currency.repository.CurrencyRepository;
import tech.kayys.currency.repository.ExchangeRateRepository;
import tech.kayys.finance.domain.ExchangeRate;

@ApplicationScoped
public class CurrencyService {

    @Inject
    CurrencyRepository currencyRepo;

    @Inject
    ExchangeRateRepository rateRepo;

    /**
     * Set a default currency. Ensures only one default at a time.
     */
    public Uni<Void> setDefaultCurrency(Currency currency, String updatedBy) {
        return currencyRepo.update("defaultCurrency = true", false) // reset all to false
            .replaceWith(currency)
            .flatMap(cur -> {
                cur.defaultCurrency = true;
                cur.lastModifiedBy = updatedBy;
                cur.lastModifiedDate = LocalDateTime.now();
                return currencyRepo.persist(cur).replaceWithVoid();
            });
    }

    /**
     * Get the current default currency.
     */
    public Uni<Currency> getDefaultCurrency() {
        return currencyRepo.find("defaultCurrency", true).firstResult();
    }

    /**
     * List all active currencies.
     */
    public Uni<List<Currency>> listActive() {
        return currencyRepo.find("active", true).list();
    }

    /**
     * Historical audit: find all exchange rates for a currency pair.
     */
    public Uni<List<ExchangeRate>> getHistory(Currency from, Currency to) {
        return rateRepo.find("baseCurrency = ?1 and targetCurrency = ?2 order by validFrom desc", from, to)
                       .list();
    }

    /**
     * Deactivate a currency instead of deleting (for history integrity).
     */
    public Uni<Void> deactivate(Long currencyId, String updatedBy) {
        return currencyRepo.findById(currencyId)
            .onItem().ifNotNull().transformToUni(currency -> {
                currency.active = false;
                currency.lastModifiedBy = updatedBy;
                currency.lastModifiedDate = LocalDateTime.now();
                return currencyRepo.persist(currency).replaceWithVoid();
            })
            .replaceWithVoid();
    }
}
