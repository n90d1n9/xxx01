package tech.kayys.finance.domain;

import java.time.LocalDateTime;
import java.util.List;
import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.json.bind.annotation.JsonbTransient;
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
import tech.kayys.project.domain.Project;
@Entity
@Table(name = "change_orders")
public class ChangeOrder extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "change_order_number", unique = true)
    public String changeOrderNumber;
    
    @Column(name = "title")
    public String title;
    
    @Column(length = 2000)
    public String description;
    
    @Column(length = 2000)
    public String justification;
    
    @Enumerated(EnumType.STRING)
    public ChangeOrderType type;
    
    @Enumerated(EnumType.STRING)
    public ChangeOrderStatus status = ChangeOrderStatus.DRAFT;
    
    @Column(name = "cost_impact", precision = 15, scale = 2)
    public BigDecimal costImpact;
    
    @Column(name = "time_impact_days")
    public Integer timeImpactDays;
    
    @Column(name = "requested_by")
    public String requestedBy;
    
    @Column(name = "requested_date")
    public LocalDateTime requestedDate;
    
    @Column(name = "reviewed_by")
    public String reviewedBy;
    
    @Column(name = "reviewed_date")
    public LocalDateTime reviewedDate;
    
    @Column(name = "approved_by")
    public String approvedBy;
    
    @Column(name = "approved_date")
    public LocalDateTime approvedDate;
    
    @Column(name = "rejection_reason", length = 1000)
    public String rejectionReason;
    
    @OneToMany(mappedBy = "changeOrder", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonbTransient
    public List<ChangeOrderItem> items;
    
    @OneToMany(mappedBy = "changeOrder", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonbTransient
    public List<ChangeOrderApproval> approvals;
    
    public enum ChangeOrderType {
        SCOPE_CHANGE("Perubahan Lingkup"),
        DESIGN_CHANGE("Perubahan Desain"),
        SPECIFICATION_CHANGE("Perubahan Spesifikasi"),
        ADDITIONAL_WORK("Pekerjaan Tambahan"),
        OMITTED_WORK("Pekerjaan Dikurangi"),
        TIME_EXTENSION("Perpanjangan Waktu");
        
        private final String label;
        ChangeOrderType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum ChangeOrderStatus {
        DRAFT("Draft"),
        SUBMITTED("Diajukan"),
        UNDER_REVIEW("Dalam Review"),
        APPROVED("Disetujui"),
        REJECTED("Ditolak"),
        IMPLEMENTED("Diimplementasi");
        
        private final String label;
        ChangeOrderStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
