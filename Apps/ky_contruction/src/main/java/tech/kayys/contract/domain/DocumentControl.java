package tech.kayys.contract.domain;

import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "document_control")
public class DocumentControl extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "document_number", unique = true)
    public String documentNumber;
    
    @Column(name = "document_title")
    public String documentTitle;
    
    @Enumerated(EnumType.STRING)
    public DocumentType documentType;
    
    @Column(name = "revision")
    public String revision = "A";
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "discipline")
    public String discipline;
    
    @Column(name = "originator")
    public String originator;
    
    @Column(name = "issued_date")
    public LocalDate issuedDate;
    
    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    public DocumentStatus status = DocumentStatus.DRAFT;
    
    @Column(name = "purpose_of_issue")
    public String purposeOfIssue;
    
    @Column(name = "distribution_list", length = 1000)
    public String distributionList;
    
    @OneToMany(mappedBy = "document", cascade = CascadeType.ALL)
    public List<DocumentApproval> approvals;
    
    @OneToMany(mappedBy = "document", cascade = CascadeType.ALL)
    public List<DocumentTransmittal> transmittals;
    
    public enum DocumentType {
        DRAWING("Drawing"),
        SPECIFICATION("Specification"),
        RFI("Request for Information"),
        SUBMITTAL("Submittal"),
        SHOP_DRAWING("Shop Drawing"),
        METHOD_STATEMENT("Method Statement"),
        MATERIAL_APPROVAL("Material Approval"),
        TEST_CERTIFICATE("Test Certificate");
        
        private final String label;
        DocumentType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum DocumentStatus {
        DRAFT("Draft"),
        FOR_APPROVAL("For Approval"),
        APPROVED("Approved"),
        REJECTED("Rejected"),
        SUPERSEDED("Superseded"),
        ARCHIVED("Archived");
        
        private final String label;
        DocumentStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
