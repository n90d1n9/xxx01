package tech.kayys.construction.service;

import java.math.BigDecimal;
import java.time.LocalDate;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import tech.kayys.finance.domain.ProgressPayment;

@ApplicationScoped
public class EFakturIntegrationService {
    
    @ConfigProperty(name = "efaktur.integration.enabled", defaultValue = "false")
    boolean eFakturIntegrationEnabled;
    
    @Transactional
    public String generateEFaktur(ProgressPayment payment) {
        if (!eFakturIntegrationEnabled) {
            return null;
        }
        
        try {
            // Generate e-Faktur number
            String eFakturNumber = generateEFakturNumber();
            
            // Create e-Faktur data
            EFakturData eFakturData = new EFakturData();
            eFakturData.fakturNumber = eFakturNumber;
            eFakturData.fakturDate = payment.submittedDate;
            eFakturData.buyerName = payment.contract.project.clientName;
            eFakturData.buyerNPWP = ""; // Get from project client data
            eFakturData.sellerName = payment.contract.contractorName;
            eFakturData.dpp = payment.netPayment; // Dasar Pengenaan Pajak
            eFakturData.ppn = payment.ppnAmount;
            eFakturData.totalAmount = payment.totalPayment;
            
            // Submit to e-Faktur system (simplified)
            submitEFaktur(eFakturData);
            
            // Update payment record
            payment.eFakturNumber = eFakturNumber;
            payment.persist();
            
            return eFakturNumber;
            
        } catch (Exception e) {
            System.err.println("Failed to generate e-Faktur: " + e.getMessage());
            return null;
        }
    }
    
    private String generateEFakturNumber() {
        // Generate e-Faktur number according to Indonesian format
        // Format: 010-YY-XXXXXXXX
        int year = LocalDate.now().getYear() % 100;
        long sequence = ProgressPayment.count() + 1;
        return String.format("010-%02d-%08d", year, sequence);
    }
    
    private void submitEFaktur(EFakturData data) {
        // Integration with e-Faktur system
        // This would typically involve XML/JSON API calls to DJP systems
    }
    
    public static class EFakturData {
        public String fakturNumber;
        public LocalDate fakturDate;
        public String buyerName;
        public String buyerNPWP;
        public String sellerName;
        public BigDecimal dpp;
        public BigDecimal ppn;
        public BigDecimal totalAmount;
    }
}
