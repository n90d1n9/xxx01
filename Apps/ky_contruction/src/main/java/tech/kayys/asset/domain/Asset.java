package tech.kayys.asset.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.accounting.domain.ChartOfAccount;
import tech.kayys.accounting.model.DepreciationMethod;
import tech.kayys.asset.model.AssetCategory;
import tech.kayys.asset.model.AssetStatus;
import tech.kayys.company.domain.Company;

@Entity
@Table(name = "assets")
public class Asset extends PanacheEntity {
    @NotBlank
    public String assetCode;
    
    @NotBlank
    public String assetName;
    
    @Enumerated(EnumType.STRING)
    public AssetCategory category;
    
    @NotNull
    public BigDecimal purchasePrice;
    
    @NotNull
    public BigDecimal currentValue;
    
    @NotNull
    public LocalDate purchaseDate;
    
    @NotNull
    public Integer usefulLife; // in years
    
    @Enumerated(EnumType.STRING)
    public DepreciationMethod depreciationMethod;
    
    @NotNull
    public BigDecimal accumulatedDepreciation = BigDecimal.ZERO;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
    
    @ManyToOne
    @JoinColumn(name = "account_id")
    public ChartOfAccount account;
    
    public String serialNumber;
    public String location;
    public String supplier;
    public String invoiceNumber;
    
    @NotNull
    public AssetStatus status = AssetStatus.ACTIVE;
}