import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_status_update_service.dart';
import 'project_timeline_health_service.dart';

enum ProjectChangeControlLevel { recovery, approval, monitor, controlled }

enum ProjectChangeControlKind {
  domain,
  schedule,
  dependency,
  budget,
  risk,
  approvalRoute,
}

class ProjectChangeControlItem {
  const ProjectChangeControlItem({
    required this.title,
    required this.detail,
    required this.icon,
    required this.level,
    required this.kind,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProjectChangeControlLevel level;
  final ProjectChangeControlKind kind;
}

class ProjectChangeControlSummary {
  const ProjectChangeControlSummary({
    required this.vocabulary,
    required this.audience,
    required this.title,
    required this.subtitle,
    required this.changeWindow,
    required this.items,
    this.briefText = '',
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final String title;
  final String subtitle;
  final String changeWindow;
  final List<ProjectChangeControlItem> items;
  final String briefText;

  int get recoveryCount =>
      items
          .where((item) => item.level == ProjectChangeControlLevel.recovery)
          .length;

  int get approvalCount =>
      items
          .where((item) => item.level == ProjectChangeControlLevel.approval)
          .length;

  int get monitorCount =>
      items
          .where((item) => item.level == ProjectChangeControlLevel.monitor)
          .length;

  int get controlledCount =>
      items
          .where((item) => item.level == ProjectChangeControlLevel.controlled)
          .length;

  ProjectChangeControlLevel get level {
    if (recoveryCount > 0) return ProjectChangeControlLevel.recovery;
    if (approvalCount > 0) return ProjectChangeControlLevel.approval;
    if (monitorCount > 0) return ProjectChangeControlLevel.monitor;

    return ProjectChangeControlLevel.controlled;
  }

  ProjectChangeControlItem get primaryItem {
    return items.firstWhere(
      (item) => item.level == level,
      orElse: () => items.first,
    );
  }
}

ProjectChangeControlSummary buildProjectChangeControl({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  List<gantt.GanttTask>? dependencyTasks,
  ProjectStatusUpdateVocabulary vocabulary =
      ProjectStatusUpdateVocabulary.general,
  ProjectStatusUpdateAudience audience =
      ProjectStatusUpdateAudience.stakeholder,
  DateTime? today,
}) {
  final referenceDate = DateUtils.dateOnly(today ?? DateTime.now());
  final timelineHealth = buildProjectTimelineHealthRollup(
    tasks: timelineTasks,
    dependencyTasks: dependencyTasks,
    today: referenceDate,
  );
  final overdueTaskCount =
      timelineTasks.where((task) {
        return task.progress < 1 &&
            DateUtils.dateOnly(task.endDate).isBefore(referenceDate);
      }).length;
  final overdueMilestoneCount =
      project.milestones.where((milestone) {
        return !milestone.isComplete &&
            DateUtils.dateOnly(milestone.dueDate).isBefore(referenceDate);
      }).length;
  final nextMilestone = _nextOpenMilestone(project.milestones);
  final nextMilestoneDays =
      nextMilestone == null
          ? null
          : DateUtils.dateOnly(
            nextMilestone.dueDate,
          ).difference(referenceDate).inDays;
  final blockedRiskCount =
      project.risks
          .where((risk) => risk.severity == ProjectHealth.blocked)
          .length;
  final activeRiskCount =
      project.risks
          .where((risk) => risk.severity != ProjectHealth.onTrack)
          .length;
  final budgetDrift = project.budgetUsed - project.progress;
  final overdueCount = overdueTaskCount + overdueMilestoneCount;
  final level = _summaryLevel(
    project: project,
    overdueCount: overdueCount,
    blockedRiskCount: blockedRiskCount,
    activeRiskCount: activeRiskCount,
    dependencyBlockCount: timelineHealth.dependencyBlockCount,
    budgetDrift: budgetDrift,
    timelineTaskCount: timelineTasks.length,
    nextMilestoneDays: nextMilestoneDays,
  );
  final spec =
      _domainChangeControlSpecs[vocabulary.id] ??
      _domainChangeControlSpecs['general']!;
  final items = [
    _domainItem(spec: spec, level: level),
    _scheduleItem(
      project: project,
      vocabulary: vocabulary,
      taskCount: timelineTasks.length,
      overdueCount: overdueCount,
      nextMilestone: nextMilestone,
      nextMilestoneDays: nextMilestoneDays,
    ),
    _dependencyItem(
      vocabulary: vocabulary,
      taskCount: timelineTasks.length,
      dependencyBlockCount: timelineHealth.dependencyBlockCount,
    ),
    _budgetItem(vocabulary: vocabulary, budgetDrift: budgetDrift),
    _riskItem(
      vocabulary: vocabulary,
      blockedRiskCount: blockedRiskCount,
      activeRiskCount: activeRiskCount,
    ),
    _approvalRouteItem(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      level: level,
    ),
  ];
  final title =
      vocabulary == ProjectStatusUpdateVocabulary.general
          ? 'Delivery change control'
          : '${vocabulary.label} change control';
  final changeWindow = spec.changeWindowFor(level);

  return ProjectChangeControlSummary(
    vocabulary: vocabulary,
    audience: audience,
    title: title,
    subtitle: '${level.label} - $changeWindow - ${items.length} controls',
    changeWindow: changeWindow,
    items: List.unmodifiable(items),
    briefText: _changeControlBriefText(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      title: title,
      level: level,
      changeWindow: changeWindow,
      items: items,
    ),
  );
}

ProjectChangeControlLevel _summaryLevel({
  required ProjectPortfolioItem project,
  required int overdueCount,
  required int blockedRiskCount,
  required int activeRiskCount,
  required int dependencyBlockCount,
  required double budgetDrift,
  required int timelineTaskCount,
  required int? nextMilestoneDays,
}) {
  if (project.health == ProjectHealth.blocked ||
      blockedRiskCount > 0 ||
      dependencyBlockCount > 0 ||
      overdueCount > 0) {
    return ProjectChangeControlLevel.recovery;
  }

  if (budgetDrift >= 0.15 ||
      (nextMilestoneDays != null &&
          nextMilestoneDays >= 0 &&
          nextMilestoneDays <= 10)) {
    return ProjectChangeControlLevel.approval;
  }

  if (project.health == ProjectHealth.atRisk ||
      activeRiskCount > 0 ||
      timelineTaskCount == 0 ||
      budgetDrift >= 0.08) {
    return ProjectChangeControlLevel.monitor;
  }

  return ProjectChangeControlLevel.controlled;
}

ProjectChangeControlItem _domainItem({
  required _DomainChangeControlSpec spec,
  required ProjectChangeControlLevel level,
}) {
  return ProjectChangeControlItem(
    title: spec.titleFor(level),
    detail: spec.detailFor(level),
    icon: spec.icon,
    level: level,
    kind: ProjectChangeControlKind.domain,
  );
}

ProjectChangeControlItem _scheduleItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required int taskCount,
  required int overdueCount,
  required ProjectMilestone? nextMilestone,
  required int? nextMilestoneDays,
}) {
  if (taskCount == 0) {
    return ProjectChangeControlItem(
      title: 'Declare ${vocabulary.scheduleLabel} baseline',
      detail:
          'Attach ${vocabulary.scheduleItemLabel}s before accepting change requests or milestone promises.',
      icon: Icons.add_link_outlined,
      level: ProjectChangeControlLevel.monitor,
      kind: ProjectChangeControlKind.schedule,
    );
  }

  if (overdueCount > 0) {
    return ProjectChangeControlItem(
      title: 'Rebaseline ${vocabulary.scheduleLabel} change',
      detail:
          '$overdueCount overdue signal${overdueCount == 1 ? '' : 's'} need a clear baseline, owner, and date decision.',
      icon: Icons.event_busy_outlined,
      level: ProjectChangeControlLevel.recovery,
      kind: ProjectChangeControlKind.schedule,
    );
  }

  if (nextMilestoneDays != null &&
      nextMilestoneDays >= 0 &&
      nextMilestoneDays <= 10) {
    return ProjectChangeControlItem(
      title: 'Freeze changes before ${nextMilestone!.label}',
      detail:
          'Keep new requests explicit before the ${vocabulary.milestoneLabel} due in ${nextMilestoneDays == 0 ? 'today' : '${nextMilestoneDays}d'}.',
      icon: Icons.lock_clock_outlined,
      level: ProjectChangeControlLevel.approval,
      kind: ProjectChangeControlKind.schedule,
    );
  }

  return ProjectChangeControlItem(
    title: 'Keep ${vocabulary.scheduleLabel} change log current',
    detail:
        'Track owner, impact, and timing for changes that affect ${project.owner} or the next ${vocabulary.milestoneLabel}.',
    icon: Icons.timeline_outlined,
    level: ProjectChangeControlLevel.controlled,
    kind: ProjectChangeControlKind.schedule,
  );
}

ProjectChangeControlItem _dependencyItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int taskCount,
  required int dependencyBlockCount,
}) {
  if (dependencyBlockCount > 0) {
    return ProjectChangeControlItem(
      title: 'Gate ${vocabulary.scheduleLabel} dependencies',
      detail:
          '$dependencyBlockCount blocked dependency signal${dependencyBlockCount == 1 ? '' : 's'} should stop unmanaged scope or date changes until predecessor ownership is clear.',
      icon: Icons.account_tree_outlined,
      level: ProjectChangeControlLevel.recovery,
      kind: ProjectChangeControlKind.dependency,
    );
  }

  if (taskCount == 0) {
    return ProjectChangeControlItem(
      title: 'Declare dependency baseline',
      detail:
          'Attach ${vocabulary.scheduleItemLabel}s before dependency-sensitive changes are accepted.',
      icon: Icons.add_link_outlined,
      level: ProjectChangeControlLevel.monitor,
      kind: ProjectChangeControlKind.dependency,
    );
  }

  return ProjectChangeControlItem(
    title: 'Keep dependency changes traceable',
    detail:
        'Dependency movement is clear enough; keep predecessor, owner, and timing notes attached to the ${vocabulary.scheduleLabel}.',
    icon: Icons.account_tree_outlined,
    level: ProjectChangeControlLevel.controlled,
    kind: ProjectChangeControlKind.dependency,
  );
}

