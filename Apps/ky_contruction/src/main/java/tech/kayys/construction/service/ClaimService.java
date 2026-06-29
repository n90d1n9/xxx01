package tech.kayys.construction.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.contract.domain.ContractClaim;

@ApplicationScoped
public class ClaimService {
    
    public ContractClaim createClaim(ContractClaim claim) {
        // Generate claim number
        long count = ContractClaim.count("contract", claim.contract) + 1;
        claim.claimNumber = String.format("CL-%s-%03d", claim.contract.contractNumber, count);
        claim.submittedDate = LocalDate.now();
        claim.responseDueDate = LocalDate.now().plusDays(28);
        claim.persist();
        
        return claim;
    }
    
    public ContractClaim updateClaimStatus(Long claimId, ContractClaim.ClaimStatus newStatus) {
        ContractClaim claim = ContractClaim.findById(claimId);
        if (claim != null) {
            claim.status = newStatus;
            if (newStatus == ContractClaim.ClaimStatus.AGREED) {
                claim.settlementDate = LocalDate.now();
            }
            claim.persist();
        }
        return claim;
    }
    
    public List<ContractClaim> getClaimsByStatus(ContractClaim.ClaimStatus status) {
        return ContractClaim.list("status = ?1 ORDER BY submittedDate DESC", status);
    }
    
    public BigDecimal calculateTotalClaimedAmount(Long contractId) {
        List<ContractClaim> claims = ContractClaim
            .list("contract.id = ?1 AND status = ?2", contractId, ContractClaim.ClaimStatus.AGREED);
        
        return claims.stream()
            .map(c -> c.agreedAmount != null ? c.agreedAmount : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}