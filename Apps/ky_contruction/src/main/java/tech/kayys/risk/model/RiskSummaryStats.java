package tech.kayys.risk.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;


public class RiskSummaryStats {
    public Integer totalRisks;
    public Integer activeRisks;
    public Integer closedRisks;
    public Double averageRiskScore;
    public Double averageInherentRiskScore;
    public Double averageResidualRiskScore;
    
    // Risk Level Distribution
    public Integer criticalRisks;
    public Integer highRisks;
    public Integer mediumRisks;
    public Integer lowRisks;
    public Integer veryLowRisks;
    
    // Action Items Statistics
    public Integer totalActions;
    public Integer overdueActions;
    public Integer completedActions;
    public Integer pendingActions;
    public Integer reviewsDue;
    
    // Trend Analysis
    public Integer newRisksThisMonth;
    public Integer closedRisksThisMonth;
    public Integer escalatedRisks;
    public Double riskTrend; // Percentage change from previous period
    public String trendDirection; // INCREASING, DECREASING, STABLE
    
    // Category Breakdown
    public Map<RiskCategory, Integer> risksByCategory;
    public Map<RiskStatus, Integer> risksByStatus;
    public Map<String, Integer> risksByOwner;
    public Map<String, Integer> risksByProject;
    
    // Financial Impact
    public BigDecimal totalFinancialImpact;
    public BigDecimal averageFinancialImpact;
    public BigDecimal highestFinancialImpact;
    
    // Risk Management Effectiveness
    public Double mitigationEffectiveness;
    public Double controlEffectiveness;
    public Double riskReductionPercentage;
    
    // Time-based Analysis
    public Double averageTimeToResolve; // Days
    public Double averageTimeToEscalate; // Days
    public Integer overdueDays; // Total overdue days across all risks
    
    // Compliance Statistics
    public Integer complianceRisks;
    public Integer regulatoryBreaches;
    public Map<RegulatoryRequirement, Integer> risksByRegulation;
    
    // Metadata
    public LocalDateTime lastUpdated;
    public LocalDateTime calculationTime;
    public String calculatedBy;
    public String reportingPeriod;
    
    public RiskSummaryStats() {
        this.risksByCategory = new HashMap<>();
        this.risksByStatus = new HashMap<>();
        this.risksByOwner = new HashMap<>();
        this.risksByProject = new HashMap<>();
        this.risksByRegulation = new HashMap<>();
        this.lastUpdated = LocalDateTime.now();
        this.totalFinancialImpact = BigDecimal.ZERO;
        this.averageFinancialImpact = BigDecimal.ZERO;
        this.highestFinancialImpact = BigDecimal.ZERO;
    }
    
    // Calculated Properties
    public Integer getTotalActiveRisks() {
        return totalRisks - (closedRisks != null ? closedRisks : 0);
    }
    
    public Double getCriticalRiskPercentage() {
        if (totalRisks == null || totalRisks == 0) return 0.0;
        return (criticalRisks != null ? criticalRisks.doubleValue() : 0.0) / totalRisks * 100;
    }
    
    public Double getHighRiskPercentage() {
        if (totalRisks == null || totalRisks == 0) return 0.0;
        return (highRisks != null ? highRisks.doubleValue() : 0.0) / totalRisks * 100;
    }
    
    public Double getActionCompletionRate() {
        if (totalActions == null || totalActions == 0) return 100.0;
        return (completedActions != null ? completedActions.doubleValue() : 0.0) / totalActions * 100;
    }
    
    public String getRiskTrendDirection() {
        if (riskTrend == null) return "NO_DATA";
        if (riskTrend > 5) return "INCREASING";
        if (riskTrend < -5) return "DECREASING";
        return "STABLE";
    }
    
    public String getOverallRiskHealth() {
        double criticalPercentage = getCriticalRiskPercentage();
        double completionRate = getActionCompletionRate();
        
        if (criticalPercentage > 20 || completionRate < 70) return "POOR";
        if (criticalPercentage > 10 || completionRate < 85) return "FAIR";
        if (criticalPercentage > 5 || completionRate < 95) return "GOOD";
        return "EXCELLENT";
    }
    
    // Builder Pattern for Easy Construction
    public static class Builder {
        private RiskSummaryStats stats = new RiskSummaryStats();
        
        public Builder totalRisks(Integer total) { stats.totalRisks = total; return this; }
        public Builder activeRisks(Integer active) { stats.activeRisks = active; return this; }
        public Builder averageRiskScore(Double avg) { stats.averageRiskScore = avg; return this; }
        public Builder criticalRisks(Integer critical) { stats.criticalRisks = critical; return this; }
        public Builder highRisks(Integer high) { stats.highRisks = high; return this; }
        public Builder overdueActions(Integer overdue) { stats.overdueActions = overdue; return this; }
        public Builder riskTrend(Double trend) { stats.riskTrend = trend; return this; }
        public Builder financialImpact(BigDecimal impact) { stats.totalFinancialImpact = impact; return this; }
        public Builder calculatedBy(String by) { stats.calculatedBy = by; return this; }
        
        public RiskSummaryStats build() {
            stats.calculationTime = LocalDateTime.now();
            return stats;
        }
    }
}