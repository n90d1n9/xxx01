import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_action_plan_service.dart';
import 'project_decision_register_service.dart';

/// Operating cadence signal for project decision review and escalation.
enum ProjectDecisionCadenceSignal { immediate, accelerated, routine }

/// Decision cadence work type used to organize review agenda items.
enum ProjectDecisionCadenceItemKind {
  review,
  escalation,
  ownerSync,
  evidence,
  domain,
}

/// Agenda item for keeping decision review and escalation work on rhythm.
class ProjectDecisionCadenceItem {
  const ProjectDecisionCadenceItem({
    required this.title,
    required this.detail,
    required this.owner,
    required this.cadenceLabel,
    required this.kind,
    required this.signal,
    this.dueDate,
  });

  final String title;
  final String detail;
  final String owner;
  final String cadenceLabel;
  final ProjectDecisionCadenceItemKind kind;
  final ProjectDecisionCadenceSignal signal;
  final DateTime? dueDate;

  String get dueDateLabel {
    final date = dueDate;
    if (date == null) return '';

    return 'Due ${_dateLabel(date)}';
  }
}

/// Decision cadence plan with review rhythm, escalation window, and agenda text.
class ProjectDecisionCadenceSummary {
  const ProjectDecisionCadenceSummary({
    required this.register,
    required this.actionPlan,
    required this.signal,
    required this.title,
    required this.subtitle,
    required this.reviewCadenceLabel,
    required this.cadenceMetricLabel,
    required this.escalationWindowLabel,
    required this.nextReviewDate,
    required this.items,
    required this.agendaText,
  });

  final ProjectDecisionRegisterSummary register;
  final ProjectDecisionActionPlanSummary actionPlan;
  final ProjectDecisionCadenceSignal signal;
  final String title;
  final String subtitle;
  final String reviewCadenceLabel;
  final String cadenceMetricLabel;
  final String escalationWindowLabel;
  final DateTime nextReviewDate;
  final List<ProjectDecisionCadenceItem> items;
  final String agendaText;

  int get itemCount => items.length;
  int get ownerCount => actionPlan.ownerCount;
  int get immediateCount =>
      items
          .where(
            (item) => item.signal == ProjectDecisionCadenceSignal.immediate,
          )
          .length;
  int get acceleratedCount =>
      items
          .where(
            (item) => item.signal == ProjectDecisionCadenceSignal.accelerated,
          )
          .length;
}

/// Builds a review cadence and agenda from the project decision register.
ProjectDecisionCadenceSummary buildProjectDecisionCadenceSummary({
  required ProjectDecisionRegisterSummary registerSummary,
  required ProjectDecisionActionPlanSummary actionPlanSummary,
}) {
  final signal = _cadenceSignal(registerSummary, actionPlanSummary);
  final nextReviewDate = _nextReviewDate(registerSummary.today, signal);
  final reviewCadenceLabel = _reviewCadenceLabel(signal);
  final cadenceMetricLabel = _cadenceMetricLabel(signal);
  final escalationWindowLabel = _escalationWindowLabel(signal);
  final items = _cadenceItems(
    registerSummary: registerSummary,
    actionPlanSummary: actionPlanSummary,
    signal: signal,
    nextReviewDate: nextReviewDate,
  );
  final title = _title(signal);
  final subtitle =
      '$reviewCadenceLabel - $escalationWindowLabel - ${registerSummary.openCount} open decisions';
  final agendaText = _agendaText(
    projectName: registerSummary.project.name,
    signal: signal,
    reviewCadenceLabel: reviewCadenceLabel,
    escalationWindowLabel: escalationWindowLabel,
    nextReviewDate: nextReviewDate,
    items: items,
  );

  return ProjectDecisionCadenceSummary(
    register: registerSummary,
    actionPlan: actionPlanSummary,
    signal: signal,
    title: title,
    subtitle: subtitle,
    reviewCadenceLabel: reviewCadenceLabel,
    cadenceMetricLabel: cadenceMetricLabel,
    escalationWindowLabel: escalationWindowLabel,
    nextReviewDate: nextReviewDate,
    items: List.unmodifiable(items),
    agendaText: agendaText,
  );
}

ProjectDecisionCadenceSignal _cadenceSignal(
  ProjectDecisionRegisterSummary registerSummary,
  ProjectDecisionActionPlanSummary actionPlanSummary,
) {
  if (registerSummary.overdueCount > 0 ||
      registerSummary.blockedCount > 0 ||
      actionPlanSummary.signal == ProjectDecisionOwnerSignal.critical) {
    return ProjectDecisionCadenceSignal.immediate;
  }
  if (registerSummary.awaitingDecisionCount > 0 ||
      registerSummary.openCount > 0) {
    return ProjectDecisionCadenceSignal.accelerated;
  }

  return ProjectDecisionCadenceSignal.routine;
}

