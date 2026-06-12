import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_archive.dart';
import '../models/financial_report_release_evidence_manifest.dart';

class FinancialReportReleaseArchiveService {
  static const defaultRetentionYears = 10;
  static const defaultRetentionPolicy =
      'Indonesia statutory/tax archive policy';
  static const defaultCustodian = 'Finance controller';
  static const defaultStorageLocation = 'Secure report pack archive';

  const FinancialReportReleaseArchiveService();

  FinancialReportReleaseArchiveSummary summarize({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseEvidenceManifestSummary evidenceManifest,
    FinancialReportReleaseArchiveRecord? record,
  }) {
    if (record != null) {
      return FinancialReportReleaseArchiveSummary(
        periodKey: periodKey,
        periodLabel: periodLabel,
        status: FinancialReportReleaseArchiveStatus.archived,
        record: record,
        evidenceReady: evidenceManifest.archiveReady,
        evidenceItemCount: evidenceManifest.items.length,
        readyEvidenceCount: evidenceManifest.readyCount,
        nextAction:
            'Archive record sealed under ${record.archiveId}; retain through ${_dateLabel(record.retainUntil)}.',
      );
    }

    if (!evidenceManifest.archiveReady) {
      return FinancialReportReleaseArchiveSummary(
        periodKey: periodKey,
        periodLabel: periodLabel,
        status: FinancialReportReleaseArchiveStatus.blocked,
        record: null,
        evidenceReady: false,
        evidenceItemCount: evidenceManifest.items.length,
        readyEvidenceCount: evidenceManifest.readyCount,
        nextAction: evidenceManifest.nextAction,
      );
    }

    return FinancialReportReleaseArchiveSummary(
      periodKey: periodKey,
      periodLabel: periodLabel,
      status: FinancialReportReleaseArchiveStatus.ready,
      record: null,
      evidenceReady: true,
      evidenceItemCount: evidenceManifest.items.length,
      readyEvidenceCount: evidenceManifest.readyCount,
      nextAction:
          'Release evidence is ready. Create the archive register before closing the release file.',
    );
  }

  FinancialReportReleaseArchiveRecord createRecord({
    required String periodKey,
    required String periodLabel,
    required FinancialReportPackageIntegrity packageIntegrity,
    required FinancialReportReleaseEvidenceManifestSummary evidenceManifest,
    required String archivedBy,
    String custodian = defaultCustodian,
    String storageLocation = defaultStorageLocation,
    String retentionPolicy = defaultRetentionPolicy,
    String note = '',
    DateTime? archivedAt,
    int retentionYears = defaultRetentionYears,
  }) {
    if (!evidenceManifest.archiveReady) {
      throw StateError('Release evidence is incomplete.');
    }

    final archivedOn = archivedAt ?? DateTime.now();
    final retentionBase = packageIntegrity.closeRecord?.periodEnd ?? archivedOn;
    return FinancialReportReleaseArchiveRecord(
      periodKey: periodKey,
      periodLabel: periodLabel,
      archiveId: _archiveId(periodKey, packageIntegrity.currentShortHash),
      archivedAt: archivedOn,
      archivedBy: _fallback(archivedBy, 'Current user'),
      custodian: _fallback(custodian, defaultCustodian),
      storageLocation: _fallback(storageLocation, defaultStorageLocation),
      retentionPolicy: _fallback(retentionPolicy, defaultRetentionPolicy),
      retainUntil: _addYears(retentionBase, retentionYears),
      packageFingerprint: packageIntegrity.currentHash,
      packageFingerprintAlgorithm: packageIntegrity.currentAlgorithm,
      evidenceItemCount: evidenceManifest.items.length,
      note: note.trim(),
    );
  }

  String _archiveId(String periodKey, String shortHash) {
    final normalizedPeriod = periodKey.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final normalizedHash = shortHash.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    return 'FR-ARCH-$normalizedPeriod-${normalizedHash.toUpperCase()}';
  }

  String _fallback(String value, String fallback) {
    final normalized = value.trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  DateTime _addYears(DateTime date, int years) {
    final target = DateTime(date.year + years, date.month, date.day);
    if (target.month != date.month) {
      return DateTime(date.year + years, date.month + 1, 0);
    }
    return target;
  }

  String _dateLabel(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
