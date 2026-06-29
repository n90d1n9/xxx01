package tech.kayys.contract.domain;

import java.time.LocalDate;
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
import jakarta.persistence.Table;
import tech.kayys.finance.domain.ProgressPayment;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "contracts")
public class Contract extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "contract_number", unique = true)
    public String contractNumber;
    
    @Column(name = "contract_title")
    public String contractTitle;
    
    @Enumerated(EnumType.STRING)
    public ContractType contractType;
    
    @Enumerated(EnumType.STRING)
    public ContractStatus status = ContractStatus.DRAFT;
    
    @Column(name = "contractor_name")
    public String contractorName;
    
    @Column(name = "contract_value", precision = 15, scale = 2)
    public BigDecimal contractValue;
    
    @Column(name = "contract_date")
    public LocalDate contractDate;
    
    @Column(name = "commencement_date")
    public LocalDate commencementDate;
    
    @Column(name = "completion_date")
    public LocalDate completionDate;
    
    @Column(name = "maintenance_period_months")
    public Integer maintenancePeriodMonths;
    
    @Column(name = "retention_percentage", precision = 5, scale = 2)
    public BigDecimal retentionPercentage;
    
    @Column(name = "performance_bond_percentage", precision = 5, scale = 2)
    public BigDecimal performanceBondPercentage;
    
    @Column(name = "advance_payment_percentage", precision = 5, scale = 2)
    public BigDecimal advancePaymentPercentage;
    
    @OneToMany(mappedBy = "contract", cascade = CascadeType.ALL)
    public List<ContractDocument> documents;
    
    @OneToMany(mappedBy = "contract", cascade = CascadeType.ALL)
    public List<ContractMilestone> milestones;
    
    @OneToMany(mappedBy = "contract", cascade = CascadeType.ALL)
    public List<ProgressPayment> progressPayments;
    
    public enum ContractType {
        LUMP_SUM("Lump Sum"),
        UNIT_PRICE("Unit Price"),
        COST_PLUS("Cost Plus Fee"),
        DESIGN_BUILD("Design-Build"),
        EPC("Engineering, Procurement, Construction"),
        CONSTRUCTION_MANAGEMENT("Construction Management");
        
        private final String label;
        ContractType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum ContractStatus {
        DRAFT("Draft"),
        TENDER("Tender"),
        AWARDED("Awarded"),
        SIGNED("Signed"),
        ACTIVE("Active"),
        COMPLETED("Completed"),
        TERMINATED("Terminated");
        
        private final String label;
        ContractStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}