package tech.kayys.hse.domain;

import java.time.LocalDateTime;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "safety_incidents")
public class SafetyIncident extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "incident_number", unique = true)
    public String incidentNumber;
    
    @Column(name = "incident_date")
    public LocalDateTime incidentDate;
    
    @Column(name = "location")
    public String location;
    
    @Enumerated(EnumType.STRING)
    public IncidentType incidentType;
    
    @Enumerated(EnumType.STRING)
    public IncidentSeverity severity;
    
    @Column(name = "description", length = 2000)
    public String description;
    
    @Column(name = "injured_person")
    public String injuredPerson;
    
    @Column(name = "company_department")
    public String companyDepartment;
    
    @Column(name = "immediate_cause", length = 1000)
    public String immediateCause;
    
    @Column(name = "root_cause", length = 1000)
    public String rootCause;
    
    @Column(name = "corrective_actions", length = 2000)
    public String correctiveActions;
    
    @Column(name = "preventive_actions", length = 2000)
    public String preventiveActions;
    
    @Column(name = "reported_by")
    public String reportedBy;
    
    @Column(name = "investigated_by")
    public String investigatedBy;
    
    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    public IncidentStatus status = IncidentStatus.REPORTED;
    
    public enum IncidentType {
        NEAR_MISS("Near Miss"),
        FIRST_AID("First Aid"),
        MEDICAL_TREATMENT("Medical Treatment"),
        LOST_TIME_INJURY("Lost Time Injury"),
        PROPERTY_DAMAGE("Property Damage"),
        ENVIRONMENTAL("Environmental");
        
        private final String label;
        IncidentType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum IncidentSeverity {
        LOW("Low"),
        MEDIUM("Medium"),
        HIGH("High"),
        CRITICAL("Critical");
        
        private final String label;
        IncidentSeverity(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public enum IncidentStatus {
        REPORTED("Reported"),
        UNDER_INVESTIGATION("Under Investigation"),
        INVESTIGATION_COMPLETE("Investigation Complete"),
        CLOSED("Closed");
        
        private final String label;
        IncidentStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