DateTime _nextReviewDate(DateTime today, ProjectDecisionCadenceSignal signal) {
  switch (signal) {
    case ProjectDecisionCadenceSignal.immediate:
      return today;
    case ProjectDecisionCadenceSignal.accelerated:
      return today.add(const Duration(days: 1));
    case ProjectDecisionCadenceSignal.routine:
      return today.add(const Duration(days: 7));
  }
}

String _reviewCadenceLabel(ProjectDecisionCadenceSignal signal) {
  switch (signal) {
    case ProjectDecisionCadenceSignal.immediate:
      return 'Daily until blockers clear';
    case ProjectDecisionCadenceSignal.accelerated:
      return 'Twice-weekly decision review';
    case ProjectDecisionCadenceSignal.routine:
      return 'Weekly governance review';
  }
}

String _cadenceMetricLabel(ProjectDecisionCadenceSignal signal) {
  switch (signal) {
    case ProjectDecisionCadenceSignal.immediate:
      return 'Daily';
    case ProjectDecisionCadenceSignal.accelerated:
      return '2x weekly';
    case ProjectDecisionCadenceSignal.routine:
      return 'Weekly';
  }
}

String _escalationWindowLabel(ProjectDecisionCadenceSignal signal) {
  switch (signal) {
    case ProjectDecisionCadenceSignal.immediate:
      return 'Escalate today';
    case ProjectDecisionCadenceSignal.accelerated:
      return 'Escalate if owner action slips 48h';
    case ProjectDecisionCadenceSignal.routine:
      return 'Escalate at next milestone gate';
  }
}

String _title(ProjectDecisionCadenceSignal signal) {
  switch (signal) {
    case ProjectDecisionCadenceSignal.immediate:
      return 'Decision cadence needs recovery';
    case ProjectDecisionCadenceSignal.accelerated:
      return 'Decision cadence needs review';
    case ProjectDecisionCadenceSignal.routine:
      return 'Decision cadence steady';
  }
}

List<ProjectDecisionCadenceItem> _cadenceItems({
  required ProjectDecisionRegisterSummary registerSummary,
  required ProjectDecisionActionPlanSummary actionPlanSummary,
  required ProjectDecisionCadenceSignal signal,
  required DateTime nextReviewDate,
}) {
  final primaryOwner = actionPlanSummary.primaryAction;
  final projectOwner =
      registerSummary.project.owner.trim().isEmpty
          ? 'Project Owner'
          : registerSummary.project.owner.trim();
  final items = <ProjectDecisionCadenceItem>[
    ProjectDecisionCadenceItem(
      title: 'Run decision review',
      detail:
          'Review open decisions, owner blockers, governance route, and proof needed before the next delivery checkpoint.',
      owner: primaryOwner?.owner ?? projectOwner,
      cadenceLabel: _reviewCadenceLabel(signal),
      kind: ProjectDecisionCadenceItemKind.review,
      signal: signal,
      dueDate: nextReviewDate,
    ),
  ];

  if (registerSummary.overdueCount > 0 || registerSummary.blockedCount > 0) {
    items.add(
      ProjectDecisionCadenceItem(
        title: 'Escalate blocked decisions',
        detail:
            '${registerSummary.blockedCount} blocked and ${registerSummary.overdueCount} overdue decisions need sponsor review before cadence can relax.',
        owner: primaryOwner?.owner ?? projectOwner,
        cadenceLabel: 'Same-day escalation',
        kind: ProjectDecisionCadenceItemKind.escalation,
        signal: ProjectDecisionCadenceSignal.immediate,
        dueDate: registerSummary.today,
      ),
    );
  }

  if (primaryOwner != null) {
    items.add(
      ProjectDecisionCadenceItem(
        title: 'Clear owner next action',
        detail:
            '${primaryOwner.owner} owns ${primaryOwner.openCount} open decision actions; next focus is ${primaryOwner.nextStepLabel}.',
        owner: primaryOwner.owner,
        cadenceLabel: _ownerCadenceLabel(signal),
        kind: ProjectDecisionCadenceItemKind.ownerSync,
        signal:
            primaryOwner.signal == ProjectDecisionOwnerSignal.critical
                ? ProjectDecisionCadenceSignal.immediate
                : signal,
        dueDate: primaryOwner.primaryRecord.dueDate ?? nextReviewDate,
      ),
    );
  }

  final evidenceRecord = _firstEvidenceRecord(registerSummary);
  if (evidenceRecord != null) {
    items.add(
      ProjectDecisionCadenceItem(
        title: 'Lock decision proof',
        detail:
            '${evidenceRecord.evidenceLabel} is needed for ${evidenceRecord.title}.',
        owner: evidenceRecord.owner,
        cadenceLabel: 'Confirm before closeout',
        kind: ProjectDecisionCadenceItemKind.evidence,
        signal:
            evidenceRecord.isOpen
                ? signal
                : ProjectDecisionCadenceSignal.routine,
        dueDate: evidenceRecord.dueDate ?? nextReviewDate,
      ),
    );
  }

  final domainCount =
      registerSummary.recordsFor(ProjectDecisionRegisterLens.domain).length;
  if (domainCount > 0) {
    items.add(
      ProjectDecisionCadenceItem(
        title: 'Refresh domain fields',
        detail:
            '$domainCount domain field records should stay aligned with decisions and evidence for ${registerSummary.project.businessDomain}.',
        owner: projectOwner,
        cadenceLabel: 'Review with governance update',
        kind: ProjectDecisionCadenceItemKind.domain,
        signal: ProjectDecisionCadenceSignal.routine,
        dueDate: nextReviewDate,
      ),
    );
  }

  return items;
}

