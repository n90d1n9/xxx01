package tech.kayys.finance.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "change_order_approvals")
public class ChangeOrderApproval extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "change_order_id")
    public ChangeOrder changeOrder;

    @Column(name = "approver")
    public String approver;

    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    public ApprovalRole role;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    public ApprovalStatus status = ApprovalStatus.PENDING;

    @Column(name = "comments", length = 2000)
    public String comments;

    @Column(name = "decision_date")
    public LocalDateTime decisionDate;

    public enum ApprovalRole {
        PROJECT_MANAGER,
        ENGINEER,
        FINANCE,
        CLIENT
    }

    public enum ApprovalStatus {
        PENDING,
        APPROVED,
        REJECTED
    }
}
