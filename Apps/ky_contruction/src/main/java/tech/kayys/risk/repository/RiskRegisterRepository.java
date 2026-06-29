package tech.kayys.risk.repository;

import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.service.RiskSeverity;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.model.RiskStatus;

@ApplicationScoped
public class RiskRegisterRepository implements PanacheRepository<RiskRegister> {
    
    public Uni<List<RiskRegister>> findByProject(Long projectId) {
        return find("project.id", projectId).list();
    }
    
    public Uni<List<RiskRegister>> findByStatus(RiskStatus status) {
        return find("status", status).list();
    }
    
    public Uni<List<RiskRegister>> findByOwner(String owner) {
        return find("owner", owner).list();
    }
    
    public Uni<List<RiskRegister>> findHighRisks(int threshold) {
        return find("riskScore >= ?1", threshold).list();
    }
    
    public Uni<List<RiskRegister>> findOverdueRisks() {
        return find("targetClosureDate < ?1 and status != ?2", 
                    LocalDate.now(), RiskStatus.CLOSED).list();
    }
    
    public Uni<List<RiskRegister>> findByCategory(RiskCategory category) {
        return find("category", category).list();
    }
    
    public Uni<RiskRegister> findByRiskId(String riskId) {
        return find("riskId", riskId).firstResult();
    }

   public Uni<Long> countByProject(Long projectId) {
        return count("project.id", projectId);
    }

    public Uni<Long> countByProjectAndSeverity(Long projectId, RiskSeverity severity) {
        return count("project.id = ?1 and severity = ?2", projectId, severity);
    }
}
