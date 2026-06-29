package tech.kayys.construction.domain;

import tech.kayys.project.domain.Project;
import tech.kayys.vendor.domain.Vendor;

import java.time.LocalDate;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "material_submittals")
public class MaterialSubmittal extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @ManyToOne
    @JoinColumn(name = "material_id")
    public Material material;
    
    @ManyToOne
    @JoinColumn(name = "vendor_id")
    public Vendor vendor;
    
    @Column(name = "submittal_number", unique = true)
    public String submittalNumber;
    
    @Column(name = "submittal_date")
    public LocalDate submittalDate;
    
    @Column(name = "material_description", length = 1000)
    public String materialDescription;
    
    @Column(name = "proposed_brand")
    public String proposedBrand;
    
    @Column(name = "specifications", length = 2000)
    public String specifications;
    
    @Column(name = "test_certificates")
    public String testCertificates; // File paths or URLs
    
    @Enumerated(EnumType.STRING)
    public SubmittalStatus status = SubmittalStatus.SUBMITTED;
    
    @Column(name = "reviewed_by")
    public String reviewedBy;
    
    @Column(name = "review_date")
    public LocalDate reviewDate;
    
    @Column(name = "review_comments", length = 2000)
    public String reviewComments;
    
    public enum SubmittalStatus {
        SUBMITTED("Submitted"),
        UNDER_REVIEW("Under Review"),
        APPROVED("Approved"),
        APPROVED_WITH_COMMENTS("Approved with Comments"),
        REJECTED("Rejected"),
        RESUBMIT_REQUIRED("Resubmit Required");
        
        private final String label;
        SubmittalStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
