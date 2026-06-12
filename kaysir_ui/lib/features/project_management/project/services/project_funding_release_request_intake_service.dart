import 'package:flutter/material.dart';

import 'project_funding_release_service.dart';

/// Release timing option used by the funding release request flow.
enum ProjectFundingReleaseRequestDateOption {
  today,
  nextGate,
  nextWeek,
  gateClose,
}

/// Validation issue emitted for a funding release request draft.
class ProjectFundingReleaseRequestIssue {
  const ProjectFundingReleaseRequestIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable funding release request draft captured by the intake form.
class ProjectFundingReleaseRequestDraft {
  const ProjectFundingReleaseRequestDraft({
    required this.projectId,
    required this.kind,
    required this.title,
    required this.owner,
    required this.amountText,
    required this.dateOption,
    required this.gateNote,
    required this.evidenceNote,
  });

  final String projectId;
  final ProjectFundingReleaseKind kind;
  final String title;
  final String owner;
  final String amountText;
  final ProjectFundingReleaseRequestDateOption dateOption;
  final String gateNote;
  final String evidenceNote;

  ProjectFundingReleaseRequestDraft copyWith({
    ProjectFundingReleaseKind? kind,
    String? title,
    String? owner,
    String? amountText,
    ProjectFundingReleaseRequestDateOption? dateOption,
    String? gateNote,
    String? evidenceNote,
  }) {
    return ProjectFundingReleaseRequestDraft(
      projectId: projectId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      amountText: amountText ?? this.amountText,
      dateOption: dateOption ?? this.dateOption,
      gateNote: gateNote ?? this.gateNote,
      evidenceNote: evidenceNote ?? this.evidenceNote,
    );
  }
}

/// Submitted local funding release request for demo workflow history.
class ProjectFundingReleaseRequestSubmission {
  const ProjectFundingReleaseRequestSubmission({
    required this.step,
    required this.routeLabel,
    required this.releaseDate,
    required this.submittedAt,
    required this.summaryText,
  });

  final ProjectFundingReleaseStep step;
  final String routeLabel;
  final DateTime releaseDate;
  final DateTime submittedAt;
  final String summaryText;
}

/// Service for validating and submitting funding release request drafts.
class ProjectFundingReleaseRequestIntakeService {
  const ProjectFundingReleaseRequestIntakeService();

  ProjectFundingReleaseRequestDraft initialDraft(
    ProjectFundingReleaseSummary summary,
  ) {
    final primary = summary.primaryStep;

    return ProjectFundingReleaseRequestDraft(
      projectId: summary.projectId,
      kind: primary?.kind ?? ProjectFundingReleaseKind.activeFunding,
      title: '',
      owner: primary?.ownerLabel ?? '',
      amountText: '',
      dateOption: _recommendedDateOption(summary),
      gateNote: '',
      evidenceNote: '',
    );
  }

  double? amountFor(ProjectFundingReleaseRequestDraft draft) {
    final normalized = draft.amountText.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;

    return double.tryParse(normalized);
  }

  String routeLabelFor({
    required ProjectFundingReleaseSummary summary,
    required ProjectFundingReleaseRequestDraft draft,
  }) {
    if (summary.level == ProjectFundingReleaseLevel.blocked) {
      return 'Release hold';
    }
    if (draft.kind == ProjectFundingReleaseKind.reserveGuardrail) {
      return 'Reserve approval';
    }

    final amount = amountFor(draft) ?? 0;
    if (summary.totalBudget > 0 && amount / summary.totalBudget > 0.2) {
      return 'Sponsor release';
    }
    if (summary.level == ProjectFundingReleaseLevel.review) {
      return 'Finance gate';
    }

    return 'Standard release';
  }

  DateTime releaseDateFor({
    required ProjectFundingReleaseSummary summary,
    required ProjectFundingReleaseRequestDateOption option,
  }) {
    final today = DateUtils.dateOnly(DateTime.now());
    final primary = summary.primaryStep;
    switch (option) {
      case ProjectFundingReleaseRequestDateOption.today:
        return today;
      case ProjectFundingReleaseRequestDateOption.nextGate:
        return DateUtils.dateOnly(primary?.startDate ?? today);
      case ProjectFundingReleaseRequestDateOption.nextWeek:
        return today.add(const Duration(days: 7));
      case ProjectFundingReleaseRequestDateOption.gateClose:
        return DateUtils.dateOnly(
          primary?.endDate ?? today.add(const Duration(days: 14)),
        );
    }
  }

