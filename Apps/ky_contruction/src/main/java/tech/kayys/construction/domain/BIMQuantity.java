package tech.kayys.construction.domain;

import java.time.LocalDateTime;
import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import tech.kayys.finance.domain.BoqItem;

@Entity
@Table(name = "bim_quantities")
public class BIMQuantity extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "bim_model_id")
    public BIMModel bimModel;
    
    @ManyToOne
    @JoinColumn(name = "boq_item_id")
    public BoqItem boqItem;
    
    @Column(name = "element_id")
    public String elementId; // BIM element ID
    
    @Column(name = "element_type")
    public String elementType; // Wall, Slab, Column, etc.
    
    @Column(name = "extracted_quantity", precision = 12, scale = 3)
    public BigDecimal extractedQuantity;
    
    @Column(name = "extraction_date")
    public LocalDateTime extractionDate;
    
    @Column(name = "is_verified")
    public Boolean isVerified = false;
    
    @Column(name = "verification_notes", length = 1000)
    public String verificationNotes;
}
