import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Due-date preset used by the decision intake form.
enum ProjectDecisionIntakeDueOption {
  today,
  nextReview,
  nextWeek,
  milestoneGate,
  unscheduled,
}

/// Validation issue emitted for a project decision intake draft.
class ProjectDecisionIntakeIssue {
  const ProjectDecisionIntakeIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable draft collected by the project decision intake form.
class ProjectDecisionIntakeDraft {
  const ProjectDecisionIntakeDraft({
    required this.projectId,
    required this.domainLabel,
    required this.title,
    required this.detail,
    required this.owner,
    required this.source,
    required this.status,
    required this.priority,
    required this.dueOption,
    this.evidenceLabel = '',
  });

  final String projectId;
  final String domainLabel;
  final String title;
  final String detail;
  final String owner;
  final ProjectDecisionSource source;
  final ProjectDecisionStatus status;
  final ProjectDecisionPriority priority;
  final ProjectDecisionIntakeDueOption dueOption;
  final String evidenceLabel;

  /// Creates an empty intake draft seeded from the selected project context.
  factory ProjectDecisionIntakeDraft.initial(
    ProjectDecisionRegisterSummary register,
  ) {
    final project = register.project;

    return ProjectDecisionIntakeDraft(
      projectId: project.id,
      domainLabel: project.businessDomain,
      title: '',
      detail: '',
      owner: project.owner.trim().isEmpty ? 'Project Owner' : project.owner,
      source: ProjectDecisionSource.governance,
      status: ProjectDecisionStatus.awaitingDecision,
      priority: ProjectDecisionPriority.medium,
      dueOption: ProjectDecisionIntakeDueOption.nextReview,
    );
  }

  ProjectDecisionIntakeDraft copyWith({
    String? title,
    String? detail,
    String? owner,
    ProjectDecisionSource? source,
    ProjectDecisionStatus? status,
    ProjectDecisionPriority? priority,
    ProjectDecisionIntakeDueOption? dueOption,
    String? evidenceLabel,
  }) {
    return ProjectDecisionIntakeDraft(
      projectId: projectId,
      domainLabel: domainLabel,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      owner: owner ?? this.owner,
      source: source ?? this.source,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueOption: dueOption ?? this.dueOption,
      evidenceLabel: evidenceLabel ?? this.evidenceLabel,
    );
  }
}

/// Submitted decision draft held by the local demo intake queue.
class ProjectDecisionIntakeSubmission {
  const ProjectDecisionIntakeSubmission({
    required this.record,
    required this.submittedAt,
    required this.routeLabel,
    required this.summaryText,
  });

  final ProjectDecisionRecord record;
  final DateTime submittedAt;
  final String routeLabel;
  final String summaryText;
}

/// Service for validating decision drafts and building queue submissions.
class ProjectDecisionIntakeService {
  const ProjectDecisionIntakeService();