ProjectChangeControlItem _budgetItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required double budgetDrift,
}) {
  if (budgetDrift >= 0.15) {
    return ProjectChangeControlItem(
      title: 'Approve ${vocabulary.budgetLabel} variance',
      detail:
          '${(budgetDrift * 100).round()} point spend/progress drift needs a scoped approval route.',
      icon: Icons.account_balance_wallet_outlined,
      level: ProjectChangeControlLevel.approval,
      kind: ProjectChangeControlKind.budget,
    );
  }

  if (budgetDrift >= 0.08) {
    return ProjectChangeControlItem(
      title: 'Watch ${vocabulary.budgetLabel} movement',
      detail:
          'Budget pressure is visible; keep any scope or supplier change attached to a decision note.',
      icon: Icons.receipt_long_outlined,
      level: ProjectChangeControlLevel.monitor,
      kind: ProjectChangeControlKind.budget,
    );
  }

  return ProjectChangeControlItem(
    title: 'Keep ${vocabulary.budgetLabel} baseline stable',
    detail:
        'Spend and progress are close enough to keep financial change control lightweight.',
    icon: Icons.savings_outlined,
    level: ProjectChangeControlLevel.controlled,
    kind: ProjectChangeControlKind.budget,
  );
}

ProjectChangeControlItem _riskItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int blockedRiskCount,
  required int activeRiskCount,
}) {
  if (blockedRiskCount > 0) {
    return ProjectChangeControlItem(
      title: 'Escalate ${vocabulary.riskLabel} change impact',
      detail:
          '$blockedRiskCount blocked ${vocabulary.riskLabel}${blockedRiskCount == 1 ? '' : 's'} should pause uncontrolled scope or date changes.',
      icon: Icons.block_outlined,
      level: ProjectChangeControlLevel.recovery,
      kind: ProjectChangeControlKind.risk,
    );
  }

  if (activeRiskCount > 0) {
    return ProjectChangeControlItem(
      title: 'Track ${vocabulary.riskLabel} change impact',
      detail:
          '$activeRiskCount active ${vocabulary.riskLabel}${activeRiskCount == 1 ? '' : 's'} need mitigation owner and impact notes.',
      icon: Icons.health_and_safety_outlined,
      level: ProjectChangeControlLevel.monitor,
      kind: ProjectChangeControlKind.risk,
    );
  }

  return ProjectChangeControlItem(
    title: 'Keep ${vocabulary.riskLabel} impact clear',
    detail:
        'No active ${vocabulary.riskLabel}s are forcing heavier change control.',
    icon: Icons.verified_outlined,
    level: ProjectChangeControlLevel.controlled,
    kind: ProjectChangeControlKind.risk,
  );
}

