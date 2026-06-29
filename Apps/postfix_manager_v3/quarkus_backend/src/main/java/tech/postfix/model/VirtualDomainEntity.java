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





