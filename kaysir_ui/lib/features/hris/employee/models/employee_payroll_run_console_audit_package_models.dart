import 'employee_payroll_run_console_audit_models.dart';
import 'employee_payroll_run_console_command_models.dart';

/// Evidence state for one payroll console command stage.
enum EmployeePayrollRunConsoleAuditCommandCoverageStatus {
  missing('Missing'),
  ready('Evidenced'),
  reviewNeeded('Review'),
  noChange('No change');

  final String label;

  const EmployeePayrollRunConsoleAuditCommandCoverageStatus(this.label);
}

/// Audit evidence coverage for one payroll console command stage.
class EmployeePayrollRunConsoleAuditCommandCoverage {
  final EmployeePayrollRunConsoleCommandType type;
  final List<EmployeePayrollRunConsoleAuditEvent> events;

  const EmployeePayrollRunConsoleAuditCommandCoverage({
    required this.type,
    required this.events,
  });

  int get eventCount => events.length;

  int get completedUpdateCount {
    return events.fold(0, (total, event) => total + event.completedCount);
  }

  int get reviewCount {
    return events
        .where(
          (event) =>
              event.status == EmployeePayrollRunConsoleAuditStatus.warning,
        )
        .length;
  }

  bool get hasEvidence => events.isNotEmpty;

  EmployeePayrollRunConsoleAuditEvent? get latestEvent {
    if (events.isEmpty) return null;
    return events.reduce((a, b) => a.occurredAt.isAfter(b.occurredAt) ? a : b);
  }

  EmployeePayrollRunConsoleAuditCommandCoverageStatus get status {
    if (events.isEmpty) {
      return EmployeePayrollRunConsoleAuditCommandCoverageStatus.missing;
    }
    if (reviewCount > 0) {
      return EmployeePayrollRunConsoleAuditCommandCoverageStatus.reviewNeeded;
    }
    if (completedUpdateCount > 0) {
      return EmployeePayrollRunConsoleAuditCommandCoverageStatus.ready;
    }
    return EmployeePayrollRunConsoleAuditCommandCoverageStatus.noChange;
  }

  String get detailLabel {
    final latest = latestEvent;
    if (latest == null) return 'No command evidence captured';
    return '${_plural(eventCount, 'event')}, '
        '${_plural(completedUpdateCount, 'completed update')}';
  }
}

/// Readiness row for a payroll console audit evidence package.
class EmployeePayrollRunConsoleAuditPackageItem {
  final String title;
  final String detail;
  final bool isReady;

  const EmployeePayrollRunConsoleAuditPackageItem({
    required this.title,
    required this.detail,
    required this.isReady,
  });
}

/// Close-review package assembled from payroll console audit evidence.
class EmployeePayrollRunConsoleAuditEvidencePackage {
  final EmployeePayrollRunConsoleAuditEvidenceReport report;

  const EmployeePayrollRunConsoleAuditEvidencePackage({required this.report});

  EmployeePayrollRunConsoleAuditSummary get summary => report.summary;

  String get packageReference {
    if (summary.eventCount == 0) return 'PKG-PAYROLL-DRAFT';
    return 'PKG-${_slug(summary.runReferenceLabel)}-'
        '${summary.eventCount.toString().padLeft(2, '0')}';
  }

  DateTime? get openedAt {
    if (summary.events.isEmpty) return null;
    return summary.events
        .map((event) => event.occurredAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? get closedAt {
    if (summary.events.isEmpty) return null;
    return summary.events
        .map((event) => event.occurredAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  int get readyItemCount {
    return items.where((item) => item.isReady).length;
  }

  int get totalItemCount => items.length;

  int get evidencedCommandCount {
    return commandCoverage.where((coverage) => coverage.hasEvidence).length;
  }

  int get totalCommandCount => commandCoverage.length;

  bool get hasCompleteCommandCoverage {
    return evidencedCommandCount == totalCommandCount;
  }

  String get readinessLabel => '$readyItemCount/$totalItemCount ready';

  String get handoffLabel {
    return switch (report.status) {
      EmployeePayrollRunConsoleAuditEvidenceStatus.empty =>
        'Capture command evidence before packaging.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.reviewNeeded =>
        'Clear review items before package handoff.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.ready =>
        'Package is ready for payroll close handoff.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.noChange =>
        'Package needs an effective payroll update.',
    };
  }

  List<EmployeePayrollRunConsoleAuditPackageItem> get items {
    final hasEvents = summary.eventCount > 0;
    final hasRunTrace = hasEvents && summary.runReferenceLabel != 'No run';
    final hasOperatorTrace =
        hasEvents && summary.operatorLabel != 'No operator';
    final hasOutcomeEvidence =
        hasEvents &&
        (summary.completedCount > 0 ||
            summary.attentionCount > 0 ||
            summary.noChangeCount > 0);
    final hasReviewClearance = hasEvents && summary.attentionCount == 0;
    final hasCommandCoverage = hasEvents && hasCompleteCommandCoverage;

    return [
      EmployeePayrollRunConsoleAuditPackageItem(
        title: 'Run trace',
        detail:
            hasRunTrace ? summary.runReferenceLabel : 'No payroll run linked',
        isReady: hasRunTrace,
      ),
      EmployeePayrollRunConsoleAuditPackageItem(
        title: 'Operator trace',
        detail:
            hasOperatorTrace ? summary.operatorLabel : 'No operator captured',
        isReady: hasOperatorTrace,
      ),
      EmployeePayrollRunConsoleAuditPackageItem(
        title: 'Outcome evidence',
        detail:
            '${summary.completedCount} completed, '
            '${summary.attentionCount} review, '
            '${summary.noChangeCount} no change',
        isReady: hasOutcomeEvidence,
      ),
      EmployeePayrollRunConsoleAuditPackageItem(
        title: 'Review clearance',
        detail:
            hasReviewClearance
                ? 'No audit events need review'
                : _reviewClearanceDetail(summary),
        isReady: hasReviewClearance,
      ),
      EmployeePayrollRunConsoleAuditPackageItem(
        title: 'Command coverage',
        detail: '$evidencedCommandCount/$totalCommandCount stages evidenced',
        isReady: hasCommandCoverage,
      ),
    ];
  }

  List<EmployeePayrollRunConsoleAuditCommandCoverage> get commandCoverage {
    return [
      for (final type in EmployeePayrollRunConsoleCommandType.values)
        EmployeePayrollRunConsoleAuditCommandCoverage(
          type: type,
          events: summary.events
              .where((event) => event.commandType == type)
              .toList(growable: false),
        ),
    ];
  }
}

String _slug(String value) {
  final normalized = value
      .toUpperCase()
      .replaceAll(RegExp('[^A-Z0-9]+'), '-')
      .replaceAll(RegExp('-+'), '-');
  final slug = normalized.replaceAll(RegExp('^-|-\$'), '');
  return slug.isEmpty ? 'PAYROLL' : slug;
}

String _reviewClearanceDetail(EmployeePayrollRunConsoleAuditSummary summary) {
  if (summary.eventCount == 0) return 'No audit events captured';
  final suffix = summary.attentionCount == 1 ? 'event needs' : 'events need';
  return '${summary.attentionCount} $suffix review';
}

String _plural(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
