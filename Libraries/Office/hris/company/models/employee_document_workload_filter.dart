import 'company_employee_document_workload.dart';
import 'company_employee_document_workload_digest_status.dart';

const employeeDocumentHighMissingThreshold = 5;

/// Filters employee document owner workloads for focused HR triage.
enum EmployeeDocumentWorkloadFilter {
  all,
  dueDigest,
  escalation,
  watchlist,
  highMissing,
  noDigest,
}

/// Presentation labels and matching logic for workload filters.
extension EmployeeDocumentWorkloadFilterDetails
    on EmployeeDocumentWorkloadFilter {
  String get label {
    switch (this) {
      case EmployeeDocumentWorkloadFilter.all:
        return 'All';
      case EmployeeDocumentWorkloadFilter.dueDigest:
        return 'Due digest';
      case EmployeeDocumentWorkloadFilter.escalation:
        return 'Escalation';
      case EmployeeDocumentWorkloadFilter.watchlist:
        return 'Watchlist';
      case EmployeeDocumentWorkloadFilter.highMissing:
        return 'High missing';
      case EmployeeDocumentWorkloadFilter.noDigest:
        return 'No digest';
    }
  }

  bool matches({
    required CompanyEmployeeDocumentWorkload workload,
    required CompanyEmployeeDocumentWorkloadDigestStatus digestStatus,
    required DateTime asOfDate,
  }) {
    switch (this) {
      case EmployeeDocumentWorkloadFilter.all:
        return true;
      case EmployeeDocumentWorkloadFilter.dueDigest:
        return digestStatus.isDueFor(workload: workload, asOfDate: asOfDate);
      case EmployeeDocumentWorkloadFilter.escalation:
        return workload.requiresEscalation;
      case EmployeeDocumentWorkloadFilter.watchlist:
        return !workload.requiresEscalation;
      case EmployeeDocumentWorkloadFilter.highMissing:
        return workload.missingDocumentCount >=
            employeeDocumentHighMissingThreshold;
      case EmployeeDocumentWorkloadFilter.noDigest:
        return !digestStatus.hasDigest;
    }
  }
}

/// Applies the selected owner workload filter while preserving workload order.
List<CompanyEmployeeDocumentWorkload> filterEmployeeDocumentWorkloads({
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyEmployeeDocumentWorkloadDigestStatus> digestStatuses,
  required EmployeeDocumentWorkloadFilter filter,
  required DateTime asOfDate,
}) {
  final statusesByOwner = {
    for (final status in digestStatuses) _ownerKey(status.ownerName): status,
  };

  return [
    for (final workload in workloads)
      if (filter.matches(
        workload: workload,
        digestStatus:
            statusesByOwner[_ownerKey(workload.ownerName)] ??
            CompanyEmployeeDocumentWorkloadDigestStatus(
              ownerName: workload.ownerName,
              digestCount: 0,
              lastSentAt: null,
              lastAuditEventId: '',
            ),
        asOfDate: asOfDate,
      ))
        workload,
  ];
}

/// Counts owner lanes for each filter using the same matching rules as the UI.
Map<EmployeeDocumentWorkloadFilter, int> countEmployeeDocumentWorkloadFilters({
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyEmployeeDocumentWorkloadDigestStatus> digestStatuses,
  required DateTime asOfDate,
}) {
  return {
    for (final filter in EmployeeDocumentWorkloadFilter.values)
      filter:
          filterEmployeeDocumentWorkloads(
            workloads: workloads,
            digestStatuses: digestStatuses,
            filter: filter,
            asOfDate: asOfDate,
          ).length,
  };
}

String _ownerKey(String ownerName) => ownerName.trim().toLowerCase();
