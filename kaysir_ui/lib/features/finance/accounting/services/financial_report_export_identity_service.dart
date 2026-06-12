import '../models/financial_period_close.dart';
import '../models/financial_report_export_identity.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_evidence_manifest.dart';

class FinancialReportExportIdentityService {
  final String generatedBy;

  const FinancialReportExportIdentityService({this.generatedBy = 'Kaysir'});

  FinancialReportExportIdentity build({
    required FinancialReportPack pack,
    FinancialPeriodCloseRecord? closeRecord,
    FinancialReportPackageIntegrity? packageIntegrity,
    FinancialReportReleaseEvidenceManifestSummary? releaseEvidenceManifest,
  }) {
    final certifiedClose = packageIntegrity?.closeRecord ?? closeRecord;

    return FinancialReportExportIdentity(
      generatedBy: generatedBy,
      generatedAt: pack.generatedAt,
      entityName: pack.entityName,
      periodLabel: pack.periodLabel,
      frameworkName: pack.frameworkName,
      jurisdiction: pack.jurisdiction,
      currency: pack.presentationCurrency,
      packageStatus: _packageStatus(certifiedClose, packageIntegrity),
      packageDetail: _packageDetail(certifiedClose, packageIntegrity),
      periodLockHash: certifiedClose?.reportPackageShortHash ?? '',
      closedPackageAlgorithm:
          packageIntegrity?.closedAlgorithm ??
          certifiedClose?.reportPackageHashAlgorithm ??
          '',
      currentPackageHash: packageIntegrity?.currentShortHash ?? '',
      currentPackageAlgorithm: packageIntegrity?.currentAlgorithm ?? '',
      evidenceReadyCount: releaseEvidenceManifest?.readyCount,
      evidenceAttentionCount: releaseEvidenceManifest?.attentionCount,
      evidenceMissingCount: releaseEvidenceManifest?.missingCount,
      evidenceCompletionRatio: releaseEvidenceManifest?.completionRatio,
      archiveReady: releaseEvidenceManifest?.archiveReady,
      releaseNextAction: releaseEvidenceManifest?.nextAction,
    );
  }

  String _packageStatus(
    FinancialPeriodCloseRecord? closeRecord,
    FinancialReportPackageIntegrity? packageIntegrity,
  ) {
    if (packageIntegrity != null) {
      return packageIntegrity.status.label;
    }
    if (closeRecord?.isClosed ?? false) {
      return 'Closed package without current verification';
    }
    return 'Draft export';
  }

  String _packageDetail(
    FinancialPeriodCloseRecord? closeRecord,
    FinancialReportPackageIntegrity? packageIntegrity,
  ) {
    if (packageIntegrity != null) {
      return packageIntegrity.detail;
    }
    if (closeRecord?.isClosed ?? false) {
      return 'Closed package metadata is attached, but the current package fingerprint was not verified for this export.';
    }
    return 'No period close lock is attached to this export.';
  }
}
