import '../models/project_portfolio_item.dart';
import 'project_domain_gap_repair_service.dart';

enum ProjectDomainGapRepairSessionFocusKind {
  stabilization,
  riskControl,
  domainCoverage,
  contextPolish,
}

class ProjectDomainGapRepairSessionFocusSummary {
  const ProjectDomainGapRepairSessionFocusSummary({
    required this.focusKind,
    required this.totalTargetCount,
    required this.projectCount,
    required this.domainCount,
    required this.blockedProjectCount,
    required this.atRiskProjectCount,
  });

  factory ProjectDomainGapRepairSessionFocusSummary.empty() {
    return const ProjectDomainGapRepairSessionFocusSummary(
      focusKind: ProjectDomainGapRepairSessionFocusKind.contextPolish,
      totalTargetCount: 0,
      projectCount: 0,
      domainCount: 0,
      blockedProjectCount: 0,
      atRiskProjectCount: 0,
    );
  }

  final ProjectDomainGapRepairSessionFocusKind focusKind;
  final int totalTargetCount;
  final int projectCount;
  final int domainCount;
  final int blockedProjectCount;
  final int atRiskProjectCount;

  bool get isEmpty => totalTargetCount == 0;
  bool get hasUrgentHealthContext =>
      blockedProjectCount > 0 || atRiskProjectCount > 0;

  String get focusLabel {
    switch (focusKind) {
      case ProjectDomainGapRepairSessionFocusKind.stabilization:
        return blockedProjectCount > 0
            ? 'Stabilize blockers'
            : 'Complete required fields';
      case ProjectDomainGapRepairSessionFocusKind.riskControl:
        return 'Reduce delivery risk';
      case ProjectDomainGapRepairSessionFocusKind.domainCoverage:
        return 'Broaden domain coverage';
      case ProjectDomainGapRepairSessionFocusKind.contextPolish:
        return 'Polish operating context';
    }
  }

  String get focusTooltip {
    switch (focusKind) {
      case ProjectDomainGapRepairSessionFocusKind.stabilization:
        return hasUrgentHealthContext
            ? 'Prioritize mandatory context on blocked or at-risk work.'
            : 'Prioritize mandatory fields before optional context.';
      case ProjectDomainGapRepairSessionFocusKind.riskControl:
        return 'Fill watched signals that help teams see delivery risk earlier.';
      case ProjectDomainGapRepairSessionFocusKind.domainCoverage:
        return 'Expand reusable domain fields across the active project set.';
      case ProjectDomainGapRepairSessionFocusKind.contextPolish:
        return 'Add recommended context that improves reporting and handoff.';
    }
  }

  String get paceLabel {
    if (totalTargetCount <= 2) return 'Quick pass';
    if (totalTargetCount <= 5) return 'Focused cleanup';
    return 'Deep cleanup';
  }

  String get scopeLabel {
    if (domainCount > 1) return '$domainCount-domain pass';
    if (projectCount > 1) return '$projectCount-project pass';
    return 'Single-project pass';
  }

  String get scopeTooltip {
    final projects = _countLabel(projectCount, 'project');
    final domains = _countLabel(domainCount, 'domain');
    return '$projects across $domains.';
  }
}

ProjectDomainGapRepairSessionFocusSummary
buildProjectDomainGapRepairSessionFocusSummary({
  required ProjectDomainGapRepairPlan plan,
}) {
  if (plan.isEmpty) return ProjectDomainGapRepairSessionFocusSummary.empty();

  final projectIds = <String>{};
  final domains = <String>{};
  final blockedProjectIds = <String>{};
  final atRiskProjectIds = <String>{};

  for (final target in plan.allTargets) {
    projectIds.add(target.project.id);
    domains.add(_domainLabel(target.project.businessDomain));

    switch (target.project.health) {
      case ProjectHealth.blocked:
        blockedProjectIds.add(target.project.id);
      case ProjectHealth.atRisk:
        atRiskProjectIds.add(target.project.id);
      case ProjectHealth.onTrack:
        break;
    }
  }

  return ProjectDomainGapRepairSessionFocusSummary(
    focusKind: _resolveFocusKind(
      plan: plan,
      blockedProjectCount: blockedProjectIds.length,
      atRiskProjectCount: atRiskProjectIds.length,
    ),
    totalTargetCount: plan.totalTargetCount,
    projectCount: projectIds.length,
    domainCount: domains.length,
    blockedProjectCount: blockedProjectIds.length,
    atRiskProjectCount: atRiskProjectIds.length,
  );
}

ProjectDomainGapRepairSessionFocusKind _resolveFocusKind({
  required ProjectDomainGapRepairPlan plan,
  required int blockedProjectCount,
  required int atRiskProjectCount,
}) {
  if (plan.requiredTargetCount > 0) {
    return ProjectDomainGapRepairSessionFocusKind.stabilization;
  }

  if (plan.riskSignalTargetCount > 0 ||
      blockedProjectCount > 0 ||
      atRiskProjectCount > 0) {
    return ProjectDomainGapRepairSessionFocusKind.riskControl;
  }

  if (plan.coverageGapTargetCount > 0) {
    return ProjectDomainGapRepairSessionFocusKind.domainCoverage;
  }

  return ProjectDomainGapRepairSessionFocusKind.contextPolish;
}

String _domainLabel(String value) {
  final label = value.trim();
  return label.isEmpty ? 'General Business' : label;
}

String _countLabel(int count, String singularLabel) {
  final label = count == 1 ? singularLabel : '${singularLabel}s';
  return '$count $label';
}
