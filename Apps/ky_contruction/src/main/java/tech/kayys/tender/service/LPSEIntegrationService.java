package tech.kayys.tender.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.rest.client.inject.RestClient;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.tender.domain.Tender;

@ApplicationScoped
public class LPSEIntegrationService {
    
    @ConfigProperty(name = "lpse.integration.enabled", defaultValue = "false")
    boolean lpseIntegrationEnabled;
    
    @ConfigProperty(name = "lpse.api.base-url")
    Optional<String> lpseBaseUrl;
    
    @Inject
    @RestClient
    LPSEClient lpseClient;
    
    public void syncTenderToLPSE(Tender tender) {
        if (!lpseIntegrationEnabled || lpseBaseUrl.isEmpty()) {
            return;
        }
        
        try {
            LPSETenderData lpseData = new LPSETenderData();
            lpseData.tenderNumber = tender.tenderNumber;
            lpseData.tenderTitle = tender.tenderTitle;
            lpseData.description = tender.description;
            lpseData.estimatedValue = tender.estimatedValue;
            lpseData.submissionDeadline = tender.submissionDeadline;
            lpseData.openingDate = tender.openingDate;
            
            lpseClient.publishTender(lpseData);
            
        } catch (Exception e) {
            System.err.println("Failed to sync tender to LPSE: " + e.getMessage());
        }
    }
    
    public List<LPSEVendorData> getQualifiedVendors(String category) {
        if (!lpseIntegrationEnabled) {
            return Collections.emptyList();
        }
        
        try {
            return lpseClient.getQualifiedVendors(category);
        } catch (Exception e) {
            System.err.println("Failed to fetch qualified vendors from LPSE: " + e.getMessage());
            return Collections.emptyList();
        }
    }
    
    public static class LPSETenderData {
        public String tenderNumber;
        public String tenderTitle;
        public String description;
        public BigDecimal estimatedValue;
        public LocalDateTime submissionDeadline;
        public LocalDateTime openingDate;
    }
    
    public static class LPSEVendorData {
        public String vendorCode;
        public String companyName;
        public String qualificationGrade;
        public String sbuClassification;
        public LocalDate qualificationExpiry;
    }
}
