package tech.kayys.contract.domain;


import java.time.LocalDateTime;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;


@Entity
@Table(name = "document_versions")
public class DocumentVersion extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "document_id")
    public DocumentControl document;
    
    @Column(name = "version_number")
    public String versionNumber;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_hash")
    public String fileHash; // For integrity verification
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "upload_date")
    public LocalDateTime uploadDate;
    
    @Column(name = "uploaded_by")
    public String uploadedBy;
    
    @Column(name = "change_description", length = 1000)
    public String changeDescription;
    
    @Column(name = "is_current")
    public Boolean isCurrent = false;
}
