import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_release_evidence_manifest.dart';
import '../../services/financial_report_release_evidence_manifest_service.dart';
import 'financial_report_management_measure_provider.dart';
import 'financial_report_package_integrity_provider.dart';
import 'financial_report_release_distribution_provider.dart';
import 'financial_report_release_signoff_provider.dart';

final financialReportReleaseEvidenceManifestServiceProvider =
    Provider<FinancialReportReleaseEvidenceManifestService>((ref) {
      return const FinancialReportReleaseEvidenceManifestService();
    });

final currentFinancialReportReleaseEvidenceManifestProvider =
    Provider<FinancialReportReleaseEvidenceManifestSummary>((ref) {
      return ref
          .watch(financialReportReleaseEvidenceManifestServiceProvider)
          .buildManifest(
            packageIntegrity: ref.watch(
              currentFinancialReportPackageIntegrityProvider,
            ),
            signOffItems: ref.watch(
              currentFinancialReportReleaseSignOffItemsProvider,
            ),
            signOffAuditEvents: ref.watch(
              currentFinancialReportReleaseSignOffAuditProvider,
            ),
            managementMeasureAuditEvents: ref.watch(
              currentFinancialReportManagementMeasureAuditProvider,
            ),
            distributionItems: ref.watch(
              currentFinancialReportReleaseDistributionItemsProvider,
            ),
            distributionAuditEvents: ref.watch(
              currentFinancialReportReleaseDistributionAuditProvider,
            ),
          );
    });
