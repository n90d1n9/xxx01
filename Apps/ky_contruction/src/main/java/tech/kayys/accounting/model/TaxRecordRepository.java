package tech.kayys.accounting.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.accounting.domain.TaxRecord;

@ApplicationScoped
public class TaxRecordRepository implements PanacheRepository<TaxRecord> {
    
    public List<TaxRecord> findByCompanyAndYear(Long companyId, Integer year) {
        return find("company.id = ?1 AND taxYear = ?2 ORDER BY taxMonth", companyId, year).list();
    }
    
    public List<TaxRecord> findOverdueTaxes() {
        return find("status != ?1 AND dueDate < ?2", TaxStatus.PAID, LocalDate.now()).list();
    }
    
    public BigDecimal getTotalTaxByTypeAndYear(Long companyId, TaxType taxType, Integer year) {
        return find("SELECT COALESCE(SUM(t.taxAmount), 0) FROM TaxRecord t " +
                   "WHERE t.company.id = ?1 AND t.taxType = ?2 AND t.taxYear = ?3",
                companyId, taxType, year)
                .project(BigDecimal.class).firstResult();
    }
}

