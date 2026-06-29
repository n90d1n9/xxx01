package tech.kayys.construction.domain;


import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.LocalDate;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;

@Entity
@Table(name = "drawing_revisions")
public class DrawingRevision extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "drawing_id", nullable = false)
    public ConstructionDrawing drawing;
    
    @NotBlank
    @Column(name = "revision_code", nullable = false)
    public String revisionCode; // A, B, C, etc.
    
    @Column(name = "revision_date", nullable = false)
    public LocalDate revisionDate;
    
    @Column(name = "revision_description", length = 1000)
    public String revisionDescription;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public RevisionReason revisionReason;
    
    @Column(name = "revised_by")
    public String revisedBy;
    
    @Column(name = "checked_by")
    public String checkedBy;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "is_current")
    public Boolean isCurrent = false;
    
    @Column(name = "superseded_date")
    public LocalDate supersededDate;
    
    @Column(name = "distribution_list", length = 2000)
    public String distributionList;
    
    @Column(name = "cloud_sync_status")
    @Enumerated(EnumType.STRING)
    public CloudSyncStatus cloudSyncStatus = CloudSyncStatus.PENDING;
    
    // BIM integration
    @Column(name = "bim_model_updated")
    public Boolean bimModelUpdated = false;
    
    @Column(name = "coordination_impact")
    @Enumerated(EnumType.STRING)
    public CoordinationImpact coordinationImpact = CoordinationImpact.NONE;
    
    public enum RevisionReason {
        DESIGN_CHANGE("Perubahan Desain", "Design modification required"),
        CLIENT_REQUIREMENT("Permintaan Klien", "Client requested changes"),
        AUTHORITY_REQUIREMENT("Permintaan Otoritas", "Authority comments incorporation"),
        COORDINATION("Koordinasi", "Inter-discipline coordination"),
        CONSTRUCTION_REQUIREMENT("Kebutuhan Konstruksi", "Construction practicality"),
        ERROR_CORRECTION("Koreksi Kesalahan", "Error correction"),
        ADDITIONAL_INFORMATION("Informasi Tambahan", "Additional details added"),
        SPECIFICATION_CHANGE("Perubahan Spesifikasi", "Specification updates");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        RevisionReason(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum CloudSyncStatus {
        PENDING, SYNCING, SYNCED, FAILED
    }
    
    public enum CoordinationImpact {
        NONE("Tidak Ada", "No coordination impact"),
        MINOR("Kecil", "Minor coordination required"),
        MAJOR("Besar", "Major coordination required"),
        CRITICAL("Kritis", "Critical coordination required");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        CoordinationImpact(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    @PrePersist
    public void prePersist() {
        if (revisionDate == null) {
            revisionDate = LocalDate.now();
        }
    }
}