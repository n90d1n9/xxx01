package tech.kayys.contract.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "contract_milestones")
public class ContractMilestone extends PanacheEntity {
    @ManyToOne
    @JoinColumn(name = "contract_id")
    public Contract contract;
    
    @Column(name = "milestone_name")
    public String milestoneName;
    
    @Column(name = "milestone_description", length = 1000)
    public String milestoneDescription;
    
    @Column(name = "planned_start_date")
    public LocalDate plannedStartDate;
    
    @Column(name = "planned_end_date")
    public LocalDate plannedEndDate;
    
    @Column(name = "actual_start_date")
    public LocalDate actualStartDate;
    
    @Column(name = "actual_end_date")
    public LocalDate actualEndDate;
    
    @Column(name = "progress_percentage", precision = 5, scale = 2)
    public BigDecimal progressPercentage = BigDecimal.ZERO;
    
    @Enumerated(EnumType.STRING)
    public MilestoneStatus status = MilestoneStatus.NOT_STARTED;
    
    @Column(name = "milestone_value", precision = 15, scale = 2)
    public BigDecimal milestoneValue;
    
    @Column(name = "sequence_number")
    public Integer sequenceNumber;
    
    public enum MilestoneStatus {
        NOT_STARTED("Belum Dimulai"),
        IN_PROGRESS("Dalam Pengerjaan"),
        COMPLETED("Selesai"),
        DELAYED("Terlambat"),
        CANCELLED("Dibatalkan");
        
        private final String label;
        MilestoneStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
