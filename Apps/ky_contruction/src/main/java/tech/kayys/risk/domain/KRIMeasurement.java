package tech.kayys.risk.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "kri_measurements")
public class KRIMeasurement extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "indicator_id")
    public KeyRiskIndicator indicator;
    
    @Column(name = "measurement_date")
    public LocalDate measurementDate;
    
    @Column(name = "measured_value")
    public BigDecimal measuredValue;
    
    @Column(name = "notes", length = 1000)
    public String notes;
    
    @Column(name = "measured_by")
    public String measuredBy;
    
    @Column(name = "is_breach")
    public Boolean isBreach = false;
    
    @Column(name = "breach_explanation", length = 1000)
    public String breachExplanation;
}