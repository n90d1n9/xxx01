import '../models/project_custom_attribute.dart';
import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';
import '../data/project_domain_registry.dart';

class ProjectDomainMilestoneTemplateService {
  const ProjectDomainMilestoneTemplateService();

  List<ProjectMilestone> buildMilestones(ProjectFormDraft draft) {
    final labels = _labelsFor(draft);
    final totalDays = draft.endDate.difference(draft.startDate).inDays;
    final reviewOffset = totalDays <= 0 ? 0 : totalDays ~/ 2;
    final reviewDate = draft.startDate.add(Duration(days: reviewOffset));
    final thresholds = [0.15, 0.55, 0.95];
    final dates = [draft.startDate, reviewDate, draft.endDate];

    return List.unmodifiable([
      for (var index = 0; index < labels.length; index++)
        ProjectMilestone(
          label: labels[index],
          dueDate: dates[index],
          isComplete: draft.progress >= thresholds[index],
        ),
    ]);
  }

  List<String> _labelsFor(ProjectFormDraft draft) {
    final template =
        projectDomainPackForBusinessDomain(
          draft.businessDomain,
        ).milestoneTemplate;
    final reviewLabel =
        template.reviewLabel.trim().isEmpty
            ? '${draft.businessDomain} Review'
            : template.reviewLabel;

    return [
      _contextLabel(
        _attributeValue(draft, template.kickoffContextAttributeKey),
        template.kickoffLabel,
      ),
      _contextLabel(
        _attributeValue(draft, template.reviewContextAttributeKey),
        reviewLabel,
      ),
      _contextLabel(
        _attributeValue(draft, template.handoverContextAttributeKey),
        template.handoverLabel,
      ),
    ];
  }

  String _attributeValue(ProjectFormDraft draft, String key) {
    final normalizedKey = normalizeProjectCustomAttributeKey(key);
    for (final attribute in draft.customAttributes) {
      if (normalizeProjectCustomAttributeKey(attribute.key) == normalizedKey &&
          attribute.value.trim().isNotEmpty) {
        return attribute.displayValue;
      }
    }

    return '';
  }

  String _contextLabel(String context, String fallback) {
    final trimmed = context.trim();
    if (trimmed.isEmpty) return fallback;

    return '$trimmed: $fallback';
  }
}