ProjectChangeControlItem _approvalRouteItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required ProjectChangeControlLevel level,
}) {
  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return ProjectChangeControlItem(
        title: 'Publish stakeholder change route',
        detail:
            'Summarize what changed, why it matters, and who approves the next ${vocabulary.milestoneLabel}.',
        icon: audience.icon,
        level:
            level == ProjectChangeControlLevel.controlled
                ? ProjectChangeControlLevel.monitor
                : level,
        kind: ProjectChangeControlKind.approvalRoute,
      );
    case ProjectStatusUpdateAudience.sponsor:
      return ProjectChangeControlItem(
        title: 'Prepare sponsor approval route',
        detail:
            'Make the change ask clear for ${project.sponsor.isEmpty ? project.owner : project.sponsor}.',
        icon: audience.icon,
        level:
            level == ProjectChangeControlLevel.recovery
                ? ProjectChangeControlLevel.approval
                : level,
        kind: ProjectChangeControlKind.approvalRoute,
      );
    case ProjectStatusUpdateAudience.team:
      return ProjectChangeControlItem(
        title: 'Queue team change actions',
        detail:
            'Turn accepted changes into owner-ready ${vocabulary.scheduleItemLabel}s and handoff notes.',
        icon: audience.icon,
        level: ProjectChangeControlLevel.monitor,
        kind: ProjectChangeControlKind.approvalRoute,
      );
    case ProjectStatusUpdateAudience.client:
      return ProjectChangeControlItem(
        title: 'Prepare client-visible change note',
        detail:
            'Show ${project.client} timing, scope, and confidence impact in plain language.',
        icon: audience.icon,
        level:
            level == ProjectChangeControlLevel.controlled
                ? ProjectChangeControlLevel.monitor
                : level,
        kind: ProjectChangeControlKind.approvalRoute,
      );
  }
}

