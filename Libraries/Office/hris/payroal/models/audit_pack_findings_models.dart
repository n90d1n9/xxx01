import 'payroll_audit_pack_review_models.dart';

/// Defines the risk level assigned to an audit pack review finding.
enum AuditPackFindingSeverity {
  critical('Critical'),
  high('High'),
  medium('Medium');

  final String label;

  const AuditPackFindingSeverity(this.label);
}

/// Defines the remediation state for an audit pack review finding.
enum AuditPackFindingStatus {
  open('Open'),
  remediated('Remediated'),
  closed('Closed');

  final String label;

  const AuditPackFindingStatus(this.label);
}

/// Stores reviewer remediation state for one audit pack checkpoint finding.
class AuditPackFindingRecord {
  final String checkpointId;
  final AuditPackFindingStatus status;
  final String resolutionNote;
  final DateTime? remediatedAt;
  final DateTime? closedAt;

  const AuditPackFindingRecord({
    required this.checkpointId,
    required this.status,
    this.resolutionNote = '',
    this.remediatedAt,
    this.closedAt,
  });

  AuditPackFindingRecord copyWith({
    AuditPackFindingStatus? status,
    String? resolutionNote,
    DateTime? remediatedAt,
    DateTime? closedAt,
  }) {
    return AuditPackFindingRecord(
      checkpointId: checkpointId,
      status: status ?? this.status,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      remediatedAt: remediatedAt ?? this.remediatedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}

/// Represents one actionable audit pack finding for payroll close review.
class AuditPackFinding {
  final String id;
  final String title;
  final String owner;
  final String finding;
  final DateTime dueDate;
  final AuditPackFindingSeverity severity;
  final AuditPackFindingStatus status;
  final String resolutionNote;

  const AuditPackFinding({
    required this.id,
    required this.title,
    required this.owner,
    required this.finding,
    required this.dueDate,
    required this.severity,
    required this.status,
    required this.resolutionNote,
  });

  bool get isOpen => status == AuditPackFindingStatus.open;

  bool get isRemediated => status == AuditPackFindingStatus.remediated;

  bool get isClosed => status == AuditPackFindingStatus.closed;

  bool get canClose => isRemediated;

  String get nextAction {
    if (isClosed) return 'Finding is closed.';
    if (isRemediated) return 'Close finding after reviewer validation.';
    return finding;
  }
}

/// Summarizes audit pack findings and remediation progress.
class AuditPackFindingsSummary {
  final String periodLabel;
  final DateTime asOfDate;
  final List<AuditPackFinding> findings;

  const AuditPackFindingsSummary({
    required this.periodLabel,
    required this.asOfDate,
    required this.findings,
  });

  factory AuditPackFindingsSummary.fromReview({
    required PayrollAuditPackReviewSummary review,
    required DateTime asOfDate,
    required Map<String, AuditPackFindingRecord> records,
  }) {
    return AuditPackFindingsSummary(
      periodLabel: review.periodLabel,
      asOfDate: asOfDate,
      findings: [
        for (final checkpoint in review.checkpoints)
          if (checkpoint.hasBlockers || records.containsKey(checkpoint.id))
            _findingFromCheckpoint(
              checkpoint: checkpoint,
              asOfDate: asOfDate,
              record: records[checkpoint.id],
            ),
      ],
    );
  }

  int get openCount => findings.where((finding) => finding.isOpen).length;

  int get remediatedCount =>
      findings.where((finding) => finding.isRemediated).length;

  int get closedCount => findings.where((finding) => finding.isClosed).length;

  int get criticalCount {
    return findings
        .where(
          (finding) =>
              finding.severity == AuditPackFindingSeverity.critical &&
              !finding.isClosed,
        )
        .length;
  }

  bool get hasOpenFindings => openCount > 0;

  double get closureRate {
    if (findings.isEmpty) return 1;
    return closedCount / findings.length;
  }

  String get nextAction {
    if (openCount > 0) return 'Remediate $openCount audit pack findings.';
    if (remediatedCount > 0) {
      return 'Close $remediatedCount remediated audit findings.';
    }
    return 'Audit pack findings are closed.';
  }
}

AuditPackFinding _findingFromCheckpoint({
  required PayrollAuditPackReviewCheckpoint checkpoint,
  required DateTime asOfDate,
  required AuditPackFindingRecord? record,
}) {
  final status = record?.status ?? AuditPackFindingStatus.open;
  final fallbackFinding =
      checkpoint.blockers.isEmpty
          ? 'Reviewer requested validation for ${checkpoint.title}.'
          : checkpoint.blockers.first;

  return AuditPackFinding(
    id: checkpoint.id,
    title: checkpoint.title,
    owner: checkpoint.owner,
    finding: fallbackFinding,
    dueDate: asOfDate.add(Duration(days: _dueDaysFor(checkpoint.id))),
    severity: _severityFor(checkpoint.id),
    status: status,
    resolutionNote: record?.resolutionNote ?? '',
  );
}

AuditPackFindingSeverity _severityFor(String checkpointId) {
  return switch (checkpointId) {
    'archive-retention' => AuditPackFindingSeverity.critical,
    'report-artifacts' => AuditPackFindingSeverity.high,
    'distribution-receipts' => AuditPackFindingSeverity.high,
    'control-evidence' => AuditPackFindingSeverity.critical,
    'audit-trail' => AuditPackFindingSeverity.medium,
    _ => AuditPackFindingSeverity.medium,
  };
}

int _dueDaysFor(String checkpointId) {
  return switch (checkpointId) {
    'archive-retention' => 2,
    'control-evidence' => 2,
    'report-artifacts' => 3,
    'distribution-receipts' => 3,
    'audit-trail' => 5,
    _ => 5,
  };
}
