import '../models/project_custom_attribute.dart';
import 'project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairFieldTypeGroup {
  const ProjectDomainGapRepairFieldTypeGroup({
    required this.type,
    required this.targets,
  });

  final ProjectCustomAttributeType type;
  final List<ProjectDomainGapRepairTarget> targets;

  ProjectDomainGapRepairTarget get primaryTarget => targets.first;
  int get targetCount => targets.length;
  int get requiredCount => _count(ProjectDomainGapRepairPriority.requiredField);
  int get riskSignalCount => _count(ProjectDomainGapRepairPriority.riskSignal);
  int get recommendedCount =>
      _count(ProjectDomainGapRepairPriority.recommended);
  int get coverageGapCount =>
      _count(ProjectDomainGapRepairPriority.coverageGap);

  String get actionLabel {
    final suffix = targetCount == 1 ? 'fix' : 'fixes';
    return '$targetCount ${type.label} $suffix';
  }

  String get fieldSummaryLabel {
    final labels = targets.map((target) => target.fieldLabel).toSet().toList();
    if (labels.length <= 3) return labels.join(', ');
    return '${labels.take(3).join(', ')} +${labels.length - 3} more';
  }

  String get projectScopeLabel {
    final projectCount =
        targets.map((target) => target.project.id).toSet().length;
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
      'Missing $fieldSummaryLabel across $projectScopeLabel.';

  int _count(ProjectDomainGapRepairPriority priority) {
    return targets.where((target) => target.priority == priority).length;
  }
}

class ProjectDomainGapRepairFieldTypeMixSummary {
  const ProjectDomainGapRepairFieldTypeMixSummary({
    required this.visibleGroups,
    required this.allGroups,
    required this.totalGroupCount,
    required this.totalTargetCount,
  });

  factory ProjectDomainGapRepairFieldTypeMixSummary.empty() {
    return const ProjectDomainGapRepairFieldTypeMixSummary(
      visibleGroups: [],
      allGroups: [],
      totalGroupCount: 0,
      totalTargetCount: 0,
    );
  }

  factory ProjectDomainGapRepairFieldTypeMixSummary.fromPlan(
    ProjectDomainGapRepairPlan plan, {
    int maxGroups = 4,
  }) {
    if (plan.isEmpty || maxGroups <= 0) {
      return ProjectDomainGapRepairFieldTypeMixSummary.empty();
    }

    final builders = <ProjectCustomAttributeType, _FieldTypeGroupBuilder>{};

    for (var index = 0; index < plan.allTargets.length; index++) {
      final target = plan.allTargets[index];
      final builder = builders.putIfAbsent(
        target.column.type,
        () =>
            _FieldTypeGroupBuilder(type: target.column.type, firstIndex: index),
      );
      builder.targets.add(target);
    }

    final groups =
        builders.values.map((builder) => builder.build()).toList()
          ..sort(_compareFieldTypeGroups);

    return ProjectDomainGapRepairFieldTypeMixSummary(
      visibleGroups: List.unmodifiable(groups.take(maxGroups)),
      allGroups: List.unmodifiable(groups),
      totalGroupCount: groups.length,
      totalTargetCount: plan.totalTargetCount,
    );
  }

  final List<ProjectDomainGapRepairFieldTypeGroup> visibleGroups;
  final List<ProjectDomainGapRepairFieldTypeGroup> allGroups;
  final int totalGroupCount;
  final int totalTargetCount;

  bool get hasMix => totalTargetCount > 1 && visibleGroups.isNotEmpty;
  bool get hasHiddenGroups => hiddenGroupCount > 0;
  int get hiddenGroupCount => totalGroupCount - visibleGroups.length;
}

ProjectDomainGapRepairFieldTypeMixSummary
buildProjectDomainGapRepairFieldTypeMixSummary({
  required ProjectDomainGapRepairPlan plan,
  int maxGroups = 4,
}) {
  return ProjectDomainGapRepairFieldTypeMixSummary.fromPlan(
    plan,
    maxGroups: maxGroups,
  );
}

int _compareFieldTypeGroups(
  ProjectDomainGapRepairFieldTypeGroup first,
  ProjectDomainGapRepairFieldTypeGroup second,
) {
  final countCompare = second.targetCount.compareTo(first.targetCount);
  if (countCompare != 0) return countCompare;

  return _sortOrder(first).compareTo(_sortOrder(second));
}

int _sortOrder(ProjectDomainGapRepairFieldTypeGroup group) {
  return group is _OrderedProjectDomainGapRepairFieldTypeGroup
      ? group.compareOrder
      : 0;
}

class _FieldTypeGroupBuilder {
  _FieldTypeGroupBuilder({required this.type, required this.firstIndex});

  final ProjectCustomAttributeType type;
  final int firstIndex;
  final List<ProjectDomainGapRepairTarget> targets = [];

  ProjectDomainGapRepairFieldTypeGroup build() {
    return _OrderedProjectDomainGapRepairFieldTypeGroup(
      type: type,
      targets: List.unmodifiable(targets),
      compareOrder: firstIndex,
    );
  }
}

class _OrderedProjectDomainGapRepairFieldTypeGroup
    extends ProjectDomainGapRepairFieldTypeGroup {
  const _OrderedProjectDomainGapRepairFieldTypeGroup({
    required super.type,
    required super.targets,
    required this.compareOrder,
  });

  final int compareOrder;
}
