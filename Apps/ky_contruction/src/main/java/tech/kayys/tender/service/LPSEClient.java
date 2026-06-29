package tech.kayys.tender.service;

import java.util.List;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@RegisterRestClient(configKey = "lpse-client")
public interface LPSEClient {
    
    @POST
    @Path("/tenders")
    @Consumes(MediaType.APPLICATION_JSON)
    Response publishTender(LPSEIntegrationService.LPSETenderData tender);
    
    @GET
    @Path("/vendors/qualified")
    List<LPSEIntegrationService.LPSEVendorData> getQualifiedVendors(@QueryParam("category") String category);
}
