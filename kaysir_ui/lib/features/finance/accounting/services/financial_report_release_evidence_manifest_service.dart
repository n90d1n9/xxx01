import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_management_measure.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_evidence_manifest.dart';
import '../models/financial_report_release_signoff.dart';
import 'financial_report_release_distribution_service.dart';
import 'financial_report_release_signoff_service.dart';

class FinancialReportReleaseEvidenceManifestService {
  final FinancialReportReleaseSignOffService signOffService;
  final FinancialReportReleaseDistributionService distributionService;

  const FinancialReportReleaseEvidenceManifestService({
    this.signOffService = const FinancialReportReleaseSignOffService(),
    this.distributionService =
        const FinancialReportReleaseDistributionService(),
  });

  FinancialReportReleaseEvidenceManifestSummary buildManifest({
    required FinancialReportPackageIntegrity packageIntegrity,
    required List<FinancialReportReleaseSignOffItem> signOffItems,
    required List<FinancialReportReleaseSignOffAuditEvent> signOffAuditEvents,
    List<FinancialReportManagementMeasureAuditEvent>
        managementMeasureAuditEvents =
        const [],
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required List<FinancialReportReleaseDistributionAuditEvent>
    distributionAuditEvents,
  }) {
    final items = [
      _closeCertificateItem(packageIntegrity),
      _packageFingerprintItem(packageIntegrity),
      _signOffCertificateItem(signOffItems),
      _signOffAuditTrailItem(signOffAuditEvents),
      _managementMeasureAuditTrailItem(managementMeasureAuditEvents),
      _distributionRegisterItem(distributionItems),
      _distributionAuditTrailItem(distributionAuditEvents),
    ];
    final readyCount =
        items
            .where(
              (item) =>
                  item.status == FinancialReportReleaseEvidenceStatus.ready,
            )
            .length;
    final attentionCount =
        items
            .where(
              (item) =>
                  item.status == FinancialReportReleaseEvidenceStatus.attention,
            )
            .length;
    final missingCount =
        items
            .where(
              (item) =>
                  item.status == FinancialReportReleaseEvidenceStatus.missing,
            )
            .length;
    final requiredItems = items.where((item) => item.requiredForArchive);
    final archiveReady = requiredItems.every(
      (item) => item.status == FinancialReportReleaseEvidenceStatus.ready,
    );

    return FinancialReportReleaseEvidenceManifestSummary(
      items: List.unmodifiable(items),
      readyCount: readyCount,
      attentionCount: attentionCount,
      missingCount: missingCount,
      archiveReady: archiveReady,
      completionRatio: readyCount / items.length,
      nextAction: _nextAction(items, archiveReady),
    );
  }

