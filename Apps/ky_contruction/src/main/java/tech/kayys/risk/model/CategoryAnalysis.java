package tech.kayys.risk.model;

import java.util.Comparator;
import java.util.List;

import tech.kayys.risk.domain.RiskRegister;

public class CategoryAnalysis {
    public Integer riskCount;
    public Double averageScore;
    public RiskLevel highestLevel;
    
    public CategoryAnalysis(List<RiskRegister> risks) {
        this.riskCount = risks.size();
        this.averageScore = risks.stream()
                .filter(r -> r.residualRiskScore != null)
                .mapToInt(r -> r.residualRiskScore)
                .average().orElse(0.0);
        this.highestLevel = risks.stream()
                .map(RiskRegister::getRiskLevel)
                .max(Comparator.comparingInt(Enum::ordinal))
                .orElse(RiskLevel.VERY_LOW);
    }
}

