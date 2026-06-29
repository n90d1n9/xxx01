package tech.kayys.project.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;
import tech.kayys.project.domain.Project;

public class ProjectRequest {
    @NotBlank public String name;
    public String description;
    public LocalDate startDate;
    public LocalDate endDate;
    public Project.ProjectStatus status;
}