package tech.kayys.ai.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.construction.domain.Material;
import tech.kayys.finance.domain.ChangeOrder;
import tech.kayys.hris.domain.LaborProductivity;
import tech.kayys.hse.domain.QualityInspection;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ProjectAnalytics;
import tech.kayys.project.domain.ScheduleActivity;
import tech.kayys.report.domain.NonConformanceReport;
import tech.kayys.vendor.domain.VendorEvaluation;

@ApplicationScoped
public class PredictiveAnalyticsService {
    
    public ProjectAnalytics analyzeProject(Long projectId) {
        Project project = Project.findById(projectId);
        if (project == null) return null;
        
        ProjectAnalytics analytics = new ProjectAnalytics();
        analytics.project = project;
        analytics.analysisDate = LocalDate.now();
        
        // Calculate delay risk score based on multiple factors
        analytics.delayRiskScore = calculateDelayRisk(project);
        
        // Calculate cost overrun risk score
        analytics.costOverrunRiskScore = calculateCostOverrunRisk(project);
        
        // Calculate quality risk score
        analytics.qualityRiskScore = calculateQualityRisk(project);
        
        // Predict completion date using historical data and current progress
        analytics.predictedCompletionDate = predictCompletionDate(project);
        
        // Predict final cost using trend analysis
        analytics.predictedFinalCost = predictFinalCost(project);
        
        // Calculate productivity index
        analytics.productivityIndex = calculateProductivityIndex(project);
        
        // Generate recommendations based on analysis
        analytics.recommendations = generateRecommendations(analytics);
        
        analytics.persist();
        return analytics;
    }
    
    private BigDecimal calculateDelayRisk(Project project) {
        BigDecimal riskScore = BigDecimal.ZERO;
        
        // Factor 1: Schedule Performance Index
        Double spi = project.getSchedulePerformance();
        if (spi != null && spi < 1.0) {
            riskScore = riskScore.add(new BigDecimal((1.0 - spi) * 30));
        }
        
        // Factor 2: Critical activities behind schedule
        long criticalActivitiesBehind = ScheduleActivity
                .count("workPackage.project = ?1 and isCritical = true and actualStart > earlyStart", project);
        riskScore = riskScore.add(new BigDecimal(criticalActivitiesBehind * 10));
        
        // Factor 3: Weather impact (rainy season in Indonesia)
        LocalDate now = LocalDate.now();
        if (now.getMonthValue() >= 11 || now.getMonthValue() <= 3) { // Rainy season
            riskScore = riskScore.add(new BigDecimal("15"));
        }
        
        // Factor 4: Resource availability
        long shortageAlerts = Material.count("stockQuantity <= minimumStock");
        riskScore = riskScore.add(new BigDecimal(shortageAlerts * 5));
        
        return riskScore.min(new BigDecimal("100")); // Cap at 100
    }
    
    private BigDecimal calculateCostOverrunRisk(Project project) {
        BigDecimal riskScore = BigDecimal.ZERO;
        
        // Factor 1: Cost Performance Index
        Double cpi = project.getCostPerformance();
        if (cpi != null && cpi < 1.0) {
            riskScore = riskScore.add(new BigDecimal((1.0 - cpi) * 40));
        }
        
        // Factor 2: Number of approved change orders
        long changeOrders = ChangeOrder.count("project = ?1 and status = 'APPROVED'", project);
        riskScore = riskScore.add(new BigDecimal(changeOrders * 5));
        
        // Factor 3: Material price volatility
        // Check recent price changes
        long recentPriceChanges = MaterialPriceHistory
                .count("changeDate >= ?1", LocalDate.now().minusMonths(1));
        riskScore = riskScore.add(new BigDecimal(recentPriceChanges * 2));
        
        return riskScore.min(new BigDecimal("100"));
    }
    
    private BigDecimal calculateQualityRisk(Project project) {
        BigDecimal riskScore = BigDecimal.ZERO;
        
        // Factor 1: Non-conformance reports
        long openNCRs = NonConformanceReport.count("inspection.project = ?1 and status != 'CLOSED'", project);
        riskScore = riskScore.add(new BigDecimal(openNCRs * 10));
        
        // Factor 2: Failed inspections
        long failedInspections = QualityInspection
                .count("project = ?1 and result = 'FAILED'", project);
        riskScore = riskScore.add(new BigDecimal(failedInspections * 8));
        
        // Factor 3: Vendor performance issues
        long poorVendors = VendorEvaluation
                .count("project = ?1 and overallScore < 60", project);
        riskScore = riskScore.add(new BigDecimal(poorVendors * 15));
        
        return riskScore.min(new BigDecimal("100"));
    }
    
    private LocalDate predictCompletionDate(Project project) {
        if (project.endDate == null || project.progressPercentage == 0) {
            return project.endDate;
        }
        
        // Simple linear projection based on current progress
        LocalDate now = LocalDate.now();
        long elapsedDays = project.startDate.until(now).getDays();
        double progressRate = project.progressPercentage / 100.0;
        
        if (progressRate > 0) {
            long projectedTotalDays = (long) (elapsedDays / progressRate);
            return project.startDate.plusDays(projectedTotalDays);
        }
        
        return project.endDate;
    }
    
    private BigDecimal predictFinalCost(Project project) {
        if (project.estimatedBudget == null) return null;
        
        Double cpi = project.getCostPerformance();
        if (cpi != null && cpi > 0) {
            // Estimate at Completion (EAC) = BAC / CPI
            return project.estimatedBudget.divide(new BigDecimal(cpi), 2, java.math.RoundingMode.HALF_UP);
        }
        
        return project.estimatedBudget;
    }
    
    private BigDecimal calculateProductivityIndex(Project project) {
        // Calculate average productivity across all work packages
        List<LaborProductivity> productivityData = LaborProductivity
                .list("project = ?1", project);
        
        if (productivityData.isEmpty()) return new BigDecimal("100");
        
        double avgEfficiency = productivityData.stream()
                .filter(p -> p.efficiencyPercentage != null)
                .mapToDouble(p -> p.efficiencyPercentage.doubleValue())
                .average()
                .orElse(100.0);
        
        return new BigDecimal(avgEfficiency);
    }
    
    private String generateRecommendations(ProjectAnalytics analytics) {
        List<String> recommendations = new ArrayList<>();
        
        if (analytics.delayRiskScore.compareTo(new BigDecimal("70")) > 0) {
            recommendations.add("High delay risk detected. Consider adding resources to critical activities.");
        }
        
        if (analytics.costOverrunRiskScore.compareTo(new BigDecimal("60")) > 0) {
            recommendations.add("Cost overrun risk identified. Review change orders and material procurement.");
        }
        
        if (analytics.qualityRiskScore.compareTo(new BigDecimal("50")) > 0) {
            recommendations.add("Quality issues detected. Increase inspection frequency and vendor monitoring.");
        }
        
        if (analytics.productivityIndex.compareTo(new BigDecimal("80")) < 0) {
            recommendations.add("Low productivity observed. Review work methods and provide additional training.");
        }
        
        return String.join(" ", recommendations);
    }
}
