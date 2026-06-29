package tech.kayys.project.dto;

import java.time.LocalDate;

public record ResourceUtilizationPoint(LocalDate date, String resourceType, Integer inUse) {}
