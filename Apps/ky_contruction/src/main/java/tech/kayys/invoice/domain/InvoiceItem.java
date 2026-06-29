package tech.kayys.invoice.domain;

@Entity
@Table(name = "invoice_items")
public class InvoiceItem extends PanacheEntity {
    @NotBlank
    public String description;
    
    @NotNull
    public BigDecimal quantity;
    
    @NotBlank
    public String unit;
    
    @NotNull
    public BigDecimal unitPrice;
    
    @NotNull
    public BigDecimal amount;
    
    @ManyToOne
    @JoinColumn(name = "invoice_id")
    public Invoice invoice;
    
    @ManyToOne
    @JoinColumn(name = "account_id")
    public ChartOfAccount account;
}