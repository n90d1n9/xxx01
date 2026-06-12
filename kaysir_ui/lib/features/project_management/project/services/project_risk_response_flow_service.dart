import 'package:flutter/material.dart';

import 'project_risk_issue_workspace_service.dart';

/// Response mode applied to an active project risk or issue.
enum ProjectRiskResponseMode { mitigate, recover, escalate, accept }

/// Target timing option used by the risk response flow.
enum ProjectRiskResponseDueOption { today, next48Hours, thisWeek, governance }

/// Validation issue emitted for a risk response draft.
class ProjectRiskResponseIssue {
  const ProjectRiskResponseIssue({required this.field, required this.message});

  final String field;
  final String message;
}

/// Editable risk response draft for one risk or issue item.
class ProjectRiskResponseDraft {
  const ProjectRiskResponseDraft({
    required this.itemId,
    required this.mode,
    required this.title,
    required this.owner,
    required this.dueOption,
    required this.responseNote,
    required this.evidenceNote,
  });

  final String itemId;
  final ProjectRiskResponseMode mode;
  final String title;
  final String owner;
  final ProjectRiskResponseDueOption dueOption;
  final String responseNote;
  final String evidenceNote;

  ProjectRiskResponseDraft copyWith({
    String? itemId,
    ProjectRiskResponseMode? mode,
    String? title,
    String? owner,
    ProjectRiskResponseDueOption? dueOption,
    String? responseNote,
    String? evidenceNote,
  }) {
    return ProjectRiskResponseDraft(
      itemId: itemId ?? this.itemId,
      mode: mode ?? this.mode,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueOption: dueOption ?? this.dueOption,
      responseNote: responseNote ?? this.responseNote,
      evidenceNote: evidenceNote ?? this.evidenceNote,
    );
  }
}

/// Submitted local risk response for demo workflow history.
class ProjectRiskResponseSubmission {
  const ProjectRiskResponseSubmission({
    required this.sourceItem,
    required this.responseItem,
    required this.mode,
    required this.routeLabel,
    required this.dueDate,
    required this.submittedAt,
    required this.summaryText,
  });

  final ProjectRiskIssueItem sourceItem;
  final ProjectRiskIssueItem responseItem;
  final ProjectRiskResponseMode mode;
  final String routeLabel;
  final DateTime dueDate;
  final DateTime submittedAt;
  final String summaryText;
}

/// Service for validating and queueing risk response drafts.
class ProjectRiskResponseFlowService {
  const ProjectRiskResponseFlowService();

  List<ProjectRiskIssueItem> actionableItems(
    ProjectRiskIssueWorkspaceSummary summary,
  ) {
    final activeItems = [
      for (final item in summary.items)
        if (item.isActive) item,
    ];
    if (activeItems.isNotEmpty) return List.unmodifiable(activeItems);

    return summary.items;
  }

  ProjectRiskResponseDraft initialDraft(
    ProjectRiskIssueWorkspaceSummary summary,
  ) {
    final items = actionableItems(summary);
    if (items.isEmpty) {
      return const ProjectRiskResponseDraft(
        itemId: '',
        mode: ProjectRiskResponseMode.mitigate,
        title: '',
        owner: '',
        dueOption: ProjectRiskResponseDueOption.governance,
        responseNote: '',
        evidenceNote: '',
      );
    }

    return draftForItem(items.first);
  }

  ProjectRiskResponseDraft draftForItem(ProjectRiskIssueItem item) {
    return ProjectRiskResponseDraft(
      itemId: item.id,
      mode: recommendedMode(item),
      title: '',
      owner: item.ownerLabel,
      dueOption: recommendedDueOption(item),
      responseNote: '',
      evidenceNote: '',
    );
  }

  ProjectRiskIssueItem? itemFor(
    ProjectRiskIssueWorkspaceSummary summary,
    String itemId,
  ) {
    for (final item in summary.items) {
      if (item.id == itemId) return item;
    }

    return null;
  }

  ProjectRiskResponseMode recommendedMode(ProjectRiskIssueItem item) {
    if (item.level == ProjectRiskIssueLevel.critical) {
      return ProjectRiskResponseMode.escalate;
    }
    if (item.kind == ProjectRiskIssueKind.milestone ||
        item.kind == ProjectRiskIssueKind.budget ||
        item.kind == ProjectRiskIssueKind.cashFlow) {
      return ProjectRiskResponseMode.recover;
    }

    return ProjectRiskResponseMode.mitigate;
  }

