package tech.kayys.tax.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import tech.kayys.accounting.domain.FinancialTransaction;
import tech.kayys.accounting.domain.TaxRecord;
import tech.kayys.accounting.model.AccountType;
import tech.kayys.accounting.model.TaxRecordRepository;
import tech.kayys.accounting.model.TaxStatus;
import tech.kayys.accounting.model.TaxType;
import tech.kayys.accounting.repository.FinancialTransactionRepository;
import tech.kayys.company.domain.Company;

@ApplicationScoped
public class TaxService {
    
    @Inject
    TaxRecordRepository taxRepo;
    
    @Inject
    FinancialTransactionRepository transactionRepo;
    
    @Transactional
    public TaxRecord calculatePPh21(Long companyId, Integer year, Integer month, BigDecimal grossSalary) {
        // PPh 21 calculation based on Indonesian tax law
        BigDecimal ptkp = getPTKP(); // Penghasilan Tidak Kena Pajak
        BigDecimal taxableIncome = grossSalary.multiply(BigDecimal.valueOf(12)).subtract(ptkp);
        
        BigDecimal taxAmount = BigDecimal.ZERO;
        if (taxableIncome.compareTo(BigDecimal.ZERO) > 0) {
            taxAmount = calculateProgressiveTax(taxableIncome).divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);
        }
        
        TaxRecord taxRecord = new TaxRecord();
        taxRecord.taxYear = year;
        taxRecord.taxMonth = month;
        taxRecord.taxType = TaxType.PPH_21;
        taxRecord.taxableAmount = grossSalary;
        taxRecord.taxAmount = taxAmount;
        taxRecord.taxRate = grossSalary.compareTo(BigDecimal.ZERO) > 0 ? 
                           taxAmount.divide(grossSalary, 4, RoundingMode.HALF_UP) : BigDecimal.ZERO;
        taxRecord.dueDate = LocalDate.of(year, month, 10).plusMonths(1);
        taxRecord.company = Company.findById(companyId);
        taxRecord.status = TaxStatus.UNPAID;
        
        taxRepo.persist(taxRecord);
        return taxRecord;
    }
    
    @Transactional
    public TaxRecord calculatePPN(Long companyId, Integer year, Integer month) {
        // PPN calculation (11% of taxable sales)
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.plusMonths(1).minusDays(1);
        
        List<FinancialTransaction> salesTransactions = transactionRepo
                .findByCompanyAndDateRange(companyId, startDate, endDate)
                .stream()
                .filter(t -> t.creditAccount.accountType == AccountType.REVENUE)
                .collect(Collectors.toList());
        
        BigDecimal totalSales = salesTransactions.stream()
                .map(t -> t.amount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal ppnRate = new BigDecimal("0.11"); // 11% PPN
        BigDecimal ppnAmount = totalSales.multiply(ppnRate);
        
        TaxRecord taxRecord = new TaxRecord();
        taxRecord.taxYear = year;
        taxRecord.taxMonth = month;
        taxRecord.taxType = TaxType.PPN;
        taxRecord.taxableAmount = totalSales;
        taxRecord.taxAmount = ppnAmount;
        taxRecord.taxRate = ppnRate;
        taxRecord.dueDate = LocalDate.of(year, month, 15).plusMonths(1);
        taxRecord.company = Company.findById(companyId);
        taxRecord.status = TaxStatus.UNPAID;
        
        taxRepo.persist(taxRecord);
        return taxRecord;
    }
    
    private BigDecimal getPTKP() {
        // 2024 PTKP rates
        return new BigDecimal("54000000"); // 54 million for single person
    }
    
    private BigDecimal calculateProgressiveTax(BigDecimal income) {
        BigDecimal tax = BigDecimal.ZERO;
        
        // Indonesian progressive tax rates 2024
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
    
    public List<TaxRecord> getOverdueTaxes() {
        return taxRepo.findOverdueTaxes();
    }
    
    @Transactional
    public TaxRecord payTax(Long taxRecordId, String ntpnNumber) {
        TaxRecord taxRecord = taxRepo.findById(taxRecordId);
        if (taxRecord == null) {
            throw new EntityNotFoundException("Tax record not found");
        }
        
        taxRecord.status = TaxStatus.PAID;
        taxRecord.paidDate = LocalDate.now();
        taxRecord.ntpnNumber = ntpnNumber;
        
        return taxRecord;
    }
}
