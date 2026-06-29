package tech.kayys.risk.dto;

import java.util.Map;

public record ReportDTO(String reportType, Map<String, Object> data) {}