  List<ProjectFundingReleaseRequestIssue> validate({
    required ProjectFundingReleaseSummary summary,
    required ProjectFundingReleaseRequestDraft draft,
  }) {
    final issues = <ProjectFundingReleaseRequestIssue>[];
    final title = draft.title.trim();
    if (title.isEmpty) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'title',
          message: 'Release title is required.',
        ),
      );
    } else if (title.length < 8) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'title',
          message: 'Release title should be specific.',
        ),
      );
    }

    if (draft.owner.trim().isEmpty) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'owner',
          message: 'Release owner is required.',
        ),
      );
    }

    final amount = amountFor(draft);
    if (amount == null) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'amount',
          message: 'Release amount is required.',
        ),
      );
    } else if (amount <= 0) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'amount',
          message: 'Release amount should be greater than zero.',
        ),
      );
    }

    final gateNote = draft.gateNote.trim();
    if (gateNote.isEmpty) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'gate',
          message: 'Gate note is required.',
        ),
      );
    } else if (gateNote.length < 20) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'gate',
          message: 'Gate note should explain the release condition.',
        ),
      );
    }

    final evidenceNote = draft.evidenceNote.trim();
    if (evidenceNote.isEmpty) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'evidence',
          message: 'Evidence note is required.',
        ),
      );
    } else if (evidenceNote.length < 20) {
      issues.add(
        const ProjectFundingReleaseRequestIssue(
          field: 'evidence',
          message: 'Evidence note should explain the approval proof.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectFundingReleaseRequestSubmission submit({
    required ProjectFundingReleaseSummary summary,
    required ProjectFundingReleaseRequestDraft draft,
    required int queueIndex,
  }) {
    final issues = validate(summary: summary, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Funding release request draft is not ready to submit.');
    }

    final amount = amountFor(draft)!;
    final releaseDate = releaseDateFor(
      summary: summary,
      option: draft.dateOption,
    );
    final routeLabel = routeLabelFor(summary: summary, draft: draft);
    final step = ProjectFundingReleaseStep(
      id: _requestId(summary.projectName, draft.title, queueIndex),
      title: draft.title.trim(),
      detail: draft.gateNote.trim(),
      kind: draft.kind,
      level: ProjectFundingReleaseLevel.review,
      icon: draft.kind.requestIcon,
      amount: amount,
      releaseShare: summary.totalBudget <= 0 ? 0 : amount / summary.totalBudget,
      gateLabel: routeLabel,
      ownerLabel: draft.owner.trim(),
      evidenceLabel: draft.evidenceNote.trim(),
      actionLabel: 'Review release',
      startDate: releaseDate,
      endDate: releaseDate.add(const Duration(days: 7)),
    );

    return ProjectFundingReleaseRequestSubmission(
      step: step,
      routeLabel: routeLabel,
      releaseDate: releaseDate,
      submittedAt: DateUtils.dateOnly(DateTime.now()),
      summaryText: _summaryText(
        summary: summary,
        step: step,
        routeLabel: routeLabel,
      ),
    );
  }
}

ProjectFundingReleaseRequestDateOption _recommendedDateOption(
  ProjectFundingReleaseSummary summary,
) {
  switch (summary.level) {
    case ProjectFundingReleaseLevel.blocked:
      return ProjectFundingReleaseRequestDateOption.today;
    case ProjectFundingReleaseLevel.review:
      return ProjectFundingReleaseRequestDateOption.nextGate;
    case ProjectFundingReleaseLevel.ready:
      return ProjectFundingReleaseRequestDateOption.nextWeek;
  }
}

String _summaryText({
  required ProjectFundingReleaseSummary summary,
  required ProjectFundingReleaseStep step,
  required String routeLabel,
}) {
  return [
    'Funding release request',
    'Project: ${summary.projectName}',
    'Release: ${step.title}',
    'Type: ${step.kind.label}',
    'Amount: ${step.amountLabel}',
    'Owner: ${step.ownerLabel}',
    'Route: $routeLabel',
    'Window: ${step.dateRangeLabel}',
    'Gate: ${step.gateLabel}',
    'Evidence: ${step.evidenceLabel}',
  ].join('\n');
}

String _requestId(String projectName, String title, int queueIndex) {
  final slug = '$projectName $title'
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return '$slug-funding-release-$queueIndex';
}

extension ProjectFundingReleaseRequestKindPresentation
    on ProjectFundingReleaseKind {
  /// Icon for a funding release request type.
  IconData get requestIcon {
    switch (this) {
      case ProjectFundingReleaseKind.activeFunding:
        return Icons.waterfall_chart_outlined;
      case ProjectFundingReleaseKind.milestoneGate:
        return Icons.flag_outlined;
      case ProjectFundingReleaseKind.completionRunway:
        return Icons.task_alt_outlined;
      case ProjectFundingReleaseKind.reserveGuardrail:
        return Icons.savings_outlined;
      case ProjectFundingReleaseKind.authorityGate:
        return Icons.verified_user_outlined;
    }
  }
}

extension ProjectFundingReleaseRequestDateOptionPresentation
    on ProjectFundingReleaseRequestDateOption {
  /// User-facing label for release timing.
  String get label {
    switch (this) {
      case ProjectFundingReleaseRequestDateOption.today:
        return 'Today';
      case ProjectFundingReleaseRequestDateOption.nextGate:
        return 'Next Gate';
      case ProjectFundingReleaseRequestDateOption.nextWeek:
        return 'Next Week';
      case ProjectFundingReleaseRequestDateOption.gateClose:
        return 'Gate Close';
    }
  }

  /// Icon for release timing.
  IconData get icon {
    switch (this) {
      case ProjectFundingReleaseRequestDateOption.today:
        return Icons.today_outlined;
      case ProjectFundingReleaseRequestDateOption.nextGate:
        return Icons.account_tree_outlined;
      case ProjectFundingReleaseRequestDateOption.nextWeek:
        return Icons.event_available_outlined;
      case ProjectFundingReleaseRequestDateOption.gateClose:
        return Icons.flag_outlined;
    }
  }
}
