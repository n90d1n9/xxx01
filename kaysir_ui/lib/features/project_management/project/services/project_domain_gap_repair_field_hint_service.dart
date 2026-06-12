import '../models/project_custom_attribute.dart';
import 'project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairFieldHint {
  const ProjectDomainGapRepairFieldHint({
    required this.type,
    required this.label,
    required this.detail,
  });

  final ProjectCustomAttributeType type;
  final String label;
  final String detail;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProjectDomainGapRepairFieldHint &&
            other.type == type &&
            other.label == label &&
            other.detail == detail;
  }

  @override
  int get hashCode => Object.hash(type, label, detail);
}

ProjectDomainGapRepairFieldHint buildProjectDomainGapRepairFieldHint({
  required ProjectDomainGapRepairTarget target,
}) {
  final field = target.fieldLabel;

  switch (target.column.type) {
    case ProjectCustomAttributeType.text:
      return ProjectDomainGapRepairFieldHint(
        type: target.column.type,
        label: 'Text value',
        detail: 'Capture concise context for $field.',
      );
    case ProjectCustomAttributeType.number:
      return ProjectDomainGapRepairFieldHint(
        type: target.column.type,
        label: 'Number value',
        detail: 'Enter a measurable numeric value for $field.',
      );
    case ProjectCustomAttributeType.date:
      return ProjectDomainGapRepairFieldHint(
        type: target.column.type,
        label: 'Date value',
        detail: 'Use a target, milestone, or decision date for $field.',
      );
    case ProjectCustomAttributeType.url:
      return ProjectDomainGapRepairFieldHint(
        type: target.column.type,
        label: 'URL value',
        detail: 'Add the link or source of truth for $field.',
      );
    case ProjectCustomAttributeType.choice:
      return ProjectDomainGapRepairFieldHint(
        type: target.column.type,
        label: 'Choice value',
        detail: 'Select the closest configured option for $field.',
      );
    case ProjectCustomAttributeType.boolean:
      return ProjectDomainGapRepairFieldHint(
        type: target.column.type,
        label: 'Yes/No value',
        detail: 'Choose yes or no for $field.',
      );
  }
}
