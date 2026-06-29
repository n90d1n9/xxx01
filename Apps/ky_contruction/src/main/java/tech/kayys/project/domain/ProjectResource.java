package tech.kayys.project.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "project_resources")
public class ProjectResource extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id", nullable = false)
    public Project project;

    @Column(name = "resource_name", nullable = false)
    public String resourceName;

    @Column(name = "quantity", nullable = false)
    public Integer quantity;

    @Column(name = "assigned_to")
    public String assignedTo;

    @Column(name = "assigned_date")
    public LocalDateTime assignedDate;

    @Column(name = "notes", length = 1000)
    public String notes;
}
