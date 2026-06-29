package tech.kayys.risk.dto;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.model.CategoryAnalysis;
import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.model.RiskConcentration;
import tech.kayys.risk.model.RiskMaturityAssessment;

public class RiskPortfolioAnalysis {
    public Integer totalRisks;
    public Double averageInherentRisk;
    public Double averageResidualRisk;
    public Double mitigationEffectiveness;
    public Map<RiskCategory, CategoryAnalysis> categoryAnalysis;
    public List<RiskConcentration> concentrationRisks;
    public RiskMaturityAssessment maturityAssessment;
    
    public RiskPortfolioAnalysis(List<RiskRegister> risks) {
        this.totalRisks = risks.size();
        this.averageInherentRisk = risks.stream()
                .filter(r -> r.inherentRiskScore != null)
                .mapToInt(r -> r.inherentRiskScore)
                .average().orElse(0.0);
        this.averageResidualRisk = risks.stream()
                .filter(r -> r.residualRiskScore != null)
                .mapToInt(r -> r.residualRiskScore)
                .average().orElse(0.0);
        this.mitigationEffectiveness = calculateOverallMitigationEffectiveness(risks);
        this.categoryAnalysis = analyzeCategoriesLive(risks);
        this.concentrationRisks = identifyConcentrationRisks(risks);
        this.maturityAssessment = assessRiskMaturity(risks);
    }
    
    private Double calculateOverallMitigationEffectiveness(List<RiskRegister> risks) {
        return risks.stream()
                .filter(r -> r.inherentRiskScore != null && r.residualRiskScore != null && r.inherentRiskScore > 0)
                .mapToDouble(r -> 1.0 - (double) r.residualRiskScore / r.inherentRiskScore)
                .average().orElse(0.0) * 100;
    }
    
    private Map<RiskCategory, CategoryAnalysis> analyzeCategoriesLive(List<RiskRegister> risks) {
        return risks.stream()
                .collect(Collectors.groupingBy(
                    r -> r.category,
                    Collectors.collectingAndThen(
                        Collectors.toList(),
                        categoryRisks -> new CategoryAnalysis(categoryRisks)
                    )
                ));
    }
    
    private List<RiskConcentration> identifyConcentrationRisks(List<RiskRegister> risks) {
        // Identify areas of high risk concentration
        return risks.stream()
                .collect(Collectors.groupingBy(r -> r.category))
                .entrySet().stream()
                .filter(entry -> entry.getValue().size() > 5) // Threshold for concentration
                .map(entry -> new RiskConcentration(entry.getKey(), entry.getValue().size()))
                .collect(Collectors.toList());
    }
    
    private RiskMaturityAssessment assessRiskMaturity(List<RiskRegister> risks) {
        // Assess overall risk management maturity based on various factors
        int documentationScore = assessDocumentationMaturity(risks);
        int mitigationScore = assessMitigationMaturity(risks);
        int monitoringScore = assessMonitoringMaturity(risks);
        
        return new RiskMaturityAssessment(documentationScore, mitigationScore, monitoringScore);
    }
    
    private int assessDocumentationMaturity(List<RiskRegister> risks) {
        // Score based on completeness of risk documentation
        return (int) (risks.stream()
                .mapToDouble(r -> {
                    int score = 0;
                    if (r.description != null && !r.description.isEmpty()) score += 25;
                    if (r.mitigationStrategy != null && !r.mitigationStrategy.isEmpty()) score += 25;
                    if (r.contingencyPlan != null && !r.contingencyPlan.isEmpty()) score += 25;
                    if (r.owner != null) score += 25;
                    return score;
                })
                .average().orElse(0.0));
    }
    
    private int assessMitigationMaturity(List<RiskRegister> risks) {
        // Score based on mitigation action completeness and effectiveness
        return (int) (risks.stream()
                .filter(r -> r.mitigationActions != null && !r.mitigationActions.isEmpty())
                .count() * 100.0 / risks.size());
    }
    
    private int assessMonitoringMaturity(List<RiskRegister> risks) {
        // Score based on KRI implementation and monitoring
        return (int) (risks.stream()
                .filter(r -> r.keyRiskIndicators != null && !r.keyRiskIndicators.isEmpty())
                .count() * 100.0 / risks.size());
    }
}
