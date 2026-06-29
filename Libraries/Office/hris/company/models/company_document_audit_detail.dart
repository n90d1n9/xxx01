import '../../employee/models/employee_compliance_models.dart';
import '../../employee/models/employee_document_request_models.dart';
import 'company_document.dart';
import 'company_document_audit_event.dart';
import 'company_document_audit_filter.dart';
import 'company_employee_document_gap.dart';

class CompanyDocumentAuditDetail {
  final CompanyDocumentAuditEvent event;
  final CompanyDocumentRecord? companyDocument;
  final CompanyEmployeeDocumentGap? employeeDocumentGap;
  final EmployeeDocumentRequest? employeeDocumentRequest;
  final List<EmployeeComplianceDocumentRecord> evidenceRecords;

  const CompanyDocumentAuditDetail({
    required this.event,
    required this.companyDocument,
    required this.employeeDocumentGap,
    required this.employeeDocumentRequest,
    required this.evidenceRecords,
  });

  bool get isEmployeeDocumentEvent => event.type.isEmployeeDocumentEvent;

  bool get hasEmployeeDocumentContext {
    return employeeDocumentGap != null ||
        employeeDocumentRequest != null ||
        evidenceRecords.isNotEmpty;
  }

  int get linkedRecordCount {
    return [
      if (companyDocument != null) companyDocument,
      if (employeeDocumentGap != null) employeeDocumentGap,
      if (employeeDocumentRequest != null) employeeDocumentRequest,
      ...evidenceRecords,
    ].length;
  }
}
