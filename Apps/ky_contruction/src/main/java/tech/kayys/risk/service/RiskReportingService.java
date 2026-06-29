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
import tech.kayys.risk.model.RegulatoryRequirement;
import tech.kayys.risk.model.RiskCategory;


@ApplicationScoped
public class RiskReportingService {
    
    @Inject
    EntityManager em;
    
    @Inject
    RiskAnalyticsService analyticsService;
    
    public RiskDashboardData generateExecutiveDashboard(Long projectId) {
        RiskDashboardData dashboard = new RiskDashboardData();
        
        // Risk summary statistics
        dashboard.riskSummary = getRiskSummaryStats(projectId);
        
        // Top risks
        dashboard.topRisks = getTopRisks(projectId, 10);
        
        // Risk trends
        dashboard.riskTrends = analyticsService.calculateRiskTrends(projectId, 12);
        
        // Risk heatmap
        dashboard.heatmap = analyticsService.generateRiskHeatmap(projectId, LocalDate.now());
        
        // KRI status
        dashboard.kriStatus = getKRIStatus(projectId);
        
        // Compliance status
        dashboard.complianceStatus = getComplianceStatus(projectId);
        
        // Recent escalations
        dashboard.recentEscalations = getRecentEscalations(projectId, 30);
        
        return dashboard;
    }
    
    public byte[] generateRiskRegisterReport(Long projectId, ReportFormat format) {
        List<RiskRegister> risks = getRisksForReport(projectId);
        
        return switch (format) {
            case PDF -> generatePDFReport(risks);
            case EXCEL -> generateExcelReport(risks);
            case CSV -> generateCSVReport(risks);
        };
    }
    
    public ComplianceReport generateComplianceReport(RegulatoryRequirement requirement, 
                                                   LocalDate fromDate, LocalDate toDate) {
        String query = """
            SELECT r FROM RiskRegister r 
            WHERE :requirement MEMBER OF r.regulatoryRequirements
            AND r.identifiedDate BETWEEN :fromDate AND :toDate
            """;
        
        List<RiskRegister> risks = em.createQuery(query, class)
                .setParameter("requirement", requirement)
                .setParameter("fromDate", fromDate)
                .setParameter("toDate", toDate)
                .getResultList();
        
        ComplianceReport report = new ComplianceReport();
        report.requirement = requirement;
        report.reportPeriod = new DateRange(fromDate, toDate);
        report.totalRisks = risks.size();
        report.riskBreakdown = analyzeComplianceRisks(risks);
        report.mitigationEffectiveness = calculateComplianceMitigationEffectiveness(risks);
        report.recommendations = generateComplianceRecommendations(risks);
        
        return report;
    }
    
    public RiskAppetiteReport generateRiskAppetiteReport(Long projectId) {
        RiskAppetiteReport report = new RiskAppetiteReport();
        
        // Get current risk levels vs appetite
        List<RiskRegister> risks = getRisksForReport(projectId);
        
        report.riskAppetiteBreaches = risks.stream()
                .filter(r -> r.residualRiskScore > getRiskAppetiteThreshold(r.category))
                .map(this::mapToAppetiteBreach)
                .collect(Collectors.toList());
        
        report.categoryAnalysis = risks.stream()
                .collect(Collectors.groupingBy(r -> r.category,
                         Collectors.collectingAndThen(
                             Collectors.toList(),
                             this::analyzeCategoryRiskAppetite)));
        
        return report;
    }
    
    private RiskSummaryStats getRiskSummaryStats(Long projectId) {
        // Implementation for risk summary statistics
        String query = """
            SELECT 
                COUNT(r),
                AVG(r.residualRiskScore),
                SUM(CASE WHEN r.residualRiskScore >= 20 THEN 1 ELSE 0 END),
                SUM(CASE WHEN r.residualRiskScore >= 15 AND r.residualRiskScore < 20 THEN 1 ELSE 0 END),
                SUM(CASE WHEN r.residualRiskScore < 15 THEN 1 ELSE 0 END)
            FROM RiskRegister r
            WHERE (:projectId IS NULL OR r.project.id = :projectId)
            AND r.status != com.company.risk.entity.RiskRegister$RiskStatus.CLOSED
            """;
        
        Object[] result = (Object[]) em.createQuery(query)
                .setParameter("projectId", projectId)
                .getSingleResult();
        
        RiskSummaryStats stats = new RiskSummaryStats();
        stats.totalRisks = ((Long) result[0]).intValue();
        stats.averageRiskScore = (Double) result[1];
        stats.criticalRisks = ((Long) result[2]).intValue();
        stats.highRisks = ((Long) result[3]).intValue();
        stats.mediumLowRisks = ((Long) result[4]).intValue();
        
        return stats;
    }
    
    private Integer getRiskAppetiteThreshold(RiskCategory category) {
        // Risk appetite thresholds by category
        return switch (category) {
            case STRATEGIC -> 16;
            case FINANCIAL -> 18;
            case OPERATIONAL -> 15;
            case COMPLIANCE -> 12;
            case CYBER_SECURITY -> 10;
            case REPUTATIONAL -> 14;
            default -> 15;
        };
    }
    
    public enum ReportFormat {
        PDF, EXCEL, CSV
    }
}
