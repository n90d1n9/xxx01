package tech.kayys.project.domain;

import java.time.LocalDate;
import java.util.List;

import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "schedule_activities")
public class ScheduleActivity extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "schedule_id")
    public ProjectSchedule schedule;
    
    @ManyToOne
    @JoinColumn(name = "work_package_id")
    public WorkPackage workPackage;
    
    @Column(name = "activity_id", unique = true)
    public String activityId;
    
    @Column(name = "activity_name")
    public String activityName;
    
    @Column(name = "early_start")
    public LocalDate earlyStart;
    
    @Column(name = "early_finish")
    public LocalDate earlyFinish;
    
    @Column(name = "late_start")
    public LocalDate lateStart;
    
    @Column(name = "late_finish")
    public LocalDate lateFinish;
    
    @Column(name = "duration")
    public Integer duration;
    
    @Column(name = "total_float")
    public Integer totalFloat;
    
    @Column(name = "free_float")
    public Integer freeFloat;
    
    @Column(name = "is_critical")
    public Boolean isCritical = false;
    
    @Column(name = "actual_start")
    public LocalDate actualStart;
    
    @Column(name = "actual_finish")
    public LocalDate actualFinish;
    
    @Column(name = "remaining_duration")
    public Integer remainingDuration;
    
    @Column(name = "percent_complete")
    public BigDecimal percentComplete = BigDecimal.ZERO;
    
    @OneToMany(mappedBy = "successor", cascade = CascadeType.ALL)
    public List<ActivityDependency> predecessors;
    
    @OneToMany(mappedBy = "predecessor", cascade = CascadeType.ALL)
    public List<ActivityDependency> successors;
}
