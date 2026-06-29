package tech.kayys.project.dto;

import java.time.LocalDate;

public record RiskTrendPoint(LocalDate date, int openRisks, int highRisks) {}