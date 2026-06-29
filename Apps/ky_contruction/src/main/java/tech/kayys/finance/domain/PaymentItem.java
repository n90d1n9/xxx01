package tech.kayys.finance.domain;

import java.math.BigDecimal;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "payment_items")
public class PaymentItem extends PanacheEntity {
    @ManyToOne
    @JoinColumn(name = "progress_payment_id")
    public ProgressPayment progressPayment;
    
    @Column(name = "item_description")
    public String itemDescription;
    
    @Column(name = "unit")
    public String unit;
    
    @Column(name = "unit_price", precision = 15, scale = 2)
    public BigDecimal unitPrice;
    
    @Column(name = "previous_quantity", precision = 10, scale = 2)
    public BigDecimal previousQuantity = BigDecimal.ZERO;
    
    @Column(name = "current_quantity", precision = 10, scale = 2)
    public BigDecimal currentQuantity;
    
    @Column(name = "total_quantity", precision = 10, scale = 2)
    public BigDecimal totalQuantity;
    
    @Column(name = "current_amount", precision = 15, scale = 2)
    public BigDecimal currentAmount;
    
    @Column(name = "total_amount", precision = 15, scale = 2)
    public BigDecimal totalAmount;
}
