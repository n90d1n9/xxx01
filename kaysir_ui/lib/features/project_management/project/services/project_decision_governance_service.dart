import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_next_decision_service.dart';
import 'project_status_update_service.dart';
import 'project_timeline_health_service.dart';

enum ProjectDecisionGovernanceLevel { escalate, approve, coordinate, delegated }

enum ProjectDecisionGovernanceKind {
  authority,
  schedule,
  finance,
  risk,
  acceptance,
  communication,
}

class ProjectDecisionGovernanceItem {
  const ProjectDecisionGovernanceItem({
    required this.title,
    required this.detail,
    required this.icon,
    required this.level,
    required this.kind,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProjectDecisionGovernanceLevel level;
  final ProjectDecisionGovernanceKind kind;
}

class ProjectDecisionGovernanceSummary {
  const ProjectDecisionGovernanceSummary({
    required this.vocabulary,
    required this.audience,
    required this.title,
    required this.subtitle,
    required this.decisionRoute,
    required this.items,
    this.briefText = '',
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final String title;
  final String subtitle;
  final String decisionRoute;
  final List<ProjectDecisionGovernanceItem> items;
  final String briefText;

  int get escalateCount =>
      items
          .where(
            (item) => item.level == ProjectDecisionGovernanceLevel.escalate,
          )
          .length;

  int get approveCount =>
      items
          .where((item) => item.level == ProjectDecisionGovernanceLevel.approve)
          .length;

  int get coordinateCount =>
      items
          .where(
            (item) => item.level == ProjectDecisionGovernanceLevel.coordinate,
          )
          .length;

  int get delegatedCount =>
      items
          .where(
            (item) => item.level == ProjectDecisionGovernanceLevel.delegated,
          )
          .length;

  ProjectDecisionGovernanceLevel get level {
    if (escalateCount > 0) return ProjectDecisionGovernanceLevel.escalate;
    if (approveCount > 0) return ProjectDecisionGovernanceLevel.approve;
    if (coordinateCount > 0) return ProjectDecisionGovernanceLevel.coordinate;

    return ProjectDecisionGovernanceLevel.delegated;
  }

  ProjectDecisionGovernanceItem get primaryItem {
    return items.firstWhere(
      (item) => item.level == level,
      orElse: () => items.first,
    );
  }
}

ProjectDecisionGovernanceSummary buildProjectDecisionGovernance({
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
  final nextDecisions = buildProjectNextDecisionSummary(
    project: project,
    timelineTasks: timelineTasks,
    dependencyTasks: dependencyTasks,
    today: referenceDate,
  );
  final activeRiskCount =
      project.risks
          .where((risk) => risk.severity != ProjectHealth.onTrack)
          .length;
  final blockedRiskCount =
      project.risks
          .where((risk) => risk.severity == ProjectHealth.blocked)
          .length;
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
  final budgetDrift = project.budgetUsed - project.progress;
  final level = _summaryLevel(
    project: project,
    timelineHealth: timelineHealth,
    nextDecisions: nextDecisions,
    activeRiskCount: activeRiskCount,
    blockedRiskCount: blockedRiskCount,
    overdueMilestoneCount: overdueMilestoneCount,
    budgetDrift: budgetDrift,
    nextMilestoneDays: nextMilestoneDays,
  );
  final spec =
      _domainGovernanceSpecs[vocabulary.id] ??
      _domainGovernanceSpecs['general']!;
  final items = [
    _authorityItem(spec: spec, level: level),
    _scheduleItem(
      vocabulary: vocabulary,
      timelineHealth: timelineHealth,
      timelineTaskCount: timelineTasks.length,
    ),
    _financeItem(vocabulary: vocabulary, budgetDrift: budgetDrift),
    _riskItem(
      vocabulary: vocabulary,
      activeRiskCount: activeRiskCount,
      blockedRiskCount: blockedRiskCount,
    ),
    _acceptanceItem(
      vocabulary: vocabulary,
      nextMilestone: nextMilestone,
      nextMilestoneDays: nextMilestoneDays,
      overdueMilestoneCount: overdueMilestoneCount,
    ),
    _communicationItem(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      level: level,
    ),
  ];
  final title =
      vocabulary == ProjectStatusUpdateVocabulary.general
          ? 'Delivery decision governance'
          : '${vocabulary.label} decision governance';
  final decisionRoute = spec.routeFor(level);

  return ProjectDecisionGovernanceSummary(
    vocabulary: vocabulary,
    audience: audience,
    title: title,
    subtitle: '${level.label} - $decisionRoute - ${items.length} routes',
    decisionRoute: decisionRoute,
    items: List.unmodifiable(items),
    briefText: _decisionGovernanceBriefText(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      title: title,
      level: level,
      decisionRoute: decisionRoute,
      items: items,
    ),
  );
}

ProjectDecisionGovernanceLevel _summaryLevel({
  required ProjectPortfolioItem project,
  required ProjectTimelineHealthRollup timelineHealth,
  required ProjectNextDecisionSummary nextDecisions,
  required int activeRiskCount,
  required int blockedRiskCount,
  required int overdueMilestoneCount,
  required double budgetDrift,
  required int? nextMilestoneDays,
}) {
  if (project.health == ProjectHealth.blocked ||
      blockedRiskCount > 0 ||
      timelineHealth.dependencyBlockCount > 0 ||
      nextDecisions.criticalCount > 0 ||
      overdueMilestoneCount > 0) {
    return ProjectDecisionGovernanceLevel.escalate;
  }

  if (budgetDrift >= 0.15 ||
      (nextMilestoneDays != null &&
          nextMilestoneDays >= 0 &&
          nextMilestoneDays <= 10)) {
    return ProjectDecisionGovernanceLevel.approve;
  }

  if (project.health == ProjectHealth.atRisk ||
      activeRiskCount > 0 ||
      timelineHealth.totalTasks == 0 ||
      project.progress < 0.5) {
    return ProjectDecisionGovernanceLevel.coordinate;
  }

  return ProjectDecisionGovernanceLevel.delegated;
}

ProjectDecisionGovernanceItem _authorityItem({
  required _DomainGovernanceSpec spec,
  required ProjectDecisionGovernanceLevel level,
}) {
  return ProjectDecisionGovernanceItem(
    title: spec.titleFor(level),
    detail: spec.detailFor(level),
    icon: spec.icon,
    level: level,
    kind: ProjectDecisionGovernanceKind.authority,
  );
}

ProjectDecisionGovernanceItem _scheduleItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectTimelineHealthRollup timelineHealth,
  required int timelineTaskCount,
}) {
  if (timelineHealth.dependencyBlockCount > 0) {
    return ProjectDecisionGovernanceItem(
      title: 'Escalate ${vocabulary.scheduleLabel} authority',
      detail:
          '${timelineHealth.dependencyBlockCount} blocked dependency decision${timelineHealth.dependencyBlockCount == 1 ? '' : 's'} need named approval before schedule movement.',
      icon: Icons.account_tree_outlined,
      level: ProjectDecisionGovernanceLevel.escalate,
      kind: ProjectDecisionGovernanceKind.schedule,
    );
  }

  if (timelineHealth.overdueCount > 0) {
    return ProjectDecisionGovernanceItem(
      title: 'Approve ${vocabulary.scheduleLabel} recovery',
      detail:
          '${timelineHealth.overdueCount} overdue ${vocabulary.scheduleItemLabel}${timelineHealth.overdueCount == 1 ? '' : 's'} need date, owner, and scope decisions.',
      icon: Icons.event_busy_outlined,
      level: ProjectDecisionGovernanceLevel.escalate,
      kind: ProjectDecisionGovernanceKind.schedule,
    );
  }

  if (timelineTaskCount == 0) {
    return ProjectDecisionGovernanceItem(
      title: 'Assign ${vocabulary.scheduleLabel} decision map',
      detail:
          'Attach ${vocabulary.scheduleItemLabel}s before decision authority can be delegated safely.',
      icon: Icons.add_link_outlined,
      level: ProjectDecisionGovernanceLevel.coordinate,
      kind: ProjectDecisionGovernanceKind.schedule,
    );
  }

  return ProjectDecisionGovernanceItem(
    title: 'Delegate ${vocabulary.scheduleLabel} decisions',
    detail:
        'Schedule signals are clear enough for ${vocabulary.ownerLabel}-level decisions with exception reporting.',
    icon: Icons.timeline_outlined,
    level: ProjectDecisionGovernanceLevel.delegated,
    kind: ProjectDecisionGovernanceKind.schedule,
  );
}

ProjectDecisionGovernanceItem _financeItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required double budgetDrift,
}) {
  if (budgetDrift >= 0.15) {
    return ProjectDecisionGovernanceItem(
      title: 'Approve ${vocabulary.budgetLabel} decision',
      detail:
          '${(budgetDrift * 100).round()} point spend/progress drift needs financial approval before new commitments.',
      icon: Icons.account_balance_wallet_outlined,
      level: ProjectDecisionGovernanceLevel.approve,
      kind: ProjectDecisionGovernanceKind.finance,
    );
  }

  if (budgetDrift >= 0.08) {
    return ProjectDecisionGovernanceItem(
      title: 'Coordinate ${vocabulary.budgetLabel} guardrail',
      detail:
          'Budget movement is visible; keep spend decisions tied to impact notes.',
      icon: Icons.receipt_long_outlined,
      level: ProjectDecisionGovernanceLevel.coordinate,
      kind: ProjectDecisionGovernanceKind.finance,
    );
  }

  return ProjectDecisionGovernanceItem(
    title: 'Delegate ${vocabulary.budgetLabel} guardrail',
    detail:
        'Spend and progress are aligned enough for lightweight owner-level control.',
    icon: Icons.savings_outlined,
    level: ProjectDecisionGovernanceLevel.delegated,
    kind: ProjectDecisionGovernanceKind.finance,
  );
}

ProjectDecisionGovernanceItem _riskItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int activeRiskCount,
  required int blockedRiskCount,
}) {
  if (blockedRiskCount > 0) {
    return ProjectDecisionGovernanceItem(
      title: 'Escalate ${vocabulary.riskLabel} decision',
      detail:
          '$blockedRiskCount blocked ${vocabulary.riskLabel}${blockedRiskCount == 1 ? '' : 's'} need an explicit accept, mitigate, or stop decision.',
      icon: Icons.block_outlined,
      level: ProjectDecisionGovernanceLevel.escalate,
      kind: ProjectDecisionGovernanceKind.risk,
    );
  }

  if (activeRiskCount > 0) {
    return ProjectDecisionGovernanceItem(
      title: 'Coordinate ${vocabulary.riskLabel} decision',
      detail:
          '$activeRiskCount active ${vocabulary.riskLabel}${activeRiskCount == 1 ? '' : 's'} need owner, mitigation, and impact notes.',
      icon: Icons.health_and_safety_outlined,
      level: ProjectDecisionGovernanceLevel.coordinate,
      kind: ProjectDecisionGovernanceKind.risk,
    );
  }

  return ProjectDecisionGovernanceItem(
    title: 'Delegate ${vocabulary.riskLabel} watch',
    detail:
        'No active ${vocabulary.riskLabel}s require heavier decision governance.',
    icon: Icons.verified_outlined,
    level: ProjectDecisionGovernanceLevel.delegated,
    kind: ProjectDecisionGovernanceKind.risk,
  );
}

