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
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.risk.domain.KRIMeasurement;
import tech.kayys.risk.domain.KeyRiskIndicator;
import tech.kayys.risk.service.RiskAnalyticsService;

@Path("/api/v2/kris")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class KRIManagementResource {
    
    @Inject
    KRIService kriService;
    
    @Inject
    RiskAnalyticsService analyticsService;
    
    @GET
    @Path("/risk/{riskId}")
    public Response getKRIsForRisk(@PathParam("riskId") Long riskId) {
        List<KeyRiskIndicator> kris = kriService.getKRIsForRisk(riskId);
        return Response.ok(kris).build();
    }
    
    @POST
    public Response createKRI(@Valid CreateKRIRequest request) {
        KeyRiskIndicator kri = kriService.createKRI(request);
        return Response.status(Response.Status.CREATED).entity(kri).build();
    }
    
    @POST
    @Path("/{kriId}/measurements")
    public Response recordMeasurement(@PathParam("kriId") Long kriId,
                                    @Valid KRIMeasurementRequest request) {
        KRIMeasurement measurement = kriService.recordMeasurement(kriId, request);
        return Response.status(Response.Status.CREATED).entity(measurement).build();
    }
    
    @GET
    @Path("/{kriId}/trends")
    public Response getKRITrends(@PathParam("kriId") Long kriId,
                               @QueryParam("months") @DefaultValue("12") int months) {
        List<KRITrendData> trends = analyticsService.analyzeKRITrends(kriId, months);
        return Response.ok(trends).build();
    }
    
    @GET
    @Path("/breaches")
    public Response getKRIBreaches(@QueryParam("days") @DefaultValue("30") int days) {
        List<KRIMeasurement> breaches = kriService.getRecentBreaches(days);
        return Response.ok(breaches).build();
    }
}
