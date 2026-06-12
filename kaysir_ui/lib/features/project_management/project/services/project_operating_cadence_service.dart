import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_status_update_service.dart';

enum ProjectOperatingCadenceLevel { recovery, decision, rhythm, steady }

enum ProjectOperatingCadenceKind {
  cadence,
  agenda,
  decisionWindow,
  evidence,
  audience,
}

class ProjectOperatingCadenceItem {
  const ProjectOperatingCadenceItem({
    required this.title,
    required this.detail,
    required this.icon,
    required this.level,
    required this.kind,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProjectOperatingCadenceLevel level;
  final ProjectOperatingCadenceKind kind;
}

class ProjectOperatingCadenceSummary {
  const ProjectOperatingCadenceSummary({
    required this.vocabulary,
    required this.audience,
    required this.title,
    required this.subtitle,
    required this.recommendedCadence,
    required this.items,
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final String title;
  final String subtitle;
  final String recommendedCadence;
  final List<ProjectOperatingCadenceItem> items;

  int get recoveryCount =>
      items
          .where((item) => item.level == ProjectOperatingCadenceLevel.recovery)
          .length;

  int get decisionCount =>
      items
          .where((item) => item.level == ProjectOperatingCadenceLevel.decision)
          .length;

  int get rhythmCount =>
      items
          .where((item) => item.level == ProjectOperatingCadenceLevel.rhythm)
          .length;

  int get steadyCount =>
      items
          .where((item) => item.level == ProjectOperatingCadenceLevel.steady)
          .length;

  ProjectOperatingCadenceLevel get level {
    if (recoveryCount > 0) return ProjectOperatingCadenceLevel.recovery;
    if (decisionCount > 0) return ProjectOperatingCadenceLevel.decision;
    if (rhythmCount > 0) return ProjectOperatingCadenceLevel.rhythm;

    return ProjectOperatingCadenceLevel.steady;
  }

  ProjectOperatingCadenceItem get primaryItem {
    return items.firstWhere(
      (item) => item.level == level,
      orElse: () => items.first,
    );
  }
}

ProjectOperatingCadenceSummary buildProjectOperatingCadence({
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
  final overdueMilestoneCount =
      project.milestones.where((milestone) {
        return !milestone.isComplete &&
            DateUtils.dateOnly(milestone.dueDate).isBefore(referenceDate);
      }).length;
  final activeRiskCount =
      project.risks
          .where((risk) => risk.severity != ProjectHealth.onTrack)
          .length;
  final blockedRiskCount =
      project.risks
          .where((risk) => risk.severity == ProjectHealth.blocked)
          .length;
  final budgetDrift = project.budgetUsed - project.progress;
  final nextMilestone = _nextOpenMilestone(project.milestones);
  final nextMilestoneDays =
      nextMilestone == null
          ? null
          : DateUtils.dateOnly(
            nextMilestone.dueDate,
          ).difference(referenceDate).inDays;
  final overdueCount = overdueTaskCount + overdueMilestoneCount;
  final summaryLevel = _cadenceLevel(
    project: project,
    overdueCount: overdueCount,
    blockedRiskCount: blockedRiskCount,
    activeRiskCount: activeRiskCount,
    budgetDrift: budgetDrift,
    timelineTaskCount: timelineTasks.length,
    nextMilestoneDays: nextMilestoneDays,
  );
  final spec =
      _domainCadenceSpecs[vocabulary.id] ?? _domainCadenceSpecs['general']!;
  final recommendedCadence = spec.cadenceFor(summaryLevel);
  final items = [
    _cadenceItem(
      spec: spec,
      level: summaryLevel,
      overdueCount: overdueCount,
      blockedRiskCount: blockedRiskCount,
    ),
    _agendaItem(
      project: project,
      vocabulary: vocabulary,
      level: summaryLevel,
      nextMilestone: nextMilestone,
      nextMilestoneDays: nextMilestoneDays,
    ),
    _decisionWindowItem(
      vocabulary: vocabulary,
      overdueCount: overdueCount,
      blockedRiskCount: blockedRiskCount,
      activeRiskCount: activeRiskCount,
      budgetDrift: budgetDrift,
    ),
    _evidenceItem(spec: spec, vocabulary: vocabulary, level: summaryLevel),
    _audienceItem(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      level: summaryLevel,
    ),
  ];
  final title =
      vocabulary == ProjectStatusUpdateVocabulary.general
          ? 'Delivery operating cadence'
          : '${vocabulary.label} operating cadence';

  return ProjectOperatingCadenceSummary(
    vocabulary: vocabulary,
    audience: audience,
    title: title,
    subtitle:
        '${summaryLevel.label} - $recommendedCadence - ${items.length} steps',
    recommendedCadence: recommendedCadence,
    items: List.unmodifiable(items),
  );
}

ProjectOperatingCadenceLevel _cadenceLevel({
  required ProjectPortfolioItem project,
  required int overdueCount,
  required int blockedRiskCount,
  required int activeRiskCount,
  required double budgetDrift,
  required int timelineTaskCount,
  required int? nextMilestoneDays,
}) {
  if (project.health == ProjectHealth.blocked ||
      blockedRiskCount > 0 ||
      overdueCount > 0) {
    return ProjectOperatingCadenceLevel.recovery;
  }

  if (budgetDrift >= 0.15 ||
      (nextMilestoneDays != null &&
          nextMilestoneDays >= 0 &&
          nextMilestoneDays <= 7)) {
    return ProjectOperatingCadenceLevel.decision;
  }

  if (project.health == ProjectHealth.atRisk ||
      activeRiskCount > 0 ||
      timelineTaskCount == 0) {
    return ProjectOperatingCadenceLevel.rhythm;
  }

  return ProjectOperatingCadenceLevel.steady;
}

ProjectOperatingCadenceItem _cadenceItem({
  required _DomainCadenceSpec spec,
  required ProjectOperatingCadenceLevel level,
  required int overdueCount,
  required int blockedRiskCount,
}) {
  final title = spec.titleFor(level);
  final detail =
      level == ProjectOperatingCadenceLevel.recovery
          ? '$blockedRiskCount blocked risk${blockedRiskCount == 1 ? '' : 's'} and $overdueCount overdue signal${overdueCount == 1 ? '' : 's'} set the cadence.'
          : spec.detailFor(level);

  return ProjectOperatingCadenceItem(
    title: title,
    detail: detail,
    icon: spec.icon,
    level: level,
    kind: ProjectOperatingCadenceKind.cadence,
  );
}

ProjectOperatingCadenceItem _agendaItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectOperatingCadenceLevel level,
  required ProjectMilestone? nextMilestone,
  required int? nextMilestoneDays,
}) {
  final dueLabel =
      nextMilestoneDays == null
          ? null
          : nextMilestoneDays < 0
          ? '${nextMilestoneDays.abs()}d overdue'
          : nextMilestoneDays == 0
          ? 'due today'
          : 'due in ${nextMilestoneDays}d';

  return ProjectOperatingCadenceItem(
    title: 'Shape ${vocabulary.scheduleLabel} agenda',
    detail:
        nextMilestone == null
            ? 'Use ${project.owner}, current progress, ${vocabulary.riskLabel}, and ${vocabulary.budgetLabel} movement to focus the next review.'
            : 'Center the next review on ${nextMilestone.label} ($dueLabel), owner asks, and ${vocabulary.scheduleItemLabel} movement.',
    icon: Icons.format_list_bulleted_outlined,
    level:
        level == ProjectOperatingCadenceLevel.steady
            ? ProjectOperatingCadenceLevel.rhythm
            : level,
    kind: ProjectOperatingCadenceKind.agenda,
  );
}

ProjectOperatingCadenceItem _decisionWindowItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int overdueCount,
  required int blockedRiskCount,
  required int activeRiskCount,
  required double budgetDrift,
}) {
  if (blockedRiskCount > 0) {
    return ProjectOperatingCadenceItem(
      title: 'Open unblock window',
      detail:
          'Create a short decision window for blocked ${vocabulary.riskLabel}s before the next ${vocabulary.milestoneLabel}.',
      icon: Icons.priority_high_rounded,
      level: ProjectOperatingCadenceLevel.recovery,
      kind: ProjectOperatingCadenceKind.decisionWindow,
    );
  }

  if (overdueCount > 0) {
    return ProjectOperatingCadenceItem(
      title: 'Open recovery window',
      detail:
          'Confirm what changes in owner, date, or scope to recover overdue ${vocabulary.scheduleItemLabel}s.',
      icon: Icons.event_busy_outlined,
      level: ProjectOperatingCadenceLevel.recovery,
      kind: ProjectOperatingCadenceKind.decisionWindow,
    );
  }

  if (budgetDrift >= 0.15) {
    return ProjectOperatingCadenceItem(
      title: 'Open spend decision window',
      detail:
          'Resolve ${vocabulary.budgetLabel} drift before the next progress commitment.',
      icon: Icons.account_balance_wallet_outlined,
      level: ProjectOperatingCadenceLevel.decision,
      kind: ProjectOperatingCadenceKind.decisionWindow,
    );
  }

  if (activeRiskCount > 0) {
    return ProjectOperatingCadenceItem(
      title: 'Keep decision window visible',
      detail:
          'Track active ${vocabulary.riskLabel}s and name who can close each decision.',
      icon: Icons.rule_folder_outlined,
      level: ProjectOperatingCadenceLevel.rhythm,
      kind: ProjectOperatingCadenceKind.decisionWindow,
    );
  }

  return ProjectOperatingCadenceItem(
    title: 'Keep decision window light',
    detail:
        'No heavy escalation is needed; keep decisions tied to the next ${vocabulary.milestoneLabel}.',
    icon: Icons.task_alt_outlined,
    level: ProjectOperatingCadenceLevel.steady,
    kind: ProjectOperatingCadenceKind.decisionWindow,
  );
}

ProjectOperatingCadenceItem _evidenceItem({
  required _DomainCadenceSpec spec,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectOperatingCadenceLevel level,
}) {
  return ProjectOperatingCadenceItem(
    title: 'Capture ${vocabulary.audienceLabel} notes',
    detail: spec.evidenceDetail,
    icon: Icons.edit_note_outlined,
    level:
        level == ProjectOperatingCadenceLevel.recovery
            ? ProjectOperatingCadenceLevel.decision
            : ProjectOperatingCadenceLevel.rhythm,
    kind: ProjectOperatingCadenceKind.evidence,
  );
}

ProjectOperatingCadenceItem _audienceItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required ProjectOperatingCadenceLevel level,
}) {
  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return ProjectOperatingCadenceItem(
        title: 'Close stakeholder loop',
        detail:
            'Send a concise rhythm note covering ${vocabulary.workLabel}, ${vocabulary.riskLabel}, and next ${vocabulary.milestoneLabel}.',
        icon: audience.icon,
        level:
            level == ProjectOperatingCadenceLevel.steady
                ? level
                : ProjectOperatingCadenceLevel.rhythm,
        kind: ProjectOperatingCadenceKind.audience,
      );
    case ProjectStatusUpdateAudience.sponsor:
      return ProjectOperatingCadenceItem(
        title: 'Close sponsor loop',
        detail:
            'Make the ask clear for ${project.sponsor.isEmpty ? project.owner : project.sponsor} before the next decision moment.',
        icon: audience.icon,
        level:
            level == ProjectOperatingCadenceLevel.recovery
                ? ProjectOperatingCadenceLevel.decision
                : level,
        kind: ProjectOperatingCadenceKind.audience,
      );
    case ProjectStatusUpdateAudience.team:
      return ProjectOperatingCadenceItem(
        title: 'Close team loop',
        detail:
            'Turn cadence notes into owner-ready ${vocabulary.scheduleItemLabel}s and blockers.',
        icon: audience.icon,
        level: ProjectOperatingCadenceLevel.rhythm,
        kind: ProjectOperatingCadenceKind.audience,
      );
    case ProjectStatusUpdateAudience.client:
      return ProjectOperatingCadenceItem(
        title: 'Close client loop',
        detail:
            'Share timing, confidence signals, and next client-visible decision for ${project.client}.',
        icon: audience.icon,
        level:
            level == ProjectOperatingCadenceLevel.recovery
                ? ProjectOperatingCadenceLevel.decision
                : ProjectOperatingCadenceLevel.rhythm,
        kind: ProjectOperatingCadenceKind.audience,
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

extension ProjectOperatingCadenceLevelPresentation
    on ProjectOperatingCadenceLevel {
  String get label {
    switch (this) {
      case ProjectOperatingCadenceLevel.recovery:
        return 'Recovery';
      case ProjectOperatingCadenceLevel.decision:
        return 'Decision';
      case ProjectOperatingCadenceLevel.rhythm:
        return 'Rhythm';
      case ProjectOperatingCadenceLevel.steady:
        return 'Steady';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectOperatingCadenceLevel.recovery:
        return Icons.priority_high_rounded;
      case ProjectOperatingCadenceLevel.decision:
        return Icons.rule_folder_outlined;
      case ProjectOperatingCadenceLevel.rhythm:
        return Icons.sync_alt_outlined;
      case ProjectOperatingCadenceLevel.steady:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectOperatingCadenceLevel.recovery:
        return colorScheme.error;
      case ProjectOperatingCadenceLevel.decision:
        return Colors.orange.shade700;
      case ProjectOperatingCadenceLevel.rhythm:
        return colorScheme.primary;
      case ProjectOperatingCadenceLevel.steady:
        return Colors.green.shade700;
    }
  }
}

class _DomainCadenceSpec {
  const _DomainCadenceSpec({
    required this.icon,
    required this.recoveryTitle,
    required this.decisionTitle,
    required this.rhythmTitle,
    required this.steadyTitle,
    required this.recoveryDetail,
    required this.decisionDetail,
    required this.rhythmDetail,
    required this.steadyDetail,
    required this.recoveryCadence,
    required this.decisionCadence,
    required this.rhythmCadence,
    required this.steadyCadence,
    required this.evidenceDetail,
  });

  final IconData icon;
  final String recoveryTitle;
  final String decisionTitle;
  final String rhythmTitle;
  final String steadyTitle;
  final String recoveryDetail;
  final String decisionDetail;
  final String rhythmDetail;
  final String steadyDetail;
  final String recoveryCadence;
  final String decisionCadence;
  final String rhythmCadence;
  final String steadyCadence;
  final String evidenceDetail;

  String titleFor(ProjectOperatingCadenceLevel level) {
    switch (level) {
      case ProjectOperatingCadenceLevel.recovery:
        return recoveryTitle;
      case ProjectOperatingCadenceLevel.decision:
        return decisionTitle;
      case ProjectOperatingCadenceLevel.rhythm:
        return rhythmTitle;
      case ProjectOperatingCadenceLevel.steady:
        return steadyTitle;
    }
  }

  String detailFor(ProjectOperatingCadenceLevel level) {
    switch (level) {
      case ProjectOperatingCadenceLevel.recovery:
        return recoveryDetail;
      case ProjectOperatingCadenceLevel.decision:
        return decisionDetail;
      case ProjectOperatingCadenceLevel.rhythm:
        return rhythmDetail;
      case ProjectOperatingCadenceLevel.steady:
        return steadyDetail;
    }
  }

  String cadenceFor(ProjectOperatingCadenceLevel level) {
    switch (level) {
      case ProjectOperatingCadenceLevel.recovery:
        return recoveryCadence;
      case ProjectOperatingCadenceLevel.decision:
        return decisionCadence;
      case ProjectOperatingCadenceLevel.rhythm:
        return rhythmCadence;
      case ProjectOperatingCadenceLevel.steady:
        return steadyCadence;
    }
  }
}

const _domainCadenceSpecs = {
  'general': _DomainCadenceSpec(
    icon: Icons.sync_alt_outlined,
    recoveryTitle: 'Run recovery huddle',
    decisionTitle: 'Run operating decision review',
    rhythmTitle: 'Run operating review',
    steadyTitle: 'Keep operating rhythm',
    recoveryDetail:
        'Use a short daily loop until blockers and dates stabilize.',
    decisionDetail: 'Collect owner decisions before the next commitment.',
    rhythmDetail: 'Keep the team on a predictable review rhythm.',
    steadyDetail: 'Stay with the current cadence and keep notes lightweight.',
    recoveryCadence: 'daily until stable',
    decisionCadence: 'next decision window',
    rhythmCadence: 'weekly review',
    steadyCadence: 'weekly review',
    evidenceDetail:
        'Capture owner, milestone, risk, budget, and decision notes from each review.',
  ),
  'construction': _DomainCadenceSpec(
    icon: Icons.construction_outlined,
    recoveryTitle: 'Run site recovery huddle',
    decisionTitle: 'Run phase-gate decision review',
    rhythmTitle: 'Run site coordination huddle',
    steadyTitle: 'Keep site coordination rhythm',
    recoveryDetail:
        'Use a daily site loop for blockers, permits, and suppliers.',
    decisionDetail:
        'Confirm phase-gate decisions before site commitments move.',
    rhythmDetail: 'Keep site, supplier, safety, and permit owners synced.',
    steadyDetail: 'Keep the site review lightweight and evidence-led.',
    recoveryCadence: 'daily site huddle',
    decisionCadence: 'phase-gate window',
    rhythmCadence: 'twice-weekly site huddle',
    steadyCadence: 'weekly site review',
    evidenceDetail:
        'Capture site access, permits, supplier readiness, safety notes, and phase-gate evidence.',
  ),
  'software': _DomainCadenceSpec(
    icon: Icons.code_outlined,
    recoveryTitle: 'Run release recovery standup',
    decisionTitle: 'Run release decision review',
    rhythmTitle: 'Run release readiness review',
    steadyTitle: 'Keep release review rhythm',
    recoveryDetail:
        'Use a daily release standup until blockers, scope, and dates stabilize.',
    decisionDetail: 'Confirm scope, dependency, QA, and rollout decisions.',
    rhythmDetail: 'Keep product, engineering, QA, and rollout owners synced.',
    steadyDetail: 'Keep release checks predictable and evidence-led.',
    recoveryCadence: 'daily until stable',
    decisionCadence: 'release decision window',
    rhythmCadence: 'twice-weekly checkpoint',
    steadyCadence: 'weekly release review',
    evidenceDetail:
        'Capture release scope, QA evidence, dependency owners, acceptance notes, and rollout decisions.',
  ),
  'event-production': _DomainCadenceSpec(
    icon: Icons.event_outlined,
    recoveryTitle: 'Run run-sheet recovery huddle',
    decisionTitle: 'Run production decision checkpoint',
    rhythmTitle: 'Run production checkpoint',
    steadyTitle: 'Keep production rhythm',
    recoveryDetail:
        'Use a daily production loop until vendor and venue risks settle.',
    decisionDetail: 'Confirm vendor, talent, venue, and contingency decisions.',
    rhythmDetail: 'Keep the run sheet and production owners current.',
    steadyDetail: 'Keep production checks clear and close to the run sheet.',
    recoveryCadence: 'daily production huddle',
    decisionCadence: 'production decision window',
    rhythmCadence: 'twice-weekly checkpoint',
    steadyCadence: 'weekly production review',
    evidenceDetail:
        'Capture run sheet updates, vendor confirmations, venue access, talent flow, and contingency owners.',
  ),
  'government': _DomainCadenceSpec(
    icon: Icons.account_balance_outlined,
    recoveryTitle: 'Run governance recovery huddle',
    decisionTitle: 'Run approval decision review',
    rhythmTitle: 'Run governance board review',
    steadyTitle: 'Keep governance rhythm',
    recoveryDetail:
        'Use a focused loop until compliance and approval blockers settle.',
    decisionDetail:
        'Confirm approval, funding, compliance, and public accountability decisions.',
    rhythmDetail: 'Keep governance owners and escalation paths visible.',
    steadyDetail: 'Keep approvals and accountability evidence current.',
    recoveryCadence: 'twice-weekly governance huddle',
    decisionCadence: 'approval window',
    rhythmCadence: 'weekly governance board',
    steadyCadence: 'biweekly governance review',
    evidenceDetail:
        'Capture approvals, compliance evidence, funding notes, public accountability, and escalation records.',
  ),
  'education': _DomainCadenceSpec(
    icon: Icons.school_outlined,
    recoveryTitle: 'Run academic recovery huddle',
    decisionTitle: 'Run academic decision checkpoint',
    rhythmTitle: 'Run academic operations review',
    steadyTitle: 'Keep academic rhythm',
    recoveryDetail:
        'Use a focused loop until faculty, calendar, or learner risks settle.',
    decisionDetail:
        'Confirm curriculum, faculty, calendar, and learner support decisions.',
    rhythmDetail: 'Keep academic operations and program owners coordinated.',
    steadyDetail: 'Keep academic checks predictable and learner-aware.',
    recoveryCadence: 'twice-weekly academic huddle',
    decisionCadence: 'academic decision window',
    rhythmCadence: 'weekly academic review',
    steadyCadence: 'biweekly academic review',
    evidenceDetail:
        'Capture curriculum proof, faculty coverage, learner readiness, support notes, and calendar risk.',
  ),
  'wedding': _DomainCadenceSpec(
    icon: Icons.celebration_outlined,
    recoveryTitle: 'Run wedding recovery huddle',
    decisionTitle: 'Run planning decision checkpoint',
    rhythmTitle: 'Run planning checkpoint',
    steadyTitle: 'Keep planning rhythm',
    recoveryDetail:
        'Use a focused loop until vendor, family, or venue risks settle.',
    decisionDetail:
        'Confirm guest-impact, vendor, venue, and day-of decisions.',
    rhythmDetail:
        'Keep planner, vendors, family decisions, and venue readiness coordinated.',
    steadyDetail: 'Keep planning checks calm, client-facing, and evidence-led.',
    recoveryCadence: 'twice-weekly planning huddle',
    decisionCadence: 'planning decision window',
    rhythmCadence: 'weekly planning checkpoint',
    steadyCadence: 'weekly planning review',
    evidenceDetail:
        'Capture vendor confirmations, family decisions, venue readiness, guest-impact notes, and day-of timing.',
  ),
};
