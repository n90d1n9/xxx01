package tech.kayys.risk.dto;

import java.time.LocalDate;

public class RiskTrendData {
    public LocalDate date;
    public Double averageScore;
    public Integer riskCount;
    
    public RiskTrendData(LocalDate date, Double averageScore, Integer riskCount) {
        this.date = date;
        this.averageScore = averageScore;
        this.riskCount = riskCount;
    }
}
