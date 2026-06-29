package tech.kayys.contract.resource;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.contract.domain.DocumentControl;
import tech.kayys.contract.domain.DocumentVersion;

@Path("/api/files")
@Consumes(MediaType.MULTIPART_FORM_DATA)
@Produces(MediaType.APPLICATION_JSON)
public class FileUploadController {
    
    @ConfigProperty(name = "file.upload.directory", defaultValue = "/tmp/contract-files")
    String uploadDirectory;
    
    @POST
    @Path("/upload")
    public Response uploadFile(
            @FormDataParam("file") InputStream fileInputStream,
            @FormDataParam("file") FormDataContentDisposition fileDetail,
            @FormDataParam("documentId") Long documentId,
            @FormDataParam("uploadedBy") String uploadedBy) {
        
        try {
            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(uploadDirectory);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // Generate unique filename
            String fileName = System.currentTimeMillis() + "_" + fileDetail.getFileName();
            Path filePath = uploadPath.resolve(fileName);
            
            // Save file
            Files.copy(fileInputStream, filePath);
            
            // Calculate file hash for integrity
            String fileHash = calculateFileHash(filePath);
            
            // Update document or create document version
            if (documentId != null) {
                DocumentControl document = DocumentControl.findById(documentId);
                if (document != null) {
                    DocumentVersion version = new DocumentVersion();
                    version.document = document;
                    version.filePath = filePath.toString();
                    version.fileHash = fileHash;
                    version.fileSize = Files.size(filePath);
                    version.uploadDate = LocalDateTime.now();
                    version.uploadedBy = uploadedBy;
                    version.versionNumber = getNextVersionNumber(document);
                    version.isCurrent = true;
                    
                    // Mark previous versions as not current
                    DocumentVersion.update("isCurrent = false WHERE document = ?1", document);
                    
                    version.persist();
                    
                    Map<String, Object> response = new HashMap<>();
                    response.put("success", true);
                    response.put("fileName", fileName);
                    response.put("filePath", filePath.toString());
                    response.put("fileSize", Files.size(filePath));
                    response.put("versionId", version.id);
                    
                    return Response.ok(response).build();
                }
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("fileName", fileName);
            response.put("filePath", filePath.toString());
            response.put("fileSize", Files.size(filePath));
            
            return Response.ok(response).build();
            
        } catch (IOException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Error uploading file: " + e.getMessage());
            return Response.status(500).entity(error).build();
        }
    }
    
    @GET
    @Path("/download/{documentId}")
    public Response downloadFile(@PathParam("documentId") Long documentId) {
        DocumentControl document = DocumentControl.findById(documentId);
        if (document == null) {
            return Response.status(404).build();
        }
        
        // Get current version
        DocumentVersion currentVersion = DocumentVersion
            .find("document = ?1 AND isCurrent = true", document)
            .firstResult();
        
        if (currentVersion == null || currentVersion.filePath == null) {
            return Response.status(404).build();
        }
        
        Path filePath = Paths.get(currentVersion.filePath);
        if (!Files.exists(filePath)) {
            return Response.status(404).build();
        }
        
        try {
            byte[] fileData = Files.readAllBytes(filePath);
            return Response.ok(fileData)
                    .header("Content-Disposition", "attachment; filename=\"" + 
                           Paths.get(currentVersion.filePath).getFileName().toString() + "\"")
                    .build();
        } catch (IOException e) {
            return Response.status(500).build();
        }
    }
    
    private String calculateFileHash(Path filePath) throws IOException {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] fileData = Files.readAllBytes(filePath);
            byte[] hash = digest.digest(fileData);
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
    
    private String getNextVersionNumber(DocumentControl document) {
        DocumentVersion lastVersion = DocumentVersion
            .find("document = ?1 ORDER BY uploadDate DESC", document)
            .firstResult();
        
        if (lastVersion == null) {
            return "A";
        }
        
        // Simple version increment (A -> B -> C, etc.)
        String lastVersionNumber = lastVersion.versionNumber;
        if (lastVersionNumber.length() == 1 && lastVersionNumber.charAt(0) >= 'A' && lastVersionNumber.charAt(0) < 'Z') {
            return String.valueOf((char) (lastVersionNumber.charAt(0) + 1));
        }
        
        return lastVersionNumber + ".1";
    }
}
