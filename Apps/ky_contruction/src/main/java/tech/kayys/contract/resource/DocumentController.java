package tech.kayys.contract.resource;

import java.util.List;

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
import tech.kayys.contract.domain.DocumentControl;
import tech.kayys.contract.domain.DocumentVersion;
import tech.kayys.contract.service.DocumentService;

@Path("/api/documents")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class DocumentController {
    
    @Inject
    DocumentService documentService;
    
    @GET
    @Path("/projects/{id}")
    public Response getProjectDocuments(
            @PathParam("id") Long projectId,
            @QueryParam("search") String searchTerm,
            @QueryParam("type") DocumentControl.DocumentType type) {
        
        List<DocumentControl> documents = documentService.searchDocuments(searchTerm, type, projectId);
        return Response.ok(documents).build();
    }
    
    @POST
    public Response createDocument(DocumentControl document) {
        DocumentControl created = documentService.createDocument(document);
        return Response.status(201).entity(created).build();
    }
    
    @POST
    @Path("/{id}/versions")
    public Response createDocumentVersion(
            @PathParam("id") Long documentId,
            @QueryParam("version") String version,
            @QueryParam("description") String description) {
        
        DocumentControl document = DocumentControl.findById(documentId);
        if (document == null) {
            return Response.status(404).build();
        }
        
        DocumentVersion newVersion = documentService.createDocumentVersion(document, version, description);
        return Response.status(201).entity(newVersion).build();
    }
    
    @GET
    @Path("/{id}/versions")
    public Response getDocumentVersions(@PathParam("id") Long documentId) {
        List<DocumentVersion> versions = DocumentVersion
            .list("document.id = ?1 ORDER BY uploadDate DESC", documentId);
        return Response.ok(versions).build();
    }
}
