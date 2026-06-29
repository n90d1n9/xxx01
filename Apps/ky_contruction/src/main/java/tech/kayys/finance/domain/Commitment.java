package tech.kayys.finance.domain;

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
import tech.kayys.ai.service.AnomalyDetectionService.CommitmentStatus;
import tech.kayys.ai.service.AnomalyDetectionService.CommitmentType;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "commitments")
public class Commitment extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "commitment_number", unique = true)
    public String commitmentNumber;
    
    @Enumerated(EnumType.STRING)
    public CommitmentType commitmentType;
    
    @Column(name = "vendor_name")
    public String vendorName;
    
    @Column(name = "commitment_amount", precision = 15, scale = 2)
    public BigDecimal commitmentAmount;
    
    @Column(name = "commitment_date")
    public LocalDate commitmentDate;
    
    @Column(name = "delivery_date")
    public LocalDate deliveryDate;
    
    @Enumerated(EnumType.STRING)
    public CommitmentStatus status = CommitmentStatus.ISSUED;
    
    @Column(name = "retention_percentage", precision = 5, scale = 2)
    public BigDecimal retentionPercentage;
    
    @Column(name = "advance_payment", precision = 15, scale = 2)
    public BigDecimal advancePayment = BigDecimal.ZERO;
    
    @OneToMany(mappedBy = "commitment", cascade = CascadeType.ALL)
