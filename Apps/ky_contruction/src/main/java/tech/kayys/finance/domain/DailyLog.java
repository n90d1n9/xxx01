package tech.kayys.finance.domain;

import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "daily_logs")
public class DailyLog extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "log_date")
    public LocalDate logDate;
    
    @Column(name = "weather_morning")
    public String weatherMorning;
    
    @Column(name = "weather_afternoon")
    public String weatherAfternoon;
    
    @Column(name = "temperature_min")
    public Integer temperatureMin;
    
    @Column(name = "temperature_max")
    public Integer temperatureMax;
    
    @Column(name = "work_hours_start")
    public java.time.LocalTime workHoursStart;
    
    @Column(name = "work_hours_end")
    public java.time.LocalTime workHoursEnd;
    
    @Column(name = "total_workers")
    public Integer totalWorkers;
    
    @Column(name = "work_accomplished", length = 2000)
    public String workAccomplished;
    
    @Column(name = "materials_delivered", length = 1000)
    public String materialsDelivered;
    
    @Column(name = "equipment_on_site", length = 1000)
    public String equipmentOnSite;
    
    @Column(name = "issues_problems", length = 2000)
    public String issuesProblems;
    
    @Column(name = "safety_incidents")
    public Integer safetyIncidents = 0;
    
    @Column(name = "quality_issues")
    public Integer qualityIssues = 0;
    
    @Column(name = "visitors", length = 1000)
    public String visitors;
    
    @Column(name = "prepared_by")
    public String preparedBy;
    
    @OneToMany(mappedBy = "dailyLog", cascade = CascadeType.ALL)
    public List<DailyLogPhoto> photos;
    
    @OneToMany(mappedBy = "dailyLog", cascade = CascadeType.ALL)
    public List<DailyLogActivity> activities;
}