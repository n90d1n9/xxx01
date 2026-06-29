package tech.kayys.risk.domain;

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

@Entity
@Table(name = "key_risk_indicators")
public class KeyRiskIndicator extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "risk_id")
    public RiskRegister risk;
    
    @Column(name = "indicator_name")
    public String indicatorName;
    
    @Column(name = "description", length = 2000)
    public String description;
    
    @Enumerated(EnumType.STRING)
    public IndicatorType type;
    
    @Column(name = "current_value")
    public BigDecimal currentValue;
    
    @Column(name = "target_value")
    public BigDecimal targetValue;
    
    @Column(name = "threshold_value")
    public BigDecimal thresholdValue;
    
    @Column(name = "alert_threshold")
    public BigDecimal alertThreshold;
    
    @Column(name = "unit_of_measure")
    public String unitOfMeasure;
    
    @Enumerated(EnumType.STRING)
    public FrequencyType frequency;
    
    @Column(name = "last_measured_date")
    public LocalDate lastMeasuredDate;
    
    @Column(name = "next_measurement_date")
    public LocalDate nextMeasurementDate;
    
    @Column(name = "data_source")
    public String dataSource;
    
    @Column(name = "responsible_party")
    public String responsibleParty;
    
    @Column(name = "is_active")
    public Boolean isActive = true;
    
    @OneToMany(mappedBy = "indicator", cascade = CascadeType.ALL)
    public List<KRIMeasurement> measurements;
    
    public enum IndicatorType {
        QUANTITATIVE("Quantitative"),
        QUALITATIVE("Qualitative"),
        FINANCIAL("Financial"),
        OPERATIONAL("Operational"),
        COMPLIANCE("Compliance");
        
        private final String label;
        IndicatorType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum FrequencyType {
        DAILY("Daily"),
        WEEKLY("Weekly"),
        MONTHLY("Monthly"),
        QUARTERLY("Quarterly"),
        SEMI_ANNUALLY("Semi-Annually"),
        ANNUALLY("Annually");
        
        private final String label;
        FrequencyType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
