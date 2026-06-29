package tech.kayys.finance.domain;

import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "change_order_items")
public class ChangeOrderItem extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "change_order_id")
    public ChangeOrder changeOrder;
    
    @ManyToOne
    @JoinColumn(name = "boq_item_id")
    public BoqItem boqItem;
    
    @Column(name = "item_description", length = 1000)
    public String itemDescription;
    
    @Column(name = "original_quantity", precision = 12, scale = 3)
    public BigDecimal originalQuantity;
    
    @Column(name = "new_quantity", precision = 12, scale = 3)
    public BigDecimal newQuantity;
    
    @Column(name = "quantity_change", precision = 12, scale = 3)
    public BigDecimal quantityChange;
    
    @Column(name = "unit_price", precision = 15, scale = 2)
    public BigDecimal unitPrice;
    
    @Column(name = "total_cost_impact", precision = 15, scale = 2)
    public BigDecimal totalCostImpact;
    
    @PrePersist
    @PreUpdate
    public void calculateImpact() {
        if (originalQuantity != null && newQuantity != null) {
            quantityChange = newQuantity.subtract(originalQuantity);
        }
        if (quantityChange != null && unitPrice != null) {
            totalCostImpact = quantityChange.multiply(unitPrice);
        }
    }
}