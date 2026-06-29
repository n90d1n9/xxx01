package tech.kayys.project.dto;

import java.util.List;

public record RiskTrendDTO(Long projectId, List<RiskTrendPoint> points, int openRisksNow, int highRisksNow) {}

