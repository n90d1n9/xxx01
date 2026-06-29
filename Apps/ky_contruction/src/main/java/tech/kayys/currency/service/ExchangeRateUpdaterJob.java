package tech.kayys.currency.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import io.quarkus.scheduler.Scheduled;
import io.smallrye.mutiny.Multi;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.currency.repository.CurrencyRepository;
import tech.kayys.currency.repository.ExchangeRateRepository;
import tech.kayys.finance.domain.ExchangeRate;

@ApplicationScoped
public class ExchangeRateUpdaterJob {

    @Inject
    ExchangeRateRepository rateRepo;
    @Inject
    CurrencyRepository currencyRepo;

    @Scheduled(cron = "0 0 6 * * ?") // every day 6 AM
    public void updateRates() {
        Map<String, BigDecimal> latestRates = fetchRatesFromProvider();

        currencyRepo.findDefaultCurrency()
                .onItem().ifNotNull().call(baseCurrency -> Multi.createFrom().iterable(latestRates.entrySet())
                        .onItem().transformToUniAndMerge(entry -> {
                            String targetCode = entry.getKey();
                            BigDecimal rate = entry.getValue();

                            return currencyRepo.find("code", targetCode).firstResult()
                                    .onItem().ifNotNull().transformToUni(targetCurrency -> {
                                        ExchangeRate exRate = new ExchangeRate();
                                        exRate.baseCurrency = baseCurrency;
                                        exRate.targetCurrency = targetCurrency;
                                        exRate.rate = rate;
                                        exRate.validFrom = LocalDate.now();

                                        return rateRepo.persist(exRate).replaceWithVoid();
                                    })
                                    .replaceWithVoid();

                        })
                        .collect().asList()
                        .replaceWithVoid())
                .subscribe().with(
                        ok -> System.out.println("Exchange rates updated"),
                        err -> System.err.println("Failed to update rates: " + err));

    }

    private Map<String, BigDecimal> fetchRatesFromProvider() {
        // TODO: integrate Bank Indonesia API or ECB API
        Map<String, BigDecimal> mock = new HashMap<>();
        mock.put("USD", new BigDecimal("0.000065")); // Example
        mock.put("EUR", new BigDecimal("0.000061"));
        return mock;
    }
}
