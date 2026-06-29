package tech.kayys.construction.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "construction_testing")
public class ConstructionTesting extends PanacheEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "phase_id")
    public ConstructionPhase phase;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id")
    public PhaseActivity activity;
    
    @NotBlank
    @Column(name = "test_number", unique = true, nullable = false)
    public String testNumber;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public TestType testType;
    
    @NotBlank
    @Column(name = "test_description", nullable = false)
    public String testDescription;
    
    @Column(name = "test_location")
    public String testLocation;
    
    @Column(name = "test_date", nullable = false)
    public LocalDate testDate;
    
    @Column(name = "test_time")
    public java.time.LocalTime testTime;
    
    @Column(name = "weather_conditions")
    public String weatherConditions;
    
    @Column(name = "temperature")
    public Double temperature; // Celsius
    
    @Column(name = "humidity_percentage")
    public Double humidityPercentage;
    
    // Test personnel
    @Column(name = "tested_by", nullable = false)
    public String testedBy;
    
    @Column(name = "witnessed_by")
    public String witnessedBy;
    
    @Column(name = "laboratory")
    public String laboratory;
    
    @Column(name = "test_equipment_used", length = 1000)
    public String testEquipmentUsed;
    
    // Standards and procedures
    @Column(name = "test_standard", nullable = false)
    public String testStandard; // SNI, ASTM, etc.
    
    @Column(name = "test_procedure", length = 2000)
    public String testProcedure;
    
    @Column(name = "acceptance_criteria", length = 1000, nullable = false)
    public String acceptanceCriteria;
    
    // Results
    @Column(name = "test_results", length = 3000, nullable = false)
    public String testResults;
    
    @Column(name = "numerical_result", precision = 15, scale = 4)
    public BigDecimal numericalResult;
    
    @Column(name = "result_unit")
    public String resultUnit;
    
    @Column(name = "minimum_required_value", precision = 15, scale = 4)
    public BigDecimal minimumRequiredValue;
    
    @Column(name = "maximum_allowed_value", precision = 15, scale = 4)
    public BigDecimal maximumAllowedValue;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public TestResult testResult;
    
    @Column(name = "remarks", length = 2000)
    public String remarks;
    
    @Column(name = "corrective_action_required")
    public Boolean correctiveActionRequired = false;
    
    @Column(name = "corrective_action", length = 2000)
    public String correctiveAction;
    
    @Column(name = "retest_required")
    public Boolean retestRequired = false;
    
    @Column(name = "retest_date")
    public LocalDate retestDate;
    
    // Certificate and reporting
    @Column(name = "certificate_number")
    public String certificateNumber;
    
    @Column(name = "certificate_date")
    public LocalDate certificateDate;
    
    @Column(name = "report_file_path")
    public String reportFilePath;
    
    @OneToMany(mappedBy = "testing", cascade = CascadeType.ALL)
    public List<TestAttachment> attachments;
    
    public enum TestType {
        CONCRETE_COMPRESSIVE_STRENGTH("Kuat Tekan Beton", "Concrete compressive strength test"),
        CONCRETE_SLUMP("Slump Beton", "Concrete slump test"),
        SOIL_BEARING_CAPACITY("Daya Dukung Tanah", "Soil bearing capacity test"),
        STEEL_TENSILE_STRENGTH("Kuat Tarik Baja", "Steel tensile strength test"),
        WELDING_TEST("Uji Las", "Welding test"),
        WATER_PERMEABILITY("Permeabilitas Air", "Water permeability test"),
        ELECTRICAL_INSULATION("Isolasi Listrik", "Electrical insulation test"),
        FIRE_RESISTANCE("Ketahanan Api", "Fire resistance test"),
        ACOUSTIC_TEST("Uji Akustik", "Acoustic test"),
        THERMAL_TEST("Uji Termal", "Thermal test"),
        VIBRATION_TEST("Uji Getaran", "Vibration test"),
        LOAD_TEST("Uji Beban", "Load test"),
        LEAK_TEST("Uji Kebocoran", "Leak test"),
        PERFORMANCE_TEST("Uji Kinerja", "Performance test");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        TestType(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
    
    public enum TestResult {
        PASSED("Lulus", "Test passed"),
        FAILED("Gagal", "Test failed"),
        MARGINAL("Batas", "Marginal result"),
        PENDING("Menunggu", "Results pending"),
        INVALID("Tidak Valid", "Invalid test");
        
        private final String indonesianLabel;
        private final String englishLabel;
        
        TestResult(String indonesianLabel, String englishLabel) {
            this.indonesianLabel = indonesianLabel;
            this.englishLabel = englishLabel;
        }
        
        public String getIndonesianLabel() { return indonesianLabel; }
        public String getEnglishLabel() { return englishLabel; }
    }
}

