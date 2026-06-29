package tech.kayys.compliance.resource;

import java.time.LocalDate;
import java.util.List;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/compliance")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ComplianceController {
    
    @GET
    @Path("/sni-standards")
    public Response getSNIStandards(@QueryParam("category") String category,
                                   @QueryParam("search") String search) {
        List<SNIStandard> standards;
        
        if (category != null && search != null) {
            standards = SNIStandard.list(
                    "category = ?1 and (title ILIKE ?2 or sniCode ILIKE ?2) and status = 'ACTIVE'",
                    category, "%" + search + "%");
        } else if (category != null) {
            standards = SNIStandard.list("category = ?1 and status = 'ACTIVE'", category);
        } else if (search != null) {
            standards = SNIStandard.list(
                    "(title ILIKE ?1 or sniCode ILIKE ?1) and status = 'ACTIVE'",
                    "%" + search + "%");
        } else {
            standards = SNIStandard.list("status = 'ACTIVE' ORDER BY sniCode");
        }
        
        return Response.ok(standards).build();
    }
    
    @GET
    @Path("/hspk-rates")
    public Response getHSPKRates(@QueryParam("region") String region,
                                @QueryParam("category") String category) {
        List<HSPKRate> rates;
        
        if (region != null && category != null) {
            rates = HSPKRate.list("region = ?1 and description ILIKE ?2 and isActive = true",
                    region, "%" + category + "%");
        } else if (region != null) {
            rates = HSPKRate.list("region = ?1 and isActive = true", region);
        } else {
            rates = HSPKRate.list("isActive = true ORDER BY region, hspkCode");
        }
        
        return Response.ok(rates).build();
    }
    
    @GET
    @Path("/bpjs-compliance")
    public Response getBPJSCompliance(@QueryParam("project") Long projectId,
                                     @QueryParam("status") String status) {
        List<BPJSCompliance> compliance;
        
        if (projectId != null && status != null) {
            try {
                BPJSCompliance.ComplianceStatus complianceStatus = 
                        BPJSCompliance.ComplianceStatus.valueOf(status.toUpperCase());
                compliance = BPJSCompliance.list("project.id = ?1 and status = ?2", 
                        projectId, complianceStatus);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid status: " + status).build();
            }
        } else if (projectId != null) {
            compliance = BPJSCompliance.list("project.id", projectId);
        } else {
            compliance = BPJSCompliance.list("ORDER BY employmentStartDate DESC");
        }
        
        return Response.ok(compliance).build();
    }
    
    @POST
    @Path("/bpjs-compliance")
    public Response addBPJSCompliance(BPJSCompliance compliance) {
        compliance.persist();
        return Response.status(201).entity(compliance).build();
    }
    
    @GET
    @Path("/environmental-permits")
    public Response getEnvironmentalPermits(@QueryParam("project") Long projectId,
                                           @QueryParam("type") String permitType) {
        List<EnvironmentalCompliance> permits;
        
        if (projectId != null && permitType != null) {
            try {
                EnvironmentalCompliance.PermitType type = 
                        EnvironmentalCompliance.PermitType.valueOf(permitType.toUpperCase());
                permits = EnvironmentalCompliance.list("project.id = ?1 and permitType = ?2", 
                        projectId, type);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid permit type: " + permitType).build();
            }
        } else if (projectId != null) {
            permits = EnvironmentalCompliance.list("project.id", projectId);
        } else {
            permits = EnvironmentalCompliance.list("ORDER BY issueDate DESC");
        }
        
        return Response.ok(permits).build();
    }
    
    @POST
    @Path("/environmental-permits")
    public Response addEnvironmentalPermit(EnvironmentalCompliance permit) {
        permit.persist();
        return Response.status(201).entity(permit).build();
    }
    
    @GET
    @Path("/expiring-permits")
    public Response getExpiringPermits(@QueryParam("days") Integer days) {
        int daysBefore = days != null ? days : 30;
        LocalDate cutoffDate = LocalDate.now().plusDays(daysBefore);
        
        List<EnvironmentalCompliance> expiringPermits = EnvironmentalCompliance
                .list("expiryDate <= ?1 and status = 'APPROVED'", cutoffDate);
        
        return Response.ok(expiringPermits).build();
    }
}