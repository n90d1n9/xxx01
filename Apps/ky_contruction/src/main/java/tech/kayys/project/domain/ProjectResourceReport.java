package tech.kayys.project.domain;

import java.time.LocalDateTime;
import java.util.Map;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "report_project_resources")
public class ProjectResourceReport extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;

    @Column(name = "resource_type")
    public String resourceType; // HUMAN, EQUIPMENT, MATERIAL

    @Column(name = "allocated_quantity")
    public Integer allocatedQuantity;

    @Column(name = "released_quantity")
    public Integer releasedQuantity;

    @Column(name = "in_use")
    public Integer inUse;

    @Column(name = "utilization_rate")
    public Double utilizationRate; // allocated vs released

    @Column(name = "last_updated")
    public LocalDateTime lastUpdated;

    @Column(name = "snapshot_by_type")
    public Map<String, Integer> snapshotByType;
}

