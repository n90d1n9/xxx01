package tech.kayys.risk.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.risk.domain.RiskTemplate;
import tech.kayys.risk.model.RiskCategory;
import io.smallrye.mutiny.Uni;
import java.util.List;

@ApplicationScoped
public class RiskTemplateRepository implements PanacheRepository<RiskTemplate> {

    public Uni<List<RiskTemplate>> findByCategory(RiskCategory category) {
        return find("category", category).list();
    }

    public Uni<List<RiskTemplate>> searchByKeyword(String keyword) {
        return find("lower(title) like ?1 or lower(description) like ?1", "%" + keyword.toLowerCase() + "%").list();
    }
}
