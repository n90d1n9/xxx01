package tech.kayys.risk.resource;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.eclipse.microprofile.openapi.annotations.Operation;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.SecurityContext;
import tech.kayys.risk.domain.RiskEscalation;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.domain.RiskWorkflow;
import tech.kayys.risk.dto.RiskHeatmapData;
import tech.kayys.risk.dto.RiskPortfolioAnalysis;
import tech.kayys.risk.dto.RiskRegisterDTO;
import tech.kayys.risk.dto.RiskSummaryDTO;
import tech.kayys.risk.dto.RiskTrendData;
import tech.kayys.risk.model.RegulatoryRequirement;
import tech.kayys.risk.service.RiskAnalyticsService;
import tech.kayys.risk.service.RiskManagementService;
import tech.kayys.risk.service.RiskReportingService;
import tech.kayys.risk.service.WorkflowService;

@Path("/api/risks")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class RiskManagementResource {
    
    @Inject
    RiskManagementService riskService;

    @Inject
    RiskAnalyticsService analyticsService;
    
    @Inject
    WorkflowService workflowService;
    
    @Inject
    RiskReportingService reportingService;
    
    @GET
    @Path("/dashboard")
    @Operation(summary = "Get executive risk dashboard")
    public Response getExecutiveDashboard(@QueryParam("projectId") Long projectId) {
        RiskDashboardData dashboard = reportingService.generateExecutiveDashboard(projectId);
        return Response.ok(dashboard).build();
    }
    
    @GET
    @Path("/heatmap")
    @Operation(summary = "Generate risk heatmap")
    public Response getRiskHeatmap(@QueryParam("projectId") Long projectId,
                                 @QueryParam("asOfDate") @DefaultValue("#{T(java.time.LocalDate).now()}") LocalDate asOfDate) {
        RiskHeatmapData heatmap = analyticsService.generateRiskHeatmap(projectId, asOfDate);
        return Response.ok(heatmap).build();
    }
    
    @GET
    @Path("/trends")
    @Operation(summary = "Get risk trend analysis")
    public Response getRiskTrends(@QueryParam("projectId") Long projectId,
                                @QueryParam("months") @DefaultValue("12") int months) {
        List<RiskTrendData> trends = analyticsService.calculateRiskTrends(projectId, months);
        return Response.ok(trends).build();
    }
    
    @GET
    @Path("/portfolio-analysis")
    @Operation(summary = "Get risk portfolio analysis")
    public Response getPortfolioAnalysis(@QueryParam("projectId") Long projectId) {
        RiskPortfolioAnalysis analysis = analyticsService.analyzeRiskPortfolio(projectId);
        return Response.ok(analysis).build();
    }
    
    @POST
    @Path("/{riskId}/workflow")
    @Operation(summary = "Initiate risk workflow")
    public Response initiateWorkflow(@PathParam("riskId") Long riskId,
                                   @QueryParam("type") RiskWorkflow.WorkflowType workflowType,
                                   @Context SecurityContext securityContext) {
        // In real implementation, get user ID from security context
        Long initiatorId = getCurrentUserId(securityContext);
        
        RiskWorkflow workflow = workflowService.initiateWorkflow(riskId, workflowType, initiatorId);
        return Response.status(Response.Status.CREATED).entity(workflow).build();
    }
    
    @POST
    @Path("/{riskId}/escalate")
    @Operation(summary = "Escalate risk")
    public Response escalateRisk(@PathParam("riskId") Long riskId,
                               @Valid EscalationRequest request,
                               @Context SecurityContext securityContext) {
        Long userId = getCurrentUserId(securityContext);
        RiskEscalation escalation = riskService.escalateRisk(riskId, request, userId);
        return Response.status(Response.Status.CREATED).entity(escalation).build();
    }
    
    @GET
    @Path("/reports/register")
    @Operation(summary = "Generate risk register report")
    @Produces({"application/pdf", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "text/csv"})
    public Response generateRiskRegisterReport(@QueryParam("projectId") Long projectId,
                                             @QueryParam("format") @DefaultValue("PDF") RiskReportingService.ReportFormat format) {
        byte[] reportData = reportingService.generateRiskRegisterReport(projectId, format);
        
        String contentType = switch (format) {
            case PDF -> "application/pdf";
            case EXCEL -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case CSV -> "text/csv";
        };
        
        return Response.ok(reportData, contentType)
                .header("Content-Disposition", "attachment; filename=risk-register." + format.name().toLowerCase())
                .build();
    }
    
    @GET
    @Path("/reports/compliance")
    @Operation(summary = "Generate compliance report")
    public Response generateComplianceReport(@QueryParam("requirement") RegulatoryRequirement requirement,
                                           @QueryParam("fromDate") LocalDate fromDate,
                                           @QueryParam("toDate") LocalDate toDate) {
        ComplianceReport report = reportingService.generateComplianceReport(requirement, fromDate, toDate);
        return Response.ok(report).build();
    }
    
    private Long getCurrentUserId(SecurityContext securityContext) {
        // In real implementation, extract from JWT or security context
        return 1L; // Placeholder
    }
    
    @GET
    public Response getAllRisks(@QueryParam("projectId") Long projectId) {
        List<RiskRegisterDTO> risks = projectId != null ? 
                riskService.getRisksByProject(projectId) :
                riskService.getAllRisks();
        return Response.ok(risks).build();
    }
    
    @GET
    @Path("/{id}")
    public Response getRiskById(@PathParam("id") Long id) {
        return riskService.getRiskById(id)
                .map(risk -> Response.ok(risk).build())
                .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }
    
    @POST
    public Response createRisk(@Valid RiskRegisterDTO dto) {
        try {
            RiskRegisterDTO created = riskService.createRisk(dto);
            return Response.status(Response.Status.CREATED).entity(created).build();
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }
    
    @PUT
    @Path("/{id}")
    public Response updateRisk(@PathParam("id") Long id, @Valid RiskRegisterDTO dto) {
        return riskService.updateRisk(id, dto)
                .map(risk -> Response.ok(risk).build())
                .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }
    
    @DELETE
    @Path("/{id}")
    public Response deleteRisk(@PathParam("id") Long id) {
        boolean deleted = riskService.deleteRisk(id);
        return deleted ? 
                Response.noContent().build() : 
                Response.status(Response.Status.NOT_FOUND).build();
    }
    
    @GET
    @Path("/high")
    public Response getHighRisks(@QueryParam("threshold") @DefaultValue("12") int threshold) {
        List<RiskRegisterDTO> risks = riskService.getHighRisks(threshold);
        return Response.ok(risks).build();
    }
    
    @GET
    @Path("/overdue")
    public Response getOverdueRisks() {
        List<RiskRegisterDTO> risks = riskService.getOverdueRisks();
        return Response.ok(risks).build();
    }
    
    @GET
    @Path("/summary")
    public Response getRiskSummary(@QueryParam("projectId") Long projectId) {
        RiskSummaryDTO summary = riskService.getRiskSummary(projectId);
        return Response.ok(summary).build();
    }
}