package tech.kayys.currency.service;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.currency.domain.Currency;
import tech.kayys.currency.repository.ExchangeRateRepository;

@ApplicationScoped
public class CurrencyConversionService {

    @Inject
    ExchangeRateRepository rateRepo;

    @Inject
    CurrencyService currencyService;

    /**
     * Convert between two currencies on a given date.
     * Falls back to default currency if no direct pair exists.
     */
    public Uni<BigDecimal> convert(BigDecimal amount, Currency from, Currency to, LocalDate date) {
        if (from.id.equals(to.id)) {
            return Uni.createFrom().item(amount);
        }

        // Try direct rate
        return rateRepo.findRate(from, to, date)
            .onItem().ifNotNull().transform(rate -> amount.multiply(rate))
            .onItem().ifNull().switchTo(() -> {
                // Fallback: go through default currency as intermediate
                return currencyService.getDefaultCurrency()
                    .flatMap(defaultCur -> 
                        convert(amount, from, defaultCur, date)
                            .flatMap(intermediate ->
                                convert(intermediate, defaultCur, to, date)
                            )
                    );
            });
    }
}
