package com.postfix.model;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.LocalDateTime;

// ─── Virtual Domain ──────────────────────────────────────────────────────────
@Entity
@Table(name = "virtual_domains")
public class VirtualDomainEntity extends PanacheEntityBase {

    @Id
    public String domain;

    @Column(name = "is_active", nullable = false)
    public boolean isActive = true;

    @Column(name = "created_at", nullable = false)
    public LocalDateTime createdAt = LocalDateTime.now();

    public static java.util.List<VirtualDomainEntity> findAllActive() {
        return list("isActive", true);
    }
}


// ─── Virtual Mailbox ──────────────────────────────────────────────────────────
@Entity
@Table(name = "virtual_mailboxes")
class VirtualMailboxEntity extends PanacheEntityBase {

    @Id
    public String email;

    @Column(nullable = false)
    public String domain;

    @Column(name = "local_part", nullable = false)
    public String localPart;

    @Column(nullable = false)
    public String password;  // stored as SHA-512-CRYPT hash

    @Column(name = "is_active", nullable = false)
    public boolean isActive = true;

    @Column(name = "quota_mb", nullable = false)
    public int quotaMb = 1024;

    @Column(name = "used_mb", nullable = false)
    public int usedMb = 0;

    @Column(name = "created_at", nullable = false)
    public LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "last_login")
    public LocalDateTime lastLogin;

    public static java.util.List<VirtualMailboxEntity> findByDomain(String domain) {
        return list("domain", domain);
    }
}


// ─── Virtual Alias ────────────────────────────────────────────────────────────
@Entity
@Table(name = "virtual_aliases")
class VirtualAliasEntity extends PanacheEntityBase {

    @Id
    public String source;

    @Column(nullable = false)
    public String destination;

    @Column(name = "is_active", nullable = false)
    public boolean isActive = true;

    @Column(nullable = false)
    public String domain;

    public static java.util.List<VirtualAliasEntity> findByDomain(String domain) {
        return list("domain", domain);
    }
}


// ─── Mail Log Entry ───────────────────────────────────────────────────────────
@Entity
@Table(name = "mail_logs", indexes = {
    @Index(name = "idx_mail_logs_timestamp", columnList = "timestamp"),
    @Index(name = "idx_mail_logs_level", columnList = "level"),
})
class MailLogEntity extends PanacheEntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(nullable = false)
    public LocalDateTime timestamp;

    @Column(nullable = false, length = 10)
    public String level;  // INFO, WARN, ERROR

    @Column(nullable = false, length = 64)
    public String process;

    @Column(nullable = false, length = 2000)
    public String message;

    @Column(name = "queue_id", length = 32)
    public String queueId;

    @Column(name = "from_addr", length = 256)
    public String fromAddr;

    @Column(name = "to_addr", length = 256)
    public String toAddr;

    @Column(length = 32)
    public String status;

    public Integer delay;

    public static io.quarkus.panache.common.Page DEFAULT_PAGE = io.quarkus.panache.common.Page.ofSize(100);
}
