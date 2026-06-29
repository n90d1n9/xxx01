package tech.kayys.invoice.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.company.domain.Company;

@Entity
@Table(name = "invoices")
public class Invoice extends PanacheEntity {
    @NotBlank
    @Column(unique = true)
    public String invoiceNumber;
    
    @NotNull
    public LocalDate invoiceDate;
    
    @NotNull
    public LocalDate dueDate;
    
    @NotBlank
    public String customerName;
    
    @NotBlank
    public String customerAddress;
    
    public String customerNpwp;
    
    @NotNull
    public BigDecimal subtotal;
    
    @NotNull
    public BigDecimal ppnAmount; // PPN 11%
    
    @NotNull
    public BigDecimal pphAmount = BigDecimal.ZERO; // PPh if applicable
    
    @NotNull
    public BigDecimal totalAmount;
    
    @Enumerated(EnumType.STRING)
    public InvoiceStatus status = InvoiceStatus.DRAFT;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    public Company company;
    
    @OneToMany(mappedBy = "invoice", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<InvoiceItem> items = new ArrayList<>();
    
    public String description;
    public String paymentTerms;
    public String fakturPajakNumber; // Indonesian tax invoice number
    public LocalDate paidDate;
}
