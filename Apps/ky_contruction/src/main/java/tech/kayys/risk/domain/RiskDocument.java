package tech.kayys.risk.domain;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "risk_document")
public class RiskDocument {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "risk_id", nullable = false)
    public RiskRegister risk;

    @Column(nullable = false, length = 255)
    public String fileName;

    @Column(length = 500)
    public String description;

    @Column(name = "file_path", length = 500, nullable = false)
    public String filePath;

    @Column(name = "file_type", length = 100)
    public String fileType;

    @Column(name = "file_size")
    public Long fileSize;

    @Column(name = "uploaded_by", length = 100)
    public String uploadedBy;

    @CreationTimestamp
    @Column(name = "uploaded_date")
    public LocalDateTime uploadedDate;

    @UpdateTimestamp
    @Column(name = "updated_date")
    public LocalDateTime updatedDate;

    @Column(name = "version")
    public Integer version = 1;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    public DocumentStatus status = DocumentStatus.ACTIVE;

    public enum DocumentStatus {
        ACTIVE,
        ARCHIVED,
        DELETED
    }
}
