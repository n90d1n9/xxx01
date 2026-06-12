import 'project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairSessionStep {
  const ProjectDomainGapRepairSessionStep({
    required this.stepNumber,
    required this.target,
  });

  final int stepNumber;
  final ProjectDomainGapRepairTarget target;

  String get actionLabel =>
      '$stepNumber ${target.fieldLabel} - ${target.projectLabel}';

  String get tooltipLabel =>
      'Open step $stepNumber: ${target.fieldLabel} for '
      '${target.projectLabel}. ${target.priorityLabel}.';
}

class ProjectDomainGapRepairSessionPathSummary {
  const ProjectDomainGapRepairSessionPathSummary({
    required this.visibleSteps,
    required this.totalStepCount,
  });

  factory ProjectDomainGapRepairSessionPathSummary.empty() {
    return const ProjectDomainGapRepairSessionPathSummary(
      visibleSteps: [],
      totalStepCount: 0,
    );
  }

  factory ProjectDomainGapRepairSessionPathSummary.fromPlan(
    ProjectDomainGapRepairPlan plan, {
    int maxSteps = 3,
  }) {
    if (plan.isEmpty || maxSteps <= 0) {
      return ProjectDomainGapRepairSessionPathSummary.empty();
    }

    final steps = <ProjectDomainGapRepairSessionStep>[];
    for (var index = 0; index < plan.allTargets.length; index++) {
      steps.add(
        ProjectDomainGapRepairSessionStep(
          stepNumber: index + 1,
          target: plan.allTargets[index],
        ),
      );
    }

    return ProjectDomainGapRepairSessionPathSummary(
      visibleSteps: List.unmodifiable(steps.take(maxSteps)),
      totalStepCount: plan.totalTargetCount,
    );
  }

  final List<ProjectDomainGapRepairSessionStep> visibleSteps;
  final int totalStepCount;

  bool get hasPath => totalStepCount > 1 && visibleSteps.isNotEmpty;
  bool get hasHiddenSteps => hiddenStepCount > 0;
  int get hiddenStepCount => totalStepCount - visibleSteps.length;
}

ProjectDomainGapRepairSessionPathSummary
buildProjectDomainGapRepairSessionPathSummary({
  required ProjectDomainGapRepairPlan plan,
  int maxSteps = 3,
}) {
  return ProjectDomainGapRepairSessionPathSummary.fromPlan(
    plan,
    maxSteps: maxSteps,
  );
}
