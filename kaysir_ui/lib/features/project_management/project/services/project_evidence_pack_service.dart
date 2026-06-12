import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_status_update_service.dart';

enum ProjectEvidenceStatus { missing, needsReview, collecting, ready }

enum ProjectEvidenceKind { domain, schedule, risk, budget, signOff }

class ProjectEvidencePackItem {
  const ProjectEvidencePackItem({
    required this.title,
    required this.detail,
    required this.icon,
    required this.status,
    required this.kind,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProjectEvidenceStatus status;
  final ProjectEvidenceKind kind;
}

class ProjectEvidencePackSummary {
  const ProjectEvidencePackSummary({
    required this.vocabulary,
    required this.audience,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final String title;
  final String subtitle;
  final List<ProjectEvidencePackItem> items;

  int get missingCount =>
      items
          .where((item) => item.status == ProjectEvidenceStatus.missing)
          .length;

  int get reviewCount =>
      items
          .where((item) => item.status == ProjectEvidenceStatus.needsReview)
          .length;

  int get collectingCount =>
      items
          .where((item) => item.status == ProjectEvidenceStatus.collecting)
          .length;

  int get readyCount =>
      items.where((item) => item.status == ProjectEvidenceStatus.ready).length;

  int get readinessPercent {
    if (items.isEmpty) return 0;

    return (readyCount / items.length * 100).round();
  }

  ProjectEvidenceStatus get status {
    if (missingCount > 0) return ProjectEvidenceStatus.missing;
    if (reviewCount > 0) return ProjectEvidenceStatus.needsReview;
    if (collectingCount > 0) return ProjectEvidenceStatus.collecting;

    return ProjectEvidenceStatus.ready;
  }

  ProjectEvidencePackItem get primaryItem {
    return items.firstWhere(
      (item) => item.status == status,
      orElse: () => items.first,
    );
  }
}

ProjectEvidencePackSummary buildProjectEvidencePack({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  ProjectStatusUpdateVocabulary vocabulary =
      ProjectStatusUpdateVocabulary.general,
  ProjectStatusUpdateAudience audience =
      ProjectStatusUpdateAudience.stakeholder,
  DateTime? today,
}) {
  final referenceDate = DateUtils.dateOnly(today ?? DateTime.now());
  final overdueTaskCount =
      timelineTasks.where((task) {
        return task.progress < 1 &&
            DateUtils.dateOnly(task.endDate).isBefore(referenceDate);
      }).length;
  final openTaskCount = timelineTasks.where((task) => task.progress < 1).length;
  final completedTaskCount =
      timelineTasks.where((task) => task.progress >= 1).length;
  final overdueMilestoneCount =
      project.milestones.where((milestone) {
        return !milestone.isComplete &&
            DateUtils.dateOnly(milestone.dueDate).isBefore(referenceDate);
      }).length;
  final blockedRiskCount =
      project.risks
          .where((risk) => risk.severity == ProjectHealth.blocked)
          .length;
  final activeRiskCount =
      project.risks
          .where((risk) => risk.severity != ProjectHealth.onTrack)
          .length;
  final budgetDrift = project.budgetUsed - project.progress;
  final items = [
    _domainEvidenceItem(
      project: project,
      vocabulary: vocabulary,
      blockedRiskCount: blockedRiskCount,
      activeRiskCount: activeRiskCount,
    ),
    _scheduleEvidenceItem(
      vocabulary: vocabulary,
      taskCount: timelineTasks.length,
      openTaskCount: openTaskCount,
      completedTaskCount: completedTaskCount,
      overdueTaskCount: overdueTaskCount,
      overdueMilestoneCount: overdueMilestoneCount,
    ),
    _riskEvidenceItem(
      vocabulary: vocabulary,
      blockedRiskCount: blockedRiskCount,
      activeRiskCount: activeRiskCount,
    ),
    _budgetEvidenceItem(vocabulary: vocabulary, budgetDrift: budgetDrift),
    _signOffEvidenceItem(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
    ),
  ];
  final readyCount =
      items.where((item) => item.status == ProjectEvidenceStatus.ready).length;
  final reviewCount =
      items
          .where((item) => item.status == ProjectEvidenceStatus.needsReview)
          .length;
  final missingCount =
      items
          .where((item) => item.status == ProjectEvidenceStatus.missing)
          .length;
  final title =
      vocabulary == ProjectStatusUpdateVocabulary.general
          ? 'Delivery evidence pack'
          : '${vocabulary.label} evidence pack';

  return ProjectEvidencePackSummary(
    vocabulary: vocabulary,
    audience: audience,
    title: title,
    subtitle: '$readyCount ready - $reviewCount review - $missingCount missing',
    items: List.unmodifiable(items),
  );
}

ProjectEvidencePackItem _domainEvidenceItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required int blockedRiskCount,
  required int activeRiskCount,
}) {
  final spec =
      _domainEvidenceSpecs[vocabulary.id] ?? _domainEvidenceSpecs['general']!;
  final status =
      blockedRiskCount > 0
          ? ProjectEvidenceStatus.needsReview
          : project.progress >= 0.72 && activeRiskCount == 0
          ? ProjectEvidenceStatus.ready
          : ProjectEvidenceStatus.collecting;

  return ProjectEvidencePackItem(
    title: spec.title,
    detail: spec.detail,
    icon: spec.icon,
    status: status,
    kind: ProjectEvidenceKind.domain,
  );
}

ProjectEvidencePackItem _scheduleEvidenceItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int taskCount,
  required int openTaskCount,
  required int completedTaskCount,
  required int overdueTaskCount,
  required int overdueMilestoneCount,
}) {
  final overdueCount = overdueTaskCount + overdueMilestoneCount;

  if (taskCount == 0) {
    return ProjectEvidencePackItem(
      title: 'Link ${vocabulary.scheduleLabel} evidence',
      detail:
          'Attach ${vocabulary.scheduleItemLabel}s so acceptance, handoff, and reporting evidence use the same plan.',
      icon: Icons.add_link_outlined,
      status: ProjectEvidenceStatus.missing,
      kind: ProjectEvidenceKind.schedule,
    );
  }

  if (overdueCount > 0) {
    return ProjectEvidencePackItem(
      title: 'Recover ${vocabulary.scheduleLabel} evidence',
      detail:
          '$overdueCount overdue schedule signal${overdueCount == 1 ? '' : 's'} need revised owner, date, and acceptance note.',
      icon: Icons.event_busy_outlined,
      status: ProjectEvidenceStatus.needsReview,
      kind: ProjectEvidenceKind.schedule,
    );
  }

  if (openTaskCount == 0) {
    return ProjectEvidencePackItem(
      title: 'Archive ${vocabulary.scheduleLabel} evidence',
      detail:
          'All linked ${vocabulary.scheduleItemLabel}s are complete; keep final proof available for handoff.',
      icon: Icons.inventory_2_outlined,
      status: ProjectEvidenceStatus.ready,
      kind: ProjectEvidenceKind.schedule,
    );
  }

  return ProjectEvidencePackItem(
    title: 'Collect ${vocabulary.scheduleLabel} evidence',
    detail:
        '$completedTaskCount complete and $openTaskCount open ${vocabulary.scheduleItemLabel}${openTaskCount == 1 ? '' : 's'} need current progress notes.',
    icon: Icons.view_timeline_outlined,
    status: ProjectEvidenceStatus.collecting,
    kind: ProjectEvidenceKind.schedule,
  );
}

