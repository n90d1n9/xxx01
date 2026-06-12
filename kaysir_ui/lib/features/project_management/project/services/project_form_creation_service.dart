import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';
import '../models/project_custom_attribute.dart';
import 'project_domain_milestone_template_service.dart';
import 'project_domain_risk_template_service.dart';
import 'project_domain_team_template_service.dart';

class ProjectFormCreationService {
  const ProjectFormCreationService({
    ProjectDomainMilestoneTemplateService milestoneTemplateService =
        const ProjectDomainMilestoneTemplateService(),
    ProjectDomainRiskTemplateService riskTemplateService =
        const ProjectDomainRiskTemplateService(),
    ProjectDomainTeamTemplateService teamTemplateService =
        const ProjectDomainTeamTemplateService(),
  }) : _milestoneTemplateService = milestoneTemplateService,
       _riskTemplateService = riskTemplateService,
       _teamTemplateService = teamTemplateService;

  final ProjectDomainMilestoneTemplateService _milestoneTemplateService;
  final ProjectDomainRiskTemplateService _riskTemplateService;
  final ProjectDomainTeamTemplateService _teamTemplateService;

  ProjectPortfolioItem createProject({
    required ProjectFormDraft draft,
    required Iterable<ProjectPortfolioItem> existingProjects,
  }) {
    return ProjectPortfolioItem(
      id: _uniqueProjectId(draft.name, existingProjects),
      name: draft.name.trim(),
      owner: draft.owner.trim(),
      client: draft.client.trim(),
      businessDomain: draft.businessDomain,
      sponsor: draft.sponsor.trim(),
      summary: draft.summary.trim(),
      startDate: draft.startDate,
      endDate: draft.endDate,
      progress: draft.progress.clamp(0, 1),
      budgetUsed: draft.budgetUsed.clamp(0, 1),
      health: draft.health,
      milestones: _milestoneTemplateService.buildMilestones(draft),
      risks: _riskTemplateService.buildRisks(draft),
      team: _teamTemplateService.buildTeam(draft),
      customAttributes: projectCustomAttributesForStorage(
        draft.customAttributes,
      ),
    );
  }

  ProjectPortfolioItem updateProject({
    required ProjectPortfolioItem project,
    required ProjectFormDraft draft,
  }) {
    return ProjectPortfolioItem(
      id: project.id,
      name: draft.name.trim(),
      owner: draft.owner.trim(),
      client: draft.client.trim(),
      businessDomain: draft.businessDomain,
      sponsor: draft.sponsor.trim(),
      summary: draft.summary.trim(),
      startDate: draft.startDate,
      endDate: draft.endDate,
      progress: draft.progress.clamp(0, 1),
      budgetUsed: draft.budgetUsed.clamp(0, 1),
      health: draft.health,
      milestones: _milestoneTemplateService.buildMilestones(draft),
      risks:
          project.risks.isEmpty
              ? _riskTemplateService.buildRisks(draft)
              : project.risks,
      team:
          project.team.isEmpty
              ? _teamTemplateService.buildTeam(draft)
              : project.team,
      timelineTaskIds: project.timelineTaskIds,
      customAttributes: projectCustomAttributesForStorage(
        draft.customAttributes,
      ),
    );
  }

  String _uniqueProjectId(
    String projectName,
    Iterable<ProjectPortfolioItem> existingProjects,
  ) {
    final existingIds = existingProjects.map((project) => project.id).toSet();
    final baseId = _slugFor(projectName);
    var candidate = baseId;
    var suffix = 2;

    while (existingIds.contains(candidate)) {
      candidate = '$baseId-$suffix';
      suffix += 1;
    }

    return candidate;
  }

  String _slugFor(String value) {
    final slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'new-project' : slug;
  }
}
