package tech.kayys.project.resource;

import java.util.HashMap;
import java.util.Map;

import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.Response;
import tech.kayys.project.service.ProjectService;

public class ProjectDashboardResource {
    @Inject
    ProjectService projectService;

    @GET
    public Uni<Response> getDashboard(@PathParam("id") Long projectId) {
        return projectService.findById(projectId)
                .onItem().ifNull().failWith(() -> new NotFoundException("Project not found"))
                .flatMap(project -> projectService.getDashboardData(projectId)
                        .map(data -> {
                            Map<String, Object> dashboard = new HashMap<>(data);
                            dashboard.put("project", project);
                            return Response.ok(dashboard).build();
                        }));
    }
}
