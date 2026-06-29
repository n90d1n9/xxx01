package tech.kayys.hse.domain;

import java.time.LocalDate;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "environmental_compliance")
public class EnvironmentalCompliance extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "permit_type")
    @Enumerated(EnumType.STRING)
    public PermitType permitType;
    
    @Column(name = "permit_number")
    public String permitNumber;
    
    @Column(name = "permit_title")
    public String permitTitle;
    
    @Column(name = "issuing_authority")
    public String issuingAuthority;
    
    @Column(name = "issue_date")
    public LocalDate issueDate;
    
    @Column(name = "expiry_date")
    public LocalDate expiryDate;
    
    @Column(name = "renewal_date")
    public LocalDate renewalDate;
    
    @Enumerated(EnumType.STRING)
    public PermitStatus status = PermitStatus.PENDING;
    
    @Column(name = "compliance_requirements", length = 2000)
    public String complianceRequirements;
    
    @Column(name = "monitoring_schedule", length = 1000)
    public String monitoringSchedule;
    
    public enum PermitType {
        AMDAL("AMDAL - Environmental Impact Assessment"),
        UKL_UPL("UKL-UPL - Environmental Management"),
        IMB_PBG("IMB/PBG - Building Permit"),
        PERSETUJUAN_LINGKUNGAN("Persetujuan Lingkungan"),
        IZIN_GANGGUAN("Izin Gangguan - Nuisance Permit");
        
        private final String label;
        PermitType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum PermitStatus {
        PENDING("Pending"),
        APPROVED("Approved"),
        EXPIRED("Expired"),
        REVOKED("Revoked"),
        UNDER_RENEWAL("Under Renewal");
        
        private final String label;
        PermitStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
