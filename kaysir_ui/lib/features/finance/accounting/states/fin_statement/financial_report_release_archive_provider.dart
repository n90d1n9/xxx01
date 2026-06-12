import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_package_integrity.dart';
import '../../models/financial_report_release_archive.dart';
import '../../models/financial_report_release_archive_retention.dart';
import '../../models/financial_report_release_evidence_manifest.dart';
import '../../models/financial_report_statutory_filing.dart';
import '../../repositories/financial_report_release_archive_repository_provider.dart';
import '../../services/financial_report_release_archive_audit_service.dart';
import '../../services/financial_report_release_archive_retention_service.dart';
import '../../services/financial_report_release_archive_service.dart';
import '../../services/financial_report_statutory_filing_service.dart';
import 'financial_provider.dart';
import 'financial_report_pack_provider.dart';
import 'financial_report_release_distribution_provider.dart';
import 'financial_report_release_evidence_manifest_provider.dart';
import 'financial_report_release_signoff_provider.dart';

final financialReportReleaseArchiveServiceProvider =
    Provider<FinancialReportReleaseArchiveService>((ref) {
      return const FinancialReportReleaseArchiveService();
    });

final financialReportReleaseArchiveAuditServiceProvider =
    Provider<FinancialReportReleaseArchiveAuditService>((ref) {
      return FinancialReportReleaseArchiveAuditService();
    });

final financialReportReleaseArchiveRetentionServiceProvider =
    Provider<FinancialReportReleaseArchiveRetentionService>((ref) {
      return const FinancialReportReleaseArchiveRetentionService();
    });

final financialReportStatutoryFilingServiceProvider =
    Provider<FinancialReportStatutoryFilingService>((ref) {
      return const FinancialReportStatutoryFilingService();
    });

final financialReportReleaseArchiveProvider = StateNotifierProvider<
  FinancialReportReleaseArchiveNotifier,
  Map<String, FinancialReportReleaseArchiveRecord>
>((ref) {
  return FinancialReportReleaseArchiveNotifier(
    repository: ref.watch(financialReportReleaseArchiveRepositoryProvider),
    service: ref.watch(financialReportReleaseArchiveServiceProvider),
    auditService: ref.watch(financialReportReleaseArchiveAuditServiceProvider),
  );
});

final currentFinancialReportReleaseArchiveRecordProvider =
    Provider<FinancialReportReleaseArchiveRecord?>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportReleaseSignOffPeriodKeyProvider,
      );
      return ref.watch(financialReportReleaseArchiveProvider)[periodKey];
    });

final currentFinancialReportReleaseArchiveSummaryProvider =
    Provider<FinancialReportReleaseArchiveSummary>((ref) {
      return ref
          .watch(financialReportReleaseArchiveServiceProvider)
          .summarize(
            periodKey: ref.watch(
              currentFinancialReportReleaseSignOffPeriodKeyProvider,
            ),
            periodLabel: ref.watch(selectedFinancialPeriodProvider).label,
            evidenceManifest: ref.watch(
              currentFinancialReportReleaseEvidenceManifestProvider,
            ),
            record: ref.watch(
              currentFinancialReportReleaseArchiveRecordProvider,
            ),
          );
    });

final currentFinancialReportReleaseArchiveAuditProvider = Provider<
  List<FinancialReportReleaseArchiveAuditEvent>
>((ref) {
  final periodKey = ref.watch(
    currentFinancialReportReleaseSignOffPeriodKeyProvider,
  );
  final repository = ref.watch(financialReportReleaseArchiveRepositoryProvider);
  final auditService = ref.watch(
    financialReportReleaseArchiveAuditServiceProvider,
  );
  ref.watch(financialReportReleaseArchiveProvider);
  return auditService.newestFirst(
    repository.loadAuditEvents().where((event) => event.periodKey == periodKey),
  );
});

