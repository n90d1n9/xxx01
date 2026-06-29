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
import tech.kayys.project.domain.Project;
import tech.kayys.risk.domain.RiskAssessmentHistory;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.dto.RiskCoordinate;
import tech.kayys.risk.dto.RiskHeatmapData;
import tech.kayys.risk.dto.RiskPortfolioAnalysis;
import tech.kayys.risk.dto.RiskRegisterDTO;
import tech.kayys.risk.dto.RiskSummaryDTO;
import tech.kayys.risk.dto.RiskTrendData;
import tech.kayys.risk.repository.RiskRegisterRepository;

@ApplicationScoped
@Transactional
public class RiskManagementService {
    
    @Inject
    RiskRegisterRepository riskRepository;
    
    public List<RiskRegisterDTO> getAllRisks() {
        return riskRepository.listAll().stream()
                .map(RiskRegisterDTO::from)
                .collect(Collectors.toList());
    }
    
    public List<RiskRegisterDTO> getRisksByProject(Long projectId) {
        return riskRepository.findByProject(projectId).stream()
                .map(RiskRegisterDTO::from)
                .collect(Collectors.toList());
    }
    
    public Optional<RiskRegisterDTO> getRiskById(Long id) {
        return riskRepository.findByIdOptional(id)
                .map(RiskRegisterDTO::from);
    }
    
    public RiskRegisterDTO createRisk(RiskRegisterDTO dto) {
        RiskRegister risk = new RiskRegister();
        mapDtoToEntity(dto, risk);
        
        // Generate risk ID if not provided
        if (risk.riskId == null || risk.riskId.isEmpty()) {
            risk.riskId = generateRiskId(risk.project.id);
        }
        
        if (risk.identifiedDate == null) {
            risk.identifiedDate = LocalDate.now();
        }
        
        riskRepository.persist(risk);
        return RiskRegisterDTO.from(risk);
    }
    
    public Optional<RiskRegisterDTO> updateRisk(Long id, RiskRegisterDTO dto) {
        return riskRepository.findByIdOptional(id)
                .map(risk -> {
                    // Store previous values for history
                    RiskProbability prevProbability = risk.probability;
                    RiskImpact prevImpact = risk.impact;
                    Integer prevScore = risk.riskScore;
                    
                    mapDtoToEntity(dto, risk);
                    
                    // Create assessment history if risk assessment changed
                    if ((prevProbability != risk.probability || prevImpact != risk.impact) 
                        && prevProbability != null && prevImpact != null) {
                        createAssessmentHistory(risk, prevProbability, prevImpact, prevScore);
                    }
                    
                    return RiskRegisterDTO.from(risk);
                });
    }
    
    public boolean deleteRisk(Long id) {
        return riskRepository.deleteById(id);
    }
    
    public List<RiskRegisterDTO> getHighRisks(int threshold) {
        return riskRepository.findHighRisks(threshold).stream()
                .map(RiskRegisterDTO::from)
                .collect(Collectors.toList());
    }
    
    public List<RiskRegisterDTO> getOverdueRisks() {
        return riskRepository.findOverdueRisks().stream()
                .map(RiskRegisterDTO::from)
                .collect(Collectors.toList());
    }
    
    public RiskSummaryDTO getRiskSummary(Long projectId) {
        List<RiskRegister> risks = projectId != null ? 
                riskRepository.findByProject(projectId) : 
                riskRepository.listAll();
        
        RiskSummaryDTO summary = new RiskSummaryDTO();
        summary.totalRisks = (long) risks.size();
        
        // Count risks by score level
        summary.highRisks = risks.stream().mapToLong(r -> r.riskScore != null && r.riskScore >= 12 ? 1 : 0).sum();
        summary.mediumRisks = risks.stream().mapToLong(r -> r.riskScore != null && r.riskScore >= 6 && r.riskScore < 12 ? 1 : 0).sum();
        summary.lowRisks = risks.stream().mapToLong(r -> r.riskScore != null && r.riskScore < 6 ? 1 : 0).sum();
        
        // Group by category
        summary.risksByCategory = risks.stream()
                .collect(Collectors.groupingBy(r -> r.category, Collectors.counting()));
        
        // Group by status
        summary.risksByStatus = risks.stream()
                .collect(Collectors.groupingBy(r -> r.status, Collectors.counting()));
        
        // Calculate average risk score
        summary.averageRiskScore = risks.stream()
                .filter(r -> r.riskScore != null)
                .mapToInt(r -> r.riskScore)
                .average()
                .orElse(0.0);
        
        return summary;
    }
    
    private void mapDtoToEntity(RiskRegisterDTO dto, RiskRegister risk) {
        if (dto.projectId != null) {
            risk.project = Project.findById(dto.projectId);
        }
        risk.riskId = dto.riskId;
        risk.riskTitle = dto.riskTitle;
        risk.description = dto.description;
        risk.category = dto.category;
        risk.probability = dto.probability;
        risk.impact = dto.impact;
        risk.status = dto.status;
        risk.owner = dto.owner;
        risk.identifiedDate = dto.identifiedDate;
        risk.targetClosureDate = dto.targetClosureDate;
        risk.mitigationStrategy = dto.mitigationStrategy;
        risk.contingencyPlan = dto.contingencyPlan;
    }
    
    private String generateRiskId(Long projectId) {
        String projectCode = Project.<Project>findById(projectId).projectCode;
        long riskCount = riskRepository.count("project.id", projectId);
        return String.format("%s-RISK-%03d", projectCode, riskCount + 1);
    }
    
    private void createAssessmentHistory(RiskRegister risk, 
                                       RiskProbability prevProbability,
                                       RiskImpact prevImpact,
                                       Integer prevScore) {
        RiskAssessmentHistory history = new RiskAssessmentHistory();
        history.risk = risk;
        history.previousProbability = prevProbability;
        history.newProbability = risk.probability;
        history.previousImpact = prevImpact;
        history.newImpact = risk.impact;
        history.previousScore = prevScore;
        history.newScore = risk.riskScore;
        history.assessedBy = "system"; // In real app, get from security context
        history.persist();
    }
}

