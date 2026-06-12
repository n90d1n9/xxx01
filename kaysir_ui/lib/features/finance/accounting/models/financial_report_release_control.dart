enum FinancialReportReleaseControlStageKind {
  packageIntegrity,
  managementMeasures,
  signOff,
  distribution,
}

enum FinancialReportReleaseControlStageStatus {
  complete,
  actionNeeded,
  blocked,
}

extension FinancialReportReleaseControlStageStatusLabel
    on FinancialReportReleaseControlStageStatus {
  String get label {
    switch (this) {
      case FinancialReportReleaseControlStageStatus.complete:
        return 'Complete';
      case FinancialReportReleaseControlStageStatus.actionNeeded:
        return 'Action needed';
      case FinancialReportReleaseControlStageStatus.blocked:
        return 'Blocked';
    }
  }
}

class FinancialReportReleaseControlStage {
  final FinancialReportReleaseControlStageKind kind;
  final String title;
  final FinancialReportReleaseControlStageStatus status;
  final String detail;

  const FinancialReportReleaseControlStage({
    required this.kind,
    required this.title,
    required this.status,
    required this.detail,
  });
}

class FinancialReportReleaseControlSummary {
  final bool packageVerified;
  final bool signOffComplete;
  final bool distributionComplete;
  final bool releaseComplete;
  final double completionRatio;
  final String headline;
  final String nextAction;
  final List<FinancialReportReleaseControlStage> stages;

  const FinancialReportReleaseControlSummary({
    required this.packageVerified,
    required this.signOffComplete,
    required this.distributionComplete,
    required this.releaseComplete,
    required this.completionRatio,
    required this.headline,
    required this.nextAction,
    required this.stages,
  });
}
