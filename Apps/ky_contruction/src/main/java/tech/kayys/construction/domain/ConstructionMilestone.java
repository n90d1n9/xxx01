package tech.kayys.construction.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "construction_milestones")
public class ConstructionMilestone extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id")
    public ConstructionPhase phase;
    
    @NotBlank
    @Column(name = "milestone_code", nullable = false)
    public String milestoneCode;
    
    @NotBlank
    @Column(name = "milestone_name", nullable = false)
    public String milestoneName;
    
    @Column(length = 2000)
    public String description;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public MilestoneType milestoneType;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public MilestoneCategory category;
    
    @Column(name = "planned_date", nullable = false)
    public LocalDate plannedDate;
    
    @Column(name = "baseline_date")
    public LocalDate baselineDate;
    
    @Column(name = "actual_date")
    public LocalDate actualDate;
    
    @Column(name = "critical_milestone")
    public Boolean criticalMilestone = false;
    
    @Column(name = "contractual_milestone")
    public Boolean contractualMilestone = false;
    
    @Column(name = "client_milestone")
    public Boolean clientMilestone = false;
    
    @DecimalMin("0.00")
    @Column(name = "milestone_payment_percentage", precision = 5, scale = 2)
    public BigDecimal milestonePaymentPercentage = BigDecimal.ZERO;
    
    @DecimalMin("0.00")
    @Column(name = "milestone_payment_amount", precision = 15, scale = 2)
    public BigDecimal milestonePaymentAmount = BigDecimal.ZERO;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public MilestoneStatus status = MilestoneStatus.NOT_STARTED;
    
    @Column(name = "completion_criteria", length = 2000, nullable = false)
    public String completionCriteria;
    
    @Column(name = "deliverables", length = 2000)
    public String deliverables;
    
    @Column(name = "dependencies", length = 1500)
    public String dependencies;
    
    @Column(name = "responsible_party")
    public String responsibleParty;
    
    @Column(name = "approval_required")
    public Boolean approvalRequired = false;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "approval_date")
    public LocalDate approvalDate;
    
    @Column(name = "comments", length = 2000)
    public String comments;
    
    // Indonesian specific fields
    @Column(name = "permit_required")
    public Boolean permitRequired = false;
    
    @Column(name = "permit_reference")
    public String permitReference;
    
    @Column(name = "inspection_required")
    public Boolean inspectionRequired = false;
    
    @Column(name = "inspection_agency")
    public String inspectionAgency;
    
    @OneToMany(mappedBy = "milestone", cascade = CascadeType.ALL)
    public List<MilestoneDocument> documents;
    
    public enum MilestoneType {
        START_MILESTONE("Start Milestone"),
        FINISH_MILESTONE("Finish Milestone"),
        DECISION_MILESTONE("Decision Milestone"),
        DELIVERY_MILESTONE("Delivery Milestone"),
        APPROVAL_MILESTONE("Approval Milestone"),
        PAYMENT_MILESTONE("Payment Milestone");
        
        private final String label;
        
        MilestoneType(String label) {
            this.label = label;
        }
        
        public String getLabel() { return label; }
    }
    
    public enum MilestoneCategory {
        PROJECT_INITIATION("Inisiasi Proyek", "Project initiation milestones"),
        DESIGN_COMPLETION("Penyelesaian Desain", "Design completion milestones"),
        PERMIT_APPROVAL("Persetujuan Izin", "Permit approval milestones"),
        CONSTRUCTION_START("Mulai Konstruksi", "Construction start milestones"),
        STRUCTURAL_COMPLETION("Selesai Struktur", "Structural completion milestones"),
        BUILDING_ENVELOPE("Selubung Bangunan", "Building envelope milestones"),
        MEP_COMPLETION("Selesai MEP", "MEP completion milestones"),
        FINISHING_COMPLETION("Selesai Finishing", "Finishing completion milestones"),
        TESTING_COMMISSIONING("Testing & Commissioning", "Testing and commissioning milestones"),
        HANDOVER("Serah Terima", "Handover milestones"),
        PROJECT_CLOSURE("Penutupan Proyek", "Project closure milestones");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        MilestoneCategory(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum MilestoneStatus {
        NOT_STARTED("Belum Dimulai"),
        IN_PROGRESS("Dalam Proses"),
        COMPLETED("Selesai"),
        DELAYED("Terlambat"),
        CANCELLED("Dibatalkan"),
        ON_HOLD("Ditunda");
        
        private final String indonesianLabel;
        
        MilestoneStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public Boolean isOverdue() {
        if (actualDate != null || status == MilestoneStatus.COMPLETED || status == MilestoneStatus.CANCELLED) {
            return false;
        }
        return LocalDate.now().isAfter(plannedDate);
    }
    
    public Long getDaysOverdue() {
        if (!isOverdue()) return 0L;
        return (long) plannedDate.until(LocalDate.now()).getDays();
    }
}
