package tech.kayys.compliance.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "hspk_rates")
public class HSPKRate extends PanacheEntity {
    
    @Column(name = "hspk_code", unique = true)
    public String hspkCode;
    
    @Column(name = "description")
    public String description;
    
    @Column(name = "unit")
    public String unit;
    
    @Column(name = "region")
    public String region;
