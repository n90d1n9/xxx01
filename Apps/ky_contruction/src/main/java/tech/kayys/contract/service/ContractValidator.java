package tech.kayys.contract.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.contract.domain.Contract;

@ApplicationScoped
public class ContractValidator {
    
    public List<String> validateContract(Contract contract) {
        List<String> errors = new ArrayList<>();
        
        if (contract.contractValue == null || contract.contractValue.compareTo(BigDecimal.ZERO) <= 0) {
            errors.add("Nilai kontrak harus lebih besar dari nol");
        }
        
        if (contract.contractDate == null) {
            errors.add("Tanggal kontrak harus diisi");
        }
        
        if (contract.commencementDate == null) {
            errors.add("Tanggal mulai kerja harus diisi");
        }
        
        if (contract.completionDate == null) {
            errors.add("Tanggal selesai kerja harus diisi");
        }
        
        if (contract.commencementDate != null && contract.completionDate != null) {
            if (contract.commencementDate.isAfter(contract.completionDate)) {
                errors.add("Tanggal mulai kerja tidak boleh setelah tanggal selesai");
            }
        }
        
        if (contract.retentionPercentage != null && 
            (contract.retentionPercentage.compareTo(BigDecimal.ZERO) < 0 || 
             contract.retentionPercentage.compareTo(BigDecimal.valueOf(20)) > 0)) {
            errors.add("Persentase retensi harus antara 0-20%");
        }
        
        return errors;
    }
    
    public boolean isContractExpired(Contract contract) {
        return contract.completionDate != null && contract.completionDate.isBefore(LocalDate.now());
    }
    
    public boolean isMaintenancePeriodActive(Contract contract) {
        if (contract.completionDate == null || contract.maintenancePeriodMonths == null) {
            return false;
        }
        
        LocalDate maintenanceEndDate = contract.completionDate.plusMonths(contract.maintenancePeriodMonths);
        LocalDate now = LocalDate.now();
        
        return now.isAfter(contract.completionDate) && now.isBefore(maintenanceEndDate);
    }
}
