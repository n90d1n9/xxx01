package tech.kayys.tax.dto;


public class PPh21Request {
    @NotNull public Long companyId;
    @NotNull public Integer year;
    @NotNull public Integer month;
    @NotNull public BigDecimal grossSalary;
}