ProjectMilestone? _nextOpenMilestone(List<ProjectMilestone> milestones) {
  final openMilestones =
      milestones.where((milestone) => !milestone.isComplete).toList()
        ..sort((first, second) => first.dueDate.compareTo(second.dueDate));

  if (openMilestones.isEmpty) return null;

  return openMilestones.first;
}

String _changeControlBriefText({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required String title,
  required ProjectChangeControlLevel level,
  required String changeWindow,
  required List<ProjectChangeControlItem> items,
}) {
  final primaryItem = items.firstWhere(
    (item) => item.level == level,
    orElse: () => items.first,
  );
  final approvalItems =
      items.where((item) {
        return item.kind == ProjectChangeControlKind.approvalRoute ||
            item.level == ProjectChangeControlLevel.approval;
      }).toList();

  return [
    '$title brief',
    'Status: ${level.label}',
    'Window: $changeWindow',
    'Audience: ${audience.summaryLabel(vocabulary)}',
    'Owner: ${project.owner}',
    '',
    'Primary control',
    '- ${primaryItem.title}: ${primaryItem.detail}',
    '',
    'Guardrails',
    for (final item in items)
      if (item != primaryItem && !approvalItems.contains(item))
        '- ${item.title}: ${item.detail}',
    if (approvalItems.isNotEmpty) ...[
      '',
      'Approval route',
      for (final item in approvalItems) '- ${item.title}: ${item.detail}',
    ],
    '',
    'Change rule',
    '- Keep scope, timing, dependency, and ${vocabulary.budgetLabel} movement inside the $changeWindow until owner, impact, and decision notes are clear.',
  ].join('\n');
}

extension ProjectChangeControlLevelPresentation on ProjectChangeControlLevel {
  String get label {
    switch (this) {
      case ProjectChangeControlLevel.recovery:
        return 'Recovery';
      case ProjectChangeControlLevel.approval:
        return 'Approval';
      case ProjectChangeControlLevel.monitor:
        return 'Monitor';
      case ProjectChangeControlLevel.controlled:
        return 'Controlled';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectChangeControlLevel.recovery:
        return Icons.priority_high_rounded;
      case ProjectChangeControlLevel.approval:
        return Icons.rule_folder_outlined;
      case ProjectChangeControlLevel.monitor:
        return Icons.visibility_outlined;
      case ProjectChangeControlLevel.controlled:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectChangeControlLevel.recovery:
        return colorScheme.error;
      case ProjectChangeControlLevel.approval:
        return Colors.orange.shade700;
      case ProjectChangeControlLevel.monitor:
        return colorScheme.primary;
      case ProjectChangeControlLevel.controlled:
        return Colors.green.shade700;
    }
  }
}

