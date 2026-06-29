package tech.kayys.ai.service;

import java.util.List;

import io.quarkus.scheduler.Scheduled;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.CascadeType;
import jakarta.persistence.OneToMany;
import jakarta.transaction.Transactional;
import tech.kayys.project.domain.Project;

@ApplicationScoped
public class AnomalyDetectionService {
    
    @Scheduled(cron = "0 0 2 * * ?") // Run daily at 2 AM
    @Transactional
    public void runDailyAnomalyDetection() {
        List<Project> activeProjects = Project.list("status.statusType IN ('INITIAL', 'IN_PROGRESS')");
        
        for (Project project : activeProjects) {
            detectCostAnomalies(project);
            detectScheduleAnomalies(project);
            detectProductivityAnomalies(project);
            detectInvoiceAnomalies(project);
        }
    }
    
    private void detectCostAnomalies(Project project) {
        // Detect unusual cost spikes
        LocalDate cutoffDate = LocalDate.now().minusWeeks(1);
        
        List<MaterialTransaction> recentTransactions = MaterialTransaction
                .list("project = ?1 and transactionDate >= ?2", project, cutoffDate.atStartOfDay());
        
        // Calculate average weekly cost
        BigDecimal weeklyAverage = calculateAverageWeeklyCost(project);
        
        BigDecimal currentWeekCost = recentTransactions.stream()
                .map(t -> t.totalCost != null ? t.totalCost : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        if (weeklyAverage.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal costRatio = currentWeekCost.divide(weeklyAverage, 2, java.math.RoundingMode.HALF_UP);
            
            if (costRatio.compareTo(new BigDecimal("2.0")) > 0) { // 100% increase
                createAnomaly(project, AnomalyDetection.AnomalyType.COST_ANOMALY,
                        costRatio.multiply(new BigDecimal("50")),
                        String.format("Weekly cost %.0f%% above average", 
                                (costRatio.doubleValue() -     
                                
    
    
    @OneToMany(mappedBy = "commitment", cascade = CascadeType.ALL)
    public List<CommitmentPayment> payments;
    
    public enum CommitmentType {
        PURCHASE_ORDER("Purchase Order"),
        SUBCONTRACT("Subcontract"),
        SERVICE_AGREEMENT("Service Agreement"),
        RENTAL_AGREEMENT("Rental Agreement"),
        CONSULTING_AGREEMENT("Consulting Agreement");
        
        private final String label;
        CommitmentType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum CommitmentStatus {
        DRAFT("Draft"),
        ISSUED("Issued"),
        ACKNOWLEDGED("Acknowledged"),
        IN_PROGRESS("In Progress"),
        COMPLETED("Completed"),
        CANCELLED("Cancelled");
        
        private final String label;
        CommitmentStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
