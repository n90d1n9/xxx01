package tech.kayys.asset.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.accounting.model.DepreciationMethod;
import tech.kayys.asset.model.AssetCategory;

public class CreateAssetRequest {
    @NotNull public Long companyId;
    @NotNull public Long accountId;
    @NotBlank public String assetName;
    @NotNull public AssetCategory category;
    @NotNull public BigDecimal purchasePrice;
    @NotNull public LocalDate purchaseDate;
    @NotNull public Integer usefulLife;
    @NotNull public DepreciationMethod depreciationMethod;
    public String serialNumber;
    public String location;
    public String supplier;
    public String invoiceNumber;
}