class _DomainChangeControlSpec {
  const _DomainChangeControlSpec({
    required this.icon,
    required this.recoveryTitle,
    required this.approvalTitle,
    required this.monitorTitle,
    required this.controlledTitle,
    required this.recoveryDetail,
    required this.approvalDetail,
    required this.monitorDetail,
    required this.controlledDetail,
    required this.recoveryWindow,
    required this.approvalWindow,
    required this.monitorWindow,
    required this.controlledWindow,
  });

  final IconData icon;
  final String recoveryTitle;
  final String approvalTitle;
  final String monitorTitle;
  final String controlledTitle;
  final String recoveryDetail;
  final String approvalDetail;
  final String monitorDetail;
  final String controlledDetail;
  final String recoveryWindow;
  final String approvalWindow;
  final String monitorWindow;
  final String controlledWindow;

  String titleFor(ProjectChangeControlLevel level) {
    switch (level) {
      case ProjectChangeControlLevel.recovery:
        return recoveryTitle;
      case ProjectChangeControlLevel.approval:
        return approvalTitle;
      case ProjectChangeControlLevel.monitor:
        return monitorTitle;
      case ProjectChangeControlLevel.controlled:
        return controlledTitle;
    }
  }

  String detailFor(ProjectChangeControlLevel level) {
    switch (level) {
      case ProjectChangeControlLevel.recovery:
        return recoveryDetail;
      case ProjectChangeControlLevel.approval:
        return approvalDetail;
      case ProjectChangeControlLevel.monitor:
        return monitorDetail;
      case ProjectChangeControlLevel.controlled:
        return controlledDetail;
    }
  }

  String changeWindowFor(ProjectChangeControlLevel level) {
    switch (level) {
      case ProjectChangeControlLevel.recovery:
        return recoveryWindow;
      case ProjectChangeControlLevel.approval:
        return approvalWindow;
      case ProjectChangeControlLevel.monitor:
        return monitorWindow;
      case ProjectChangeControlLevel.controlled:
        return controlledWindow;
    }
  }
}

