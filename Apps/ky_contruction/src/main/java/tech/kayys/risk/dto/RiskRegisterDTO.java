package tech.kayys.risk.dto;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import tech.kayys.profile.domain.User;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.model.RiskImpact;
import tech.kayys.risk.model.RiskProbability;
import tech.kayys.risk.model.RiskStatus;

public class RiskRegisterDTO {
    public Long id;
    public Long projectId;
    public String projectName;
    public String riskId;
    public String riskTitle;
    public String description;
    public RiskCategory category;
    public RiskProbability probability;
    public RiskImpact impact;
    public Integer riskScore;
    public RiskStatus status;
    public User owner;
    public LocalDate identifiedDate;
    public LocalDate targetClosureDate;
    public String mitigationStrategy;
    public String contingencyPlan;
    public List<RiskMitigationActionDTO> mitigationActions;
    
    // Constructors, getters, setters
    public RiskRegisterDTO() {}
    
    public static RiskRegisterDTO from(RiskRegister risk) {
        RiskRegisterDTO dto = new RiskRegisterDTO();
        dto.id = risk.id;
        dto.projectId = risk.project != null ? risk.project.id : null;
        dto.projectName = risk.project != null ? risk.project.projectName : null;
        dto.riskId = risk.riskId;
        dto.riskTitle = risk.riskTitle;
        dto.description = risk.description;
        dto.category = risk.category;
        dto.probability = risk.probability;
        dto.impact = risk.impact;
        dto.riskScore = risk.riskScore;
        dto.status = risk.status;
        dto.owner = risk.owner;
        dto.identifiedDate = risk.identifiedDate;
        dto.targetClosureDate = risk.targetClosureDate;
        dto.mitigationStrategy = risk.mitigationStrategy;
        dto.contingencyPlan = risk.contingencyPlan;
        
        if (risk.mitigationActions != null) {
            dto.mitigationActions = risk.mitigationActions.stream()
                .map(RiskMitigationActionDTO::from)
                .collect(Collectors.toList());
        }
        
        return dto;
    }
}
