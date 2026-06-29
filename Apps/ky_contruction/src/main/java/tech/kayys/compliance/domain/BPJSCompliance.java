package tech.kayys.compliance.domain;

import java.time.LocalDate;
import java.math.BigDecimal;
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
@Table(name = "bpjs_compliance")
public class BPJSCompliance extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "worker_name")
    public String workerName;
    
    @Column(name = "nik")
    public String nik; // National ID Number
    
    @Column(name = "bpjs_ketenagakerjaan_number")
    public String bpjsKetenagakerjaanNumber;
    
    @Column(name = "bpjs_kesehatan_number")
    public String bpjsKesehatanNumber;
    
    @Column(name = "employment_start_date")
    public LocalDate employmentStartDate;
    
    @Column(name = "employment_end_date")
    public LocalDate employmentEndDate;
    
    @Column(name = "daily_wage", precision = 12, scale = 2)
    public BigDecimal dailyWage;
    
    @Column(name = "contribution_amount", precision = 12, scale = 2)
    public BigDecimal contributionAmount;
    
    @Column(name = "last_contribution_date")
    public LocalDate lastContributionDate;
    
    @Enumerated(EnumType.STRING)
    public ComplianceStatus status = ComplianceStatus.ACTIVE;
    
    @Column(name = "job_position")
    public String jobPosition;
    
    @Column(name = "company_name")
    public String companyName;
    
    public enum ComplianceStatus {
        ACTIVE("Active"),
        INACTIVE("Inactive"),
        SUSPENDED("Suspended"),
        TERMINATED("Terminated");
        
        private final String label;
        ComplianceStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
