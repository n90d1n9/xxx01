package tech.kayys.project.domain;


import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;

@Entity
@Table(name = "project_schedules")
public class ProjectSchedule extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "schedule_name")
    public String scheduleName;
    
    @Column(name = "schedule_type")
    @Enumerated(EnumType.STRING)
    public ScheduleType scheduleType;
    
    @Column(name = "baseline_date")
    public LocalDate baselineDate;
    
    @Column(name = "last_update")
    public LocalDateTime lastUpdate;
    
    @Column(name = "critical_path_duration")
    public Integer criticalPathDuration; // in days
    
    @Column(name = "total_float")
    public Integer totalFloat;
    
    @Column(name = "is_current")
    public Boolean isCurrent = false;
    
    @OneToMany(mappedBy = "schedule", cascade = CascadeType.ALL)
    public List<ScheduleActivity> activities;
    
    public enum ScheduleType {
        BASELINE("Baseline"),
        CURRENT("Current"),
        FORECAST("Forecast"),
        WHAT_IF("What-If Analysis");
        
        private final String label;
        ScheduleType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
