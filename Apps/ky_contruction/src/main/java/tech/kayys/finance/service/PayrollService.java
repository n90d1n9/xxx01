package tech.kayys.finance.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import tech.kayys.company.domain.Company;
import tech.kayys.finance.dto.CreatePayrollRequest;
import tech.kayys.finance.model.PayrollStatus;
import tech.kayys.invoice.domain.Payroll;
import tech.kayys.profile.model.MaritalStatus;
import tech.kayys.tax.service.TaxService;

@ApplicationScoped
public class PayrollService {
    
    @Inject
    PayrollRepository payrollRepo;
    
    @Inject
    TaxService taxService;
    
    @Transactional
    public Payroll processPayroll(CreatePayrollRequest request) {
        Payroll payroll = new Payroll();
        payroll.employeeId = request.employeeId;
        payroll.employeeName = request.employeeName;
        payroll.nik = request.nik;
        payroll.npwp = request.npwp;
        payroll.payrollYear = request.payrollYear;
        payroll.payrollMonth = request.payrollMonth;
        payroll.basicSalary = request.basicSalary;
        payroll.allowances = request.allowances;
        payroll.overtime = request.overtime;
        payroll.company = Company.findById(request.companyId);
        payroll.maritalStatus = request.maritalStatus;
        payroll.dependents = request.dependents;
        
        // Calculate gross salary
        payroll.grossSalary = payroll.basicSalary.add(payroll.allowances).add(payroll.overtime);
        
        // Calculate BPJS contributions
        payroll.bpjsTk = calculateBpjsTk(payroll.grossSalary);
        payroll.bpjsKes = calculateBpjsKes(payroll.grossSalary);
        
        // Calculate PPh 21
        payroll.pph21 = calculatePph21(payroll.grossSalary, payroll.maritalStatus, payroll.dependents);
        
        // Calculate total deductions and net salary
        payroll.totalDeductions = payroll.bpjsTk.add(payroll.bpjsKes).add(payroll.pph21);
        payroll.netSalary = payroll.grossSalary.subtract(payroll.totalDeductions);
        
        payroll.processedDate = LocalDate.now();
        payroll.status = PayrollStatus.PROCESSED;
        
        payrollRepo.persist(payroll);
        
        // Create tax record for PPh 21
        if (payroll.pph21.compareTo(BigDecimal.ZERO) > 0) {
            taxService.calculatePPh21(request.companyId, request.payrollYear, 
                                     request.payrollMonth, payroll.grossSalary);
        }
        
        return payroll;
    }
    
    private BigDecimal calculateBpjsTk(BigDecimal grossSalary) {
        // BPJS TK employee contribution: 2% of gross salary
        BigDecimal maxBpjsTk = new BigDecimal("373584"); // 2024 maximum
        BigDecimal bpjsTk = grossSalary.multiply(new BigDecimal("0.02"));
        return bpjsTk.min(maxBpjsTk);
    }
    
    private BigDecimal calculateBpjsKes(BigDecimal grossSalary) {
        // BPJS Kesehatan employee contribution: 1% of gross salary
        BigDecimal maxBpjsKes = new BigDecimal("120000"); // 2024 maximum
        BigDecimal bpjsKes = grossSalary.multiply(new BigDecimal("0.01"));
        return bpjsKes.min(maxBpjsKes);
    }
    
    private BigDecimal calculatePph21(BigDecimal grossSalary, MaritalStatus maritalStatus, Integer dependents) {
        // Get PTKP based on marital status and dependents
        BigDecimal ptkp = getPtkpAmount(maritalStatus, dependents);
        
        // Annual taxable income
        BigDecimal annualIncome = grossSalary.multiply(BigDecimal.valueOf(12));
        BigDecimal taxableIncome = annualIncome.subtract(ptkp);
        
        if (taxableIncome.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }
        
        // Calculate annual tax using progressive rates
        BigDecimal annualTax = calculateProgressiveTax(taxableIncome);
        
        // Monthly PPh 21
        return annualTax.divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);
    }
    
    private BigDecimal getPtkpAmount(MaritalStatus maritalStatus, Integer dependents) {
        BigDecimal basePtkp = new BigDecimal("54000000"); // Base PTKP for single person
        
        if (maritalStatus == MaritalStatus.MARRIED) {
            basePtkp = basePtkp.add(new BigDecimal("4500000")); // Additional for married
        }
        
        // Additional for dependents (max 3)
        int maxDependents = Math.min(dependents, 3);
        BigDecimal dependentAllowance = new BigDecimal("4500000").multiply(BigDecimal.valueOf(maxDependents));
        
        return basePtkp.add(dependentAllowance);
    }
    
    private BigDecimal calculateProgressiveTax(BigDecimal income) {
        // Same progressive tax calculation as in TaxService
        BigDecimal tax = BigDecimal.ZERO;
        
        if (income.compareTo(new BigDecimal("60000000")) <= 0) {
            tax = income.multiply(new BigDecimal("0.05"));
        } else if (income.compareTo(new BigDecimal("250000000")) <= 0) {
            tax = new BigDecimal("3000000")
                    .add(income.subtract(new BigDecimal("60000000")).multiply(new BigDecimal("0.15")));
        } else if (income.compareTo(new BigDecimal("500000000")) <= 0) {
            tax = new BigDecimal("31500000")
                    .add(income.subtract(new BigDecimal("250000000")).multiply(new BigDecimal("0.25")));
        } else {
            tax = new BigDecimal("94000000")
                    .add(income.subtract(new BigDecimal("500000000")).multiply(new BigDecimal("0.30")));
        }
        
        return tax;
    }
    
    public List<Payroll> getPayrollByCompanyAndPeriod(Long companyId, Integer year, Integer month) {
        return payrollRepo.find("company.id = ?1 AND payrollYear = ?2 AND payrollMonth = ?3",
                               companyId, year, month).list();
    }
}
