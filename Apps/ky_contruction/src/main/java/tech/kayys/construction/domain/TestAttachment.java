package tech.kayys.construction.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "test_attachments")
public class TestAttachment extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "testing_id", nullable = false)
    public ConstructionTesting testing;
    
    @NotBlank
    @Column(name = "attachment_name", nullable = false)
    public String attachmentName;
    
    @Column(name = "attachment_description", length = 1000)
    public String attachmentDescription;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public AttachmentType attachmentType;
    
    @Column(name = "file_path")
    public String filePath;
    
    @Column(name = "file_size")
    public Long fileSize;
    
    @Column(name = "file_format")
    public String fileFormat;
    
    @Column(name = "upload_date")
    public LocalDateTime uploadDate;
    
    @Column(name = "uploaded_by")
    public String uploadedBy;
    
    @Column(name = "is_mandatory")
    public Boolean isMandatory = false;
    
    @Column(name = "sequence_number")
    public Integer sequenceNumber;
    
    @Column(name = "checksum")
    public String checksum;
    
    // For image/photo attachments
    @Column(name = "image_width")
    public Integer imageWidth;
    
    @Column(name = "image_height")
    public Integer imageHeight;
    
    @Column(name = "geolocation_latitude")
    public Double geolocationLatitude;
    
    @Column(name = "geolocation_longitude")
    public Double geolocationLongitude;
    
    @Column(name = "camera_settings", length = 500)
    public String cameraSettings;
    
    public enum AttachmentType {
        TEST_REPORT("Laporan Test", "Official test report document"),
        CERTIFICATE("Sertifikat", "Test certificate or calibration certificate"),
        PHOTO_BEFORE("Foto Sebelum", "Before test photograph"),
        PHOTO_DURING("Foto Selama", "During test photograph"),
        PHOTO_AFTER("Foto Setelah", "After test photograph"),
        VIDEO_RECORDING("Video", "Test procedure video recording"),
        DATA_SHEET("Data Sheet", "Raw test data sheet"),
        CALIBRATION_CERT("Sertifikat Kalibrasi", "Equipment calibration certificate"),
        SAMPLE_PHOTO("Foto Sampel", "Test sample photograph"),
        EQUIPMENT_PHOTO("Foto Alat", "Test equipment photograph"),
        CALCULATION_SHEET("Lembar Perhitungan", "Test calculation worksheet");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        AttachmentType(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    @PrePersist
    public void prePersist() {
        if (uploadDate == null) {
            uploadDate = LocalDateTime.now();
        }
    }
}