  ProjectRiskResponseDueOption recommendedDueOption(ProjectRiskIssueItem item) {
    switch (item.level) {
      case ProjectRiskIssueLevel.critical:
        return ProjectRiskResponseDueOption.next48Hours;
      case ProjectRiskIssueLevel.watch:
        return ProjectRiskResponseDueOption.thisWeek;
      case ProjectRiskIssueLevel.stable:
        return ProjectRiskResponseDueOption.governance;
    }
  }

  ProjectRiskIssueLevel resultingLevelFor(ProjectRiskResponseMode mode) {
    switch (mode) {
      case ProjectRiskResponseMode.mitigate:
      case ProjectRiskResponseMode.recover:
        return ProjectRiskIssueLevel.watch;
      case ProjectRiskResponseMode.escalate:
        return ProjectRiskIssueLevel.critical;
      case ProjectRiskResponseMode.accept:
        return ProjectRiskIssueLevel.stable;
    }
  }

  String routeLabelFor({
    required ProjectRiskIssueItem item,
    required ProjectRiskResponseMode mode,
  }) {
    if (mode == ProjectRiskResponseMode.escalate ||
        item.level == ProjectRiskIssueLevel.critical) {
      return 'Executive escalation';
    }
    if (mode == ProjectRiskResponseMode.accept) return 'Risk acceptance';

    switch (item.kind) {
      case ProjectRiskIssueKind.budget:
      case ProjectRiskIssueKind.authority:
      case ProjectRiskIssueKind.cashFlow:
        return 'Finance recovery';
      case ProjectRiskIssueKind.evidence:
        return 'Evidence recovery';
      case ProjectRiskIssueKind.milestone:
        return 'Milestone recovery';
      case ProjectRiskIssueKind.blocker:
      case ProjectRiskIssueKind.deliveryRisk:
      case ProjectRiskIssueKind.financeControl:
        return mode == ProjectRiskResponseMode.recover
            ? 'Recovery route'
            : 'Mitigation review';
    }
  }

  DateTime dueDateFor(ProjectRiskResponseDueOption option) {
    final today = DateUtils.dateOnly(DateTime.now());
    switch (option) {
      case ProjectRiskResponseDueOption.today:
        return today;
      case ProjectRiskResponseDueOption.next48Hours:
        return today.add(const Duration(days: 2));
      case ProjectRiskResponseDueOption.thisWeek:
        return today.add(const Duration(days: 7));
      case ProjectRiskResponseDueOption.governance:
        return today.add(const Duration(days: 14));
    }
  }

  List<ProjectRiskResponseIssue> validate({
    required ProjectRiskIssueWorkspaceSummary summary,
    required ProjectRiskResponseDraft draft,
  }) {
    final issues = <ProjectRiskResponseIssue>[];
    final item = itemFor(summary, draft.itemId);
    if (item == null) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'item',
          message: 'Select a risk or issue to respond to.',
        ),
      );
    }

    final title = draft.title.trim();
    if (title.isEmpty) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'title',
          message: 'Risk response title is required.',
        ),
      );
    } else if (title.length < 8) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'title',
          message: 'Risk response title should be specific.',
        ),
      );
    }

    if (draft.owner.trim().isEmpty) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'owner',
          message: 'Response owner is required.',
        ),
      );
    }

    final responseNote = draft.responseNote.trim();
    if (responseNote.isEmpty) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'response',
          message: 'Response note is required.',
        ),
      );
    } else if (responseNote.length < 20) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'response',
          message: 'Response note should explain the mitigation or recovery.',
        ),
      );
    }

    final evidenceNote = draft.evidenceNote.trim();
    if (evidenceNote.isEmpty) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'evidence',
          message: 'Evidence note is required.',
        ),
      );
    } else if (evidenceNote.length < 20) {
      issues.add(
        const ProjectRiskResponseIssue(
          field: 'evidence',
          message: 'Evidence note should explain the response proof.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectRiskResponseSubmission submit({
    required ProjectRiskIssueWorkspaceSummary summary,
    required ProjectRiskResponseDraft draft,
    required int queueIndex,
  }) {
    final issues = validate(summary: summary, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Risk response draft is not ready to submit.');
    }

    final sourceItem = itemFor(summary, draft.itemId)!;
    final routeLabel = routeLabelFor(item: sourceItem, mode: draft.mode);
    final resultingLevel = resultingLevelFor(draft.mode);
    final dueDate = dueDateFor(draft.dueOption);
    final responseItem = ProjectRiskIssueItem(
      id: _responseId(summary.projectName, draft.title, queueIndex),
      title: draft.title.trim(),
      detail: draft.responseNote.trim(),
      kind: sourceItem.kind,
      level: resultingLevel,
      icon: draft.mode.icon,
      ownerLabel: draft.owner.trim(),
      evidenceLabel: draft.evidenceNote.trim(),
      actionLabel: routeLabel,
      sourceLabel: sourceItem.title,
    );

    return ProjectRiskResponseSubmission(
      sourceItem: sourceItem,
      responseItem: responseItem,
      mode: draft.mode,
      routeLabel: routeLabel,
      dueDate: dueDate,
      submittedAt: DateUtils.dateOnly(DateTime.now()),
      summaryText: _summaryText(
        summary: summary,
        sourceItem: sourceItem,
        responseItem: responseItem,
        mode: draft.mode,
        routeLabel: routeLabel,
        dueDate: dueDate,
      ),
    );
  }
}