const _domainChangeControlSpecs = {
  'general': _DomainChangeControlSpec(
    icon: Icons.rule_folder_outlined,
    recoveryTitle: 'Lock delivery change recovery',
    approvalTitle: 'Approve delivery change',
    monitorTitle: 'Monitor delivery changes',
    controlledTitle: 'Keep delivery changes controlled',
    recoveryDetail:
        'Stop unmanaged scope, timing, or budget movement until recovery decisions are clear.',
    approvalDetail:
        'Route material scope, timing, or budget movement through explicit approval.',
    monitorDetail: 'Watch change pressure and keep owner impact visible.',
    controlledDetail: 'Keep lightweight change notes attached to the plan.',
    recoveryWindow: 'change freeze',
    approvalWindow: 'approval window',
    monitorWindow: 'watch window',
    controlledWindow: 'light control',
  ),
  'construction': _DomainChangeControlSpec(
    icon: Icons.construction_outlined,
    recoveryTitle: 'Lock site variation recovery',
    approvalTitle: 'Approve site variation',
    monitorTitle: 'Monitor site variations',
    controlledTitle: 'Keep site variations controlled',
    recoveryDetail:
        'Freeze unmanaged site, supplier, permit, or safety changes until recovery is approved.',
    approvalDetail:
        'Route phase, supplier, permit, and cost movement through variation approval.',
    monitorDetail:
        'Watch site variation pressure and keep phase impact visible.',
    controlledDetail: 'Keep site changes tied to phase-gate evidence.',
    recoveryWindow: 'site variation freeze',
    approvalWindow: 'variation approval window',
    monitorWindow: 'site watch window',
    controlledWindow: 'controlled site log',
  ),
  'software': _DomainChangeControlSpec(
    icon: Icons.code_outlined,
    recoveryTitle: 'Lock release scope recovery',
    approvalTitle: 'Approve release scope change',
    monitorTitle: 'Monitor release scope changes',
    controlledTitle: 'Keep release scope controlled',
    recoveryDetail:
        'Freeze unmanaged scope, QA, dependency, or rollout changes until recovery is approved.',
    approvalDetail:
        'Route scope, acceptance, dependency, and rollout movement through release approval.',
    monitorDetail:
        'Watch release scope pressure and keep dependency or QA impact visible.',
    controlledDetail: 'Keep release changes tied to acceptance evidence.',
    recoveryWindow: 'release change freeze',
    approvalWindow: 'release approval window',
    monitorWindow: 'scope watch window',
    controlledWindow: 'controlled release log',
  ),
  'event-production': _DomainChangeControlSpec(
    icon: Icons.event_outlined,
    recoveryTitle: 'Lock run-sheet recovery',
    approvalTitle: 'Approve production change',
    monitorTitle: 'Monitor production changes',
    controlledTitle: 'Keep production changes controlled',
    recoveryDetail:
        'Freeze unmanaged vendor, venue, talent, or contingency changes until recovery is approved.',
    approvalDetail:
        'Route run-sheet, vendor, venue, and contingency movement through production approval.',
    monitorDetail:
        'Watch production change pressure and keep show-impact notes visible.',
    controlledDetail: 'Keep production changes tied to run-sheet evidence.',
    recoveryWindow: 'run-sheet freeze',
    approvalWindow: 'production approval window',
    monitorWindow: 'production watch window',
    controlledWindow: 'controlled run-sheet log',
  ),
  'government': _DomainChangeControlSpec(
    icon: Icons.account_balance_outlined,
    recoveryTitle: 'Lock governance change recovery',
    approvalTitle: 'Approve governance change',
    monitorTitle: 'Monitor governance changes',
    controlledTitle: 'Keep governance changes controlled',
    recoveryDetail:
        'Freeze unmanaged approval, compliance, funding, or public-accountability changes until recovery is clear.',
    approvalDetail:
        'Route approvals, compliance, funding, and accountability movement through governance approval.',
    monitorDetail:
        'Watch governance change pressure and keep accountability impact visible.',
    controlledDetail: 'Keep governance changes tied to approval evidence.',
    recoveryWindow: 'governance freeze',
    approvalWindow: 'approval board window',
    monitorWindow: 'governance watch window',
    controlledWindow: 'controlled approval log',
  ),
  'education': _DomainChangeControlSpec(
    icon: Icons.school_outlined,
    recoveryTitle: 'Lock academic change recovery',
    approvalTitle: 'Approve academic change',
    monitorTitle: 'Monitor academic changes',
    controlledTitle: 'Keep academic changes controlled',
    recoveryDetail:
        'Freeze unmanaged curriculum, faculty, calendar, or learner-support changes until recovery is approved.',
    approvalDetail:
        'Route curriculum, calendar, faculty, and learner-impact movement through academic approval.',
    monitorDetail:
        'Watch academic change pressure and keep learner impact visible.',
    controlledDetail: 'Keep academic changes tied to readiness evidence.',
    recoveryWindow: 'academic change freeze',
    approvalWindow: 'academic approval window',
    monitorWindow: 'academic watch window',
    controlledWindow: 'controlled academic log',
  ),
  'wedding': _DomainChangeControlSpec(
    icon: Icons.celebration_outlined,
    recoveryTitle: 'Lock wedding change recovery',
    approvalTitle: 'Approve wedding planning change',
    monitorTitle: 'Monitor wedding planning changes',
    controlledTitle: 'Keep wedding changes controlled',
    recoveryDetail:
        'Freeze unmanaged vendor, guest-impact, venue, or day-of changes until recovery is approved.',
    approvalDetail:
        'Route vendor, guest, venue, and day-of movement through planning approval.',
    monitorDetail:
        'Watch planning change pressure and keep client-impact notes visible.',
    controlledDetail:
        'Keep wedding changes tied to vendor and day-of evidence.',
    recoveryWindow: 'planning change freeze',
    approvalWindow: 'planning approval window',
    monitorWindow: 'planning watch window',
    controlledWindow: 'controlled planning log',
  ),
};
