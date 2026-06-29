package tech.kayys.construction.resource;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.company.domain.Company;
import tech.kayys.construction.domain.GISLocation;
import tech.kayys.construction.service.EFakturIntegrationService;
import tech.kayys.contract.domain.DocumentVersion;
import tech.kayys.finance.domain.ProgressPayment;

@Path("/api/system")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class SystemController {
    
    @Inject
    EFakturIntegrationService eFakturService;
    
    @GET
    @Path("/companies")
    public Response getCompanies() {
        List<Company> companies = Company.list("isActive = true ORDER BY companyName");
        return Response.ok(companies).build();
    }
    
    @POST
    @Path("/companies")
    @RolesAllowed("ADMIN")
    public Response createCompany(Company company) {
        // Generate company code
        String prefix = company.companyName.replaceAll("[^A-Z]", "").substring(0, 3);
        long count = Company.count() + 1;
        company.companyCode = String.format("%s%03d", prefix, count);
        
        company.persist();
        return Response.status(201).entity(company).build();
    }
    
    @GET
    @Path("/document-versions/{documentId}")
    public Response getDocumentVersions(@PathParam("documentId") Long documentId) {
        List<DocumentVersion> versions = DocumentVersion
                .list("document.id = ?1 ORDER BY versionNumber DESC", documentId);
        return Response.ok(versions).build();
    }
    
    @POST
    @Path("/document-versions")
    @RolesAllowed({"PROJECT_MANAGER", "SITE_ENGINEER"})
    public Response uploadDocumentVersion(DocumentVersion version) {
        // Calculate version number
        String lastVersion = DocumentVersion
                .find("document = ?1 ORDER BY versionNumber DESC", version.document)
                .project(String.class, "versionNumber")
                .firstResult();
        
        version.versionNumber = generateNextVersion(lastVersion);
        version.uploadDate = LocalDateTime.now();
        
        // Mark previous versions as not current
        DocumentVersion.update("isCurrent = false WHERE document = ?1", version.document);
        version.isCurrent = true;
        
        version.persist();
        return Response.status(201).entity(version).build();
    }
    
    @GET
    @Path("/gis-locations")
    public Response getGISLocations(@QueryParam("project") Long projectId,
                                   @QueryParam("type") String locationType) {
        List<GISLocation> locations;
        
        if (projectId != null && locationType != null) {
            try {
                GISLocation.LocationType type = 
                        GISLocation.LocationType.valueOf(locationType.toUpperCase());
                locations = GISLocation.list("project.id = ?1 and locationType = ?2", 
                        projectId, type);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid location type: " + locationType).build();
            }
        } else if (projectId != null) {
            locations = GISLocation.list("project.id", projectId);
        } else {
            locations = GISLocation.listAll();
        }
        
        return Response.ok(locations).build();
    }
    
    @POST
    @Path("/gis-locations")
    public Response addGISLocation(GISLocation location) {
        location.persist();
        return Response.status(201).entity(location).build();
    }
    
    @POST
    @Path("/payments/{id}/generate-efaktur")
    @RolesAllowed({"FINANCE", "ADMIN"})
    public Response generateEFaktur(@PathParam("id") Long paymentId) {
        ProgressPayment payment = ProgressPayment.findById(paymentId);
        if (payment == null) {
            return Response.status(404).entity("Payment not found").build();
        }
        
        String eFakturNumber = eFakturService.generateEFaktur(payment);
        if (eFakturNumber != null) {
            return Response.ok()
                    .entity(Map.of("eFakturNumber", eFakturNumber))
                    .build();
        } else {
            return Response.status(500).entity("Failed to generate e-Faktur").build();
        }
    }
    
    private String generateNextVersion(String currentVersion) {
        if (currentVersion == null) {
            return "1.0";
        }
        
        // Simple version increment logic
        String[] parts = currentVersion.split("\\.");
        if (parts.length == 2) {
            try {
                int major = Integer.parseInt(parts[0]);
                int minor = Integer.parseInt(parts[1]);
                return String.format("%d.%d", major, minor + 1);
            } catch (NumberFormatException e) {
                return "1.0";
            }
        }
        
        return "1.0";
    }
}
