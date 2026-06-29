package tech.kayys.contract.service;

import java.time.LocalDate;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.contract.domain.Contract;
import tech.kayys.contract.domain.ContractClaim;
import tech.kayys.contract.domain.DocumentTransmittal;

@ApplicationScoped
public class ContractNumberGenerator {
    
    public String generateContractNumber(Contract contract) {
        String year = String.valueOf(LocalDate.now().getYear());
        long count = Contract.count("project = ?1 AND EXTRACT(YEAR FROM contractDate) = ?2", 
            contract.project, LocalDate.now().getYear()) + 1;
        
        return String.format("CT-%s-%s-%03d", 
            contract.project.projectCode, year, count);
    }
    
    public String generateClaimNumber(ContractClaim claim) {
        long count = ContractClaim.count("contract", claim.contract) + 1;
        return String.format("CL-%s-%03d", claim.contract.contractNumber, count);
    }
    
    public String generateTransmittalNumber(DocumentTransmittal transmittal) {
        String year = String.valueOf(LocalDate.now().getYear());
        long count = DocumentTransmittal.count("EXTRACT(YEAR FROM transmittalDate) = ?1", 
            LocalDate.now().getYear()) + 1;
        
        return String.format("TM-%s-%04d", year, count);
    }
}