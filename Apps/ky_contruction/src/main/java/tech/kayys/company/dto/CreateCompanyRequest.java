package tech.kayys.company.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.company.model.CompanyType;

public class CreateCompanyRequest {
    @NotBlank public String npwp;
    @NotBlank public String name;
    @NotBlank public String address;
    @NotNull public CompanyType type;
    @NotNull public LocalDate establishedDate;
    @NotNull public BigDecimal authorizedCapital;
    @NotNull public BigDecimal paidUpCapital;
    public String siup;
    public String tdp;
}
