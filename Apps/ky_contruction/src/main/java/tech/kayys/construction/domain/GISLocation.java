package tech.kayys.construction.domain;

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
@Table(name = "gis_locations")
public class GISLocation extends PanacheEntity {
    
    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;
    
    @Column(name = "location_name")
    public String locationName;
    
    @Column(name = "latitude")
    public Double latitude;
    
    @Column(name = "longitude")
    public Double longitude;
    
    @Column(name = "elevation")
    public Double elevation;
    
    @Column(name = "accuracy")
    public Double accuracy; // GPS accuracy in meters
    
    @Column(name = "location_type")
    @Enumerated(EnumType.STRING)
    public LocationType locationType;
    
    @Column(name = "address")
    public String address;
    
    @Column(name = "land_parcel_number")
    public String landParcelNumber;
    
    @Column(name = "coordinate_system")
    public String coordinateSystem; // UTM, WGS84, etc.
    
    public enum LocationType {
        PROJECT_SITE("Project Site"),
        MATERIAL_SOURCE("Material Source"),
        EQUIPMENT_YARD("Equipment Yard"),
        OFFICE_LOCATION("Office Location"),
        CHECKPOINT("Checkpoint"),
        BOUNDARY_POINT("Boundary Point");
        
        private final String label;
        LocationType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}
