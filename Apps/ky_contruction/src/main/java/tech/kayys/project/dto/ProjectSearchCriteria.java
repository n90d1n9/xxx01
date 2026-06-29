package tech.kayys.project.dto;

import java.time.LocalDate;

import tech.kayys.project.domain.Project;

public class ProjectSearchCriteria {
    public String keyword;
    public Project.ProjectStatus status;
    public LocalDate startDate;
    public LocalDate endDate;
    public int page = 0;
    public int size = 20;
}