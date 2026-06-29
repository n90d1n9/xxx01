package tech.kayys.ai.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import io.quarkus.scheduler.Scheduled;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import tech.kayys.ai.domain.AIRecommendation;
import tech.kayys.construction.domain.Material;
import tech.kayys.finance.domain.BoqItem;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ScheduleActivity;
import tech.kayys.vendor.domain.Vendor;
import tech.kayys.vendor.domain.VendorEvaluation;

@ApplicationScoped
public class AIRecommendationEngine {
    
    @Scheduled(cron = "0 0 6 * * ?") // Run daily at 6 AM
    @Transactional
    public void generateDailyRecommendations() {
        List<Project> activeProjects = Project.list("status.statusType IN ('INITIAL', 'IN_PROGRESS')");
        
        for (Project project : activeProjects) {
            generateVendorRecommendations(project);
            generateMaterialAlternatives(project);
            generateScheduleOptimizations(project);
            generateCostReductions(project);
        }
    }
    
    private void generateVendorRecommendations(Project project) {
        // Recommend vendors based on performance history
        List<VendorEvaluation> topVendors = VendorEvaluation
                .list("overallScore >= 80 ORDER BY overallScore DESC");
        
        // Get current project's material needs
        List<Material> lowStockMaterials = Material
                .list("stockQuantity <= reorderPoint and isActive = true");
        
        for (Material material : lowStockMaterials) {
            // Find vendors who have supplied this material category before
            List<Vendor> suitableVendors = Vendor
                    .list("category = 'MATERIAL_SUPPLIER' and status = 'ACTIVE'");
            
            if (!suitableVendors.isEmpty()) {
                Vendor recommendedVendor = suitableVendors.get(0); // Simplified selection
                
                AIRecommendation recommendation = new AIRecommendation();
                recommendation.project = project;
                recommendation.recommendationDate = LocalDateTime.now();
                recommendation.recommendationType = AIRecommendation.RecommendationType.VENDOR_RECOMMENDATION;
                recommendation.title = "Vendor Recommendation for " + material.name;
                recommendation.description = String.format(
                        "Recommend vendor %s for material %s based on performance history and availability",
                        recommendedVendor.companyName, material.name);
                recommendation.confidenceScore = new BigDecimal("85");
                recommendation.potentialImpact = "Ensure timely delivery and quality materials";
                recommendation.implementationEffort = AIRecommendation.ImplementationEffort.LOW;
                recommendation.persist();
            }
        }
    }
    
    private void generateMaterialAlternatives(Project project) {
        // Recommend material alternatives for cost optimization
        List<Material> expensiveMaterials = Material
                .list("unitPrice > (SELECT AVG(unitPrice) * 1.5 FROM Material WHERE category = ?1) and isActive = true");
        
        for (Material material : expensiveMaterials) {
            List<Material> alternatives = Material
                    .list("category = ?1 and unitPrice < ?2 and id != ?3 and isActive = true ORDER BY unitPrice",
                            material.category, material.unitPrice, material.id);
            
            if (!alternatives.isEmpty()) {
                Material alternative = alternatives.get(0);
                BigDecimal savings = material.unitPrice.subtract(alternative.unitPrice);
                BigDecimal savingsPercent = savings.divide(material.unitPrice, 4, java.math.RoundingMode.HALF_UP)
                        .multiply(new BigDecimal("100"));
                
                AIRecommendation recommendation = new AIRecommendation();
                recommendation.project = project;
                recommendation.recommendationDate = LocalDateTime.now();
                recommendation.recommendationType = AIRecommendation.RecommendationType.MATERIAL_ALTERNATIVE;
                recommendation.title = "Cost-effective Alternative for " + material.name;
                recommendation.description = String.format(
                        "Consider using %s instead of %s. Potential savings: %.1f%% (Rp %,.0f per unit)",
                        alternative.name, material.name, savingsPercent.doubleValue(), savings);
                recommendation.confidenceScore = new BigDecimal("75");
                recommendation.potentialImpact = String.format("Cost savings of Rp %,.0f per unit", savings);
                recommendation.implementationEffort = AIRecommendation.ImplementationEffort.MEDIUM;
                recommendation.persist();
            }
        }
    }
    
    private void generateScheduleOptimizations(Project project) {
        // Analyze schedule for optimization opportunities
        List<ScheduleActivity> criticalActivities = ScheduleActivity
                .list("schedule.project = ?1 and isCritical = true and totalFloat = 0", project);
        
        List<ScheduleActivity> nonCriticalActivities = ScheduleActivity
                .list("schedule.project = ?1 and isCritical = false and totalFloat > 7", project);
        
        if (!criticalActivities.isEmpty() && !nonCriticalActivities.isEmpty()) {
            AIRecommendation recommendation = new AIRecommendation();
            recommendation.project = project;
            recommendation.recommendationDate = LocalDateTime.now();
            recommendation.recommendationType = AIRecommendation.RecommendationType.SCHEDULE_OPTIMIZATION;
            recommendation.title = "Resource Reallocation Opportunity";
            recommendation.description = String.format(
                    "Consider reallocating resources from %d non-critical activities to %d critical activities",
                    nonCriticalActivities.size(), criticalActivities.size());
            recommendation.confidenceScore = new BigDecimal("80");
            recommendation.potentialImpact = "Reduce project duration and delay risk";
            recommendation.implementationEffort = AIRecommendation.ImplementationEffort.HIGH;
            recommendation.persist();
        }
    }
    
    private void generateCostReductions(Project project) {
        // Analyze cost patterns for reduction opportunities
        Double cpi = project.getCostPerformance();
        if (cpi != null && cpi < 0.9) { // CPI below 0.9 indicates cost overrun
            
            // Find highest cost categories
            List<Object[]> costByCategory = BoqItem.find(
                    "SELECT b.workCategory.name, SUM(b.totalPrice) as total " +
                    "FROM BoqItem b WHERE b.project = ?1 and b.isActive = true " +
                    "GROUP BY b.workCategory.name ORDER BY total DESC",
                    project
            ).project(Object[].class).list();
            
            if (!costByCategory.isEmpty()) {
                Object[] highestCost = costByCategory.get(0);
                String category = (String) highestCost[0];
                BigDecimal amount = (BigDecimal) highestCost[1];
                
                AIRecommendation recommendation = new AIRecommendation();
                recommendation.project = project;
                recommendation.recommendationDate = LocalDateTime.now();
                recommendation.recommendationType = AIRecommendation.RecommendationType.COST_REDUCTION;
                recommendation.title = "Cost Reduction Focus Area: " + category;
                recommendation.description = String.format(
                        "Focus cost reduction efforts on %s category (Rp %,.0f, %.1f%% of budget). " +
                        "Current CPI: %.2f indicates cost overrun.",
                        category, amount, 
                        amount.divide(project.estimatedBudget, 4, java.math.RoundingMode.HALF_UP).multiply(new BigDecimal("100")).doubleValue(),
                        cpi);
                recommendation.confidenceScore = new BigDecimal("85");
                recommendation.potentialImpact = "Improve cost performance index and reduce budget variance";
                recommendation.implementationEffort = AIRecommendation.ImplementationEffort.MEDIUM;
                recommendation.persist();
            }
        }
    }
}
