import 'package:uuid/uuid.dart';

import '../models/financial_report_release_archive.dart';

typedef FinancialReportReleaseArchiveAuditIdGenerator = String Function();

class FinancialReportReleaseArchiveAuditService {
  final FinancialReportReleaseArchiveAuditIdGenerator nextId;

  FinancialReportReleaseArchiveAuditService({
    FinancialReportReleaseArchiveAuditIdGenerator? nextId,
  }) : nextId = nextId ?? const Uuid().v4;

  FinancialReportReleaseArchiveAuditEvent archived(
    FinancialReportReleaseArchiveRecord record,
  ) {
    return FinancialReportReleaseArchiveAuditEvent(
      id: nextId(),
      periodKey: record.periodKey,
      periodLabel: record.periodLabel,
      archiveId: record.archiveId,
      action: FinancialReportReleaseArchiveAuditAction.archived,
      occurredAt: record.archivedAt,
      actor: record.archivedBy,
      custodian: record.custodian,
      storageLocation: record.storageLocation,
      retentionPolicy: record.retentionPolicy,
      retainUntil: record.retainUntil,
      packageFingerprint: record.packageFingerprint,
      note:
          record.note.trim().isEmpty
              ? '${record.archiveId} created for ${record.periodLabel}.'
              : record.note,
    );
  }

  FinancialReportReleaseArchiveAuditEvent cleared({
    required String periodKey,
    required String periodLabel,
    required String actor,
    FinancialReportReleaseArchiveRecord? record,
    DateTime? occurredAt,
  }) {
    return FinancialReportReleaseArchiveAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      archiveId: record?.archiveId,
      action: FinancialReportReleaseArchiveAuditAction.cleared,
      occurredAt: occurredAt ?? DateTime.now(),
      actor: actor,
      custodian: record?.custodian,
      storageLocation: record?.storageLocation,
      retentionPolicy: record?.retentionPolicy,
      retainUntil: record?.retainUntil,
      packageFingerprint: record?.packageFingerprint,
      note:
          record == null
              ? 'Release archive record cleared.'
              : '${record.archiveId} archive record cleared.',
    );
  }

  FinancialReportReleaseArchiveAuditEvent retentionReviewed({
    required FinancialReportReleaseArchiveRecord record,
    required String actor,
    required String note,
    DateTime? occurredAt,
  }) {
    final reviewedAt = occurredAt ?? DateTime.now();
    return FinancialReportReleaseArchiveAuditEvent(
      id: nextId(),
      periodKey: record.periodKey,
      periodLabel: record.periodLabel,
      archiveId: record.archiveId,
      action: FinancialReportReleaseArchiveAuditAction.retentionReviewed,
      occurredAt: reviewedAt,
      actor: _fallback(actor, record.custodian),
      custodian: record.custodian,
      storageLocation: record.storageLocation,
      retentionPolicy: record.retentionPolicy,
      retainUntil: record.retainUntil,
      nextReviewDate: _nextReviewDate(reviewedAt, record.retainUntil),
      packageFingerprint: record.packageFingerprint,
      note:
          note.trim().isEmpty
              ? '${record.archiveId} retention custody reviewed.'
              : note.trim(),
    );
  }

  FinancialReportReleaseArchiveAuditEvent disposalReviewRequested({
    required FinancialReportReleaseArchiveRecord record,
    required String actor,
    required String note,
    DateTime? occurredAt,
  }) {
    return FinancialReportReleaseArchiveAuditEvent(
      id: nextId(),
      periodKey: record.periodKey,
      periodLabel: record.periodLabel,
      archiveId: record.archiveId,
      action: FinancialReportReleaseArchiveAuditAction.disposalReviewRequested,
      occurredAt: occurredAt ?? DateTime.now(),
      actor: _fallback(actor, record.custodian),
      custodian: record.custodian,
      storageLocation: record.storageLocation,
      retentionPolicy: record.retentionPolicy,
      retainUntil: record.retainUntil,
      packageFingerprint: record.packageFingerprint,
      note:
          note.trim().isEmpty
              ? '${record.archiveId} requested for disposal or legal-hold review.'
              : note.trim(),
    );
  }

  List<FinancialReportReleaseArchiveAuditEvent> newestFirst(
    Iterable<FinancialReportReleaseArchiveAuditEvent> events,
  ) {
    return events.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  DateTime _nextReviewDate(DateTime reviewedAt, DateTime retainUntil) {
    final nextReview = _addYears(reviewedAt, 1);
    return nextReview.isAfter(retainUntil) ? retainUntil : nextReview;
  }

  DateTime _addYears(DateTime date, int years) {
    final target = DateTime(date.year + years, date.month, date.day);
    if (target.month != date.month) {
      return DateTime(date.year + years, date.month + 1, 0);
    }
    return target;
  }

  String _fallback(String value, String fallback) {
    final normalized = value.trim();
    return normalized.isEmpty ? fallback : normalized;
  }
}
