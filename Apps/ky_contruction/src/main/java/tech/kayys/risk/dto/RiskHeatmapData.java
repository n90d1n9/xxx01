package tech.kayys.risk.dto;

import java.time.LocalDate;
import java.util.Map;

public class RiskHeatmapData {
    public Map<RiskCoordinate, Integer> data;
    public LocalDate generatedDate = LocalDate.now();
}