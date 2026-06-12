import 'project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairSessionSummary {
  const ProjectDomainGapRepairSessionSummary({
    required this.nextTarget,
    required this.totalStepCount,
    required this.projectCount,
    required this.domainCount,
    required this.requiredStepCount,
    required this.riskSignalStepCount,
    required this.recommendedStepCount,
    required this.coverageGapStepCount,
  });

  factory ProjectDomainGapRepairSessionSummary.empty() {
    return const ProjectDomainGapRepairSessionSummary(
      nextTarget: null,
      totalStepCount: 0,
      projectCount: 0,
      domainCount: 0,
      requiredStepCount: 0,
      riskSignalStepCount: 0,
      recommendedStepCount: 0,
      coverageGapStepCount: 0,
    );
  }

  final ProjectDomainGapRepairTarget? nextTarget;
  final int totalStepCount;
  final int projectCount;
  final int domainCount;
  final int requiredStepCount;
  final int riskSignalStepCount;
  final int recommendedStepCount;
  final int coverageGapStepCount;

  bool get isEmpty => nextTarget == null || totalStepCount == 0;

  String get stepCountLabel {
    final suffix = totalStepCount == 1 ? 'step' : 'steps';
    return 'Guided: $totalStepCount $suffix';
  }

  String get nextStepLabel {
    final target = nextTarget;
    if (target == null) return 'No repair step';
    return 'Step 1: ${target.fieldLabel} - ${target.projectLabel}';
  }

  String get projectScopeLabel {
    return projectCount == 1 ? '1 project' : '$projectCount projects';
  }

  String get domainScopeLabel {
    return domainCount == 1 ? '1 domain' : '$domainCount domains';
  }

  String get priorityPathLabel {
    final labels = <String>[
      if (requiredStepCount > 0) '$requiredStepCount required',
      if (riskSignalStepCount > 0) '$riskSignalStepCount risk',
      if (recommendedStepCount > 0) '$recommendedStepCount recommended',
      if (coverageGapStepCount > 0) '$coverageGapStepCount coverage',
    ];
    return labels.join(' - ');
  }
}

ProjectDomainGapRepairSessionSummary buildProjectDomainGapRepairSessionSummary({
  required ProjectDomainGapRepairPlan plan,
}) {
  if (plan.isEmpty) return ProjectDomainGapRepairSessionSummary.empty();

  final projectIds = <String>{};
  final domainLabels = <String>{};

  for (final target in plan.allTargets) {
    projectIds.add(target.project.id);
    domainLabels.add(_domainLabel(target.project.businessDomain));
  }

  return ProjectDomainGapRepairSessionSummary(
    nextTarget: plan.allTargets.first,
    totalStepCount: plan.totalTargetCount,
    projectCount: projectIds.length,
    domainCount: domainLabels.length,
    requiredStepCount: plan.requiredTargetCount,
    riskSignalStepCount: plan.riskSignalTargetCount,
    recommendedStepCount: plan.recommendedTargetCount,
    coverageGapStepCount: plan.coverageGapTargetCount,
  );
}

String _domainLabel(String value) {
  final label = value.trim();
  return label.isEmpty ? 'General Business' : label;
}
