package tech.kayys.risk.dto;

import java.util.Map;

import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.model.RiskStatus;

public class RiskSummaryDTO {
    public Long totalRisks;
    public Long highRisks;
    public Long mediumRisks;
    public Long lowRisks;
    public Map<RiskCategory, Long> risksByCategory;
    public Map<RiskStatus, Long> risksByStatus;
    public Double averageRiskScore;
}