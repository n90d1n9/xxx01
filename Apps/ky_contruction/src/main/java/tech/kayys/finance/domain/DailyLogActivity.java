package tech.kayys.finance.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.*;

@Entity
@Table(name = "daily_log_activities")
public class DailyLogActivity extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "daily_log_id")
    public DailyLog dailyLog;

    @Column(name = "activity_name", nullable = false)
    public String activityName;

    @Column(name = "description", length = 2000)
    public String description;

    @Column(name = "work_hours")
    public Double workHours;

    @Column(name = "workers_count")
    public Integer workersCount;

    @Column(name = "progress_percent")
    public Integer progressPercent;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    public ActivityStatus status = ActivityStatus.IN_PROGRESS;

    public enum ActivityStatus {
        NOT_STARTED,
        IN_PROGRESS,
        COMPLETED,
        DELAYED
    }
}

