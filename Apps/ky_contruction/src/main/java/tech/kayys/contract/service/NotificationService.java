package tech.kayys.contract.service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.contract.domain.Contract;
import tech.kayys.contract.domain.ContractClaim;
import tech.kayys.contract.domain.DocumentControl;
import tech.kayys.finance.domain.ProgressPayment;

@ApplicationScoped
public class NotificationService {
    
    public void sendClaimNotification(ContractClaim claim) {
        // Implementation for sending notifications
        // Could integrate with email service, SMS, or push notifications
        System.out.println("Klaim baru diajukan: " + claim.claimNumber);
    }
    
    public void sendPaymentApprovalNotification(ProgressPayment payment) {
        System.out.println("Pembayaran disetujui: " + payment.paymentNumber + 
                          " untuk kontrak " + payment.contract.contractNumber);
    }
    
    public void sendDocumentApprovalNotification(DocumentControl document) {
        System.out.println("Dokumen menunggu persetujuan: " + document.documentNumber);
    }
    
    public List<String> getContractExpiryReminders() {
        List<String> reminders = new ArrayList<>();
        LocalDate thirtyDaysFromNow = LocalDate.now().plusDays(30);
        
        List<Contract> expiringContracts = Contract
            .list("completionDate BETWEEN ?1 AND ?2 AND status IN (?3, ?4)", 
                  LocalDate.now(), thirtyDaysFromNow,
                  Contract.ContractStatus.ACTIVE, Contract.ContractStatus.SIGNED);
        
        for (Contract contract : expiringContracts) {
            long daysUntilExpiry = ChronoUnit.DAYS.between(LocalDate.now(), contract.completionDate);
            reminders.add(String.format("Kontrak %s akan berakhir dalam %d hari", 
                         contract.contractNumber, daysUntilExpiry));
        }
        
        return reminders;
    }
}
