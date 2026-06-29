package tech.kayys.construction.domain;

import java.time.LocalDate;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "drawing_transmittals")
public class DrawingTransmittal extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "drawing_id", nullable = false)
    public ConstructionDrawing drawing;
    
    @Column(name = "transmittal_number", unique = true, nullable = false)
    public String transmittalNumber;
    
    @Column(name = "transmittal_date", nullable = false)
    public LocalDate transmittalDate;
    
    @Column(name = "transmitted_by", nullable = false)
    public String transmittedBy;
    
    @Column(name = "transmitted_to", nullable = false)
    public String transmittedTo;
    
    @Column(name = "organization")
    public String organization;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public TransmittalPurpose purpose;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public TransmittalMethod method = TransmittalMethod.EMAIL;
    
    @Column(name = "cover_letter", length = 2000)
    public String coverLetter;
    
    @Column(name = "action_required")
    @Enumerated(EnumType.STRING)
    public ActionRequired actionRequired;
    
    @Column(name = "response_required_by")
    public LocalDate responseRequiredBy;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public TransmittalStatus status = TransmittalStatus.SENT;
    
    @Column(name = "acknowledgment_date")
    public LocalDate acknowledgmentDate;
    
    @Column(name = "acknowledged_by")
    public String acknowledgedBy;
    
    @Column(name = "delivery_receipt")
    public String deliveryReceipt;
    
    @Column(name = "number_of_copies")
    public Integer numberOfCopies = 1;
    
    public enum TransmittalPurpose {
        FOR_APPROVAL("Untuk Persetujuan"),
        FOR_REVIEW("Untuk Review"),
        FOR_INFORMATION("Untuk Informasi"),
        FOR_CONSTRUCTION("Untuk Konstruksi"),
        FOR_TENDER("Untuk Tender"),
        AS_BUILT("As Built"),
        RESUBMISSION("Resubmisi");
        
        private final String indonesianLabel;
        
        TransmittalPurpose(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum TransmittalMethod {
        EMAIL("Email"),
        COURIER("Kurir"),
        HAND_DELIVERY("Antar Langsung"),
        REGISTERED_MAIL("Pos Tercatat"),
        CLOUD_SHARING("Cloud Sharing");
        
        private final String indonesianLabel;
        
        TransmittalMethod(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum ActionRequired {
        NO_ACTION("Tidak Ada Aksi"),
        REVIEW_AND_COMMENT("Review dan Komentar"),
        APPROVAL_REQUIRED("Persetujuan Diperlukan"),
        FOR_INFORMATION_ONLY("Hanya Untuk Informasi"),
        RETURN_WITH_COMMENTS("Kembalikan dengan Komentar");
        
        private final String indonesianLabel;
        
        ActionRequired(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public enum TransmittalStatus {
        SENT("Dikirim"),
        DELIVERED("Terkirim"),
        ACKNOWLEDGED("Diakui"),
        RESPONDED("Direspons"),
        CLOSED("Ditutup");
        
        private final String indonesianLabel;
        
        TransmittalStatus(String indonesianLabel) {
            this.indonesianLabel = indonesianLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
    }
    
    public Boolean isOverdue() {
        return responseRequiredBy != null && 
               responseRequiredBy.isBefore(LocalDate.now()) && 
               status != TransmittalStatus.RESPONDED && 
               status != TransmittalStatus.CLOSED;
    }
}
