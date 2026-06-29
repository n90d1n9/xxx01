package tech.kayys.risk.service;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.Project;
import tech.kayys.risk.domain.RiskRegister;
import tech.kayys.risk.domain.RiskTemplate;
import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.repository.RiskTemplateRepository;

import java.util.List;

@ApplicationScoped
public class RiskTemplateService {

    @Inject
    RiskTemplateRepository templateRepo;

    public Uni<List<RiskTemplate>> getAllTemplates() {
        return templateRepo.listAll();
    }

    public Uni<List<RiskTemplate>> getByCategory(RiskCategory category) {
        return templateRepo.findByCategory(category);
    }

    public Uni<List<RiskTemplate>> searchTemplates(String keyword) {
        return templateRepo.searchByKeyword(keyword);
    }

    /**
     * Clone template into a real RiskRegister entry for a project
     */
    public RiskRegister instantiateTemplate(RiskTemplate template, Project project, String createdBy) {
        RiskRegister risk = new RiskRegister();
        risk.project = project;
        risk.riskId = template.code + "-" + project.id;
        risk.riskTitle = template.title;
        risk.description = template.description;
        risk.category = template.category;
        risk.type = template.type;
        risk.probability = template.defaultProbability;
        risk.impact = template.defaultImpact;
        risk.mitigationStrategy = template.mitigationSuggestion;
        risk.contingencyPlan = template.contingencySuggestion;
        risk.createdBy = createdBy;
        return risk;
    }
}
