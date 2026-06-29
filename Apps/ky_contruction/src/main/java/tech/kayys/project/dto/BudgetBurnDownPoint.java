package tech.kayys.project.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record BudgetBurnDownPoint(LocalDate date, BigDecimal planned, BigDecimal actual) {}