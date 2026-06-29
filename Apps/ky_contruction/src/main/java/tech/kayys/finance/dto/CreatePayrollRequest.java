package tech.kayys.finance.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.profile.model.MaritalStatus;

public class CreatePayrollRequest {
    @NotNull public Long companyId;
    @NotBlank public String employeeId;
    @NotBlank public String employeeName;
    @NotBlank public String nik;
    @NotBlank public String npwp;
    @NotNull public Integer payrollYear;
    @NotNull public Integer payrollMonth;
    @NotNull public BigDecimal basicSalary;
    @NotNull public BigDecimal allowances;
    @NotNull public BigDecimal overtime;
    @NotNull public MaritalStatus maritalStatus;
    @NotNull public Integer dependents;
}
