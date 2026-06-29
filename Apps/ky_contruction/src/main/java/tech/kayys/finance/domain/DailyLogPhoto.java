package tech.kayys.finance.domain;

import java.time.LocalDateTime;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "daily_log_photos")
public class DailyLogPhoto extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "daily_log_id")
    public DailyLog dailyLog;
    
    @Column(name = "photo_path")
    public String photoPath;
    
    @Column(name = "photo_description")
    public String photoDescription;
    
    @Column(name = "location_latitude")
    public Double locationLatitude;
    
    @Column(name = "location_longitude")
    public Double locationLongitude;
    
    @Column(name = "taken_at")
    public LocalDateTime takenAt;
    
    @Column(name = "taken_by")
    public String takenBy;
}
