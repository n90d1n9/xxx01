package tech.kayys.risk.dto;

import java.util.Objects;

import tech.kayys.risk.model.RiskImpact;
import tech.kayys.risk.model.RiskProbability;

public class RiskCoordinate {
    public RiskProbability probability;
    public RiskImpact impact;
    
    public RiskCoordinate(RiskProbability probability, RiskImpact impact) {
        this.probability = probability;
        this.impact = impact;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RiskCoordinate)) return false;
        RiskCoordinate that = (RiskCoordinate) o;
        return probability == that.probability && impact == that.impact;
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(probability, impact);
    }
}
