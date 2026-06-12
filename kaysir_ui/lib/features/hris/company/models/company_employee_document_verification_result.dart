import '../../employee/models/employee_compliance_models.dart';

class CompanyEmployeeDocumentVerificationResult {
  final List<EmployeeComplianceDocumentRecord> evidenceRecords;
  final int closedRequestCount;

  const CompanyEmployeeDocumentVerificationResult({
    required this.evidenceRecords,
    required this.closedRequestCount,
  });

  const CompanyEmployeeDocumentVerificationResult.empty()
    : evidenceRecords = const [],
      closedRequestCount = 0;

  bool get hasChanges => evidenceRecords.isNotEmpty || closedRequestCount > 0;
}
