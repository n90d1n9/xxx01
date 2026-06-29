package tech.kayys.construction.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "milestone_documents")
public class MilestoneDocument extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "milestone_id", nullable = false)
    public ConstructionMilestone milestone;
    
    @NotBlank
    @Column(name = "document_name", nullable = false)
    public String documentName;
    
    @Column(name = "document_description", length = 1000)
    public String documentDescription;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DocumentType documentType;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "file_format")
    public String fileFormat;
    
    @Column(name = "uploaded_date")
    public LocalDateTime uploadedDate;
    
    @Column(name = "uploaded_by")
    public String uploadedBy;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DocumentStatus status = DocumentStatus.DRAFT;
    
    @Column(name = "required_for_completion")
    public Boolean requiredForCompletion = true;
    
    @Column(name = "submission_deadline")
    public LocalDate submissionDeadline;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "approval_date")
    public LocalDate approvalDate;
    
    @Column(name = "version_number")
    public String versionNumber = "1.0";
    
    @Column(name = "checksum")
    public String checksum; // For file integrity
    
    public enum DocumentType {
        COMPLETION_CERTIFICATE("Sertifikat Penyelesaian"),
        TEST_REPORT("Laporan Test"),
        INSPECTION_REPORT("Laporan Inspeksi"),
        QUALITY_CERTIFICATE("Sertifikat Mutu"),
        AS_BUILT_DRAWING("Gambar As Built"),
        OPERATION_MANUAL("Manual Operasi"),
        WARRANTY_CERTIFICATE("Sertifikat Garansi"),
        PERMIT_CERTIFICATE("Sertifikat Izin"),
        HANDOVER_DOCUMENT("Dokumen Serah Terima"),
        COMMISSIONING_REPORT("Laporan Commissioning");
        
        private final String indonesianLabel;
        
        DocumentType(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum DocumentStatus {
        DRAFT("Draft"),
        SUBMITTED("Diajukan"),
        UNDER_REVIEW("Dalam Review"),
        APPROVED("Disetujui"),
        REJECTED("Ditolak"),
        SUPERSEDED("Digantikan");
        
        private final String indonesianLabel;
        
        DocumentStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    @PrePersist
    public void prePersist() {
        if (uploadedDate == null) {
            uploadedDate = LocalDateTime.now();
        }
    }
}

