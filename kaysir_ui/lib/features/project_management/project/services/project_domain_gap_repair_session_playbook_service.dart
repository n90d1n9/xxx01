import '../models/project_portfolio_item.dart';
import 'project_domain_gap_repair_service.dart';

enum ProjectDomainGapRepairSessionPlaybookKind {
  recoveryChecklist,
  riskReview,
  domainSetup,
  reportingPolish,
}

class ProjectDomainGapRepairSessionPlaybookSummary {
  const ProjectDomainGapRepairSessionPlaybookSummary({
    required this.kind,
    required this.totalTargetCount,
    required this.domainCount,
    required this.blockedProjectCount,
    required this.atRiskProjectCount,
  });

  factory ProjectDomainGapRepairSessionPlaybookSummary.empty() {
    return const ProjectDomainGapRepairSessionPlaybookSummary(
      kind: ProjectDomainGapRepairSessionPlaybookKind.reportingPolish,
      totalTargetCount: 0,
      domainCount: 0,
      blockedProjectCount: 0,
      atRiskProjectCount: 0,
    );
  }

  final ProjectDomainGapRepairSessionPlaybookKind kind;
  final int totalTargetCount;
  final int domainCount;
  final int blockedProjectCount;
  final int atRiskProjectCount;

  bool get isEmpty => totalTargetCount == 0;
  bool get hasMultipleDomains => domainCount > 1;
  bool get hasUrgentHealthContext =>
      blockedProjectCount > 0 || atRiskProjectCount > 0;

  String get playbookLabel {
    switch (kind) {
      case ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist:
        return 'Recovery checklist';
      case ProjectDomainGapRepairSessionPlaybookKind.riskReview:
        return 'Risk review';
      case ProjectDomainGapRepairSessionPlaybookKind.domainSetup:
        return hasMultipleDomains ? 'Cross-domain setup' : 'Domain setup';
      case ProjectDomainGapRepairSessionPlaybookKind.reportingPolish:
        return 'Reporting polish';
    }
  }

  String get reviewerLabel {
    switch (kind) {
      case ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist:
        return 'Owner + sponsor';
      case ProjectDomainGapRepairSessionPlaybookKind.riskReview:
        return 'Delivery + risk';
      case ProjectDomainGapRepairSessionPlaybookKind.domainSetup:
        return hasMultipleDomains ? 'Domain leads' : 'Domain owner';
      case ProjectDomainGapRepairSessionPlaybookKind.reportingPolish:
        return 'PMO / operations';
    }
  }

  String get evidenceLabel {
    switch (kind) {
      case ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist:
        return 'Minimum fields';
      case ProjectDomainGapRepairSessionPlaybookKind.riskReview:
        return 'Watched signals';
      case ProjectDomainGapRepairSessionPlaybookKind.domainSetup:
        return 'Reusable fields';
      case ProjectDomainGapRepairSessionPlaybookKind.reportingPolish:
        return 'Recommended context';
    }
  }

  String get playbookTooltip {
    switch (kind) {
      case ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist:
        return 'Use this pass to restore mandatory context before the next delivery review.';
      case ProjectDomainGapRepairSessionPlaybookKind.riskReview:
        return 'Use this pass to make risk signals visible before status reporting.';
      case ProjectDomainGapRepairSessionPlaybookKind.domainSetup:
        return 'Use this pass to normalize reusable fields across business domains.';
      case ProjectDomainGapRepairSessionPlaybookKind.reportingPolish:
        return 'Use this pass to improve context quality for reporting and handoff.';
    }
  }

  String get reviewerTooltip {
    if (hasUrgentHealthContext) {
      return 'Include accountable reviewers because the queue touches blocked or at-risk work.';
    }
    return 'Suggested reviewers for validating the repaired project context.';
  }

  String get evidenceTooltip {
    return 'Primary evidence to complete during this repair session.';
  }
}

ProjectDomainGapRepairSessionPlaybookSummary
buildProjectDomainGapRepairSessionPlaybookSummary({
  required ProjectDomainGapRepairPlan plan,
}) {
  if (plan.isEmpty) {
    return ProjectDomainGapRepairSessionPlaybookSummary.empty();
  }

  final domains = <String>{};
  final blockedProjectIds = <String>{};
  final atRiskProjectIds = <String>{};

  for (final target in plan.allTargets) {
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

  return ProjectDomainGapRepairSessionPlaybookSummary(
    kind: _resolvePlaybookKind(
      plan: plan,
      blockedProjectCount: blockedProjectIds.length,
      atRiskProjectCount: atRiskProjectIds.length,
    ),
    totalTargetCount: plan.totalTargetCount,
    domainCount: domains.length,
    blockedProjectCount: blockedProjectIds.length,
    atRiskProjectCount: atRiskProjectIds.length,
  );
}

ProjectDomainGapRepairSessionPlaybookKind _resolvePlaybookKind({
  required ProjectDomainGapRepairPlan plan,
  required int blockedProjectCount,
  required int atRiskProjectCount,
}) {
  if (plan.requiredTargetCount > 0 && blockedProjectCount > 0) {
    return ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist;
  }

  if (plan.riskSignalTargetCount > 0 ||
      blockedProjectCount > 0 ||
      atRiskProjectCount > 0) {
    return ProjectDomainGapRepairSessionPlaybookKind.riskReview;
  }

  if (plan.coverageGapTargetCount > 0) {
    return ProjectDomainGapRepairSessionPlaybookKind.domainSetup;
  }

  return ProjectDomainGapRepairSessionPlaybookKind.reportingPolish;
}

String _domainLabel(String value) {
  final label = value.trim();
  return label.isEmpty ? 'General Business' : label;
}