ProjectDecisionGovernanceItem _acceptanceItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectMilestone? nextMilestone,
  required int? nextMilestoneDays,
  required int overdueMilestoneCount,
}) {
  if (overdueMilestoneCount > 0) {
    return ProjectDecisionGovernanceItem(
      title: 'Escalate overdue ${vocabulary.milestoneLabel} acceptance',
      detail:
          '$overdueMilestoneCount overdue ${vocabulary.milestoneLabel}${overdueMilestoneCount == 1 ? '' : 's'} need acceptance, deferral, or recovery decision.',
      icon: Icons.assignment_late_outlined,
      level: ProjectDecisionGovernanceLevel.escalate,
      kind: ProjectDecisionGovernanceKind.acceptance,
    );
  }

  if (nextMilestone == null) {
    return ProjectDecisionGovernanceItem(
      title: 'Close final acceptance decision',
      detail:
          'All ${vocabulary.milestoneLabel}s are complete; route remaining proof into closure notes.',
      icon: Icons.inventory_2_outlined,
      level: ProjectDecisionGovernanceLevel.delegated,
      kind: ProjectDecisionGovernanceKind.acceptance,
    );
  }

  if (nextMilestoneDays != null &&
      nextMilestoneDays >= 0 &&
      nextMilestoneDays <= 10) {
    return ProjectDecisionGovernanceItem(
      title: 'Approve ${nextMilestone.label} decision',
      detail:
          'The next ${vocabulary.milestoneLabel} is due ${nextMilestoneDays == 0 ? 'today' : 'in ${nextMilestoneDays}d'}; confirm proof, owner, and acceptance route.',
      icon: Icons.fact_check_outlined,
      level: ProjectDecisionGovernanceLevel.approve,
      kind: ProjectDecisionGovernanceKind.acceptance,
    );
  }

  return ProjectDecisionGovernanceItem(
    title: 'Coordinate ${nextMilestone.label} decision path',
    detail:
        'Keep decision owners and acceptance proof ready before the next ${vocabulary.milestoneLabel}.',
    icon: Icons.flag_outlined,
    level: ProjectDecisionGovernanceLevel.coordinate,
    kind: ProjectDecisionGovernanceKind.acceptance,
  );
}

