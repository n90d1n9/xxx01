package tech.kayys.construction.domain;

import java.time.LocalDateTime;
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
@Table(name = "bim_models")
public class BIMModel extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "model_name")
    public String modelName;
    
    @Column(name = "model_type")
    @Enumerated(EnumType.STRING)
    public BIMModelType modelType;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "version")
    public String version;
    
    @Column(name = "discipline")
    public String discipline; // Architecture, Structure, MEP, etc.
    
    @Column(name = "software_used")
    public String softwareUsed; // Revit, ArchiCAD, Tekla, etc.
    
    @Column(name = "last_updated")
    public LocalDateTime lastUpdated;
    
    @Column(name = "is_current")
    public Boolean isCurrent = false;
    
    @OneToMany(mappedBy = "bimModel", cascade = CascadeType.ALL)
    public List<BIMQuantity> quantities;
    
    public enum BIMModelType {
        ARCHITECTURAL("Arsitektur"),
        STRUCTURAL("Struktur"),
        MEP("MEP"),
        CIVIL("Sipil"),
        COORDINATION("Koordinasi"),
        FEDERATED("Gabungan");
        
        private final String label;
        BIMModelType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}