package tech.kayys.contract.domain;

import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "document_transmittals")
public class DocumentTransmittal extends PanacheEntity {
    @ManyToOne
    @JoinColumn(name = "document_id")
    public DocumentControl document;
    
    @Column(name = "transmittal_number", unique = true)
    public String transmittalNumber;
    
    @Column(name = "transmittal_date")
    public LocalDate transmittalDate;
    
    @Column(name = "from_organization")
    public String fromOrganization;
    
    @Column(name = "to_organization")
    public String toOrganization;
    
    @Column(name = "attention")
    public String attention;
    
    @Column(name = "subject")
    public String subject;
    
    @Enumerated(EnumType.STRING)
    public TransmittalPurpose purpose;
    
    @Column(name = "remarks", length = 1000)
    public String remarks;
    
    public enum TransmittalPurpose {
        FOR_APPROVAL("Untuk Persetujuan"),
        FOR_REVIEW("Untuk Review"),
        FOR_INFORMATION("Untuk Informasi"),
        FOR_CONSTRUCTION("Untuk Konstruksi"),
        AS_BUILT("As Built");
        
        private final String label;
        TransmittalPurpose(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
