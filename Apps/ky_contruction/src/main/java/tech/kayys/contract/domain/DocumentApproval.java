package tech.kayys.contract.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "document_approvals")
public class DocumentApproval extends PanacheEntity {
    @ManyToOne
    @JoinColumn(name = "document_id")
    public DocumentControl document;
    
    @Column(name = "approver_name")
    public String approverName;
    
    @Column(name = "approver_role")
    public String approverRole;
    
    @Column(name = "approval_date")
    public LocalDateTime approvalDate;
    
    @Enumerated(EnumType.STRING)
    public ApprovalStatus status = ApprovalStatus.PENDING;
    
    @Column(name = "comments", length = 1000)
    public String comments;
    
    @Column(name = "sequence_order")
    public Integer sequenceOrder;
    
    public enum ApprovalStatus {
        PENDING("Menunggu"),
        APPROVED("Disetujui"),
        REJECTED("Ditolak"),
        REVIEWED("Direview");
        
        private final String label;
        ApprovalStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