ProjectEvidencePackItem _riskEvidenceItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int blockedRiskCount,
  required int activeRiskCount,
}) {
  if (blockedRiskCount > 0) {
    return ProjectEvidencePackItem(
      title: 'Update ${vocabulary.riskLabel} evidence',
      detail:
          '$blockedRiskCount blocked ${vocabulary.riskLabel}${blockedRiskCount == 1 ? '' : 's'} need decision proof before sign-off.',
      icon: Icons.block_outlined,
      status: ProjectEvidenceStatus.needsReview,
      kind: ProjectEvidenceKind.risk,
    );
  }

  if (activeRiskCount > 0) {
    return ProjectEvidencePackItem(
      title: 'Collect ${vocabulary.riskLabel} evidence',
      detail:
          '$activeRiskCount active ${vocabulary.riskLabel}${activeRiskCount == 1 ? '' : 's'} should include mitigation owner and next review.',
      icon: Icons.health_and_safety_outlined,
      status: ProjectEvidenceStatus.collecting,
      kind: ProjectEvidenceKind.risk,
    );
  }

  return ProjectEvidencePackItem(
    title: 'Archive ${vocabulary.riskLabel} register',
    detail:
        'No active ${vocabulary.riskLabel}s are blocking acceptance or handoff evidence.',
    icon: Icons.verified_outlined,
    status: ProjectEvidenceStatus.ready,
    kind: ProjectEvidenceKind.risk,
  );
}

