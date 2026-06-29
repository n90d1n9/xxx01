package tech.kayys.project.resource;

import jakarta.inject.Inject;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.project.dto.ProjectRequest;
import tech.kayys.project.dto.ProjectSearchCriteria;
import tech.kayys.project.service.ProjectService;
import tech.kayys.project.service.TransactionService;
import tech.kayys.report.service.ReportingService;
import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.*;

@Path("/api/projects")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ProjectController {

    @Inject
    ProjectService projectService;
    @Inject
    TransactionService transactionService;
    @Inject
    ReportingService reportService;

    @GET
    public Uni<Response> listAll() {
        return projectService.listAll()
                .map(resp -> Response.ok(resp).build());
    }

    @POST
    public Uni<Response> create(ProjectRequest request, @HeaderParam("X-User") String createdBy) {
        return projectService.create(request, createdBy)
                .map(resp -> Response.status(Response.Status.CREATED).entity(resp).build());
    }

    @PUT
    @Path("/{id}")
    public Uni<Response> update(@PathParam("id") Long id, ProjectRequest request,
            @HeaderParam("X-User") String updatedBy) {
        return projectService.update(id, request, updatedBy)
                .map(resp -> Response.ok(resp).build());
    }

    @GET
    @Path("/{id}")
    public Uni<Response> getById(@PathParam("id") Long id) {
        return projectService.findById(id)
                .map(resp -> Response.ok(resp).build());
    }

    @POST
    @Path("/search")
    public Uni<Response> search(ProjectSearchCriteria criteria) {
        return projectService.search(criteria)
                .map(resp -> Response.ok(resp).build());
    }
}
