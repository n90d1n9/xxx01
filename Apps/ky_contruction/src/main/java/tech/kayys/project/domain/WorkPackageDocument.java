package tech.kayys.project.domain;


import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

@Entity
@Table(name = "work_package_documents")
public class WorkPackageDocument extends PanacheEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "work_package_id", nullable = false)
    public WorkPackage workPackage;

    @Column(nullable = false)
    @NotBlank
    public String documentName;

    @Column(length = 2000)
    public String description;

    @Column(nullable = false)
    @NotBlank
    public String filePath; // storage path or URI

    @Column(name = "uploaded_by", nullable = false)
    public String uploadedBy;

    @Column(name = "uploaded_at", nullable = false)
    public LocalDateTime uploadedAt = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(name = "document_type", nullable = false)
    public DocumentType type = DocumentType.OTHER;

    public enum DocumentType {
        DRAWING,
        SPECIFICATION,
        CONTRACT,
        APPROVAL,
        PHOTO,
        REPORT,
        OTHER
    }
}
