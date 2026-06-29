package tech.kayys.company.dto;

public class CreateTransactionRequest {
    @NotNull public Long companyId;
    @NotNull public Long debitAccountId;
    @NotNull public Long creditAccountId;
    @NotNull public LocalDate transactionDate;
    @NotBlank public String description;
    @NotNull public BigDecimal amount;
    @NotNull public TransactionType transactionType;
    public String reference;
}
