package tech.kayys.project.resource;

import java.time.LocalDate;

import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.report.service.ReportingService;

@Path("/projects/{id}/reports")
@Produces(MediaType.APPLICATION_JSON)
public class ReportsResource {

    @Inject ReportingService reportingService;

    @GET
    @Path("/budget-burndown")
    public Uni<Response> budgetBurnDown(@PathParam("id") Long id,
                                        @QueryParam("from") String from,
                                        @QueryParam("to") String to) {
        LocalDate f = LocalDate.parse(from);
        LocalDate t = LocalDate.parse(to);
        return reportingService.generateBudgetBurnDown(id, f, t)
                .map(dto -> Response.ok(dto).build())
                .onFailure().recoverWithItem(err ->
                        Response.status(Response.Status.BAD_REQUEST).entity(err.getMessage()).build());
    }

    @GET
    @Path("/resources")
    public Uni<Response> resourceUtilization(@PathParam("id") Long id,
                                             @QueryParam("from") String from,
                                             @QueryParam("to") String to) {
        LocalDate f = LocalDate.parse(from);
        LocalDate t = LocalDate.parse(to);
        return reportingService.generateResourceUtilization(id, f, t)
                .map(dto -> Response.ok(dto).build())
                .onFailure().recoverWithItem(err ->
                        Response.status(Response.Status.BAD_REQUEST).entity(err.getMessage()).build());
    }

    @GET
    @Path("/tasks")
    public Uni<Response> taskProgress(@PathParam("id") Long id) {
        return reportingService.generateTaskProgress(id)
                .map(dto -> Response.ok(dto).build())
                .onFailure().recoverWithItem(err ->
                        Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(err.getMessage()).build());
    }

    @GET
    @Path("/risk-trend")
    public Uni<Response> riskTrend(@PathParam("id") Long id,
                                   @QueryParam("from") String from,
                                   @QueryParam("to") String to) {
        LocalDate f = LocalDate.parse(from);
        LocalDate t = LocalDate.parse(to);
        return reportingService.generateRiskTrend(id, f, t)
                .map(dto -> Response.ok(dto).build())
                .onFailure().recoverWithItem(err ->
                        Response.status(Response.Status.BAD_REQUEST).entity(err.getMessage()).build());
    }

    @GET
    @Path("/health")
    public Uni<Response> health(@PathParam("id") Long id) {
        return reportingService.generateProjectHealth(id)
                .map(dto -> Response.ok(dto).build())
                .onFailure().recoverWithItem(err ->
                        Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(err.getMessage()).build());
    }

    // ---------------- Extra Endpoints (to match ReportingService snapshots) ----------------

    @GET
    @Path("/budget-snapshot")
    public Uni<Response> budgetSnapshot(@PathParam("id") Long id) {
        return reportingService.generateBudgetReport(id)
                .map(dto -> Response.ok(dto).build());
    }

    @GET
    @Path("/resource-snapshot")
    public Uni<Response> resourceSnapshot(@PathParam("id") Long id) {
        return reportingService.generateResourceReport(id)
                .map(dto -> Response.ok(dto).build());
    }

    @GET
    @Path("/task-snapshot")
    public Uni<Response> taskSnapshot(@PathParam("id") Long id) {
        return reportingService.generateTaskReport(id)
                .map(dto -> Response.ok(dto).build());
    }

    @GET
    @Path("/risk-snapshot")
    public Uni<Response> riskSnapshot(@PathParam("id") Long id) {
        return reportingService.generateRiskReport(id)
                .map(dto -> Response.ok(dto).build());
    }
}

