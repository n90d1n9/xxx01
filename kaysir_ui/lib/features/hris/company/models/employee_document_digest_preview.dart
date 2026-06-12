import 'company_employee_document_workload.dart';
import 'company_employee_document_workload_digest_status.dart';

/// Aggregated preview for a due employee document digest dispatch.
class EmployeeDocumentDigestPreview {
  final List<EmployeeDocumentDigestPreviewOwner> owners;

  const EmployeeDocumentDigestPreview({required this.owners});

  bool get isEmpty => owners.isEmpty;

  int get ownerCount => owners.length;

  int get gapCount =>
      owners.fold(0, (total, owner) => total + owner.workload.gapCount);

  int get missingDocumentCount => owners.fold(
    0,
    (total, owner) => total + owner.workload.missingDocumentCount,
  );

  int get openRequestCount =>
      owners.fold(0, (total, owner) => total + owner.workload.openRequestCount);

  int get escalationCount =>
      owners.where((owner) => owner.workload.requiresEscalation).length;

  List<String> get ownerNames => [
    for (final owner in owners) owner.workload.ownerName,
  ];
}

/// Owner-level digest preview row with workload and freshness context.
class EmployeeDocumentDigestPreviewOwner {
  final CompanyEmployeeDocumentWorkload workload;
  final CompanyEmployeeDocumentWorkloadDigestStatus digestStatus;
  final DateTime asOfDate;

  const EmployeeDocumentDigestPreviewOwner({
    required this.workload,
    required this.digestStatus,
    required this.asOfDate,
  });

  bool get isDue =>
      digestStatus.isDueFor(workload: workload, asOfDate: asOfDate);

  String get freshnessLabel =>
      digestStatus.freshnessLabel(workload: workload, asOfDate: asOfDate);

  String get cadenceLabel => digestStatus.cadenceLabel(workload);

  String get lastSentLabel => digestStatus.label(asOfDate);

  String get primarySummary {
    if (workload.primaryEmployeeName.trim().isEmpty) {
      return '${workload.primaryAction}, ${workload.score} workload score';
    }
    return '${workload.primaryAction} for ${workload.primaryEmployeeName}';
  }
}

/// Builds a deduplicated digest preview from selected owner names.
EmployeeDocumentDigestPreview buildEmployeeDocumentDigestPreview({
  required Iterable<String> ownerNames,
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyEmployeeDocumentWorkloadDigestStatus> digestStatuses,
  required DateTime asOfDate,
}) {
  final workloadsByOwner = {
    for (final workload in workloads) _ownerKey(workload.ownerName): workload,
  };
  final statusesByOwner = {
    for (final status in digestStatuses) _ownerKey(status.ownerName): status,
  };
  final seenOwners = <String>{};
  final owners = <EmployeeDocumentDigestPreviewOwner>[];

  for (final ownerName in ownerNames) {
    final key = _ownerKey(ownerName);
    if (!seenOwners.add(key)) continue;

    final workload = workloadsByOwner[key];
    if (workload == null) continue;

    owners.add(
      EmployeeDocumentDigestPreviewOwner(
        workload: workload,
        digestStatus:
            statusesByOwner[key] ??
            CompanyEmployeeDocumentWorkloadDigestStatus(
              ownerName: workload.ownerName,
              digestCount: 0,
              lastSentAt: null,
              lastAuditEventId: '',
            ),
        asOfDate: asOfDate,
      ),
    );
  }

  return EmployeeDocumentDigestPreview(owners: owners);
}

String _ownerKey(String ownerName) => ownerName.trim().toLowerCase();
