import '../data/project_domain_registry.dart';
import '../models/project_custom_attribute.dart';

enum ProjectCustomAttributeExtensionSuggestionKind {
  governance,
  operations,
  success,
  dependency,
}

class ProjectCustomAttributeExtensionSuggestion {
  const ProjectCustomAttributeExtensionSuggestion({
    required this.kind,
    required this.key,
    required this.label,
    required this.type,
    required this.reason,
    this.unit = '',
    this.options = const [],
  });

  final ProjectCustomAttributeExtensionSuggestionKind kind;
  final String key;
  final String label;
  final ProjectCustomAttributeType type;
  final String reason;
  final String unit;
  final List<String> options;

  String get actionLabel => 'Add $label';

  ProjectCustomAttribute toAttribute() {
    return ProjectCustomAttribute(
      key: key,
      label: label,
      type: type,
      unit: unit,
      options: options,
      isPinned: true,
    );
  }
}

class ProjectCustomAttributeExtensionSuggestionSet {
  const ProjectCustomAttributeExtensionSuggestionSet({
    required this.businessDomain,
    required this.visibleSuggestions,
    required this.totalSuggestionCount,
  });

  final String businessDomain;
  final List<ProjectCustomAttributeExtensionSuggestion> visibleSuggestions;
  final int totalSuggestionCount;

  bool get hasSuggestions => totalSuggestionCount > 0;
  bool get hasHiddenSuggestions => hiddenSuggestionCount > 0;
  int get hiddenSuggestionCount =>
      totalSuggestionCount - visibleSuggestions.length;
}

class ProjectCustomAttributeExtensionSuggestionService {
  const ProjectCustomAttributeExtensionSuggestionService();

  ProjectCustomAttributeExtensionSuggestionSet build({
    required String businessDomain,
    required Iterable<ProjectCustomAttribute> attributes,
    int maxVisibleSuggestions = 4,
  }) {
    if (maxVisibleSuggestions <= 0) {
      return ProjectCustomAttributeExtensionSuggestionSet(
        businessDomain:
            projectDomainPackForBusinessDomain(businessDomain).businessDomain,
        visibleSuggestions: const [],
        totalSuggestionCount: 0,
      );
    }

    final pack = projectDomainPackForBusinessDomain(businessDomain);
    final normalized = normalizeProjectCustomAttributes(
      attributes,
      keepEmpty: true,
    );
    final usedKeys = {
      for (final attribute in normalized)
        normalizeProjectCustomAttributeKey(attribute.key),
    };
    final availableSlots = projectCustomAttributeLimit - normalized.length;

    if (availableSlots <= 0) {
      return ProjectCustomAttributeExtensionSuggestionSet(
        businessDomain: pack.businessDomain,
        visibleSuggestions: const [],
        totalSuggestionCount: 0,
      );
    }

    final suggestions = <ProjectCustomAttributeExtensionSuggestion>[];
    final suggestedKeys = <String>{};

    void addSuggestions(
      Iterable<ProjectCustomAttributeExtensionSuggestion> candidates,
    ) {
      for (final candidate in candidates) {
        final key = normalizeProjectCustomAttributeKey(candidate.key);
        if (usedKeys.contains(key) || !suggestedKeys.add(key)) continue;
        suggestions.add(candidate);
      }
    }

    addSuggestions(_domainSuggestions[pack.id] ?? const []);
    addSuggestions(_sharedSuggestions);

    final visibleCount =
        availableSlots < maxVisibleSuggestions
            ? availableSlots
            : maxVisibleSuggestions;

    return ProjectCustomAttributeExtensionSuggestionSet(
      businessDomain: pack.businessDomain,
      visibleSuggestions: List.unmodifiable(suggestions.take(visibleCount)),
      totalSuggestionCount: suggestions.length,
    );
  }
}