  FinancialReportReleaseEvidenceManifestItem _closeCertificateItem(
    FinancialReportPackageIntegrity packageIntegrity,
  ) {
    final closeRecord = packageIntegrity.closeRecord;
    final isReady = closeRecord?.isClosed ?? false;
    return FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.closeCertificate,
      title: 'Period close certificate',
      status:
          isReady
              ? FinancialReportReleaseEvidenceStatus.ready
              : FinancialReportReleaseEvidenceStatus.missing,
      detail:
          isReady
              ? 'Closed by ${closeRecord!.closedBy ?? 'Unknown'} with ${closeRecord.blockerCount} blocker(s).'
              : 'Close the period to create the release certificate.',
      reference: 'Close certificate',
    );
  }

  FinancialReportReleaseEvidenceManifestItem _packageFingerprintItem(
    FinancialReportPackageIntegrity packageIntegrity,
  ) {
    return FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.packageFingerprint,
      title: 'Package fingerprint',
      status:
          packageIntegrity.isVerified
              ? FinancialReportReleaseEvidenceStatus.ready
              : packageIntegrity.hasWarning
              ? FinancialReportReleaseEvidenceStatus.attention
              : FinancialReportReleaseEvidenceStatus.missing,
      detail: packageIntegrity.detail,
      reference: packageIntegrity.currentShortHash,
    );
  }

  FinancialReportReleaseEvidenceManifestItem _signOffCertificateItem(
    List<FinancialReportReleaseSignOffItem> signOffItems,
  ) {
    final signedCount = signOffService.signedCount(signOffItems);
    final releaseReady = signOffService.releaseReady(signOffItems);
    return FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.signOffCertificate,
      title: 'Release sign-off certificate',
      status:
          releaseReady
              ? FinancialReportReleaseEvidenceStatus.ready
              : FinancialReportReleaseEvidenceStatus.missing,
      detail:
          '$signedCount/${signOffItems.length} sign-off(s) complete; '
          '${signOffService.returnedCount(signOffItems)} returned.',
      reference: 'Release approvals',
    );
  }

  FinancialReportReleaseEvidenceManifestItem _signOffAuditTrailItem(
    List<FinancialReportReleaseSignOffAuditEvent> signOffAuditEvents,
  ) {
    return FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.signOffAuditTrail,
      title: 'Sign-off audit trail',
      status:
          signOffAuditEvents.isNotEmpty
              ? FinancialReportReleaseEvidenceStatus.ready
              : FinancialReportReleaseEvidenceStatus.missing,
      detail:
          signOffAuditEvents.isNotEmpty
              ? '${signOffAuditEvents.length} sign-off event(s) captured.'
              : 'Capture sign-off audit events for the release file.',
      reference: 'Release approvals audit',
    );
  }

  FinancialReportReleaseEvidenceManifestItem _managementMeasureAuditTrailItem(
    List<FinancialReportManagementMeasureAuditEvent>
    managementMeasureAuditEvents,
  ) {
    return FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.managementMeasureAuditTrail,
      title: 'UKTM audit trail',
      status:
          managementMeasureAuditEvents.isNotEmpty
              ? FinancialReportReleaseEvidenceStatus.ready
              : FinancialReportReleaseEvidenceStatus.missing,
      detail:
          managementMeasureAuditEvents.isNotEmpty
              ? '${managementMeasureAuditEvents.length} UKTM management-measure event(s) captured.'
              : 'Capture UKTM approval audit events before archive.',
      reference: 'UKTM management measures audit',
    );
  }

  FinancialReportReleaseEvidenceManifestItem _distributionRegisterItem(
    List<FinancialReportReleaseDistributionItem> distributionItems,
  ) {
    final completeCount = distributionService.completedCount(distributionItems);
    final exceptionCount = distributionService.exceptionCount(
      distributionItems,
    );
    final distributionComplete = distributionService.distributionComplete(
      distributionItems,
    );
    return FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.distributionRegister,
      title: 'Distribution register',
      status:
          distributionItems.isEmpty
              ? FinancialReportReleaseEvidenceStatus.missing
              : distributionComplete
              ? FinancialReportReleaseEvidenceStatus.ready
              : FinancialReportReleaseEvidenceStatus.attention,
      detail:
          distributionItems.isEmpty
              ? 'Configure report pack recipients before archive.'
              : '$completeCount/${distributionItems.length} recipient(s) complete; $exceptionCount exception(s).',
      reference: 'Release recipients',
    );
  }

  FinancialReportReleaseEvidenceManifestItem _distributionAuditTrailItem(
    List<FinancialReportReleaseDistributionAuditEvent> distributionAuditEvents,
  ) {
    return FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.distributionAuditTrail,
      title: 'Distribution audit trail',
      status:
          distributionAuditEvents.isNotEmpty
              ? FinancialReportReleaseEvidenceStatus.ready
              : FinancialReportReleaseEvidenceStatus.missing,
      detail:
          distributionAuditEvents.isNotEmpty
              ? '${distributionAuditEvents.length} distribution event(s) captured.'
              : 'Capture distribution audit events for the release file.',
      reference: 'Release distribution audit',
    );
  }

  String _nextAction(
    List<FinancialReportReleaseEvidenceManifestItem> items,
    bool archiveReady,
  ) {
    if (archiveReady) {
      return 'Release evidence manifest is complete. Archive it with the report pack.';
    }
    final blocker = items.firstWhere(
      (item) =>
          item.requiredForArchive &&
          item.status != FinancialReportReleaseEvidenceStatus.ready,
    );
    return '${blocker.title}: ${blocker.detail}';
  }
}
