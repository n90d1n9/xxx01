package tech.kayys.finance.domain;

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
import tech.kayys.construction.domain.MethodStatement;

@Entity
@Table(name = "method_statement_attachments")
public class MethodStatementAttachment extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "method_statement_id", nullable = false)
    public MethodStatement methodStatement;
    
    @NotBlank
    @Column(name = "attachment_name", nullable = false)
    public String attachmentName;
    
    @Column(name = "attachment_description", length = 1000)
    public String attachmentDescription;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public MSAttachmentType attachmentType;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "file_format")
    public String fileFormat;
    
    @Column(name = "upload_date")
    public LocalDateTime uploadDate;
    
    @Column(name = "uploaded_by")
    public String uploadedBy;
    
    @Column(name = "version_number")
    public String versionNumber = "1.0";
    
    @Column(name = "is_mandatory")
    public Boolean isMandatory = false;
    
    @Column(name = "approval_required")
    public Boolean approvalRequired = false;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "approval_date")
    public LocalDate approvalDate;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public AttachmentStatus status = AttachmentStatus.DRAFT;
    
    public enum MSAttachmentType {
        REFERENCE_DRAWING("Gambar Referensi", "Reference technical drawings"),
        RISK_ASSESSMENT("Analisis Risiko", "Risk assessment document"),
        SAFETY_PLAN("Rencana K3", "Safety plan and procedures"),
        QUALITY_PLAN("Rencana Mutu", "Quality control plan"),
        INSPECTION_CHECKLIST("Checklist Inspeksi", "Inspection checklist form"),
        MATERIAL_SPECIFICATION("Spesifikasi Material", "Material specifications"),
        EQUIPMENT_SPECIFICATION("Spesifikasi Alat", "Equipment specifications"),
        WORK_INSTRUCTION("Instruksi Kerja", "Detailed work instructions"),
        CALCULATION_SHEET("Lembar Perhitungan", "Engineering calculations"),
        PHOTO_ILLUSTRATION("Foto Ilustrasi", "Illustrative photographs"),
        FLOWCHART("Diagram Alur", "Process flowchart"),
        SITE_LAYOUT("Layout Site", "Site layout plan");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        MSAttachmentType(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum AttachmentStatus {
        DRAFT("Draft"),
        SUBMITTED("Diajukan"),
        APPROVED("Disetujui"),
        REJECTED("Ditolak"),
        SUPERSEDED("Digantikan");
        
        private final String indonesianLabel;
        
        AttachmentStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    @PrePersist
    public void prePersist() {
        if (uploadDate == null) {
            uploadDate = LocalDateTime.now();
        }
    }
}