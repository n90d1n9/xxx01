package tech.kayys.risk.domain;

import jakarta.persistence.*;
import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.model.RiskImpact;
import tech.kayys.risk.model.RiskProbability;
import tech.kayys.risk.model.RiskType;

@Entity
@Table(name = "risk_template")
public class RiskTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(nullable = false, unique = true)
    public String code; // e.g., "IT-SEC-001"

    @Column(nullable = false, length = 255)
    public String title;

    @Column(length = 2000)
    public String description;

    @Enumerated(EnumType.STRING)
    public RiskCategory category;

    @Enumerated(EnumType.STRING)
    public RiskType type;

    @Enumerated(EnumType.STRING)
    public RiskProbability defaultProbability;

    @Enumerated(EnumType.STRING)
    public RiskImpact defaultImpact;

    @Column(length = 2000)
    public String mitigationSuggestion;

    @Column(length = 2000)
    public String contingencySuggestion;
}
