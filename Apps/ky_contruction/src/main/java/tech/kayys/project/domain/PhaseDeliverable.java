package tech.kayys.project.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import tech.kayys.construction.domain.ConstructionPhase;

@Entity
@Table(name = "phase_deliverables")
public class PhaseDeliverable extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id", nullable = false)
    public ConstructionPhase phase;
    
    @NotBlank
    @Column(name = "deliverable_name", nullable = false)
    public String deliverableName;
    
    @Column(name = "deliverable_description", length = 2000)
    public String deliverableDescription;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DeliverableType deliverableType;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DeliverablePriority priority = DeliverablePriority.MEDIUM;
    
    @Column(name = "planned_delivery_date")
    public LocalDate plannedDeliveryDate;
    
    @Column(name = "actual_delivery_date")
    public LocalDate actualDeliveryDate;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DeliverableStatus status = DeliverableStatus.PLANNED;
    
    @Column(name = "responsible_person")
    public String responsiblePerson;
    
    @Column(name = "approval_required")
    public Boolean approvalRequired = false;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "approval_date")
    public LocalDate approvalDate;
    
    @Min(0) @Max(100)
    @Column(name = "completion_percentage", precision = 5, scale = 2)
    public BigDecimal completionPercentage = BigDecimal.ZERO;
    
    @Column(name = "quality_criteria", length = 2000)
    public String qualityCriteria;
    
    @Column(name = "acceptance_criteria", length = 2000)
    public String acceptanceCriteria;
    
    @Column(name = "deliverable_location")
    public String deliverableLocation;
    
    @Column(name = "file_attachments", length = 1000)
    public String fileAttachments; // JSON array of file paths
    
    @Column(name = "review_comments", length = 2000)
    public String reviewComments;
    
    @Column(name = "revision_required")
    public Boolean revisionRequired = false;
    
    @Column(name = "client_deliverable")
    public Boolean clientDeliverable = false;
    
    @Column(name = "contractual_deliverable")
    public Boolean contractualDeliverable = false;
    
    public enum DeliverableType {
        DOCUMENT("Dokumen", "Documentation deliverable"),
        PHYSICAL_WORK("Pekerjaan Fisik", "Physical construction work"),
        DRAWING("Gambar", "Technical drawings"),
        REPORT("Laporan", "Reports and studies"),
        CERTIFICATE("Sertifikat", "Certificates and approvals"),
        TESTING("Testing", "Testing and commissioning"),
        TRAINING("Pelatihan", "Training and knowledge transfer"),
        SOFTWARE("Software", "Software or digital deliverable");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        DeliverableType(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum DeliverablePriority {
        LOW("Rendah"),
        MEDIUM("Sedang"),
        HIGH("Tinggi"),
        CRITICAL("Kritis");
        
        private final String indonesianLabel;
        
        DeliverablePriority(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum DeliverableStatus {
        PLANNED("Direncanakan"),
        IN_PROGRESS("Dalam Proses"),
        UNDER_REVIEW("Dalam Review"),
        REVISION_REQUIRED("Perlu Revisi"),
        APPROVED("Disetujui"),
        DELIVERED("Diserahkan"),
        ACCEPTED("Diterima"),
        REJECTED("Ditolak");
        
        private final String indonesianLabel;
        
        DeliverableStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public Boolean isOverdue() {
        return plannedDeliveryDate != null && 
               plannedDeliveryDate.isBefore(LocalDate.now()) && 
               status != DeliverableStatus.DELIVERED && 
               status != DeliverableStatus.ACCEPTED;
    }
    
    public Long getDaysOverdue() {
        if (!isOverdue()) return 0L;
        return (long) plannedDeliveryDate.until(LocalDate.now()).getDays();
    }
}