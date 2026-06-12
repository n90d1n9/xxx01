import 'project_custom_attribute.dart';

class ProjectDomainPack {
  const ProjectDomainPack({
    required this.id,
    required this.businessDomain,
    required this.label,
    required this.statusVocabularyId,
    required this.statusAudienceId,
    required this.customAttributeTemplates,
    required this.playbookControlTemplate,
    required this.riskRules,
    required this.milestoneTemplate,
    required this.teamTemplate,
  });

  final String id;
  final String businessDomain;
  final String label;
  final String statusVocabularyId;
  final String statusAudienceId;
  final List<ProjectCustomAttributeTemplate> customAttributeTemplates;
  final ProjectDomainPlaybookControlTemplate playbookControlTemplate;
  final List<ProjectDomainRiskRule> riskRules;
  final ProjectDomainMilestoneTemplate milestoneTemplate;
  final ProjectDomainTeamTemplate teamTemplate;
}

enum ProjectDomainRiskRuleTrigger {
  missingAttribute,
  attributeEquals,
  booleanMissing,
  booleanFalse,
  booleanTrue,
  numberAtLeast,
  attributeEqualsWhenProgressBelow,
}

class ProjectDomainRiskRule {
  const ProjectDomainRiskRule({
    required this.title,
    required this.detail,
    required this.severityId,
    required this.attributeKey,
    required this.trigger,
    this.expectedValue = '',
    this.threshold = 0,
    this.progressBelow = 0,
  });

  final String title;
  final String detail;
  final String severityId;
  final String attributeKey;
  final ProjectDomainRiskRuleTrigger trigger;
  final String expectedValue;
  final double threshold;
  final double progressBelow;
}

class ProjectDomainPlaybookControlTemplate {
  const ProjectDomainPlaybookControlTemplate({
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;
}

class ProjectDomainMilestoneTemplate {
  const ProjectDomainMilestoneTemplate({
    required this.kickoffLabel,
    required this.reviewLabel,
    required this.handoverLabel,
    this.kickoffContextAttributeKey = '',
    this.reviewContextAttributeKey = '',
    this.handoverContextAttributeKey = '',
  });

  final String kickoffLabel;
  final String reviewLabel;
  final String handoverLabel;
  final String kickoffContextAttributeKey;
  final String reviewContextAttributeKey;
  final String handoverContextAttributeKey;
}

class ProjectDomainTeamTemplate {
  const ProjectDomainTeamTemplate({
    required this.leadRole,
    required this.sponsorRole,
    required this.supportRole,
    required this.supportNameFallback,
    this.supportContextAttributeKey = '',
  });

  final String leadRole;
  final String sponsorRole;
  final String supportRole;
  final String supportNameFallback;
  final String supportContextAttributeKey;
}
