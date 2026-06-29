package tech.kayys.project.dto;

public record ProjectHealthDTO(Long projectId, double budgetScore, double scheduleScore, double riskScore, double overallScore) {}

