import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_handoff_brief_service.dart';
import 'project_milestone_timeline_service.dart';
import 'project_readiness_score_service.dart';
import 'project_timeline_health_service.dart';

enum ProjectStatusUpdateSignal { blocked, attention, watch, steady }

enum ProjectStatusUpdateAudience { stakeholder, sponsor, team, client }

class ProjectStatusUpdateVocabulary {
  const ProjectStatusUpdateVocabulary({
    required this.id,
    required this.label,
    required this.icon,
    required this.workLabel,
    required this.milestoneLabel,
    required this.riskLabel,
    required this.scheduleLabel,
    required this.scheduleItemLabel,
    required this.budgetLabel,
    required this.ownerLabel,
    required this.readinessLabel,
    required this.audienceLabel,
  });

  final String id;
  final String label;
  final IconData icon;
  final String workLabel;
  final String milestoneLabel;
  final String riskLabel;
  final String scheduleLabel;
  final String scheduleItemLabel;
  final String budgetLabel;
  final String ownerLabel;
  final String readinessLabel;
  final String audienceLabel;

  static const general = ProjectStatusUpdateVocabulary(
    id: 'general',
    label: 'General',
    icon: Icons.workspaces_outline,
    workLabel: 'project',
    milestoneLabel: 'milestone',
    riskLabel: 'risk',
    scheduleLabel: 'timeline',
    scheduleItemLabel: 'task',
    budgetLabel: 'budget',
    ownerLabel: 'owner',
    readinessLabel: 'readiness',
    audienceLabel: 'stakeholder update',
  );

  static const construction = ProjectStatusUpdateVocabulary(
    id: 'construction',
    label: 'Construction',
    icon: Icons.construction_outlined,
    workLabel: 'site build',
    milestoneLabel: 'phase gate',
    riskLabel: 'site constraint',
    scheduleLabel: 'site schedule',
    scheduleItemLabel: 'work package',
    budgetLabel: 'cost plan',
    ownerLabel: 'site lead',
    readinessLabel: 'mobilization readiness',
    audienceLabel: 'site steering update',
  );

  static const software = ProjectStatusUpdateVocabulary(
    id: 'software',
    label: 'Software',
    icon: Icons.code_outlined,
    workLabel: 'product release',
    milestoneLabel: 'release checkpoint',
    riskLabel: 'delivery risk',
    scheduleLabel: 'release plan',
    scheduleItemLabel: 'work item',
    budgetLabel: 'burn plan',
    ownerLabel: 'delivery owner',
    readinessLabel: 'release readiness',
    audienceLabel: 'delivery review',
  );

  static const eventProduction = ProjectStatusUpdateVocabulary(
    id: 'event-production',
    label: 'Event',
    icon: Icons.event_outlined,
    workLabel: 'event production',
    milestoneLabel: 'run-of-show checkpoint',
    riskLabel: 'production risk',
    scheduleLabel: 'run sheet',
    scheduleItemLabel: 'production task',
    budgetLabel: 'event budget',
    ownerLabel: 'producer',
    readinessLabel: 'show readiness',
    audienceLabel: 'production update',
  );

  static const government = ProjectStatusUpdateVocabulary(
    id: 'government',
    label: 'Government',
    icon: Icons.account_balance_outlined,
    workLabel: 'public program',
    milestoneLabel: 'approval gate',
    riskLabel: 'compliance risk',
    scheduleLabel: 'program calendar',
    scheduleItemLabel: 'program action',
    budgetLabel: 'funding plan',
    ownerLabel: 'program owner',
    readinessLabel: 'implementation readiness',
    audienceLabel: 'governance update',
  );

  static const education = ProjectStatusUpdateVocabulary(
    id: 'education',
    label: 'Education',
    icon: Icons.school_outlined,
    workLabel: 'education program',
    milestoneLabel: 'academic checkpoint',
    riskLabel: 'program risk',
    scheduleLabel: 'academic calendar',
    scheduleItemLabel: 'learning operations task',
    budgetLabel: 'program budget',
    ownerLabel: 'program lead',
    readinessLabel: 'program readiness',
    audienceLabel: 'academic operations update',
  );

  static const wedding = ProjectStatusUpdateVocabulary(
    id: 'wedding',
    label: 'Wedding',
    icon: Icons.celebration_outlined,
    workLabel: 'wedding production',
    milestoneLabel: 'planning checkpoint',
    riskLabel: 'vendor risk',
    scheduleLabel: 'wedding timeline',
    scheduleItemLabel: 'planning task',
    budgetLabel: 'wedding budget',
    ownerLabel: 'planner',
    readinessLabel: 'event readiness',
    audienceLabel: 'client planning update',
  );

