import '../models/financial_report_management_measure.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_signoff.dart';
import 'financial_report_management_measure_service.dart';
import 'financial_report_release_signoff_service.dart';

class FinancialReportReleaseGateService {
  final FinancialReportReleaseSignOffService signOffService;
  final FinancialReportManagementMeasureService managementMeasureService;

  const FinancialReportReleaseGateService({
    this.signOffService = const FinancialReportReleaseSignOffService(),
    this.managementMeasureService =
        const FinancialReportManagementMeasureService(),
  });

  bool canDistribute({
    required Iterable<FinancialReportReleaseSignOffItem> signOffItems,
    required FinancialReportPackageIntegrity packageIntegrity,
    Iterable<FinancialReportManagementMeasureReconciliation>
        managementMeasureReconciliations =
        const [],
  }) {
    return distributionLockedReason(
          signOffItems: signOffItems,
          packageIntegrity: packageIntegrity,
          managementMeasureReconciliations: managementMeasureReconciliations,
        ) ==
        null;
  }

  String? distributionLockedReason({
    required Iterable<FinancialReportReleaseSignOffItem> signOffItems,
    required FinancialReportPackageIntegrity packageIntegrity,
    Iterable<FinancialReportManagementMeasureReconciliation>
        managementMeasureReconciliations =
        const [],
  }) {
    final items = signOffItems.toList();
    if (!signOffService.releaseReady(items)) {
      return 'Complete all required release sign-offs before distribution.';
    }
    if (!packageIntegrity.isVerified) {
      return packageIntegrity.detail;
    }
    final reconciliations = managementMeasureReconciliations.toList();
    if (reconciliations.isNotEmpty) {
      return managementMeasureService.releaseLockedReason(reconciliations);
    }
    return null;
  }
}
