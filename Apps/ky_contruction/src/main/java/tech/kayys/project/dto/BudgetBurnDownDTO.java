package tech.kayys.project.dto;

import java.math.BigDecimal;
import java.util.List;

public record BudgetBurnDownDTO(Long projectId, List<BudgetBurnDownPoint> points, BigDecimal plannedTotal, BigDecimal actualTotal) {}

