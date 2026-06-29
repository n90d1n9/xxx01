package tech.kayys.risk.resource;

import java.util.List;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.SecurityContext;
import tech.kayys.risk.domain.KRIMeasurement;
import tech.kayys.risk.domain.KeyRiskIndicator;
import tech.kayys.risk.domain.RiskWorkflow;
import tech.kayys.risk.service.RiskAnalyticsService;
import tech.kayys.risk.service.WorkflowService;

@Path("/api/v2/workflows")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class WorkflowManagementResource {
    
    @Inject
    WorkflowService workflowService;
    
    @GET
    @Path("/pending")
    public Response getPendingWorkflows(@Context SecurityContext securityContext) {
        Long userId = getCurrentUserId(securityContext);
        List<RiskWorkflow> workflows = workflowService.getPendingWorkflowsForUser(userId);
        return Response.ok(workflows).build();
    }
    
    @POST
    @Path("/{workflowId}/steps/{stepId}/process")
    public Response processWorkflowStep(@PathParam("workflowId") Long workflowId,
                                      @PathParam("stepId") Long stepId,
                                      @Valid ProcessStepRequest request,
                                      @Context SecurityContext securityContext) {
        Long userId = getCurrentUserId(securityContext);
        boolean success = workflowService.processWorkflowStep(workflowId, stepId, 
                                                             request.decision, request.comments, userId);
        return success ? Response.ok().build() : Response.status(Response.Status.BAD_REQUEST).build();
    }
    
    private Long getCurrentUserId(SecurityContext securityContext) {
        return 1L; // Placeholder
    }
}