ProjectEvidencePackItem _budgetEvidenceItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required double budgetDrift,
}) {
  if (budgetDrift >= 0.15) {
    return ProjectEvidencePackItem(
      title: 'Review ${vocabulary.budgetLabel} evidence',
      detail:
          '${(budgetDrift * 100).round()} point spend/progress drift needs scope or commercial explanation.',
      icon: Icons.account_balance_wallet_outlined,
      status: ProjectEvidenceStatus.needsReview,
      kind: ProjectEvidenceKind.budget,
    );
  }

  if (budgetDrift.abs() <= 0.06) {
    return ProjectEvidencePackItem(
      title: 'Validate ${vocabulary.budgetLabel} evidence',
      detail:
          'Spend and progress are close enough to keep finance proof lightweight.',
      icon: Icons.savings_outlined,
      status: ProjectEvidenceStatus.ready,
      kind: ProjectEvidenceKind.budget,
    );
  }

  return ProjectEvidencePackItem(
    title: 'Collect ${vocabulary.budgetLabel} evidence',
    detail:
        'Keep spend, scope, and progress notes together before the next ${vocabulary.milestoneLabel}.',
    icon: Icons.receipt_long_outlined,
    status: ProjectEvidenceStatus.collecting,
    kind: ProjectEvidenceKind.budget,
  );
}

ProjectEvidencePackItem _signOffEvidenceItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
}) {
  final title = _signOffTitle(audience);
  final detail = _signOffDetail(
    project: project,
    vocabulary: vocabulary,
    audience: audience,
  );
  final status =
      _isSignOffMissing(project, audience)
          ? ProjectEvidenceStatus.missing
          : project.health == ProjectHealth.blocked
          ? ProjectEvidenceStatus.needsReview
          : project.progress >= 0.72 && project.health == ProjectHealth.onTrack
          ? ProjectEvidenceStatus.ready
          : ProjectEvidenceStatus.collecting;

  return ProjectEvidencePackItem(
    title: title,
    detail: detail,
    icon: audience.icon,
    status: status,
    kind: ProjectEvidenceKind.signOff,
  );
}

bool _isSignOffMissing(
  ProjectPortfolioItem project,
  ProjectStatusUpdateAudience audience,
) {
  switch (audience) {
    case ProjectStatusUpdateAudience.sponsor:
      return project.sponsor.isEmpty;
    case ProjectStatusUpdateAudience.team:
      return project.team.isEmpty;
    case ProjectStatusUpdateAudience.stakeholder:
    case ProjectStatusUpdateAudience.client:
      return project.owner.isEmpty;
  }
}

String _signOffTitle(ProjectStatusUpdateAudience audience) {
  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return 'Prepare stakeholder sign-off';
    case ProjectStatusUpdateAudience.sponsor:
      return 'Prepare sponsor sign-off';
    case ProjectStatusUpdateAudience.team:
      return 'Prepare team handoff route';
    case ProjectStatusUpdateAudience.client:
      return 'Prepare client acceptance route';
  }
}