  List<ProjectDecisionIntakeIssue> validate(ProjectDecisionIntakeDraft draft) {
    final issues = <ProjectDecisionIntakeIssue>[];

    void requireText(String field, String value, String label) {
      if (value.trim().isEmpty) {
        issues.add(
          ProjectDecisionIntakeIssue(
            field: field,
            message: '$label is required.',
          ),
        );
      }
    }

    requireText('title', draft.title, 'Decision title');
    requireText('detail', draft.detail, 'Decision context');
    requireText('owner', draft.owner, 'Decision owner');

    if (draft.title.trim().isNotEmpty && draft.title.trim().length < 8) {
      issues.add(
        const ProjectDecisionIntakeIssue(
          field: 'title',
          message: 'Decision title should be specific.',
        ),
      );
    }
    if (draft.detail.trim().isNotEmpty && draft.detail.trim().length < 20) {
      issues.add(
        const ProjectDecisionIntakeIssue(
          field: 'detail',
          message: 'Decision context should explain the trade-off.',
        ),
      );
    }
    if (draft.priority == ProjectDecisionPriority.critical &&
        draft.dueOption == ProjectDecisionIntakeDueOption.unscheduled) {
      issues.add(
        const ProjectDecisionIntakeIssue(
          field: 'dueOption',
          message: 'Critical decisions need a due date.',
        ),
      );
    }
    if ((draft.status == ProjectDecisionStatus.approved ||
            draft.status == ProjectDecisionStatus.completed) &&
        draft.evidenceLabel.trim().isEmpty) {
      issues.add(
        const ProjectDecisionIntakeIssue(
          field: 'evidence',
          message: 'Closed decisions need evidence.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  bool canSubmit(ProjectDecisionIntakeDraft draft) => validate(draft).isEmpty;

  ProjectDecisionIntakeSubmission submit({
    required ProjectDecisionRegisterSummary register,
    required ProjectDecisionIntakeDraft draft,
    required int queueIndex,
  }) {
    final issues = validate(draft);
    if (issues.isNotEmpty) {
      throw StateError('Decision intake draft is not ready to submit.');
    }

    final dueDate = dueDateFor(register: register, option: draft.dueOption);
    final record = ProjectDecisionRecord(
      id: _recordId(draft.title, queueIndex),
      projectId: draft.projectId,
      title: draft.title.trim(),
      detail: draft.detail.trim(),
      ownerLabel: _ownerLabelFor(draft),
      owner: draft.owner.trim(),
      status: draft.status,
      priority: draft.priority,
      source: draft.source,
      dueDate: dueDate,
      evidenceLabel: draft.evidenceLabel.trim(),
      domainLabel: draft.domainLabel,
      customAttributes: {
        'Route': routeLabelFor(draft),
        'Intake': 'Draft queue',
      },
    );

    return ProjectDecisionIntakeSubmission(
      record: record,
      submittedAt: register.today,
      routeLabel: routeLabelFor(draft),
      summaryText: _summaryText(record, draft),
    );
  }

  DateTime? dueDateFor({
    required ProjectDecisionRegisterSummary register,
    required ProjectDecisionIntakeDueOption option,
  }) {
    final today = DateUtils.dateOnly(register.today);
    switch (option) {
      case ProjectDecisionIntakeDueOption.today:
        return today;
      case ProjectDecisionIntakeDueOption.nextReview:
        return today.add(const Duration(days: 2));
      case ProjectDecisionIntakeDueOption.nextWeek:
        return today.add(const Duration(days: 7));
      case ProjectDecisionIntakeDueOption.milestoneGate:
        return _nextOpenMilestoneDate(register) ?? register.project.endDate;
      case ProjectDecisionIntakeDueOption.unscheduled:
        return null;
    }
  }

  String routeLabelFor(ProjectDecisionIntakeDraft draft) {
    if (draft.priority == ProjectDecisionPriority.critical ||
        draft.status == ProjectDecisionStatus.blocked ||
        draft.owner.toLowerCase().contains('sponsor')) {
      return 'Sponsor route';
    }
    if (draft.status == ProjectDecisionStatus.inReview ||
        draft.status == ProjectDecisionStatus.approved) {
      return 'Approval route';
    }
    if (draft.status == ProjectDecisionStatus.delegated) {
      return 'Owner follow-through';
    }

    return 'Owner route';
  }
}

DateTime? _nextOpenMilestoneDate(ProjectDecisionRegisterSummary register) {
  final milestones = [
    for (final milestone in register.project.milestones)
      if (!milestone.isComplete) milestone,
  ]..sort((left, right) => left.dueDate.compareTo(right.dueDate));

  if (milestones.isEmpty) return null;

  return milestones.first.dueDate;
}

String _ownerLabelFor(ProjectDecisionIntakeDraft draft) {
  return draft.owner.toLowerCase().contains('sponsor') ? 'Sponsor' : 'Owner';
}

String _recordId(String title, int queueIndex) {
  final slug = title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  return 'intake-$queueIndex-${slug.isEmpty ? 'decision' : slug}';
}

String _summaryText(
  ProjectDecisionRecord record,
  ProjectDecisionIntakeDraft draft,
) {
  return [
    'Decision intake draft',
    'Title: ${record.title}',
    'Owner: ${record.owner}',
    'Route: ${record.customAttributes['Route']}',
    'Status: ${record.status.label}',
    'Priority: ${record.priority.label}',
    'Source: ${record.source.label}',
    if (record.dueDateLabel.isNotEmpty) record.dueDateLabel,
    if (record.evidenceLabel.isNotEmpty) 'Evidence: ${record.evidenceLabel}',
    'Context: ${record.detail}',
    'Due preset: ${draft.dueOption.label}',
  ].join('\n');
}

extension ProjectDecisionIntakeDueOptionPresentation
    on ProjectDecisionIntakeDueOption {
  /// User-facing label for a decision intake due-date preset.
  String get label {
    switch (this) {
      case ProjectDecisionIntakeDueOption.today:
        return 'Today';
      case ProjectDecisionIntakeDueOption.nextReview:
        return 'Next review';
      case ProjectDecisionIntakeDueOption.nextWeek:
        return 'Next 7d';
      case ProjectDecisionIntakeDueOption.milestoneGate:
        return 'Milestone gate';
      case ProjectDecisionIntakeDueOption.unscheduled:
        return 'Unscheduled';
    }
  }

  /// Icon for a decision intake due-date preset.
  IconData get icon {
    switch (this) {
      case ProjectDecisionIntakeDueOption.today:
        return Icons.today_outlined;
      case ProjectDecisionIntakeDueOption.nextReview:
        return Icons.event_available_outlined;
      case ProjectDecisionIntakeDueOption.nextWeek:
        return Icons.date_range_outlined;
      case ProjectDecisionIntakeDueOption.milestoneGate:
        return Icons.flag_outlined;
      case ProjectDecisionIntakeDueOption.unscheduled:
        return Icons.event_note_outlined;
    }
  }
}
