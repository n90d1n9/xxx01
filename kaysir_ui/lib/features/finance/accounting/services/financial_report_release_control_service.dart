import '../models/financial_report_management_measure.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_control.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_signoff.dart';
import 'financial_report_management_measure_service.dart';
import 'financial_report_release_distribution_service.dart';
import 'financial_report_release_gate_service.dart';
import 'financial_report_release_signoff_service.dart';

class FinancialReportReleaseControlService {
  final FinancialReportReleaseSignOffService signOffService;
  final FinancialReportManagementMeasureService managementMeasureService;
  final FinancialReportReleaseDistributionService distributionService;
  final FinancialReportReleaseGateService gateService;

  const FinancialReportReleaseControlService({
    this.signOffService = const FinancialReportReleaseSignOffService(),
    this.managementMeasureService =
        const FinancialReportManagementMeasureService(),
    this.distributionService =
        const FinancialReportReleaseDistributionService(),
    this.gateService = const FinancialReportReleaseGateService(),
  });

  FinancialReportReleaseControlSummary summarize({
    required List<FinancialReportReleaseSignOffItem> signOffItems,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required FinancialReportPackageIntegrity packageIntegrity,
    required DateTime asOf,
    List<FinancialReportManagementMeasureReconciliation>
        managementMeasureReconciliations =
        const [],
  }) {
    final packageVerified = packageIntegrity.isVerified;
    final hasManagementMeasures = managementMeasureReconciliations.isNotEmpty;
    final managementMeasuresReady =
        !hasManagementMeasures ||
        managementMeasureService.releaseReady(managementMeasureReconciliations);
    final managementMeasureLockedReason =
        hasManagementMeasures
            ? managementMeasureService.releaseLockedReason(
              managementMeasureReconciliations,
            )
            : null;
    final signOffComplete = signOffService.releaseReady(signOffItems);
    final distributionComplete = distributionService.distributionComplete(
      distributionItems,
    );
    final distributionLockedReason = gateService.distributionLockedReason(
      signOffItems: signOffItems,
      packageIntegrity: packageIntegrity,
      managementMeasureReconciliations: managementMeasureReconciliations,
    );
    final exceptionCount = distributionService.exceptionCount(
      distributionItems,
    );
    final overdueCount = distributionService.overdueCount(
      distributionItems,
      asOf,
    );
    final stageCount = hasManagementMeasures ? 4 : 3;
    final completedStages =
        [
          packageVerified,
          if (hasManagementMeasures) managementMeasuresReady,
          signOffComplete,
          distributionComplete,
        ].where((isComplete) => isComplete).length;
    final releaseComplete =
        packageVerified &&
        managementMeasuresReady &&
        signOffComplete &&
        distributionComplete;

    return FinancialReportReleaseControlSummary(
      packageVerified: packageVerified,
      signOffComplete: signOffComplete,
      distributionComplete: distributionComplete,
      releaseComplete: releaseComplete,
      completionRatio: completedStages / stageCount,
      headline: releaseComplete ? 'Ready to release' : 'Release in progress',
      nextAction: _nextAction(
        packageIntegrity: packageIntegrity,
        packageVerified: packageVerified,
        hasManagementMeasures: hasManagementMeasures,
        managementMeasuresReady: managementMeasuresReady,
        managementMeasureLockedReason: managementMeasureLockedReason,
        signOffComplete: signOffComplete,
        distributionItems: distributionItems,
        distributionComplete: distributionComplete,
        distributionLockedReason: distributionLockedReason,
        exceptionCount: exceptionCount,
        overdueCount: overdueCount,
      ),
      stages: [
        FinancialReportReleaseControlStage(
          kind: FinancialReportReleaseControlStageKind.packageIntegrity,
          title: 'Package integrity',
          status:
              packageVerified
                  ? FinancialReportReleaseControlStageStatus.complete
                  : FinancialReportReleaseControlStageStatus.blocked,
          detail: packageIntegrity.detail,
        ),
        if (hasManagementMeasures)
          FinancialReportReleaseControlStage(
            kind: FinancialReportReleaseControlStageKind.managementMeasures,
            title: 'UKTM readiness',
            status:
                managementMeasuresReady
                    ? FinancialReportReleaseControlStageStatus.complete
                    : managementMeasureService.openVarianceCount(
                          managementMeasureReconciliations,
                        ) >
                        0
                    ? FinancialReportReleaseControlStageStatus.blocked
                    : FinancialReportReleaseControlStageStatus.actionNeeded,
            detail:
                managementMeasureLockedReason ??
                '${managementMeasureService.approvedCount(managementMeasureReconciliations)}/${managementMeasureReconciliations.length} UKTM measure(s) approved with no variance.',
          ),
        FinancialReportReleaseControlStage(
          kind: FinancialReportReleaseControlStageKind.signOff,
          title: 'Release sign-offs',
          status:
              signOffComplete
                  ? FinancialReportReleaseControlStageStatus.complete
                  : FinancialReportReleaseControlStageStatus.actionNeeded,
          detail:
              '${signOffService.signedCount(signOffItems)}/${signOffItems.length} required sign-off(s) complete.',
        ),
        FinancialReportReleaseControlStage(
          kind: FinancialReportReleaseControlStageKind.distribution,
          title: 'Distribution',
          status:
              distributionComplete
                  ? FinancialReportReleaseControlStageStatus.complete
                  : distributionLockedReason != null
                  ? FinancialReportReleaseControlStageStatus.blocked
                  : FinancialReportReleaseControlStageStatus.actionNeeded,
          detail: _distributionDetail(
            distributionItems: distributionItems,
            exceptionCount: exceptionCount,
            overdueCount: overdueCount,
          ),
        ),
      ],
    );
  }

