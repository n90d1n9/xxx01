package tech.kayys.construction.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.contract.domain.Contract;
import tech.kayys.contract.domain.ContractMilestone;
import tech.kayys.finance.domain.ProgressPayment;

@ApplicationScoped
public class ContractService {
    
    public List<Contract> getContractsByProject(Long projectId) {
        return Contract.list("project.id = ?1 ORDER BY contractDate DESC", projectId);
    }
    
    public Contract createContract(Contract contract) {
        // Generate contract number
        contract.contractNumber = generateContractNumber(contract);
        contract.persist();
        
        // Create default milestones based on contract type
        createDefaultMilestones(contract);
        
        return contract;
    }
    
    public Contract updateContractStatus(Long contractId, Contract.ContractStatus newStatus) {
        Contract contract = Contract.findById(contractId);
        if (contract != null) {
            contract.status = newStatus;
            contract.persist();
        }
        return contract;
    }
    
    public BigDecimal calculateContractProgress(Long contractId) {
        List<ContractMilestone> milestones = ContractMilestone
            .list("contract.id = ?1", contractId);
        
        if (milestones.isEmpty()) return BigDecimal.ZERO;
        
        BigDecimal totalProgress = milestones.stream()
            .map(m -> m.progressPercentage != null ? m.progressPercentage : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return totalProgress.divide(BigDecimal.valueOf(milestones.size()), 2, RoundingMode.HALF_UP);
    }
    
    public BigDecimal calculateTotalPayments(Long contractId) {
        List<ProgressPayment> payments = ProgressPayment
            .list("contract.id = ?1 AND status = ?2", contractId, ProgressPayment.PaymentStatus.PAID);
        
        return payments.stream()
            .map(p -> p.netAmount != null ? p.netAmount : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    private String generateContractNumber(Contract contract) {
        long count = Contract.count("project", contract.project) + 1;
        String year = String.valueOf(LocalDate.now().getYear());
        return String.format("CT-%s-%s-%03d", contract.project.projectCode, year, count);
    }
    
    private void createDefaultMilestones(Contract contract) {
        switch (contract.contractType) {
            case CONSTRUCTION:
                createConstructionMilestones(contract);
                break;
            case EPC:
                createEPCMilestones(contract);
                break;
            default:
                createBasicMilestones(contract);
                break;
        }
    }
    
    private void createConstructionMilestones(Contract contract) {
        String[] milestoneNames = {
            "Mobilisasi", "Pekerjaan Persiapan", "Pekerjaan Struktur", 
            "Pekerjaan Arsitektur", "Pekerjaan MEP", "Finishing", "Demobilisasi"
        };
        
        for (int i = 0; i < milestoneNames.length; i++) {
            ContractMilestone milestone = new ContractMilestone();
            milestone.contract = contract;
            milestone.milestoneName = milestoneNames[i];
            milestone.sequenceNumber = i + 1;
            milestone.persist();
        }
    }
    
    private void createEPCMilestones(Contract contract) {
        String[] milestoneNames = {
            "Engineering Design", "Procurement", "Construction", 
            "Testing & Commissioning", "Performance Test"
        };
        
        for (int i = 0; i < milestoneNames.length; i++) {
            ContractMilestone milestone = new ContractMilestone();
            milestone.contract = contract;
            milestone.milestoneName = milestoneNames[i];
            milestone.sequenceNumber = i + 1;
            milestone.persist();
        }
    }
    
    private void createBasicMilestones(Contract contract) {
        String[] milestoneNames = {"Kick-off", "50% Completion", "Final Completion"};
        
        for (int i = 0; i < milestoneNames.length; i++) {
            ContractMilestone milestone = new ContractMilestone();
            milestone.contract = contract;
            milestone.milestoneName = milestoneNames[i];
            milestone.sequenceNumber = i + 1;
            milestone.persist();
        }
    }
}