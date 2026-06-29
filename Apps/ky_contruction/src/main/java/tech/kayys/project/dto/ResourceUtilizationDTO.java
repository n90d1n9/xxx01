package tech.kayys.project.dto;

import java.util.List;
import java.util.Map;

public record ResourceUtilizationDTO(Long projectId, Map<String, Object> summary, List<ResourceUtilizationPoint> points) {}

