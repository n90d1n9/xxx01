package tech.kayys.finance.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.*;
import tech.kayys.project.domain.Project;

import java.math.BigDecimal;

@Entity
@Table(name = "boq_items")
public class BoqItem extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;

    @Column(name = "item_code", nullable = false)
    public String itemCode;

    @Column(name = "description", length = 2000)
    public String description;

    @Column(name = "unit_of_measure")
    public String unitOfMeasure;

    @Column(name = "quantity", precision = 12, scale = 3)
    public BigDecimal quantity;

    @Column(name = "unit_price", precision = 15, scale = 2)
    public BigDecimal unitPrice;

    @Column(name = "total_cost", precision = 15, scale = 2)
    public BigDecimal totalCost;

    @PrePersist
    @PreUpdate
    public void calculateTotalCost() {
        if (quantity != null && unitPrice != null) {
            totalCost = quantity.multiply(unitPrice);
        }
    }
}
