package tech.kayys.risk.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;


public class RiskAppetiteReport {
    public String reportId;
    public String reportTitle;
    public DateRange reportingPeriod;

    
    public LocalDateTime generatedDate;
    public String generatedBy;
    
    // Overall Status
    public RiskAppetiteStatus overallStatus;
    public String executiveSummary;
    public Double overallUtilization;
    public String statusReason;
    
    // Breaches and Violations
    public List<RiskAppetiteBreach> riskAppetiteBreaches;
    public Integer totalBreaches;
    public Integer criticalBreaches;
    public Integer resolvedBreaches;
    public Double breachRate;
    
    // Category Analysis
    public Map<RiskCategory, CategoryRiskAppetite> categoryAnalysis;
    public List<RiskCategory> categoriesExceedingAppetite;
    public List<RiskCategory> categoriesNearLimit;
    
    // Trend Analysis
    public RiskAppetiteTrend trendAnalysis;
    public List<RiskAppetiteHistoricalData> historicalData;
    public String forecastAnalysis;
    
    // Recommendations
    public List<RiskAppetiteRecommendation> recommendations;
    public List<RiskAppetiteAction> immediateActions;
    public List<RiskAppetiteAction> strategicActions;
    
    // Metrics and KPIs
    public RiskAppetiteMetrics metrics;
    public Map<String, Object> kpiData;
    
    // Compliance and Governance
    public List<RiskAppetiteException> approvedExceptions;
    public List<RiskAppetiteViolation> policyViolations;
    public String boardApprovalStatus;
    
    public RiskAppetiteReport() {
        this.reportId = "RAR-" + System.currentTimeMillis();
        this.reportTitle = "Risk Appetite Report";
        this.generatedDate = LocalDateTime.now();
        this.riskAppetiteBreaches = new ArrayList<>();
        this.categoryAnalysis = new HashMap<>();
        this.categoriesExceedingAppetite = new ArrayList<>();
        this.categoriesNearLimit = new ArrayList<>();
        this.recommendations = new ArrayList<>();
        this.immediateActions = new ArrayList<>();
        this.strategicActions = new ArrayList<>();
        this.historicalData = new ArrayList<>();
        this.approvedExceptions = new ArrayList<>();
        this.policyViolations = new ArrayList<>();
        this.kpiData = new HashMap<>();
    }
    
    // Enums and Inner Classes
    public enum RiskAppetiteStatus {
        WITHIN_APPETITE("Within Risk Appetite", "#28a745"),
        APPROACHING_LIMITS("Approaching Risk Appetite Limits", "#ffc107"),
        EXCEEDING_APPETITE("Exceeding Risk Appetite", "#fd7e14"),
        SIGNIFICANTLY_OVER("Significantly Over Risk Appetite", "#dc3545"),
        POLICY_VIOLATION("Risk Appetite Policy Violation", "#6f42c1");
        
        private final String label;
        private final String color;
        
        RiskAppetiteStatus(String label, String color) {
            this.label = label;
            this.color = color;
        }
        
        public String getLabel() { return label; }
        public String getColor() { return color; }
    }
    
    public static class RiskAppetiteBreach {
        public String breachId;
        public Long riskId;
        public String riskTitle;
        public RiskCategory category;
        public Integer currentRiskScore;
        public Integer appetiteThreshold;
        public Integer breachAmount;
        public Double breachPercentage;
        public LocalDate breachDate;
        public LocalDate firstBreachDate;
        public Integer breachDurationDays;
        public BreachSeverity severity;
        public BreachStatus status;
        public String businessJustification;
        public LocalDate expectedResolutionDate;
        public List<String> mitigationActions;
        public String escalationLevel;
        public String approvedBy;
        public String comments;
        
        public RiskAppetiteBreach() {
            this.breachId = "BRH-" + UUID.randomUUID().toString().substring(0, 8);
            this.mitigationActions = new ArrayList<>();
            this.status = BreachStatus.OPEN;
        }
        
        public enum BreachSeverity {
            MINOR("Minor", "up to 20% over appetite", 1),
            MODERATE("Moderate", "21-50% over appetite", 2),
            MAJOR("Major", "51-100% over appetite", 3),
            CRITICAL("Critical", "over 100% over appetite", 4),
            EXTREME("Extreme", "over 200% over appetite", 5);
            
            private final String label;
            private final String description;
            private final int severityLevel;
            
            BreachSeverity(String label, String description, int severityLevel) {
                this.label = label;
                this.description = description;
                this.severityLevel = severityLevel;
            }
            