const _sharedSuggestions = [
  ProjectCustomAttributeExtensionSuggestion(
    kind: ProjectCustomAttributeExtensionSuggestionKind.governance,
    key: 'approval-owner',
    label: 'Approval Owner',
    type: ProjectCustomAttributeType.text,
    reason: 'Capture who can unblock scope, budget, or launch decisions.',
  ),
  ProjectCustomAttributeExtensionSuggestion(
    kind: ProjectCustomAttributeExtensionSuggestionKind.success,
    key: 'success-metric',
    label: 'Success Metric',
    type: ProjectCustomAttributeType.text,
    reason: 'Make handoff quality measurable across any business domain.',
  ),
  ProjectCustomAttributeExtensionSuggestion(
    kind: ProjectCustomAttributeExtensionSuggestionKind.dependency,
    key: 'external-dependency',
    label: 'External Dependency',
    type: ProjectCustomAttributeType.text,
    reason:
        'Track vendor, stakeholder, system, venue, or authority dependency.',
  ),
  ProjectCustomAttributeExtensionSuggestion(
    kind: ProjectCustomAttributeExtensionSuggestionKind.operations,
    key: 'support-window',
    label: 'Support Window',
    type: ProjectCustomAttributeType.date,
    reason: 'Pin the operational window that needs active support.',
  ),
];

const _domainSuggestions = {
  'construction': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.operations,
      key: 'inspection-window',
      label: 'Inspection Window',
      type: ProjectCustomAttributeType.date,
      reason: 'Track the inspection date that can unlock handover readiness.',
    ),
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.dependency,
      key: 'critical-supplier',
      label: 'Critical Supplier',
      type: ProjectCustomAttributeType.text,
      reason: 'Expose supplier dependency before site execution slips.',
    ),
  ],
  'software-development': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.operations,
      key: 'rollback-owner',
      label: 'Rollback Owner',
      type: ProjectCustomAttributeType.text,
      reason: 'Capture who owns rollback decisions during release windows.',
    ),
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.success,
      key: 'adoption-signal',
      label: 'Adoption Signal',
      type: ProjectCustomAttributeType.text,
      reason: 'Define how release value will be observed after launch.',
    ),
  ],
  'music-event': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.operations,
      key: 'vendor-call-time',
      label: 'Vendor Call Time',
      type: ProjectCustomAttributeType.date,
      reason: 'Keep vendor readiness tied to production timing.',
    ),
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.dependency,
      key: 'authority-contact',
      label: 'Authority Contact',
      type: ProjectCustomAttributeType.text,
      reason: 'Capture the permit or venue authority escalation contact.',
    ),
  ],
  'government-program': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.governance,
      key: 'steering-forum',
      label: 'Steering Forum',
      type: ProjectCustomAttributeType.text,
      reason: 'Make governance cadence visible for public program decisions.',
    ),
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.success,
      key: 'public-outcome',
      label: 'Public Outcome',
      type: ProjectCustomAttributeType.text,
      reason: 'Connect program delivery to the citizen or agency outcome.',
    ),
  ],
  'education-program': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.success,
      key: 'learning-outcome',
      label: 'Learning Outcome',
      type: ProjectCustomAttributeType.text,
      reason: 'Track the learner outcome that defines delivery value.',
    ),
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.operations,
      key: 'cohort-window',
      label: 'Cohort Window',
      type: ProjectCustomAttributeType.date,
      reason: 'Keep academic or training timing visible for handoff planning.',
    ),
  ],
  'wedding-organizer': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.dependency,
      key: 'vendor-cutoff',
      label: 'Vendor Cutoff',
      type: ProjectCustomAttributeType.date,
      reason: 'Track the last safe date for vendor package decisions.',
    ),
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.success,
      key: 'client-moment',
      label: 'Client Moment',
      type: ProjectCustomAttributeType.text,
      reason: 'Capture the experience detail the client cares about most.',
    ),
  ],
  'retail-operations': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.operations,
      key: 'rollout-support',
      label: 'Rollout Support',
      type: ProjectCustomAttributeType.text,
      reason: 'Capture the team or window supporting store rollout waves.',
    ),
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.success,
      key: 'sales-lift-target',
      label: 'Sales Lift Target',
      type: ProjectCustomAttributeType.number,
      unit: '%',
      reason: 'Make retail launch value measurable after rollout.',
    ),
  ],
  'general-business': [
    ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.governance,
      key: 'decision-route',
      label: 'Decision Route',
      type: ProjectCustomAttributeType.text,
      reason: 'Capture how project decisions move across the business.',
    ),
  ],
};
