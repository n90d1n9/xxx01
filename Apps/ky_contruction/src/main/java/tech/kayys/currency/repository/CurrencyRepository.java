package tech.kayys.currency.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.currency.domain.Currency;

@ApplicationScoped
public class CurrencyRepository implements PanacheRepository<Currency> {

    public Uni<Currency> findDefaultCurrency() {
        return find("defaultCurrency", true).firstResult();
    }

    public Uni<Void> setDefaultCurrency(Currency currency, String updatedBy) {
        return update("defaultCurrency = false")
                .replaceWithVoid()
                .call(() -> {
                    currency.defaultCurrency = true;
                    currency.lastModifiedBy = updatedBy;
                    return persist(currency).replaceWithVoid();
                });
    }

}
