import '../data/project_domain_registry.dart';
import '../models/project_custom_attribute.dart';
import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';

class ProjectDomainTeamTemplateService {
  const ProjectDomainTeamTemplateService();

  List<ProjectTeamMember> buildTeam(ProjectFormDraft draft) {
    final template =
        projectDomainPackForBusinessDomain(draft.businessDomain).teamTemplate;
    final supportContext = _attributeValue(
      draft,
      template.supportContextAttributeKey,
    );

    return List.unmodifiable([
      ProjectTeamMember(
        name: _personOrFallback(draft.owner, 'Unassigned delivery lead'),
        role: template.leadRole,
        allocation: 0.7,
      ),
      ProjectTeamMember(
        name: _personOrFallback(draft.sponsor, 'Unassigned sponsor'),
        role: template.sponsorRole,
        allocation: 0.25,
      ),
      ProjectTeamMember(
        name: _contextTeamName(supportContext, template.supportNameFallback),
        role: template.supportRole,
        allocation: 0.45,
      ),
    ]);
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

  String _personOrFallback(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _contextTeamName(String context, String fallback) {
    final trimmed = context.trim();
    if (trimmed.isEmpty) return fallback;

    return '$trimmed $fallback';
  }
}
