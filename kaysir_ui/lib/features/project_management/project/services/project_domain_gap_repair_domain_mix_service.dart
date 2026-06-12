import 'project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairDomainGroup {
  const ProjectDomainGapRepairDomainGroup({
    required this.domainKey,
    required this.domainLabel,
    required this.targets,
    required this.sortOrder,
  });

  final String domainKey;
  final String domainLabel;
  final List<ProjectDomainGapRepairTarget> targets;
  final int sortOrder;

  ProjectDomainGapRepairTarget get primaryTarget => targets.first;
  int get targetCount => targets.length;
  int get projectCount =>
      targets.map((target) => target.project.id).toSet().length;
  int get requiredCount => _count(ProjectDomainGapRepairPriority.requiredField);
  int get riskSignalCount => _count(ProjectDomainGapRepairPriority.riskSignal);
  int get recommendedCount =>
      _count(ProjectDomainGapRepairPriority.recommended);
  int get coverageGapCount =>
      _count(ProjectDomainGapRepairPriority.coverageGap);

  String get actionLabel {
    final suffix = targetCount == 1 ? 'fix' : 'fixes';
    return '$targetCount $suffix: $domainLabel';
  }

  String get fieldSummaryLabel {
    final labels = targets.map((target) => target.fieldLabel).toSet().toList();
    if (labels.length <= 3) return labels.join(', ');
    return '${labels.take(3).join(', ')} +${labels.length - 3} more';
  }

  String get projectScopeLabel {
    return projectCount == 1 ? '1 project' : '$projectCount projects';
  }

  String get prioritySummaryLabel {
    final labels = <String>[
      if (requiredCount > 0) '$requiredCount required',
      if (riskSignalCount > 0) '$riskSignalCount risk',
      if (recommendedCount > 0) '$recommendedCount recommended',
      if (coverageGapCount > 0) '$coverageGapCount coverage',
    ];
    return labels.join(' - ');
  }

  String get tooltipLabel =>
      'Open ${primaryTarget.fieldLabel} - ${primaryTarget.projectLabel}. '
      '$domainLabel is missing $fieldSummaryLabel across $projectScopeLabel.';

  int _count(ProjectDomainGapRepairPriority priority) {
    return targets.where((target) => target.priority == priority).length;
  }
}

class ProjectDomainGapRepairDomainMixSummary {
  const ProjectDomainGapRepairDomainMixSummary({
    required this.visibleGroups,
    required this.allGroups,
    required this.totalGroupCount,
  });

  factory ProjectDomainGapRepairDomainMixSummary.empty() {
    return const ProjectDomainGapRepairDomainMixSummary(
      visibleGroups: [],
      allGroups: [],
      totalGroupCount: 0,
    );
  }

  factory ProjectDomainGapRepairDomainMixSummary.fromPlan(
    ProjectDomainGapRepairPlan plan, {
    int maxGroups = 3,
  }) {
    if (plan.isEmpty || maxGroups <= 0) {
      return ProjectDomainGapRepairDomainMixSummary.empty();
    }

    final builders = <String, _DomainGroupBuilder>{};

    for (var index = 0; index < plan.allTargets.length; index++) {
      final target = plan.allTargets[index];
      final domainLabel = _domainLabel(target.project.businessDomain);
      final domainKey = _domainKey(domainLabel);
      final builder = builders.putIfAbsent(
        domainKey,
        () => _DomainGroupBuilder(
          domainKey: domainKey,
          domainLabel: domainLabel,
          firstIndex: index,
        ),
      );
      builder.targets.add(target);
    }

    final groups =
        builders.values.map((builder) => builder.build()).toList()
          ..sort(_compareDomainGroups);

    return ProjectDomainGapRepairDomainMixSummary(
      visibleGroups: List.unmodifiable(groups.take(maxGroups)),
      allGroups: List.unmodifiable(groups),
      totalGroupCount: groups.length,
    );
  }

  final List<ProjectDomainGapRepairDomainGroup> visibleGroups;
  final List<ProjectDomainGapRepairDomainGroup> allGroups;
  final int totalGroupCount;

  bool get hasMix => totalGroupCount > 1 && visibleGroups.isNotEmpty;
  bool get hasHiddenGroups => hiddenGroupCount > 0;
  int get hiddenGroupCount => totalGroupCount - visibleGroups.length;
}

ProjectDomainGapRepairDomainMixSummary
buildProjectDomainGapRepairDomainMixSummary({
  required ProjectDomainGapRepairPlan plan,
  int maxGroups = 3,
}) {
  return ProjectDomainGapRepairDomainMixSummary.fromPlan(
    plan,
    maxGroups: maxGroups,
  );
}

int _compareDomainGroups(
  ProjectDomainGapRepairDomainGroup first,
  ProjectDomainGapRepairDomainGroup second,
) {
  final countCompare = second.targetCount.compareTo(first.targetCount);
  if (countCompare != 0) return countCompare;

  return first.sortOrder.compareTo(second.sortOrder);
}

String _domainLabel(String value) {
  final label = value.trim();
  return label.isEmpty ? 'General Business' : label;
}

String _domainKey(String label) {
  final normalized = label
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return normalized.isEmpty ? 'general-business' : normalized;
}

class _DomainGroupBuilder {
  _DomainGroupBuilder({
    required this.domainKey,
    required this.domainLabel,
    required this.firstIndex,
  });

  final String domainKey;
  final String domainLabel;
  final int firstIndex;
  final List<ProjectDomainGapRepairTarget> targets = [];

  ProjectDomainGapRepairDomainGroup build() {
    return ProjectDomainGapRepairDomainGroup(
      domainKey: domainKey,
      domainLabel: domainLabel,
      targets: List.unmodifiable(targets),
      sortOrder: firstIndex,
    );
  }
}