            public String getLabel() { return label; }
            public String getDescription() { return description; }
            public int getSeverityLevel() { return severityLevel; }
        }
        
        public enum BreachStatus {
            OPEN("Open"),
            ACKNOWLEDGED("Acknowledged"),
            UNDER_REVIEW("Under Review"),
            APPROVED_EXCEPTION("Approved Exception"),
            MITIGATED("Mitigated"),
            RESOLVED("Resolved");
            
            private final String label;
            BreachStatus(String label) { this.label = label; }
            public String getLabel() { return label; }
        }
        
        public void calculateSeverityAndDuration() {
            // Calculate severity based on breach percentage
            if (breachPercentage != null) {
                if (breachPercentage > 200) severity = BreachSeverity.EXTREME;
                else if (breachPercentage > 100) severity = BreachSeverity.CRITICAL;
                else if (breachPercentage > 50) severity = BreachSeverity.MAJOR;
                else if (breachPercentage > 20) severity = BreachSeverity.MODERATE;
                else severity = BreachSeverity.MINOR;
            }
            
            // Calculate duration
            if (firstBreachDate != null) {
                breachDurationDays = (int) ChronoUnit.DAYS.between(firstBreachDate, LocalDate.now());
            }
        }
    }

    // Add DateRange class if not already defined elsewhere
    public static class DateRange {
        public LocalDate startDate;
        public LocalDate endDate;

        public DateRange() {}