String _signOffDetail({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
}) {
  final owner =
      audience == ProjectStatusUpdateAudience.sponsor &&
              project.sponsor.isNotEmpty
          ? project.sponsor
          : project.owner;

  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return 'Package ${vocabulary.workLabel}, ${vocabulary.milestoneLabel}, ${vocabulary.riskLabel}, and ${vocabulary.budgetLabel} proof for stakeholder review.';
    case ProjectStatusUpdateAudience.sponsor:
      return 'Make the decision trail clear for ${owner.isEmpty ? 'the sponsor' : owner}.';
    case ProjectStatusUpdateAudience.team:
      return 'Turn evidence into owner-ready handoff notes for the delivery team.';
    case ProjectStatusUpdateAudience.client:
      return 'Lead with acceptance proof, timing, and decision items for ${project.client}.';
  }
}

extension ProjectEvidenceStatusPresentation on ProjectEvidenceStatus {
  String get label {
    switch (this) {
      case ProjectEvidenceStatus.missing:
        return 'Missing';
      case ProjectEvidenceStatus.needsReview:
        return 'Review';
      case ProjectEvidenceStatus.collecting:
        return 'Collecting';
      case ProjectEvidenceStatus.ready:
        return 'Ready';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectEvidenceStatus.missing:
        return Icons.inventory_2_outlined;
      case ProjectEvidenceStatus.needsReview:
        return Icons.visibility_outlined;
      case ProjectEvidenceStatus.collecting:
        return Icons.pending_actions_outlined;
      case ProjectEvidenceStatus.ready:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectEvidenceStatus.missing:
        return colorScheme.error;
      case ProjectEvidenceStatus.needsReview:
        return Colors.orange.shade700;
      case ProjectEvidenceStatus.collecting:
        return colorScheme.primary;
      case ProjectEvidenceStatus.ready:
        return Colors.green.shade700;
    }
  }
}

class _DomainEvidenceSpec {
  const _DomainEvidenceSpec({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final IconData icon;
}

const _domainEvidenceSpecs = {
  'general': _DomainEvidenceSpec(
    title: 'Decision evidence pack',
    detail:
        'Keep scope, timeline, owner, risk, budget, and decision notes ready for review.',
    icon: Icons.inventory_2_outlined,
  ),
  'construction': _DomainEvidenceSpec(
    title: 'Permits and safety pack',
    detail:
        'Collect permits, site access proof, supplier readiness, inspection notes, and safety records.',
    icon: Icons.construction_outlined,
  ),
  'software': _DomainEvidenceSpec(
    title: 'QA and acceptance pack',
    detail:
        'Collect test evidence, acceptance criteria, release notes, dependency proof, and rollback readiness.',
    icon: Icons.verified_outlined,
  ),
  'event-production': _DomainEvidenceSpec(
    title: 'Run sheet and vendor pack',
    detail:
        'Collect run sheet proof, vendor confirmations, venue readiness, talent flow, and contingency notes.',
    icon: Icons.event_available_outlined,
  ),
  'government': _DomainEvidenceSpec(
    title: 'Approval and compliance pack',
    detail:
        'Collect approvals, compliance evidence, public accountability notes, and escalation records.',
    icon: Icons.account_balance_outlined,
  ),
  'education': _DomainEvidenceSpec(
    title: 'Academic readiness pack',
    detail:
        'Collect curriculum proof, faculty coverage, learner readiness, calendar risk, and support plan.',
    icon: Icons.school_outlined,
  ),
  'wedding': _DomainEvidenceSpec(
    title: 'Vendor and day-of pack',
    detail:
        'Collect vendor confirmations, guest-impact decisions, venue readiness, planner notes, and day-of timing.',
    icon: Icons.celebration_outlined,
  ),
};
