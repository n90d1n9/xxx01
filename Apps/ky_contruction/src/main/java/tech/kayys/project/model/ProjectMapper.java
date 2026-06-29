package tech.kayys.project.model;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.Project;
import tech.kayys.project.dto.ProjectRequest;
import tech.kayys.project.dto.ProjectResponse;

@ApplicationScoped
public class ProjectMapper {

    public ProjectResponse toResponse(Project entity) {
        ProjectResponse dto = new ProjectResponse();
        dto.id = entity.id;
        dto.projectCode = entity.projectCode;
        dto.name = entity.name;
        dto.description = entity.description;
        dto.startDate = entity.startDate;
        dto.endDate = entity.endDate;
        dto.status = entity.status;
        dto.createdDate = entity.createdDate;
        dto.updatedDate = entity.updatedDate;
        return dto;
    }

    public Project toEntity(ProjectRequest dto) {
        Project entity = new Project();
        entity.name = dto.name;
        entity.description = dto.description;
        entity.startDate = dto.startDate;
        entity.endDate = dto.endDate;
        entity.status = dto.status;
        return entity;
    }

    public void updateEntity(Project entity, ProjectRequest dto) {
        entity.name = dto.name;
        entity.description = dto.description;
        entity.startDate = dto.startDate;
        entity.endDate = dto.endDate;
        entity.status = dto.status;
    }
}
