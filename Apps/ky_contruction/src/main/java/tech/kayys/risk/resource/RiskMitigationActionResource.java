package tech.kayys.risk.resource;

import java.util.List;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.risk.dto.RiskMitigationActionDTO;
import tech.kayys.risk.service.RiskMitigationActionService;

@Path("/api/risks/{riskId}/actions")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class RiskMitigationActionResource {
    
    @Inject
    RiskMitigationActionService actionService;
    
    @GET
    public Response getActionsByRisk(@PathParam("riskId") Long riskId) {
        List<RiskMitigationActionDTO> actions = actionService.getActionsByRisk(riskId);
        return Response.ok(actions).build();
    }
    
    @POST
    public Response createAction(@PathParam("riskId") Long riskId, 
                               @Valid RiskMitigationActionDTO dto) {
        dto.riskId = riskId;
        RiskMitigationActionDTO created = actionService.createAction(dto);
        return Response.status(Response.Status.CREATED).entity(created).build();
    }
    
    @PUT
    @Path("/{id}")
    public Response updateAction(@PathParam("riskId") Long riskId,
                               @PathParam("id") Long id,
                               @Valid RiskMitigationActionDTO dto) {
        dto.riskId = riskId;
        return actionService.updateAction(id, dto)
                .map(action -> Response.ok(action).build())
                .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }
}