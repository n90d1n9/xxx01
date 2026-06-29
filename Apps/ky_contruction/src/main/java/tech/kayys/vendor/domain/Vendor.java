package tech.kayys.vendor.domain;

import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "vendors")
public class Vendor extends PanacheEntity {
    
    @Column(name = "vendor_code", unique = true)
    public String vendorCode;
    
    @Column(name = "company_name")
    public String companyName;
    
    @Column(name = "contact_person")
    public String contactPerson;
    
    @Column(name = "email")
    public String email;
    
    @Column(name = "phone")
    public String phone;
    
    @Column(name = "address", length = 500)
    public String address;
    
    @Column(name = "npwp")
    public String npwp; // Tax ID
    
    @Column(name = "siup_number")
    public String siupNumber; // Business License
    
    @Column(name = "situ_number")
    public String situNumber; // Location Permit
    
    @Column(name = "pkp_status")
    public Boolean pkpStatus = false; // Taxable Entrepreneur status
    
    @Enumerated(EnumType.STRING)
    public VendorCategory category;
    
    @Enumerated(EnumType.STRING)
    public VendorStatus status = VendorStatus.ACTIVE;
    
    @Column(name = "qualification_grade")
    public String qualificationGrade; // Small, Medium, Large, Specialist
    
    @Column(name = "sbu_classification")
    public String sbuClassification; // Construction Business Entity classification
    
    @OneToMany(mappedBy = "vendor", cascade = CascadeType.ALL)
    public List<VendorEvaluation> evaluations;
    
    public enum VendorCategory {
        MATERIAL_SUPPLIER("Material Supplier"),
        EQUIPMENT_RENTAL("Equipment Rental"),
        SUBCONTRACTOR("Subcontractor"),
        PROFESSIONAL_SERVICE("Professional Service"),
        SPECIALIST_CONTRACTOR("Specialist Contractor");
        
        private final String label;
        VendorCategory(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum VendorStatus {
        ACTIVE("Active"),
        SUSPENDED("Suspended"),
        BLACKLISTED("Blacklisted"),
        INACTIVE("Inactive");
        
        private final String label;
        VendorStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
