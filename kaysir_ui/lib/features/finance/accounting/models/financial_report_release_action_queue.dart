enum FinancialReportReleaseActionArea {
  packageIntegrity,
  managementMeasures,
  signOff,
  evidenceManifest,
  distribution,
  archive,
  retention,
  statutoryFiling,
}

extension FinancialReportReleaseActionAreaLabel
    on FinancialReportReleaseActionArea {
  String get label {
    switch (this) {
      case FinancialReportReleaseActionArea.packageIntegrity:
        return 'Package integrity';
      case FinancialReportReleaseActionArea.managementMeasures:
        return 'UKTM';
      case FinancialReportReleaseActionArea.signOff:
        return 'Sign-off';
      case FinancialReportReleaseActionArea.evidenceManifest:
        return 'Evidence';
      case FinancialReportReleaseActionArea.distribution:
        return 'Distribution';
      case FinancialReportReleaseActionArea.archive:
        return 'Archive';
      case FinancialReportReleaseActionArea.retention:
        return 'Retention';
      case FinancialReportReleaseActionArea.statutoryFiling:
        return 'Statutory filing';
    }
  }
}

enum FinancialReportReleaseActionPriority { critical, high, normal }

extension FinancialReportReleaseActionPriorityLabel
    on FinancialReportReleaseActionPriority {
  String get label {
    switch (this) {
      case FinancialReportReleaseActionPriority.critical:
        return 'Critical';
      case FinancialReportReleaseActionPriority.high:
        return 'High';
      case FinancialReportReleaseActionPriority.normal:
        return 'Normal';
    }
  }
}

enum FinancialReportReleaseActionDestination {
  reportPack,
  signOff,
  evidenceManifest,
  distribution,
  archive,
  retention,
  statutoryFiling,
  managementMeasureReleaseChecklist,
  managementMeasureApprovalCheck,
  managementMeasureReconciliationCheck,
  managementMeasureExportEvidenceCheck,
  managementMeasureAuditTrail,
}

extension FinancialReportReleaseActionDestinationLabel
    on FinancialReportReleaseActionDestination {
  String get label {
    switch (this) {
      case FinancialReportReleaseActionDestination.reportPack:
        return 'Open Report pack';
      case FinancialReportReleaseActionDestination.signOff:
        return 'Open Sign-off';
      case FinancialReportReleaseActionDestination.evidenceManifest:
        return 'Open Evidence';
      case FinancialReportReleaseActionDestination.distribution:
        return 'Open Distribution';
      case FinancialReportReleaseActionDestination.archive:
        return 'Open Archive';
      case FinancialReportReleaseActionDestination.retention:
        return 'Open Retention';
      case FinancialReportReleaseActionDestination.statutoryFiling:
        return 'Open Filing';
      case FinancialReportReleaseActionDestination
          .managementMeasureReleaseChecklist:
      case FinancialReportReleaseActionDestination
          .managementMeasureApprovalCheck:
      case FinancialReportReleaseActionDestination
          .managementMeasureReconciliationCheck:
      case FinancialReportReleaseActionDestination
          .managementMeasureExportEvidenceCheck:
      case FinancialReportReleaseActionDestination.managementMeasureAuditTrail:
        return 'Open UKTM';
    }
  }
}

class FinancialReportReleaseActionItem {
  final String id;
  final FinancialReportReleaseActionArea area;
  final FinancialReportReleaseActionPriority priority;
  final String title;
  final String owner;
  final DateTime? dueDate;
  final String detail;
  final String reference;
  final bool blocked;
  final FinancialReportReleaseActionDestination? destination;

  const FinancialReportReleaseActionItem({
    required this.id,
    required this.area,
    required this.priority,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.detail,
    required this.reference,
    this.blocked = false,
    this.destination,
  });
}

class FinancialReportReleaseActionQueueSummary {
  final List<FinancialReportReleaseActionItem> items;
  final int criticalCount;
  final int highCount;
  final int overdueCount;
  final int blockedCount;
  final String nextAction;

  const FinancialReportReleaseActionQueueSummary({
    required this.items,
    required this.criticalCount,
    required this.highCount,
    required this.overdueCount,
    required this.blockedCount,
    required this.nextAction,
  });

  int get totalCount => items.length;

  bool get isClear => items.isEmpty;
}
