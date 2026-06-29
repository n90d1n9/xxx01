package tech.kayys.project.resource;

import java.util.HashMap;
import java.util.Map;

import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.project.domain.ProjectBudgetReport;
import tech.kayys.project.domain.ProjectResourceReport;
import tech.kayys.project.domain.ProjectTaskReport;
import tech.kayys.report.service.ReportingService;
import tech.kayys.risk.domain.ProjectRiskReport;

@Path("/api/projects/{id}/reports")
@Produces(MediaType.APPLICATION_JSON)
public class ProjectReportResource {

    @Inject ReportingService reportingService;

    @GET
    @Path("/budget")
    public Uni<ProjectBudgetReport> budgetReport(@PathParam("id") Long projectId) {
        return reportingService.generateBudgetReport(projectId);
    }

    @GET
    @Path("/resources")
    public Uni<ProjectResourceReport> resourceReport(@PathParam("id") Long projectId) {
        return reportingService.generateResourceReport(projectId);
    }

    @GET
    @Path("/tasks")
    public Uni<ProjectTaskReport> taskReport(@PathParam("id") Long projectId) {
        return reportingService.generateTaskReport(projectId);
    }

    @GET
    @Path("/risks")
    public Uni<ProjectRiskReport> riskReport(@PathParam("id") Long projectId) {
        return reportingService.generateRiskReport(projectId);
    }

    @GET
    @Path("/summary")
    public Uni<Response> summaryReport(@PathParam("id") Long projectId) {
        return Uni.combine().all().unis(
            reportingService.generateBudgetReport(projectId),
            reportingService.generateResourceReport(projectId),
            reportingService.generateTaskReport(projectId),
            reportingService.generateRiskReport(projectId)
        ).asTuple()
         .map(tuple -> {
             Map<String, Object> summary = new HashMap<>();
             summary.put("budget", tuple.getItem1());
             summary.put("resources", tuple.getItem2());
             summary.put("tasks", tuple.getItem3());
             summary.put("risks", tuple.getItem4());
             return Response.ok(summary).build();
         });
    }
}