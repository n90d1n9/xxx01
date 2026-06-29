package tech.kayys.ai.domain;

import java.time.LocalDateTime;
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
@Table(name = "anomaly_detections")
public class AnomalyDetection extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "detection_date")
    public LocalDateTime detectionDate;
    
    @Enumerated(EnumType.STRING)
    public AnomalyType anomalyType;
    
    @Column(name = "anomaly_score", precision = 5, scale = 2)
    public BigDecimal anomalyScore;
    
    @Column(name = "description", length = 1000)
    public String description;
    
    @Column(name = "affected_entity_type")
    public String affectedEntityType;
    
    @Column(name = "affected_entity_id")
    public Long affectedEntityId;
    
    @Column(name = "recommendation", length = 2000)
    public String recommendation;
    
    @Enumerated(EnumType.STRING)
    public AnomalyStatus status = AnomalyStatus.DETECTED;
    
    @Column(name = "investigated_by")
    public String investigatedBy;
    
    @Column(name = "investigation_notes", length = 2000)
    public String investigationNotes;
    
    public enum AnomalyType {
        COST_ANOMALY("Cost Anomaly"),
        SCHEDULE_ANOMALY("Schedule Anomaly"),
        PRODUCTIVITY_ANOMALY("Productivity Anomaly"),
        RESOURCE_ANOMALY("Resource Anomaly"),
        QUALITY_ANOMALY("Quality Anomaly"),
        INVOICE_ANOMALY("Invoice Anomaly");
        
        private final String label;
        AnomalyType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum AnomalyStatus {
        DETECTED("Detected"),
        INVESTIGATING("Investigating"),
        CONFIRMED("Confirmed"),
        FALSE_POSITIVE("False Positive"),
        RESOLVED("Resolved");
        
        private final String label;
        AnomalyStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
