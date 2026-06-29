package tech.kayys.finance.resource;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.construction.domain.MaterialSubmittal;
import tech.kayys.tender.domain.Tender;
import tech.kayys.tender.domain.TenderBid;
import tech.kayys.tender.service.LPSEIntegrationService;
import tech.kayys.vendor.domain.Vendor;

@Path("/api/procurement")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ProcurementController {
    
    @Inject
    LPSEIntegrationService lpseService;
    
    @GET
    @Path("/tenders")
    public Response getAllTenders(@QueryParam("project") Long projectId,
                                 @QueryParam("status") String status) {
        List<Tender> tenders;
        if (projectId != null) {
            tenders = Tender.list("project.id", projectId);
        } else if (status != null) {
            try {
                Tender.TenderStatus tenderStatus = Tender.TenderStatus.valueOf(status.toUpperCase());
                tenders = Tender.list("status", tenderStatus);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid status: " + status).build();
            }
        } else {
            tenders = Tender.listAll();
        }
        return Response.ok(tenders).build();
    }
    
    @POST
    @Path("/tenders")
    public Response createTender(Tender tender) {
        // Generate tender number
        long count = Tender.count() + 1;
        tender.tenderNumber = String.format("T-%04d-%02d", count, LocalDate.now().getYear() % 100);
        tender.issueDate = LocalDate.now();
        
        tender.persist();
        
        // Sync to LPSE if enabled
        lpseService.syncTenderToLPSE(tender);
        
        return Response.status(201).entity(tender).build();
    }
    
    @POST
    @Path("/tenders/{id}/bids")
    public Response submitBid(@PathParam("id") Long tenderId, TenderBid bid) {
        Tender tender = Tender.findById(tenderId);
        if (tender == null) {
            return Response.status(404).entity("Tender not found").build();
        }
        
        bid.tender = tender;
        bid.submissionDate = LocalDateTime.now();
        bid.persist();
        
        return Response.status(201).entity(bid).build();
    }
    
    @GET
    @Path("/vendors/qualified")
    public Response getQualifiedVendors(@QueryParam("category") String category) {
        if (category != null) {
            // Get from LPSE if available
            List<LPSEIntegrationService.LPSEVendorData> lpseVendors = 
                    lpseService.getQualifiedVendors(category);
            
            if (!lpseVendors.isEmpty()) {
                return Response.ok(lpseVendors).build();
            }
        }
        
        // Fallback to local vendors
        List<Vendor> vendors = category != null ?
                Vendor.list("category = ?1 and status = 'ACTIVE'", 
                        Vendor.VendorCategory.valueOf(category.toUpperCase())) :
                Vendor.list("status = 'ACTIVE'");
        
        return Response.ok(vendors).build();
    }
    
    @POST
    @Path("/material-submittals")
    public Response createMaterialSubmittal(MaterialSubmittal submittal) {
        // Generate submittal number
        long count = MaterialSubmittal.count("project", submittal.project) + 1;
        submittal.submittalNumber = String.format("MS-%s-%03d", 
                submittal.project.projectCode, count);
        submittal.submittalDate = LocalDate.now();
        
        submittal.persist();
        return Response.status(201).entity(submittal).build();
    }
    
    @PUT
    @Path("/material-submittals/{id}/review")
    @RolesAllowed({"SITE_ENGINEER", "PROJECT_MANAGER"})
    public Response reviewSubmittal(@PathParam("id") Long id, 
                                   @QueryParam("status") String status,
                                   @QueryParam("reviewer") String reviewer,
                                   @QueryParam("comments") String comments) {
        MaterialSubmittal submittal = MaterialSubmittal.findById(id);
        if (submittal == null) {
            return Response.status(404).build();
        }
        
        try {
            submittal.status = MaterialSubmittal.SubmittalStatus.valueOf(status.toUpperCase());
            submittal.reviewedBy = reviewer;
            submittal.reviewDate = LocalDate.now();
            submittal.reviewComments = comments;
            submittal.persist();
            
            return Response.ok(submittal).build();
        } catch (IllegalArgumentException e) {
            return Response.status(400).entity("Invalid status: " + status).build();
        }
    }
}
