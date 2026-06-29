package tech.kayys.risk.domain;

import java.time.LocalDateTime;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "report_project_risks")
public class ProjectRiskReport extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "project_id")
    public Project project;

    @Column(name = "open_risks")
    public Integer openRisks;

    @Column(name = "closed_risks")
    public Integer closedRisks;

    @Column(name = "high_risks")
    public Integer highRisks;

    @Column(name = "medium_risks")
    public Integer mediumRisks;

    @Column(name = "low_risks")
    public Integer lowRisks;

    @Column(name = "last_updated")
    public LocalDateTime lastUpdated;
}
