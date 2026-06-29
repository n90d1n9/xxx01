package tech.kayys.risk.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

import tech.kayys.profile.domain.User;
import tech.kayys.risk.domain.RiskMitigationAction;

public class RiskMitigationActionDTO {
    public Long id;
    public Long riskId;
    public String actionDescription;
    public User assignedTo;
    public LocalDate dueDate;
    public RiskMitigationAction.ActionStatus status;
    public LocalDate completionDate;
    public String notes;
    public LocalDateTime createdDate;
    
    public static RiskMitigationActionDTO from(RiskMitigationAction action) {
        RiskMitigationActionDTO dto = new RiskMitigationActionDTO();
        dto.id = action.id;
        dto.riskId = action.risk != null ? action.risk.id : null;
        dto.actionDescription = action.actionDescription;
        dto.assignedTo = action.assignedTo;
        dto.dueDate = action.dueDate;
        dto.status = action.status;
        dto.completionDate = action.completionDate;
        dto.notes = action.notes;
        dto.createdDate = action.createdDate;
        return dto;
    }
}