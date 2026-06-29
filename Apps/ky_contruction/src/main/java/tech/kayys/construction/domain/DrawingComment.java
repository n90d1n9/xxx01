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

@Entity
@Table(name = "drawing_comments")
public class DrawingComment extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "drawing_id", nullable = false)
    public ConstructionDrawing drawing;
    
    @Column(name = "comment_number")
    public Integer commentNumber;
    
    @Column(name = "comment_date", nullable = false)
    public LocalDateTime commentDate;
    
    @Column(name = "commented_by", nullable = false)
    public String commentedBy;
    
    @Column(name = "comment_text", length = 2000, nullable = false)
    public String commentText;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public CommentType commentType;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public CommentPriority priority = CommentPriority.MEDIUM;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public CommentStatus status = CommentStatus.OPEN;
    
    @Column(name = "drawing_zone")
    public String drawingZone; // Grid reference or zone
    
    @Column(name = "x_coordinate")
    public Double xCoordinate; // For digital markup
    
    @Column(name = "y_coordinate")
    public Double yCoordinate; // For digital markup
    
    @Column(name = "response_required_by")
    public LocalDate responseRequiredBy;
    
    @Column(name = "response_text", length = 2000)
    public String responseText;
    
    @Column(name = "responded_by")
    public String respondedBy;
    
    @Column(name = "response_date")
    public LocalDateTime responseDate;
    
    @Column(name = "action_taken", length = 1000)
    public String actionTaken;
    
    @Column(name = "affects_other_drawings")
    public Boolean affectsOtherDrawings = false;
    
    @Column(name = "requires_revision")
    public Boolean requiresRevision = false;
    
    public enum CommentType {
        TECHNICAL_QUERY("Query Teknis", "Technical clarification needed"),
        DESIGN_ISSUE("Masalah Desain", "Design issue identified"),
        COORDINATION_CONFLICT("Konflik Koordinasi", "Inter-discipline conflict"),
        SPECIFICATION_CLARIFICATION("Klarifikasi Spesifikasi", "Specification needs clarification"),
        CONSTRUCTION_CONCERN("Kekhawatiran Konstruksi", "Construction practicality concern"),
        AUTHORITY_COMMENT("Komentar Otoritas", "Authority review comment"),
        GENERAL_COMMENT("Komentar Umum", "General comment");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        CommentType(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum CommentPriority {
        LOW("Rendah"),
        MEDIUM("Sedang"),
        HIGH("Tinggi"),
        CRITICAL("Kritis");
        
        private final String indonesianLabel;
        
        CommentPriority(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum CommentStatus {
        OPEN("Terbuka"),
        IN_PROGRESS("Dalam Proses"),
        RESOLVED("Diselesaikan"),
        CLOSED("Ditutup"),
        DEFERRED("Ditunda");
        
        private final String indonesianLabel;
        
        CommentStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    @PrePersist
    public void prePersist() {
        if (commentDate == null) {
            commentDate = LocalDateTime.now();
        }
    }
    
    public Boolean isOverdue() {
        return responseRequiredBy != null && 
               responseRequiredBy.isBefore(LocalDate.now()) && 
               status == CommentStatus.OPEN;
    }
}
