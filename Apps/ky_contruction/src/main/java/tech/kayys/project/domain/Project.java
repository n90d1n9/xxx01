package tech.kayys.project.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import tech.kayys.risk.domain.RiskRegister;

@Entity
@Table(name = "projects")
public class Project extends PanacheEntity {
    
    @Column(name = "project_code", unique = true)
    public String projectCode;
    
    @Column(name = "name")
    public String name;
    
    @Column(length = 2000)
    public String description;
    
    @Column(name = "start_date")
    public LocalDate startDate;
    
    @Column(name = "end_date")
    public LocalDate endDate;
    
    @Enumerated(EnumType.STRING)
    public ProjectStatus status = ProjectStatus.PLANNING;
    
    @Column(name = "project_manager")
    public String projectManager;
    
    @OneToMany(mappedBy = "project", cascade = CascadeType.ALL)
    public List<RiskRegister> risks;

    @Column(name = "create_date")
    public LocalDateTime createdDate;
    @Column(name = "updated_date")
    public LocalDateTime updatedDate;

        /** ✅ Earned Value fields */
    @Column(name = "estimated_budget", precision = 15, scale = 2)
    public BigDecimal estimatedBudget = BigDecimal.ZERO;

    @Column(name = "progress_percentage")
    public double progressPercentage = 0.0; // stored as percent (0–100)

    @Column(name = "actual_cost", precision = 15, scale = 2)
    public BigDecimal actualCost = BigDecimal.ZERO;
    
    public enum ProjectStatus {
        PLANNING("Perencanaan"),
        ACTIVE("Aktif"),
        ON_HOLD("Ditahan"),
        COMPLETED("Selesai"),
        CANCELLED("Dibatalkan");
        
        private final String label;
        ProjectStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
 