String _ownerCadenceLabel(ProjectDecisionCadenceSignal signal) {
  switch (signal) {
    case ProjectDecisionCadenceSignal.immediate:
      return 'Same-day owner sync';
    case ProjectDecisionCadenceSignal.accelerated:
      return 'Next owner sync';
    case ProjectDecisionCadenceSignal.routine:
      return 'Weekly owner check';
  }
}

ProjectDecisionRecord? _firstEvidenceRecord(
  ProjectDecisionRegisterSummary registerSummary,
) {
  for (final record in registerSummary.records) {
    if (record.evidenceLabel.trim().isNotEmpty) return record;
  }

  return null;
}

String _agendaText({
  required String projectName,
  required ProjectDecisionCadenceSignal signal,
  required String reviewCadenceLabel,
  required String escalationWindowLabel,
  required DateTime nextReviewDate,
  required List<ProjectDecisionCadenceItem> items,
}) {
  return [
    '$projectName decision cadence agenda',
    'Signal: ${signal.label}',
    'Cadence: $reviewCadenceLabel',
    'Next review: ${_dateLabel(nextReviewDate)}',
    'Escalation: $escalationWindowLabel',
    '',
    'Agenda:',
    for (final item in items)
      '- ${item.title}: ${item.owner} - ${item.cadenceLabel}',
  ].join('\n');
}

String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

extension ProjectDecisionCadenceSignalPresentation
    on ProjectDecisionCadenceSignal {
  /// User-facing label for a project decision cadence signal.
  String get label {
    switch (this) {
      case ProjectDecisionCadenceSignal.immediate:
        return 'Immediate';
      case ProjectDecisionCadenceSignal.accelerated:
        return 'Accelerated';
      case ProjectDecisionCadenceSignal.routine:
        return 'Routine';
    }
  }

  /// Icon for a project decision cadence signal.
  IconData get icon {
    switch (this) {
      case ProjectDecisionCadenceSignal.immediate:
        return Icons.priority_high_rounded;
      case ProjectDecisionCadenceSignal.accelerated:
        return Icons.event_repeat_outlined;
      case ProjectDecisionCadenceSignal.routine:
        return Icons.event_available_outlined;
    }
  }

  /// Color for a project decision cadence signal.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionCadenceSignal.immediate:
        return colorScheme.error;
      case ProjectDecisionCadenceSignal.accelerated:
        return Colors.orange.shade700;
      case ProjectDecisionCadenceSignal.routine:
        return Colors.green.shade700;
    }
  }
}

extension ProjectDecisionCadenceItemKindPresentation
    on ProjectDecisionCadenceItemKind {
  /// User-facing label for a project decision cadence item kind.
  String get label {
    switch (this) {
      case ProjectDecisionCadenceItemKind.review:
        return 'Review';
      case ProjectDecisionCadenceItemKind.escalation:
        return 'Escalation';
      case ProjectDecisionCadenceItemKind.ownerSync:
        return 'Owner Sync';
      case ProjectDecisionCadenceItemKind.evidence:
        return 'Evidence';
      case ProjectDecisionCadenceItemKind.domain:
        return 'Domain';
    }
  }

  /// Icon for a project decision cadence item kind.
  IconData get icon {
    switch (this) {
      case ProjectDecisionCadenceItemKind.review:
        return Icons.event_repeat_outlined;
      case ProjectDecisionCadenceItemKind.escalation:
        return Icons.priority_high_rounded;
      case ProjectDecisionCadenceItemKind.ownerSync:
        return Icons.groups_outlined;
      case ProjectDecisionCadenceItemKind.evidence:
        return Icons.fact_check_outlined;
      case ProjectDecisionCadenceItemKind.domain:
        return Icons.extension_outlined;
    }
  }
}