final currentFinancialReportReleaseArchiveRetentionProvider =
    Provider<FinancialReportReleaseArchiveRetentionSummary>((ref) {
      return ref
          .watch(financialReportReleaseArchiveRetentionServiceProvider)
          .summarize(
            periodKey: ref.watch(
              currentFinancialReportReleaseSignOffPeriodKeyProvider,
            ),
            periodLabel: ref.watch(selectedFinancialPeriodProvider).label,
            record: ref.watch(
              currentFinancialReportReleaseArchiveRecordProvider,
            ),
            asOf: DateTime.now(),
            auditEvents: ref.watch(
              currentFinancialReportReleaseArchiveAuditProvider,
            ),
          );
    });

final currentFinancialReportStatutoryFilingProvider =
    Provider<FinancialReportStatutoryFilingSummary>((ref) {
      return ref
          .watch(financialReportStatutoryFilingServiceProvider)
          .summarize(
            pack: ref.watch(financialReportPackProvider),
            distributionItems: ref.watch(
              currentFinancialReportReleaseDistributionItemsProvider,
            ),
            archiveSummary: ref.watch(
              currentFinancialReportReleaseArchiveSummaryProvider,
            ),
            asOf: DateTime.now(),
          );
    });

class FinancialReportReleaseArchiveNotifier
    extends StateNotifier<Map<String, FinancialReportReleaseArchiveRecord>> {
  final FinancialReportReleaseArchiveRepository repository;
  final FinancialReportReleaseArchiveService service;
  final FinancialReportReleaseArchiveAuditService auditService;
  var _isDisposed = false;

  FinancialReportReleaseArchiveNotifier({
    required this.repository,
    required this.service,
    required this.auditService,
  }) : super(repository.loadRecords()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialReportReleaseArchiveRepository) {
      return;
    }

    try {
      await repository.hydrate();
    } catch (_) {
      return;
    }
    if (!_isDisposed) {
      state = repository.loadRecords();
    }
  }

  FinancialReportReleaseArchiveRecord createArchiveRecord({
    required String periodKey,
    required String periodLabel,
    required FinancialReportPackageIntegrity packageIntegrity,
    required FinancialReportReleaseEvidenceManifestSummary evidenceManifest,
    required String archivedBy,
    required String custodian,
    required String storageLocation,
    required String note,
  }) {
    final record = service.createRecord(
      periodKey: periodKey,
      periodLabel: periodLabel,
      packageIntegrity: packageIntegrity,
      evidenceManifest: evidenceManifest,
      archivedBy: archivedBy,
      custodian: custodian,
      storageLocation: storageLocation,
      note: note,
    );
    repository.upsertRecord(record);
    repository.appendAuditEvent(auditService.archived(record));
    state = repository.loadRecords();
    return record;
  }

  void clearArchiveRecord({
    required String periodKey,
    required String periodLabel,
    required String actor,
  }) {
    final record = repository.loadRecords()[periodKey];
    repository.removeRecord(periodKey);
    repository.appendAuditEvent(
      auditService.cleared(
        periodKey: periodKey,
        periodLabel: periodLabel,
        actor: actor,
        record: record,
      ),
    );
    state = repository.loadRecords();
  }

  FinancialReportReleaseArchiveAuditEvent recordRetentionReview({
    required String periodKey,
    required String actor,
    required String note,
  }) {
    final record = repository.loadRecords()[periodKey];
    if (record == null) {
      throw StateError('Release archive record is missing.');
    }
    final event = auditService.retentionReviewed(
      record: record,
      actor: actor,
      note: note,
    );
    repository.appendAuditEvent(event);
    state = repository.loadRecords();
    return event;
  }

  FinancialReportReleaseArchiveAuditEvent requestDisposalReview({
    required String periodKey,
    required String actor,
    required String note,
  }) {
    final record = repository.loadRecords()[periodKey];
    if (record == null) {
      throw StateError('Release archive record is missing.');
    }
    final event = auditService.disposalReviewRequested(
      record: record,
      actor: actor,
      note: note,
    );
    repository.appendAuditEvent(event);
    state = repository.loadRecords();
    return event;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