  static const retailOperations = ProjectStatusUpdateVocabulary(
    id: 'retail-operations',
    label: 'Retail',
    icon: Icons.storefront_outlined,
    workLabel: 'store rollout',
    milestoneLabel: 'launch checkpoint',
    riskLabel: 'store readiness risk',
    scheduleLabel: 'rollout calendar',
    scheduleItemLabel: 'store task',
    budgetLabel: 'rollout budget',
    ownerLabel: 'store rollout owner',
    readinessLabel: 'launch readiness',
    audienceLabel: 'retail operations update',
  );

  static const defaults = [
    general,
    construction,
    software,
    eventProduction,
    government,
    education,
    wedding,
    retailOperations,
  ];

  @override
  bool operator ==(Object other) {
    return other is ProjectStatusUpdateVocabulary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ProjectStatusUpdateBrief {
  const ProjectStatusUpdateBrief({
    required this.vocabulary,
    required this.audience,
    required this.signal,
    required this.headline,
    required this.summary,
    required this.draftText,
    required this.progressPercent,
    required this.budgetPercent,
    required this.readinessScore,
    required this.scheduleProgressPercent,
    required this.highlights,
    required this.watchItems,
    required this.nextActions,
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final ProjectStatusUpdateSignal signal;
  final String headline;
  final String summary;
  final String draftText;
  final int progressPercent;
  final int budgetPercent;
  final int readinessScore;
  final int scheduleProgressPercent;
  final List<String> highlights;
  final List<String> watchItems;
  final List<String> nextActions;
}

extension ProjectStatusUpdateAudiencePresentation
    on ProjectStatusUpdateAudience {
  String get id {
    switch (this) {
      case ProjectStatusUpdateAudience.stakeholder:
        return 'stakeholder';
      case ProjectStatusUpdateAudience.sponsor:
        return 'sponsor';
      case ProjectStatusUpdateAudience.team:
        return 'team';
      case ProjectStatusUpdateAudience.client:
        return 'client';
    }
  }

  String get label {
    switch (this) {
      case ProjectStatusUpdateAudience.stakeholder:
        return 'Stakeholder';
      case ProjectStatusUpdateAudience.sponsor:
        return 'Sponsor';
      case ProjectStatusUpdateAudience.team:
        return 'Team';
      case ProjectStatusUpdateAudience.client:
        return 'Client';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectStatusUpdateAudience.stakeholder:
        return Icons.diversity_3_outlined;
      case ProjectStatusUpdateAudience.sponsor:
        return Icons.verified_user_outlined;
      case ProjectStatusUpdateAudience.team:
        return Icons.groups_outlined;
      case ProjectStatusUpdateAudience.client:
        return Icons.handshake_outlined;
    }
  }

  String summaryLabel(ProjectStatusUpdateVocabulary vocabulary) {
    switch (this) {
      case ProjectStatusUpdateAudience.stakeholder:
        return vocabulary.audienceLabel;
      case ProjectStatusUpdateAudience.sponsor:
        return 'sponsor decision update';
      case ProjectStatusUpdateAudience.team:
        return '${vocabulary.scheduleLabel} team sync';
      case ProjectStatusUpdateAudience.client:
        return 'client delivery update';
    }
  }
}

extension ProjectStatusUpdateSignalPresentation on ProjectStatusUpdateSignal {
  String get label {
    switch (this) {
      case ProjectStatusUpdateSignal.blocked:
        return 'Blocked';
      case ProjectStatusUpdateSignal.attention:
        return 'Needs Attention';
      case ProjectStatusUpdateSignal.watch:
        return 'Watch';
      case ProjectStatusUpdateSignal.steady:
        return 'Steady';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectStatusUpdateSignal.blocked:
        return Icons.block_outlined;
      case ProjectStatusUpdateSignal.attention:
        return Icons.priority_high_rounded;
      case ProjectStatusUpdateSignal.watch:
        return Icons.visibility_outlined;
      case ProjectStatusUpdateSignal.steady:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectStatusUpdateSignal.blocked:
        return colorScheme.error;
      case ProjectStatusUpdateSignal.attention:
        return Colors.orange.shade700;
      case ProjectStatusUpdateSignal.watch:
        return colorScheme.primary;
      case ProjectStatusUpdateSignal.steady:
        return Colors.green.shade700;
    }
  }
}

ProjectStatusUpdateBrief buildProjectStatusUpdateBrief({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  List<gantt.GanttTask>? dependencyTasks,
  ProjectStatusUpdateVocabulary vocabulary =
      ProjectStatusUpdateVocabulary.general,
  ProjectStatusUpdateAudience audience =
      ProjectStatusUpdateAudience.stakeholder,
  DateTime? today,
}) {
  final readiness = buildProjectReadinessScoreSummary(
    project: project,
    timelineTasks: timelineTasks,
    today: today,
  );
  final timeline = buildProjectTimelineHealthRollup(
    tasks: timelineTasks,
    dependencyTasks: dependencyTasks,
    today: today,
  );
  final milestones = buildProjectMilestoneTimelineSummary(
    milestones: project.milestones,
    today: today,
  );
  final handoff = buildProjectHandoffBrief(
    project: project,
    timelineTasks: timelineTasks,
    today: today,
  );
  final signal = _statusSignal(
    project: project,
    readiness: readiness,
    timeline: timeline,
    milestones: milestones,
    handoff: handoff,
  );
  final progressPercent = (project.progress * 100).round();
  final budgetPercent = (project.budgetUsed * 100).round();
  final scheduleProgressPercent = (timeline.averageProgress * 100).round();
  final headline =
      '${project.name} ${vocabulary.workLabel} is ${signal.label.toLowerCase()} for ${project.client}.';
  final summary =
      '${audience.summaryLabel(vocabulary)}: $progressPercent% complete, $budgetPercent% ${vocabulary.budgetLabel} used, ${readiness.score}/100 ${vocabulary.readinessLabel}.';
  final highlights = _highlights(
    project: project,
    timeline: timeline,
    milestones: milestones,
    vocabulary: vocabulary,
  );
  final watchItems = _watchItems(
    project: project,
    timeline: timeline,
    milestones: milestones,
    vocabulary: vocabulary,
  );
  final nextActions = _nextActions(
    project: project,
    milestones: milestones,
    handoff: handoff,
    vocabulary: vocabulary,
    audience: audience,
  );

  return ProjectStatusUpdateBrief(
    vocabulary: vocabulary,
    audience: audience,
    signal: signal,
    headline: headline,
    summary: summary,
    draftText: _draftText(
      headline: headline,
      summary: summary,
      audience: audience,
      highlights: highlights,
      watchItems: watchItems,
      nextActions: nextActions,
    ),
    progressPercent: progressPercent,
    budgetPercent: budgetPercent,
    readinessScore: readiness.score,
    scheduleProgressPercent: scheduleProgressPercent,
    highlights: highlights,
    watchItems: watchItems,
    nextActions: nextActions,
  );
}

ProjectStatusUpdateSignal _statusSignal({
  required ProjectPortfolioItem project,
  required ProjectReadinessScoreSummary readiness,
  required ProjectTimelineHealthRollup timeline,
  required ProjectMilestoneTimelineSummary milestones,
  required ProjectHandoffBrief handoff,
}) {
  if (project.health == ProjectHealth.blocked ||
      readiness.level == ProjectReadinessLevel.blocked ||
      handoff.urgency == ProjectHandoffUrgency.blocked) {
    return ProjectStatusUpdateSignal.blocked;
  }

  if (readiness.level == ProjectReadinessLevel.constrained ||
      timeline.hasAttention ||
      milestones.overdueCount > 0 ||
      project.budgetUsed - project.progress >= 0.15) {
    return ProjectStatusUpdateSignal.attention;
  }

  if (milestones.dueSoonCount > 0 ||
      handoff.urgency == ProjectHandoffUrgency.watch) {
    return ProjectStatusUpdateSignal.watch;
  }

  return ProjectStatusUpdateSignal.steady;
}

List<String> _highlights({
  required ProjectPortfolioItem project,
  required ProjectTimelineHealthRollup timeline,
  required ProjectMilestoneTimelineSummary milestones,
  required ProjectStatusUpdateVocabulary vocabulary,
}) {
  return [
    '${(project.progress * 100).round()}% ${vocabulary.workLabel} progress with ${(project.budgetUsed * 100).round()}% ${vocabulary.budgetLabel} used.',
    timeline.totalTasks == 0
        ? 'No linked ${vocabulary.scheduleItemLabel}s in the ${vocabulary.scheduleLabel}.'
        : '${timeline.completeCount}/${timeline.totalTasks} ${vocabulary.scheduleItemLabel}s complete in the ${vocabulary.scheduleLabel}.',
    '${milestones.doneCount}/${milestones.totalCount} ${vocabulary.milestoneLabel}s complete.',
  ];
}

List<String> _watchItems({
  required ProjectPortfolioItem project,
  required ProjectTimelineHealthRollup timeline,
  required ProjectMilestoneTimelineSummary milestones,
  required ProjectStatusUpdateVocabulary vocabulary,
}) {
  final items = <String>[];
  final activeRisks = project.risks.where(
    (risk) => risk.severity != ProjectHealth.onTrack,
  );
  final topRisk = activeRisks.isEmpty ? null : activeRisks.first;
  final nextMilestone = milestones.nextOpenItem;

  if (topRisk != null) {
    items.add('${vocabulary.riskLabel}: ${topRisk.title} - ${topRisk.detail}');
  }
  if (timeline.overdueCount > 0) {
    items.add(
      '${timeline.overdueCount} overdue ${vocabulary.scheduleItemLabel}${timeline.overdueCount == 1 ? '' : 's'} in the ${vocabulary.scheduleLabel}.',
    );
  }
  if (timeline.dependencyBlockCount > 0) {
    items.add(
      '${timeline.dependencyBlockCount} dependency block${timeline.dependencyBlockCount == 1 ? '' : 's'} in the ${vocabulary.scheduleLabel}.',
    );
  }
  if (nextMilestone != null) {
    items.add(
      '${vocabulary.milestoneLabel}: ${nextMilestone.label} - ${nextMilestone.dueLabel}.',
    );
  }
  if (project.budgetUsed - project.progress >= 0.15) {
    items.add(
      '${vocabulary.budgetLabel}: ${(project.budgetUsed * 100).round()}% used against ${(project.progress * 100).round()}% progress.',
    );
  }

  if (items.isEmpty) {
    items.add('No active ${vocabulary.riskLabel}s or schedule alerts.');
  }

  return List.unmodifiable(items);
}

List<String> _nextActions({
  required ProjectPortfolioItem project,
  required ProjectMilestoneTimelineSummary milestones,
  required ProjectHandoffBrief handoff,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
}) {
  final actions = <String>[
    'Confirm ${vocabulary.ownerLabel} handoff with ${project.owner}.',
  ];
  final nextMilestone = milestones.nextOpenItem;
  final audienceAction = _audienceAction(
    project: project,
    vocabulary: vocabulary,
    audience: audience,
  );

  if (handoff.topRisk != null) {
    actions.add(
      'Resolve ${vocabulary.riskLabel.toLowerCase()}: ${handoff.topRisk!.title}.',
    );
  }
  if (nextMilestone != null) {
    actions.add(
      'Prepare ${vocabulary.milestoneLabel.toLowerCase()}: ${nextMilestone.label}.',
    );
  }
  if (project.budgetUsed - project.progress >= 0.15) {
    actions.add('Review ${vocabulary.budgetLabel} against progress baseline.');
  }
  if (audienceAction != null) {
    actions.add(audienceAction);
  }

  return List.unmodifiable(actions);
}

String? _audienceAction({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
}) {
  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return null;
    case ProjectStatusUpdateAudience.sponsor:
      return 'Confirm decision path and escalation owner with ${project.sponsor}.';
    case ProjectStatusUpdateAudience.team:
      return 'Assign next ${vocabulary.scheduleItemLabel} owners before the next execution sync.';
    case ProjectStatusUpdateAudience.client:
      return 'Prepare client-facing note on ${vocabulary.milestoneLabel} timing and ${vocabulary.riskLabel} handling.';
  }
}

String _draftText({
  required String headline,
  required String summary,
  required ProjectStatusUpdateAudience audience,
  required List<String> highlights,
  required List<String> watchItems,
  required List<String> nextActions,
}) {
  return [
    if (audience != ProjectStatusUpdateAudience.stakeholder)
      'Audience: ${audience.label}',
    if (audience != ProjectStatusUpdateAudience.stakeholder) '',
    headline,
    summary,
    '',
    'Highlights',
    for (final item in highlights) '- $item',
    '',
    'Watch items',
    for (final item in watchItems) '- $item',
    '',
    'Next actions',
    for (final item in nextActions) '- $item',
  ].join('\n');
}