  String _nextAction({
    required FinancialReportPackageIntegrity packageIntegrity,
    required bool packageVerified,
    required bool hasManagementMeasures,
    required bool managementMeasuresReady,
    required String? managementMeasureLockedReason,
    required bool signOffComplete,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required bool distributionComplete,
    required String? distributionLockedReason,
    required int exceptionCount,
    required int overdueCount,
  }) {
    if (!packageVerified) {
      return packageIntegrity.detail;
    }
    if (hasManagementMeasures && !managementMeasuresReady) {
      return managementMeasureLockedReason ??
          'Complete UKTM management measure readiness.';
    }
    if (!signOffComplete) {
      return 'Complete all required release sign-offs.';
    }
    if (distributionLockedReason != null) {
      return distributionLockedReason;
    }
    if (distributionItems.isEmpty) {
      return 'Configure release distribution recipients.';
    }
    if (exceptionCount > 0) {
      return 'Resolve $exceptionCount distribution exception(s).';
    }
    if (overdueCount > 0) {
      return 'Clear $overdueCount overdue distribution item(s).';
    }
    if (!distributionComplete) {
      return 'Send the released pack and capture required acknowledgements.';
    }
    return 'Release controls are complete. Archive the release evidence pack.';
  }

  String _distributionDetail({
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required int exceptionCount,
    required int overdueCount,
  }) {
    if (distributionItems.isEmpty) {
      return 'No distribution recipients are configured.';
    }
    final completeCount = distributionService.completedCount(distributionItems);
    final acknowledgedCount = distributionService.acknowledgedCount(
      distributionItems,
    );
    final issues = <String>[];
    if (exceptionCount > 0) {
      issues.add('$exceptionCount exception(s)');
    }
    if (overdueCount > 0) {
      issues.add('$overdueCount overdue');
    }
    final issueLabel = issues.isEmpty ? '' : ' / ${issues.join(', ')}';
    return '$completeCount/${distributionItems.length} distribution item(s) complete, $acknowledgedCount acknowledged$issueLabel.';
  }
}
