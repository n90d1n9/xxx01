package tech.kayys.finance.domain;

import java.time.LocalDate;
import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "cash_flow_forecast")
public class CashFlowForecast extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "forecast_date")
    public LocalDate forecastDate;
    
    @Column(name = "period_start")
    public LocalDate periodStart;
    
    @Column(name = "period_end")
    public LocalDate periodEnd;
    
    @Column(name = "forecasted_inflow", precision = 15, scale = 2)
    public BigDecimal forecastedInflow;
    
    @Column(name = "forecasted_outflow", precision = 15, scale = 2)
    public BigDecimal forecastedOutflow;
    
    @Column(name = "net_cash_flow", precision = 15, scale = 2)
    public BigDecimal netCashFlow;
    
    @Column(name = "cumulative_cash_flow", precision = 15, scale = 2)
    public BigDecimal cumulativeCashFlow;
    
    @Column(name = "actual_inflow", precision = 15, scale = 2)
    public BigDecimal actualInflow;
    
    @Column(name = "actual_outflow", precision = 15, scale = 2)
    public BigDecimal actualOutflow;
    
    @Column(name = "variance", precision = 15, scale = 2)
    public BigDecimal variance;
    
    @PrePersist
    @PreUpdate
    public void calculateValues() {
        if (forecastedInflow != null && forecastedOutflow != null) {
            netCashFlow = forecastedInflow.subtract(forecastedOutflow);
        }
        if (actualInflow != null && actualOutflow != null && netCashFlow != null) {
            BigDecimal actualNet = actualInflow.subtract(actualOutflow);
            variance = actualNet.subtract(netCashFlow);
        }
    }
}
