package tech.kayys.project.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public class ProjectBudgetDTO {
    public Long id;
    public String category;
    public BigDecimal amount;
    public String description;
    public LocalDate startDate;
    public LocalDate expiryDate;
    public BigDecimal remainingAmount;

    // Extra fields for reporting
    public String projectCode;
    public String createdBy;
    public String updatedBy;
}