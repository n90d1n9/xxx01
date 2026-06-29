package tech.kayys.risk.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "action_progress_updates")
public class ActionProgressUpdate extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "action_id")
    public RiskMitigationAction action;
    
    @Column(name = "update_date")
    public LocalDateTime updateDate = LocalDateTime.now();
    
    @Column(name = "progress_percentage")
    public Integer progressPercentage;
    
    @Column(name = "update_notes", length = 1000)
    public String updateNotes;
    
    @Column(name = "updated_by")
    public String updatedBy;
    
    @Column(name = "challenges", length = 1000)
    public String challenges;
    
    @Column(name = "next_steps", length = 1000)
    public String nextSteps;
}