        public DateRange(LocalDate startDate, LocalDate endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
    
    public static class CategoryRiskAppetite {
        public RiskCategory category;
        public String categoryName;
        public Integer appetiteThreshold;
        public Integer currentAverageRisk;
        public Integer currentMaxRisk;
        public Integer riskCount;
        public Integer breachCount;
        public Double utilizationPercentage;
        public AppetiteStatus status;
        public String statusDescription;
        public String recommendation;
        public List<String> topRisks;
        public List<String> breachedRisks;
        public TrendDirection trendDirection;
        public Double monthlyChange;
        
        public CategoryRiskAppetite() {
            this.topRisks = new ArrayList<>();
            this.breachedRisks = new ArrayList<>();
        }
        
        public enum AppetiteStatus {
            WELL_WITHIN("Well Within Appetite", "#28a745", 0.5),
            APPROACHING("Approaching Appetite", "#ffc107", 0.8),
            AT_APPETITE("At Appetite", "#fd7e14", 1.0),
            EXCEEDING("Exceeding Appetite", "#dc3545", 1.2),
            SIGNIFICANTLY_OVER("Significantly Over", "#6f42c1", Double.MAX_VALUE);
            
            private final String label;
            private final String color;
            private final double threshold;
            
            AppetiteStatus(String label, String color, double threshold) {
                this.label = label;
                this.color = color;
                this.threshold = threshold;
            }
            
            public String getLabel() { return label; }
            public String getColor() { return color; }
            public double getThreshold() { return threshold; }
        }
        
        public enum TrendDirection {
            IMPROVING("Improving", "↓"),
            STABLE("Stable", "→"),
            DETERIORATING("Deteriorating", "↑"),
            VOLATILE("Volatile", "↕");
            
            private final String description;
            private final String symbol;
            
            TrendDirection(String description, String symbol) {
                this.description = description;
                this.symbol = symbol;
            }
            
            public String getDescription() { return description; }
            public String getSymbol() { return symbol; }
        }
        
        public void calculateStatusAndTrend() {
            if (utilizationPercentage != null) {
                for (AppetiteStatus statusOption : AppetiteStatus.values()) {
                    if (utilizationPercentage <= statusOption.threshold * 100) {
                        status = statusOption;
                        break;
                    }
                }
                if (status == null) status = AppetiteStatus.SIGNIFICANTLY_OVER;
            }
            
            if (monthlyChange != null) {
                if (Math.abs(monthlyChange) < 2) trendDirection = TrendDirection.STABLE;
                else if (monthlyChange < -2) trendDirection = TrendDirection.IMPROVING;
                else if (monthlyChange > 10) trendDirection = TrendDirection.VOLATILE;
                else trendDirection = TrendDirection.DETERIORATING;
            }
        }
    }
    
    public static class RiskAppetiteTrend {
        public List<MonthlyAppetiteData> monthlyData;
        public TrendDirection overallDirection;
        public String trendAnalysis;
        public Double volatilityIndex;
        public String forecast;
        public Double correlationWithMarket;
        public List<String> trendDrivers;
        
        public RiskAppetiteTrend() {
            this.monthlyData = new ArrayList<>();
            this.trendDrivers = new ArrayList<>();
        }
        
        public enum TrendDirection {
            STRONGLY_IMPROVING("Strongly Improving"),
            IMPROVING("Improving"),
            STABLE("Stable"),
            DETERIORATING("Deteriorating"),
            STRONGLY_DETERIORATING("Strongly Deteriorating");
            
            private final String description;
            TrendDirection(String description) { this.description = description; }
            public String getDescription() { return description; }
        }
        
        public static class MonthlyAppetiteData {
            public String month;
            public Integer year;
            public Integer totalBreaches;
            public Double averageUtilization;
            public Integer newBreaches;
            public Integer resolvedBreaches;
            public Double riskScore;
            public Integer riskCount;
            public Double utilizationChange;
            public String significantEvents;
        }
    }
    
    public static class RiskAppetiteRecommendation {
        public String recommendationId;
        public String title;
        public String recommendation;
        public RiskCategory affectedCategory;
        public RecommendationType type;
        public RecommendationPriority priority;
        public String rationale;
        public String expectedImpact;
        public LocalDate suggestedImplementation;
        public String responsibleParty;
        public BigDecimal estimatedCost;
        public String successMetrics;
        public List<String> dependencies;
        public String riskIfNotImplemented;
        
        public RiskAppetiteRecommendation() {
            this.recommendationId = "REC-" + UUID.randomUUID().toString().substring(0, 8);
            this.dependencies = new ArrayList<>();
        }
        
        public enum RecommendationType {
            POLICY_CHANGE("Risk Policy Change"),
            APPETITE_ADJUSTMENT("Risk Appetite Adjustment"),
            CONTROL_ENHANCEMENT("Control Enhancement"),
            RESOURCE_ALLOCATION("Resource Allocation"),
            PROCESS_IMPROVEMENT("Process Improvement"),
            SYSTEM_UPGRADE("System Upgrade"),
            TRAINING("Training and Awareness"),
            GOVERNANCE("Governance Enhancement");
            
            private final String label;
            RecommendationType(String label) { this.label = label; }
            public String getLabel() { return label; }
        }
        
        public enum RecommendationPriority {
            IMMEDIATE("Immediate Action Required", 1),
            HIGH("High Priority", 2),
            MEDIUM("Medium Priority", 3),
            LOW("Low Priority", 4),
            STRATEGIC("Strategic Initiative", 5);
            
            private final String label;
            private final int priorityLevel;
            
            RecommendationPriority(String label, int priorityLevel) {
                this.label = label;
                this.priorityLevel = priorityLevel;
            }
            
            public String getLabel() { return label; }
            public int getPriorityLevel() { return priorityLevel; }
        }
    }
    
    public static class RiskAppetiteMetrics {
        public Integer totalRisksMonitored;
        public Integer risksWithinAppetite;
        public Integer risksExceedingAppetite;
        public Double overallUtilization;
        public Integer daysWithBreaches;
        public BigDecimal totalExposure;
        public BigDecimal appetiteLimit;
        public Double riskVelocity; // Rate of risk level change
        public Integer criticalBreaches;
        public Double averageTimeToResolve;
        public Double breachFrequency;
        public Double controlEffectiveness;
        public String benchmarkComparison;
        
        public Double getComplianceRate() {
            if (totalRisksMonitored == null || totalRisksMonitored == 0) return 100.0;
            return (risksWithinAppetite.doubleValue() / totalRisksMonitored) * 100;
        }
        
        public String getRiskVelocityTrend() {
            if (riskVelocity == null) return "STABLE";
            if (riskVelocity > 0.1) return "ACCELERATING";
            if (riskVelocity < -0.1) return "DECELERATING";
            return "STABLE";
        }
    }
    
    // Additional supporting classes
    public static class RiskAppetiteHistoricalData {
        public LocalDate date;
        public Double utilizationRate;
        public Integer breachCount;
        public String significantEvents;
    }
    
    public static class RiskAppetiteAction {
        public String actionId;
        public String description;
        public String assignedTo;
        public LocalDate dueDate;
        public String priority;
        public String status;
    }
    
    public static class RiskAppetiteException {
        public String exceptionId;
        public String description;
        public String approvedBy;
        public LocalDate approvalDate;
        public LocalDate expiryDate;
    }
    
    public static class RiskAppetiteViolation {
        public String violationId;
        public String description;
        public String severity;
        public LocalDate identifiedDate;
        public String status;
    }
}
