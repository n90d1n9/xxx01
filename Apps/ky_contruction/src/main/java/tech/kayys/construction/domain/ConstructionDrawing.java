package tech.kayys.construction.domain;

import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "construction_drawings")
public class ConstructionDrawing extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id")
    public ConstructionPhase phase;
    
    @NotBlank
    @Column(name = "drawing_number", unique = true, nullable = false)
    public String drawingNumber;
    
    @NotBlank
    @Column(name = "drawing_title", nullable = false)
    public String drawingTitle;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DrawingType drawingType;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DrawingDiscipline discipline;
    
    @NotBlank
    @Column(name = "current_revision", nullable = false)
    public String currentRevision = "A";
    
    @Column(name = "scale_ratio")
    public String scaleRatio; // e.g., "1:100", "1:50"
    
    @Column(name = "sheet_size")
    @Enumerated(EnumType.STRING)
    public SheetSize sheetSize = SheetSize.A1;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "file_format")
    public String fileFormat; // PDF, DWG, DXF
    
    @Column(name = "issued_date")
    public LocalDate issuedDate;
    
    @Column(name = "issued_for")
    @Enumerated(EnumType.STRING)
    public IssuePurpose issuedFor;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public DrawingStatus status = DrawingStatus.DRAFT;
    
    @Column(name = "drawn_by")
    public String drawnBy;
    
    @Column(name = "checked_by")
    public String checkedBy;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "design_consultant")
    public String designConsultant;
    
    // BIM integration
    @Column(name = "bim_model_reference")
    public String bimModelReference;
    
    @Column(name = "bim_element_ids", length = 2000)
    public String bimElementIds; // JSON array of BIM element IDs
    
    // Coordination
    @Column(name = "coordination_required")
    public Boolean coordinationRequired = false;
    
    @Column(name = "coordination_status")
    @Enumerated(EnumType.STRING)
    public CoordinationStatus coordinationStatus;
    
    @OneToMany(mappedBy = "drawing", cascade = CascadeType.ALL)
    public List<DrawingRevision> revisions;
    
    @OneToMany(mappedBy = "drawing", cascade = CascadeType.ALL)
    public List<DrawingComment> comments;
    
    @OneToMany(mappedBy = "drawing", cascade = CascadeType.ALL)
    public List<DrawingTransmittal> transmittals;
    
    public enum DrawingType {
        ARCHITECTURAL("Arsitektur"),
        STRUCTURAL("Struktur"),
        MEP_ELECTRICAL("MEP - Elektrikal"),
        MEP_MECHANICAL("MEP - Mekanikal"),
        MEP_PLUMBING("MEP - Plumbing"),
        CIVIL("Sipil"),
        LANDSCAPE("Landscape"),
        INTERIOR("Interior"),
        SHOP_DRAWING("Shop Drawing"),
        AS_BUILT("As Built");
        
        private final String indonesianLabel;
        
        DrawingType(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum DrawingDiscipline {
        ARCHITECTURE("A", "Architecture"),
        STRUCTURE("S", "Structure"),
        ELECTRICAL("E", "Electrical"),
        MECHANICAL("M", "Mechanical"),
        PLUMBING("P", "Plumbing"),
        CIVIL("C", "Civil"),
        LANDSCAPE("L", "Landscape"),
        FIRE_PROTECTION("F", "Fire Protection");
        
        private final String prefix;
        private final String description;
        
        DrawingDiscipline(String prefix, String description) {
            this.prefix = prefix;
            this.description = description;
        }
        
        public String getPrefix() { return prefix; }
        public String getDescription() { return description; }
    }
    
    public enum SheetSize {
        A0, A1, A2, A3, A4
    }
    
    public enum IssuePurpose {
        TENDER("Tender"),
        APPROVAL("Persetujuan"),
        CONSTRUCTION("Konstruksi"),
        INFORMATION("Informasi"),
        RECORD("Record"),
        AS_BUILT("As Built");
        
        private final String indonesianLabel;
        
        IssuePurpose(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum DrawingStatus {
        DRAFT("Draft"),
        FOR_REVIEW("Untuk Review"),
        FOR_APPROVAL("Untuk Persetujuan"),
        APPROVED("Disetujui"),
        ISSUED("Diterbitkan"),
        SUPERSEDED("Digantikan"),
        CANCELLED("Dibatalkan");
        
        private final String indonesianLabel;
        
        DrawingStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum CoordinationStatus {
        NOT_REQUIRED("Tidak Diperlukan"),
        PENDING("Menunggu"),
        IN_PROGRESS("Dalam Proses"),
        RESOLVED("Selesai"),
        CONFLICT("Konflik");
        
        private final String indonesianLabel;
        
        CoordinationStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
}