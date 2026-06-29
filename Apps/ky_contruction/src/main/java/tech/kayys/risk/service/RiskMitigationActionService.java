package tech.kayys.risk.service;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;
import tech.kayys.risk.domain.RiskMitigationAction;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.dto.RiskCoordinate;
import tech.kayys.risk.dto.RiskHeatmapData;
import tech.kayys.risk.dto.RiskMitigationActionDTO;
import tech.kayys.risk.dto.RiskPortfolioAnalysis;
import tech.kayys.risk.dto.RiskTrendData;

@ApplicationScoped
@Transactional
public class RiskMitigationActionService {
    
    public List<RiskMitigationActionDTO> getActionsByRisk(Long riskId) {
        return RiskMitigationAction.<RiskMitigationAction>find("risk.id", riskId)
                .stream()
                .map(RiskMitigationActionDTO::from)
                .collect(Collectors.toList());
    }
    
    public RiskMitigationActionDTO createAction(RiskMitigationActionDTO dto) {
        RiskMitigationAction action = new RiskMitigationAction();
        mapDtoToEntity(dto, action);
        action.persist();
        return RiskMitigationActionDTO.from(action);
    }
    
    public Optional<RiskMitigationActionDTO> updateAction(Long id, RiskMitigationActionDTO dto) {
        return RiskMitigationAction.<RiskMitigationAction>findByIdOptional(id)
                .map(action -> {
                    mapDtoToEntity(dto, action);
                    if (dto.status == RiskMitigationAction.ActionStatus.COMPLETED 
                        && action.completionDate == null) {
                        action.completionDate = LocalDate.now();
                    }
                    return RiskMitigationActionDTO.from(action);
                });
    }
    
    private void mapDtoToEntity(RiskMitigationActionDTO dto, RiskMitigationAction action) {
        if (dto.riskId != null) {
            action.risk = findById(dto.riskId);
        }
        action.actionDescription = dto.actionDescription;
        action.assignedTo = dto.assignedTo;
        action.dueDate = dto.dueDate;
        action.status = dto.status;
        action.notes = dto.notes;
    }
}
