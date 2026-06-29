package tech.kayys.project.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

import tech.kayys.project.domain.Project;

public class ProjectResponse {
    public Long id;
    public String projectCode;
    public String name;
    public String description;
    public LocalDate startDate;
    public LocalDate endDate;
    public Project.ProjectStatus status;
    public LocalDateTime createdDate;
    public LocalDateTime updatedDate;
}