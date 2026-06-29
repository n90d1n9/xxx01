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
@Table(name = "ai_recommendations")
public class AIRecommendation extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "recommendation_date")
    public LocalDateTime recommendationDate;
    
    @Enumerated(EnumType.STRING)
    public RecommendationType recommendationType;
    
    @Column(name = "title")
    public String title;
    
    @Column(name = "description", length = 2000)
    public String description;
    
    @Column(name = "confidence_score", precision = 5, scale = 2)
    public BigDecimal confidenceScore;
    
    @Column(name = "potential_impact", length = 1000)
    public String potentialImpact;
    
    @Column(name = "implementation_effort")
    @Enumerated(EnumType.STRING)
    public ImplementationEffort implementationEffort;
    
    @Enumerated(EnumType.STRING)
    public RecommendationStatus status = RecommendationStatus.PENDING;
    
    @Column(name = "reviewed_by")
    public String reviewedBy;
    
    @Column(name = "review_notes", length = 1000)
    public String reviewNotes;
    
    public enum RecommendationType {
        VENDOR_RECOMMENDATION("Vendor Recommendation"),
        MATERIAL_ALTERNATIVE("Material Alternative"),
        SCHEDULE_OPTIMIZATION("Schedule Optimization"),
        RESOURCE_ALLOCATION("Resource Allocation"),
        COST_REDUCTION("Cost Reduction"),
        RISK_MITIGATION("Risk Mitigation");
        
        private final String label;
        RecommendationType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum ImplementationEffort {
        LOW("Low"),
        MEDIUM("Medium"),
        HIGH("High");
        
        private final String label;
        ImplementationEffort(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum RecommendationStatus {
        PENDING("Pending"),
        ACCEPTED("Accepted"),
        REJECTED("Rejected"),
        IMPLEMENTED("Implemented");
        
        private final String label;
        RecommendationStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
