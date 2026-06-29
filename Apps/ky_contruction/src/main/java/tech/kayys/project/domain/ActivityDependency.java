package tech.kayys.project.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "activity_dependencies")
public class ActivityDependency extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "predecessor_id")
    public ScheduleActivity predecessor;
    
    @ManyToOne
    @JoinColumn(name = "successor_id")
    public ScheduleActivity successor;
    
    @Enumerated(EnumType.STRING)
    public DependencyType dependencyType;
    
    @Column(name = "lag_duration")
    public Integer lagDuration = 0;
    
    public enum DependencyType {
        FINISH_TO_START("FS"),
        START_TO_START("SS"),
        FINISH_TO_FINISH("FF"),
        START_TO_FINISH("SF");
        
        private final String code;
        DependencyType(String code) { this.code = code; }
        public String getCode() { return code; }
    }
}
