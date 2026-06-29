package tech.kayys.invoice.model;

public class CreateInvoiceItemRequest {
    @NotBlank public String description;
    @NotNull public BigDecimal quantity;
    @NotBlank public String unit;
    @NotNull public BigDecimal unitPrice;
    @NotNull public Long accountId;
}
