package tech.kayys.risk.dto;

import java.time.LocalDate;

public record ProjectDTO(Long id, String projectCode, String name,
        LocalDate startDate, LocalDate endDate,
        String status, String manager) {
}