String _summaryText({
  required ProjectRiskIssueWorkspaceSummary summary,
  required ProjectRiskIssueItem sourceItem,
  required ProjectRiskIssueItem responseItem,
  required ProjectRiskResponseMode mode,
  required String routeLabel,
  required DateTime dueDate,
}) {
  return [
    'Risk response',
    'Project: ${summary.projectName}',
    'Issue: ${sourceItem.title}',
    'Response: ${responseItem.title}',
    'Mode: ${mode.label}',
    'Owner: ${responseItem.ownerLabel}',
    'Route: $routeLabel',
    'Due: ${_dateLabel(dueDate)}',
    'Plan: ${responseItem.detail}',
    'Evidence: ${responseItem.evidenceLabel}',
  ].join('\n');
}

String _responseId(String projectName, String title, int queueIndex) {
  final slug = '$projectName $title'
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return '$slug-risk-response-$queueIndex';
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

extension ProjectRiskResponseModePresentation on ProjectRiskResponseMode {
  /// User-facing label for risk response mode.
  String get label {
    switch (this) {
      case ProjectRiskResponseMode.mitigate:
        return 'Mitigate';
      case ProjectRiskResponseMode.recover:
        return 'Recover';
      case ProjectRiskResponseMode.escalate:
        return 'Escalate';
      case ProjectRiskResponseMode.accept:
        return 'Accept';
    }
  }

  /// Icon for risk response mode.
  IconData get icon {
    switch (this) {
      case ProjectRiskResponseMode.mitigate:
        return Icons.shield_outlined;
      case ProjectRiskResponseMode.recover:
        return Icons.auto_fix_high_outlined;
      case ProjectRiskResponseMode.escalate:
        return Icons.priority_high_rounded;
      case ProjectRiskResponseMode.accept:
        return Icons.rule_outlined;
    }
  }

  /// Color for risk response mode.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectRiskResponseMode.mitigate:
        return Colors.orange.shade700;
      case ProjectRiskResponseMode.recover:
        return colorScheme.primary;
      case ProjectRiskResponseMode.escalate:
        return colorScheme.error;
      case ProjectRiskResponseMode.accept:
        return Colors.green.shade700;
    }
  }
}

extension ProjectRiskResponseDueOptionPresentation
    on ProjectRiskResponseDueOption {
  /// User-facing label for risk response due timing.
  String get label {
    switch (this) {
      case ProjectRiskResponseDueOption.today:
        return 'Today';
      case ProjectRiskResponseDueOption.next48Hours:
        return '48 Hours';
      case ProjectRiskResponseDueOption.thisWeek:
        return 'This Week';
      case ProjectRiskResponseDueOption.governance:
        return 'Governance';
    }
  }

  /// Icon for risk response due timing.
  IconData get icon {
    switch (this) {
      case ProjectRiskResponseDueOption.today:
        return Icons.today_outlined;
      case ProjectRiskResponseDueOption.next48Hours:
        return Icons.timer_outlined;
      case ProjectRiskResponseDueOption.thisWeek:
        return Icons.event_available_outlined;
      case ProjectRiskResponseDueOption.governance:
        return Icons.account_tree_outlined;
    }
  }
}
