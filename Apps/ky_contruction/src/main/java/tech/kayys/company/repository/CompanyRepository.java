package tech.kayys.company.repository;

import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.company.domain.Company;
import tech.kayys.company.model.CompanyType;

@ApplicationScoped
public class CompanyRepository implements PanacheRepository<Company> {
    
    public Company findByNpwp(String npwp) {
        return find("npwp", npwp).firstResult();
    }
    
    public List<Company> findByType(CompanyType type) {
        return find("type", type).list();
    }
    
    public List<Company> findActiveCompanies() {
        return find("SELECT c FROM Company c WHERE c.id IN (SELECT DISTINCT t.company.id FROM FinancialTransaction t WHERE t.transactionDate >= ?1)",
                LocalDate.now().minusMonths(12)).list();
    }
}