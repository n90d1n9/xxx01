package tech.kayys.contract.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "contract_documents")
public class ContractDocument extends PanacheEntity {
    @ManyToOne
    @JoinColumn(name = "contract_id")
    public Contract contract;
    
    @Column(name = "document_name")
    public String documentName;
    
    @Enumerated(EnumType.STRING)
    public DocumentType documentType;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "upload_date")
    public LocalDateTime uploadDate;
    
    @Column(name = "uploaded_by")
    public String uploadedBy;
    
    @Column(name = "is_signed")
    public Boolean isSigned = false;
    
    public enum DocumentType {
        CONTRACT_AGREEMENT("Kontrak Utama"),
        ADDENDUM("Adendum"),
        VARIATION_ORDER("Variation Order"),
        TECHNICAL_SPECIFICATION("Spesifikasi Teknis"),
        DRAWING("Gambar Kerja"),
        BQ("Bill of Quantity"),
        INSURANCE_CERTIFICATE("Sertifikat Asuransi"),
        PERFORMANCE_BOND("Jaminan Pelaksanaan"),
        BANK_GUARANTEE("Bank Garansi");
        
        private final String label;
        DocumentType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}

