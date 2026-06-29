import 'company_governance_owner_handoff.dart';

/// Immutable log entry showing that a governance owner handoff was recorded.
class CompanyGovernanceOwnerHandoffRecord {
  final String id;
  final String ownerName;
  final int actionCount;
  final int criticalCount;
  final int highCount;
  final String sourceSummary;
  final String nextDueLabel;
  final String message;
  final DateTime recordedAt;
  final String actorName;
  final String auditEventId;

  const CompanyGovernanceOwnerHandoffRecord({
    required this.id,
    required this.ownerName,
    required this.actionCount,
    required this.criticalCount,
    required this.highCount,
    required this.sourceSummary,
    required this.nextDueLabel,
    required this.message,
    required this.recordedAt,
    required this.actorName,
    this.auditEventId = '',
  });

  factory CompanyGovernanceOwnerHandoffRecord.fromHandoff({
    required String id,
    required CompanyGovernanceOwnerHandoff handoff,
    required DateTime recordedAt,
    String actorName = 'People Operations',
    String auditEventId = '',
  }) {
    return CompanyGovernanceOwnerHandoffRecord(
      id: id,
      ownerName: handoff.ownerLabel,
      actionCount: handoff.actionCount,
      criticalCount: handoff.criticalCount,
      highCount: handoff.highCount,
      sourceSummary: handoff.sourceSummary,
      nextDueLabel: handoff.nextDueLabel,
      message: handoff.handoffMessage,
      recordedAt: recordedAt,
      actorName: actorName.trim().isEmpty ? 'People Operations' : actorName,
      auditEventId: auditEventId.trim(),
    );
  }

  CompanyGovernanceOwnerHandoffRecord copyWith({String? auditEventId}) {
    return CompanyGovernanceOwnerHandoffRecord(
      id: id,
      ownerName: ownerName,
      actionCount: actionCount,
      criticalCount: criticalCount,
      highCount: highCount,
      sourceSummary: sourceSummary,
      nextDueLabel: nextDueLabel,
      message: message,
      recordedAt: recordedAt,
      actorName: actorName,
      auditEventId: auditEventId ?? this.auditEventId,
    );
  }

  String get ownerLabel {
    return ownerName.trim().isEmpty ? 'Unassigned owner' : ownerName;
  }

  bool get hasAuditEvent => auditEventId.trim().isNotEmpty;

  String get recordedDateLabel {
    final month = recordedAt.month.toString().padLeft(2, '0');
    final day = recordedAt.day.toString().padLeft(2, '0');
    return '${recordedAt.year}-$month-$day';
  }
}

/// Finds the latest recorded handoff for the selected owner.
CompanyGovernanceOwnerHandoffRecord? latestCompanyGovernanceOwnerHandoffRecord({
  required List<CompanyGovernanceOwnerHandoffRecord> records,
  required String? ownerName,
}) {
  final normalizedOwnerName = _normalizeOwnerName(ownerName);
  if (normalizedOwnerName.isEmpty) return null;

  final matches =
      records
          .where(
            (record) =>
                _normalizeOwnerName(record.ownerLabel) == normalizedOwnerName,
          )
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  return matches.firstOrNull;
}

String _normalizeOwnerName(String? ownerName) {
  return (ownerName ?? '').trim().toLowerCase();
}
