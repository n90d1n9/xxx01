import '../data/project_domain_registry.dart';
import '../models/project_custom_attribute.dart';
import '../models/project_custom_attribute_value.dart';
import '../models/project_domain_pack.dart';
import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';

class ProjectDomainRiskTemplateService {
  const ProjectDomainRiskTemplateService();

  List<ProjectDeliveryRisk> buildRisks(ProjectFormDraft draft) {
    final risks = <ProjectDeliveryRisk>[
      ..._baselineRisks(draft),
      ..._domainRisks(draft),
    ];

    if (risks.isEmpty) {
      risks.add(
        ProjectDeliveryRisk(
          title: '${draft.businessDomain} assumptions',
          detail:
              'Track the domain-specific assumptions captured in the custom attributes before execution ramps up.',
          severity: ProjectHealth.onTrack,
        ),
      );
    }

    return List.unmodifiable(risks.take(3));
  }

  List<ProjectDeliveryRisk> _baselineRisks(ProjectFormDraft draft) {
    final risks = <ProjectDeliveryRisk>[];
    final budgetGap = draft.budgetUsed - draft.progress;

    if (draft.health == ProjectHealth.blocked) {
      risks.add(
        const ProjectDeliveryRisk(
          title: 'Initial blocker',
          detail:
              'The project is entering the portfolio as blocked; capture the unblock owner and decision path.',
          severity: ProjectHealth.blocked,
        ),
      );
    } else if (draft.health == ProjectHealth.atRisk) {
      risks.add(
        const ProjectDeliveryRisk(
          title: 'Initial delivery risk',
          detail:
              'The project starts at risk; confirm the recovery owner, target date, and escalation route.',
          severity: ProjectHealth.atRisk,
        ),
      );
    }

    if (budgetGap >= 0.2) {
      risks.add(
        ProjectDeliveryRisk(
          title: 'Budget pace pressure',
          detail:
              'Budget usage is ${(draft.budgetUsed * 100).round()}% while planned progress is ${(draft.progress * 100).round()}%. Recheck scope, phase gates, and spend authority.',
          severity: ProjectHealth.atRisk,
        ),
      );
    }

    return risks;
  }

  List<ProjectDeliveryRisk> _domainRisks(ProjectFormDraft draft) {
    return [
      for (final rule
          in projectDomainPackForBusinessDomain(draft.businessDomain).riskRules)
        if (_ruleMatches(draft: draft, rule: rule)) _riskFromRule(draft, rule),
    ];
  }

  bool _ruleMatches({
    required ProjectFormDraft draft,
    required ProjectDomainRiskRule rule,
  }) {
    final value = _attributeValue(draft, rule.attributeKey);

    switch (rule.trigger) {
      case ProjectDomainRiskRuleTrigger.missingAttribute:
        return value.isEmpty;
      case ProjectDomainRiskRuleTrigger.attributeEquals:
        return value.toLowerCase() == rule.expectedValue.toLowerCase();
      case ProjectDomainRiskRuleTrigger.booleanMissing:
        return parseProjectCustomAttributeBool(value) == null;
      case ProjectDomainRiskRuleTrigger.booleanFalse:
        return parseProjectCustomAttributeBool(value) == false;
      case ProjectDomainRiskRuleTrigger.booleanTrue:
        return parseProjectCustomAttributeBool(value) == true;
      case ProjectDomainRiskRuleTrigger.numberAtLeast:
        final number = parseProjectCustomAttributeNumber(value);
        return number != null && number >= rule.threshold;
      case ProjectDomainRiskRuleTrigger.attributeEqualsWhenProgressBelow:
        return value.toLowerCase() == rule.expectedValue.toLowerCase() &&
            draft.progress < rule.progressBelow;
    }
  }

  ProjectDeliveryRisk _riskFromRule(
    ProjectFormDraft draft,
    ProjectDomainRiskRule rule,
  ) {
    return ProjectDeliveryRisk(
      title: rule.title,
      detail: _detailForRule(draft, rule),
      severity: _severityFor(rule.severityId),
    );
  }

  String _detailForRule(ProjectFormDraft draft, ProjectDomainRiskRule rule) {
    if (!rule.detail.contains('{value}')) return rule.detail;

    final attributeValue = _attributeValue(draft, rule.attributeKey);
    final number = parseProjectCustomAttributeNumber(attributeValue);
    final value = number == null ? attributeValue : '${number.round()}';

    return rule.detail.replaceAll('{value}', value);
  }

  ProjectHealth _severityFor(String severityId) {
    switch (severityId) {
      case 'blocked':
        return ProjectHealth.blocked;
      case 'atRisk':
        return ProjectHealth.atRisk;
      case 'onTrack':
      default:
        return ProjectHealth.onTrack;
    }
  }

  String _attributeValue(ProjectFormDraft draft, String key) {
    final normalizedKey = normalizeProjectCustomAttributeKey(key);
    for (final attribute in draft.customAttributes) {
      if (normalizeProjectCustomAttributeKey(attribute.key) == normalizedKey) {
        return attribute.value.trim();
      }
    }

    return '';
  }
}
