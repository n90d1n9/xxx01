package tech.kayys.currency.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "currencies")
public class Currency extends PanacheEntity {

    @Column(length = 3, unique = true, nullable = false)
    public String code; // ISO code e.g., USD, IDR, EUR

    @Column(length = 100, nullable = false)
    public String name; // e.g., US Dollar

    @Column(length = 10)
    public String symbol; // $, Rp, €

    @Column(name = "is_active", nullable = false)
    public boolean active = true;

    @Column(name = "is_default", nullable = false)
    public boolean defaultCurrency = false;

    // --- Audit Columns ---
    @Column(name = "created_by")
    public String createdBy;

    @Column(name = "created_date", nullable = false, updatable = false)
    public LocalDateTime createdDate;

    @Column(name = "last_modified_by")
    public String lastModifiedBy;

    @Column(name = "last_modified_date")
    public LocalDateTime lastModifiedDate;

    @PrePersist
    public void prePersist() {
        if (createdDate == null) {
            createdDate = LocalDateTime.now();
        }
    }

    @PreUpdate
    public void preUpdate() {
        lastModifiedDate = LocalDateTime.now();
    }
}
