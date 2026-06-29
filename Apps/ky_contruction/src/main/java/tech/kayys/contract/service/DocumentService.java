package tech.kayys.contract.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.contract.domain.DocumentControl;
import tech.kayys.contract.domain.DocumentVersion;

@ApplicationScoped
public class DocumentService {
    
    public DocumentControl createDocument(DocumentControl document) {
        document.documentNumber = generateDocumentNumber(document);
        document.issuedDate = LocalDate.now();
        document.persist();
        
        // Create initial version
        createDocumentVersion(document, "A", "Initial version");
        
        return document;
    }
    
    public DocumentVersion createDocumentVersion(DocumentControl document, String version, String changeDescription) {
        // Mark previous version as not current
        DocumentVersion.update("isCurrent = false WHERE document = ?1", document);
        
        DocumentVersion newVersion = new DocumentVersion();
        newVersion.document = document;
        newVersion.versionNumber = version;
        newVersion.uploadDate = LocalDateTime.now();
        newVersion.changeDescription = changeDescription;
        newVersion.isCurrent = true;
        newVersion.persist();
        
        // Update document revision
        document.revision = version;
        document.persist();
        
        return newVersion;
    }
    
    public List<DocumentControl> searchDocuments(String searchTerm, DocumentControl.DocumentType type, Long projectId) {
        String query = "project.id = ?1";
        Object[] params = {projectId};
        
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            query += " AND (LOWER(documentTitle) LIKE ?2 OR LOWER(documentNumber) LIKE ?2)";
            params = new Object[]{projectId, "%" + searchTerm.toLowerCase() + "%"};
        }
        
        if (type != null) {
            query += " AND documentType = ?" + (params.length + 1);
            Object[] newParams = new Object[params.length + 1];
            System.arraycopy(params, 0, newParams, 0, params.length);
            newParams[params.length] = type;
            params = newParams;
        }
        
        return DocumentControl.list(query + " ORDER BY issuedDate DESC", params);
    }
    
    private String generateDocumentNumber(DocumentControl document) {
        long count = DocumentControl.count("project = ?1 AND documentType = ?2", 
            document.project, document.documentType) + 1;
        
        String typeCode = getDocumentTypeCode(document.documentType);
        return String.format("%s-%s-%s-%03d", 
            document.project.projectCode, typeCode, 
            document.discipline != null ? document.discipline : "GEN", count);
    }
    
    private String getDocumentTypeCode(DocumentControl.DocumentType type) {
        switch (type) {
            case DRAWING: return "DRW";
            case SPECIFICATION: return "SPC";
            case RFI: return "RFI";
            case SUBMITTAL: return "SBT";
            case SHOP_DRAWING: return "SHD";
            case METHOD_STATEMENT: return "MTS";
            case MATERIAL_APPROVAL: return "MAT";
            case TEST_CERTIFICATE: return "TST";
            default: return "DOC";
        }
    }
}
