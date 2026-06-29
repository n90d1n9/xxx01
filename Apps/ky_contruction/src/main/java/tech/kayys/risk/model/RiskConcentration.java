package tech.kayys.risk.model;

public class RiskConcentration {
    public RiskCategory category;
    public Integer riskCount;
    
    public RiskConcentration(RiskCategory category, Integer riskCount) {
        this.category = category;
        this.riskCount = riskCount;
    }
}