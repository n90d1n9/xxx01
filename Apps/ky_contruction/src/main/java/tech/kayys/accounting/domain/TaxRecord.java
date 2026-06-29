package tech.kayys.accounting.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import tech.kayys.company.domain.Company;

@Entity
@Table(name = "tax_records")
public class TaxRecord extends PanacheEntity {
    @NotNull
    public Integer taxYear;
    
    @NotNull
    public Integer taxMonth;
    
    @Enumerated(EnumType.STRING)
    public TaxType taxType;
    
    @NotNull
    public BigDecimal taxableAmount;
    
    @NotNull
    public BigDecimal taxAmount;
    
    @NotNull
    public BigDecimal taxRate;
    
    @NotNull
    public LocalDate dueDate;
    
    public LocalDate paidDate;
    
    @Enumerated(EnumType.STRING)
    public TaxStatus status = TaxStatus.UNPAID;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
    
    public String sptNumber; // Nomor SPT
    public String ntpnNumber; // Nomor Transaksi Penerimaan Negara
}
