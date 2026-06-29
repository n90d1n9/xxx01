package tech.kayys.invoice.domain;

@Entity
@Table(name = "payrolls")
public class Payroll extends PanacheEntity {
    @NotBlank
    public String employeeId;
    
    @NotBlank
    public String employeeName;
    
    @NotBlank
    public String nik; // Nomor Induk Kependudukan
    
    @NotBlank
    public String npwp; // Employee NPWP
    
    @NotNull
    public Integer payrollYear;
    
    @NotNull
    public Integer payrollMonth;
    
    @NotNull
    public BigDecimal basicSalary;
    
    @NotNull
    public BigDecimal allowances = BigDecimal.ZERO;
    
    @NotNull
    public BigDecimal overtime = BigDecimal.ZERO;
    
    @NotNull
    public BigDecimal grossSalary;
    
    @NotNull
    public BigDecimal bpjsTk = BigDecimal.ZERO; // BPJS Tenaga Kerja
    
    @NotNull
    public BigDecimal bpjsKes = BigDecimal.ZERO; // BPJS Kesehatan
    
    @NotNull
    public BigDecimal pph21 = BigDecimal.ZERO;
    
    @NotNull
    public BigDecimal totalDeductions;
    
    @NotNull
    public BigDecimal netSalary;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
    
    @Enumerated(EnumType.STRING)
    public PayrollStatus status = PayrollStatus.DRAFT;
    
    @Enumerated(EnumType.STRING)
    public MaritalStatus maritalStatus = MaritalStatus.SINGLE;
    
    @NotNull
    public Integer dependents = 0;
    
    public LocalDate processedDate;
}
