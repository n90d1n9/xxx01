package tech.kayys.risk.repository;


import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.risk.domain.RiskDocument;
import io.smallrye.mutiny.Uni;

import java.util.List;

@ApplicationScoped
public class RiskDocumentRepository implements PanacheRepository<RiskDocument> {

    public Uni<List<RiskDocument>> findByRisk(Long riskId) {
        return find("risk.id", riskId).list();
    }

    public Uni<List<RiskDocument>> findActiveByRisk(Long riskId) {
        return find("risk.id = ?1 and status = ?2", riskId, RiskDocument.DocumentStatus.ACTIVE).list();
    }

    public Uni<RiskDocument> findByFileName(Long riskId, String fileName) {
        return find("risk.id = ?1 and fileName = ?2", riskId, fileName).firstResult();
    }
}
