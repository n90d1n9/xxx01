package tech.kayys.invoice.model;

public class CreateInvoiceRequest {
    @NotNull public Long companyId;
    @NotNull public LocalDate invoiceDate;
    @NotNull public LocalDate dueDate;
    @NotBlank public String customerName;
    @NotBlank public String customerAddress;
    public String customerNpwp;
    public String description;
    public String paymentTerms;
    @NotNull public List<CreateInvoiceItemRequest> items;
}