ProjectDecisionGovernanceItem _communicationItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required ProjectDecisionGovernanceLevel level,
}) {
  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return ProjectDecisionGovernanceItem(
        title: 'Publish stakeholder decision route',
        detail:
            'Show decision owner, approval lane, and the next ${vocabulary.milestoneLabel} consequence.',
        icon: audience.icon,
        level:
            level == ProjectDecisionGovernanceLevel.delegated
                ? ProjectDecisionGovernanceLevel.coordinate
                : level,
        kind: ProjectDecisionGovernanceKind.communication,
      );
    case ProjectStatusUpdateAudience.sponsor:
      return ProjectDecisionGovernanceItem(
        title: 'Prepare sponsor decision agenda',
        detail:
            'Give ${project.sponsor.isEmpty ? project.owner : project.sponsor} the approve, defer, or escalate choices.',
        icon: audience.icon,
        level:
            level == ProjectDecisionGovernanceLevel.escalate
                ? ProjectDecisionGovernanceLevel.approve
                : level,
        kind: ProjectDecisionGovernanceKind.communication,
      );
    case ProjectStatusUpdateAudience.team:
      return ProjectDecisionGovernanceItem(
        title: 'Convert decisions into team actions',
        detail:
            'Translate accepted decisions into owner-ready ${vocabulary.scheduleItemLabel}s for ${project.owner}.',
        icon: audience.icon,
        level: ProjectDecisionGovernanceLevel.coordinate,
        kind: ProjectDecisionGovernanceKind.communication,
      );
    case ProjectStatusUpdateAudience.client:
      return ProjectDecisionGovernanceItem(
        title: 'Prepare client decision confirmation',
        detail:
            'Show ${project.client} what needs a client-visible accept, defer, or trade-off decision.',
        icon: audience.icon,
        level:
            level == ProjectDecisionGovernanceLevel.delegated
                ? ProjectDecisionGovernanceLevel.coordinate
                : level,
        kind: ProjectDecisionGovernanceKind.communication,
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

String _decisionGovernanceBriefText({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required String title,
  required ProjectDecisionGovernanceLevel level,
  required String decisionRoute,
  required List<ProjectDecisionGovernanceItem> items,
}) {
  final primaryItem = items.firstWhere(
    (item) => item.level == level,
    orElse: () => items.first,
  );

  return [
    '$title brief',
    'Status: ${level.label}',
    'Route: $decisionRoute',
    'Audience: ${audience.summaryLabel(vocabulary)}',
    'Owner: ${project.owner}',
    '',
    'Primary governance route',
    '- ${primaryItem.title}: ${primaryItem.detail}',
    '',
    'Decision queue',
    for (final item in items)
      if (item != primaryItem) '- ${item.title}: ${item.detail}',
    '',
    'Decision rule',
    '- Every material ${vocabulary.workLabel} decision needs owner, impact, proof, and communication route before it changes the ${vocabulary.scheduleLabel}.',
  ].join('\n');
}

extension ProjectDecisionGovernanceLevelPresentation
    on ProjectDecisionGovernanceLevel {
  String get label {
    switch (this) {
      case ProjectDecisionGovernanceLevel.escalate:
        return 'Escalate';
      case ProjectDecisionGovernanceLevel.approve:
        return 'Approve';
      case ProjectDecisionGovernanceLevel.coordinate:
        return 'Coordinate';
      case ProjectDecisionGovernanceLevel.delegated:
        return 'Delegated';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectDecisionGovernanceLevel.escalate:
        return Icons.priority_high_rounded;
      case ProjectDecisionGovernanceLevel.approve:
        return Icons.rule_folder_outlined;
      case ProjectDecisionGovernanceLevel.coordinate:
        return Icons.hub_outlined;
      case ProjectDecisionGovernanceLevel.delegated:
        return Icons.verified_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionGovernanceLevel.escalate:
        return colorScheme.error;
      case ProjectDecisionGovernanceLevel.approve:
        return Colors.orange.shade700;
      case ProjectDecisionGovernanceLevel.coordinate:
        return colorScheme.primary;
      case ProjectDecisionGovernanceLevel.delegated:
        return Colors.green.shade700;
    }
  }
}

class _DomainGovernanceSpec {
  const _DomainGovernanceSpec({
    required this.icon,
    required this.escalateTitle,
    required this.approveTitle,
    required this.coordinateTitle,
    required this.delegatedTitle,
    required this.escalateDetail,
    required this.approveDetail,
    required this.coordinateDetail,
    required this.delegatedDetail,
    required this.escalateRoute,
    required this.approveRoute,
    required this.coordinateRoute,
    required this.delegatedRoute,
  });

  final IconData icon;
  final String escalateTitle;
  final String approveTitle;
  final String coordinateTitle;
  final String delegatedTitle;
  final String escalateDetail;
  final String approveDetail;
  final String coordinateDetail;
  final String delegatedDetail;
  final String escalateRoute;
  final String approveRoute;
  final String coordinateRoute;
  final String delegatedRoute;

  String titleFor(ProjectDecisionGovernanceLevel level) {
    switch (level) {
      case ProjectDecisionGovernanceLevel.escalate:
        return escalateTitle;
      case ProjectDecisionGovernanceLevel.approve:
        return approveTitle;
      case ProjectDecisionGovernanceLevel.coordinate:
        return coordinateTitle;
      case ProjectDecisionGovernanceLevel.delegated:
        return delegatedTitle;
    }
  }

  String detailFor(ProjectDecisionGovernanceLevel level) {
    switch (level) {
      case ProjectDecisionGovernanceLevel.escalate:
        return escalateDetail;
      case ProjectDecisionGovernanceLevel.approve:
        return approveDetail;
      case ProjectDecisionGovernanceLevel.coordinate:
        return coordinateDetail;
      case ProjectDecisionGovernanceLevel.delegated:
        return delegatedDetail;
    }
  }

  String routeFor(ProjectDecisionGovernanceLevel level) {
    switch (level) {
      case ProjectDecisionGovernanceLevel.escalate:
        return escalateRoute;
      case ProjectDecisionGovernanceLevel.approve:
        return approveRoute;
      case ProjectDecisionGovernanceLevel.coordinate:
        return coordinateRoute;
      case ProjectDecisionGovernanceLevel.delegated:
        return delegatedRoute;
    }
  }
}

const _domainGovernanceSpecs = {
  'general': _DomainGovernanceSpec(
    icon: Icons.account_tree_outlined,
    escalateTitle: 'Escalate delivery governance',
    approveTitle: 'Approve delivery decision',
    coordinateTitle: 'Coordinate delivery decisions',
    delegatedTitle: 'Delegate delivery decisions',
    escalateDetail:
        'Move blocked or material decisions into a named steering route before delivery changes.',
    approveDetail:
        'Use the approval route for material scope, schedule, budget, or acceptance movement.',
    coordinateDetail:
        'Keep decision owners aligned while work remains manageable at project level.',
    delegatedDetail:
        'Keep routine delivery decisions with the project owner and report exceptions.',
    escalateRoute: 'delivery steering escalation',
    approveRoute: 'delivery approval route',
    coordinateRoute: 'owner coordination route',
    delegatedRoute: 'delegated owner route',
  ),
  'construction': _DomainGovernanceSpec(
    icon: Icons.construction_outlined,
    escalateTitle: 'Escalate site governance',
    approveTitle: 'Approve site decision',
    coordinateTitle: 'Coordinate site decisions',
    delegatedTitle: 'Delegate site decisions',
    escalateDetail:
        'Move blocked site, supplier, permit, or safety decisions into site steering.',
    approveDetail:
        'Route material phase, cost, supplier, or permit decisions through variation approval.',
    coordinateDetail:
        'Keep site lead, supplier, and phase-gate decisions aligned before field execution.',
    delegatedDetail:
        'Let the site lead handle routine field decisions with exception reporting.',
    escalateRoute: 'site steering escalation',
    approveRoute: 'variation approval route',
    coordinateRoute: 'site lead coordination route',
    delegatedRoute: 'delegated site lead route',
  ),
  'software': _DomainGovernanceSpec(
    icon: Icons.code_outlined,
    escalateTitle: 'Escalate release governance',
    approveTitle: 'Approve release decision',
    coordinateTitle: 'Coordinate release decisions',
    delegatedTitle: 'Delegate release decisions',
    escalateDetail:
        'Move blocked dependency, QA, rollout, or scope decisions into release council.',
    approveDetail:
        'Route material scope, acceptance, dependency, or rollout decisions through release approval.',
    coordinateDetail:
        'Keep product, engineering, QA, and rollout owners aligned before release movement.',
    delegatedDetail:
        'Let the delivery owner handle routine release decisions with exception reporting.',
    escalateRoute: 'release council escalation',
    approveRoute: 'release approval route',
    coordinateRoute: 'delivery owner coordination route',
    delegatedRoute: 'delegated release owner route',
  ),
  'event-production': _DomainGovernanceSpec(
    icon: Icons.event_outlined,
    escalateTitle: 'Escalate production governance',
    approveTitle: 'Approve production decision',
    coordinateTitle: 'Coordinate production decisions',
    delegatedTitle: 'Delegate production decisions',
    escalateDetail:
        'Move blocked vendor, venue, talent, or contingency decisions into production control.',
    approveDetail:
        'Route material run-sheet, vendor, venue, or contingency decisions through production approval.',
    coordinateDetail:
        'Keep producer, vendor, venue, and show-call decisions aligned before show movement.',
    delegatedDetail:
        'Let the producer handle routine production decisions with exception reporting.',
    escalateRoute: 'production control escalation',
    approveRoute: 'production approval route',
    coordinateRoute: 'producer coordination route',
    delegatedRoute: 'delegated producer route',
  ),
  'government': _DomainGovernanceSpec(
    icon: Icons.account_balance_outlined,
    escalateTitle: 'Escalate governance board decision',
    approveTitle: 'Approve public program decision',
    coordinateTitle: 'Coordinate public program decisions',
    delegatedTitle: 'Delegate public program decisions',
    escalateDetail:
        'Move blocked compliance, approval, funding, or accountability decisions into governance board.',
    approveDetail:
        'Route material compliance, funding, and public-accountability decisions through formal approval.',
    coordinateDetail:
        'Keep program, compliance, and stakeholder decisions aligned before implementation movement.',
    delegatedDetail:
        'Let the program owner handle routine public-program decisions with exception reporting.',
    escalateRoute: 'governance board escalation',
    approveRoute: 'formal approval route',
    coordinateRoute: 'program owner coordination route',
    delegatedRoute: 'delegated program owner route',
  ),
  'education': _DomainGovernanceSpec(
    icon: Icons.school_outlined,
    escalateTitle: 'Escalate academic governance',
    approveTitle: 'Approve academic decision',
    coordinateTitle: 'Coordinate academic decisions',
    delegatedTitle: 'Delegate academic decisions',
    escalateDetail:
        'Move blocked curriculum, faculty, calendar, or learner-support decisions into academic steering.',
    approveDetail:
        'Route material curriculum, calendar, faculty, or learner-impact decisions through academic approval.',
    coordinateDetail:
        'Keep program lead, faculty, and learner-support decisions aligned before academic movement.',
    delegatedDetail:
        'Let the program lead handle routine academic decisions with exception reporting.',
    escalateRoute: 'academic steering escalation',
    approveRoute: 'academic approval route',
    coordinateRoute: 'program lead coordination route',
    delegatedRoute: 'delegated program lead route',
  ),
  'wedding': _DomainGovernanceSpec(
    icon: Icons.celebration_outlined,
    escalateTitle: 'Escalate wedding planning governance',
    approveTitle: 'Approve wedding planning decision',
    coordinateTitle: 'Coordinate wedding planning governance',
    delegatedTitle: 'Delegate wedding planning decisions',
    escalateDetail:
        'Move blocked vendor, venue, guest-impact, or day-of decisions into the client planning route.',
    approveDetail:
        'Route material vendor, guest, venue, or timeline decisions through client-visible approval.',
    coordinateDetail:
        'Keep planner, vendor, family, and day-of decisions aligned before client-facing movement.',
    delegatedDetail:
        'Let the planner handle routine planning decisions with exception reporting.',
    escalateRoute: 'client planning escalation',
    approveRoute: 'client planning approval route',
    coordinateRoute: 'planner coordination route',
    delegatedRoute: 'delegated planner route',
  ),
};
