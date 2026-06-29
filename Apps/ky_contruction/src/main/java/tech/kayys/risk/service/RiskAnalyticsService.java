package tech.kayys.risk.service;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.dto.RiskCoordinate;
import tech.kayys.risk.dto.RiskHeatmapData;
import tech.kayys.risk.dto.RiskPortfolioAnalysis;
import tech.kayys.risk.dto.RiskTrendData;
import tech.kayys.risk.model.RiskImpact;
import tech.kayys.risk.model.RiskProbability;

@ApplicationScoped
public class RiskAnalyticsService {
    
    @Inject
    EntityManager em;
    
    public RiskHeatmapData generateRiskHeatmap(Long projectId, LocalDate asOfDate) {
        String query = """
            SELECT r.probability, r.impact, COUNT(r) as count
            FROM RiskRegister r
            WHERE (:projectId IS NULL OR r.project.id = :projectId)
            AND r.status != com.company.risk.entity.RiskRegister$RiskStatus.CLOSED
            GROUP BY r.probability, r.impact
            """;
        
        List<Object[]> results = em.createQuery(query, Object[].class)
                .setParameter("projectId", projectId)
                .getResultList();
        
        RiskHeatmapData heatmap = new RiskHeatmapData();
        heatmap.data = results.stream()
                .collect(Collectors.toMap(
                    row -> new RiskCoordinate((RiskProbability) row[0], 
                                            (RiskImpact) row[1]),
                    row -> ((Long) row[2]).intValue()
                ));
        
        return heatmap;
    }
    
    public List<RiskTrendData> calculateRiskTrends(Long projectId, int months) {
        LocalDate startDate = LocalDate.now().minusMonths(months);
        
        String query = """
            SELECT DATE_TRUNC('month', rah.assessmentDate), 
                   AVG(rah.newScore), 
                   COUNT(DISTINCT rah.risk.id)
            FROM RiskAssessmentHistory rah
            WHERE rah.assessmentDate >= :startDate
            AND (:projectId IS NULL OR rah.risk.project.id = :projectId)
            GROUP BY DATE_TRUNC('month', rah.assessmentDate)
            ORDER BY DATE_TRUNC('month', rah.assessmentDate)
            """;
        
        List<Object[]> results = em.createQuery(query, Object[].class)
                .setParameter("startDate", startDate.atStartOfDay())
                .setParameter("projectId", projectId)
                .getResultList();
        
        return results.stream()
                .map(row -> new RiskTrendData(
                    ((Timestamp) row[0]).toLocalDateTime().toLocalDate(),
                    ((Double) row[1]),
                    ((Long) row[2]).intValue()
                ))
                .collect(Collectors.toList());
    }
    
    public RiskPortfolioAnalysis analyzeRiskPortfolio(Long projectId) {
        String baseQuery = """
            SELECT r FROM RiskRegister r 
            WHERE (:projectId IS NULL OR r.project.id = :projectId)
            AND r.status != com.company.risk.entity.RiskRegister$RiskStatus.CLOSED
            """;
        
        List<RiskRegister> risks = em.createQuery(baseQuery, class)
                .setParameter("projectId", projectId)
                .getResultList();
        
        return new RiskPortfolioAnalysis(risks);
    }
    
    public List<KRITrendData> analyzeKRITrends(Long riskId, int months) {
        LocalDate startDate = LocalDate.now().minusMonths(months);
        
        String query = """
            SELECT km.measurementDate, km.measuredValue, kri.indicatorName
            FROM KRIMeasurement km
            JOIN km.indicator kri
            WHERE kri.risk.id = :riskId
            AND km.measurementDate >= :startDate
            ORDER BY km.measurementDate
            """;
        
        List<Object[]> results = em.createQuery(query, Object[].class)
                .setParameter("riskId", riskId)
                .setParameter("startDate", startDate)
                .getResultList();
        
        return results.stream()
                .map(row -> new KRITrendData(
                    (LocalDate) row[0],
                    (BigDecimal) row[1],
                    (String) row[2]
                ))
                .collect(Collectors.toList());
    }
}