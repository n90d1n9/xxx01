import 'company_document_audit_event.dart';
import 'company_document_audit_filter.dart';

class CompanyDocumentAuditActivitySummary {
  final int totalEventCount;
  final int companyDocumentEventCount;
  final int employeeDocumentEventCount;
  final int filteredEventCount;

  const CompanyDocumentAuditActivitySummary({
    required this.totalEventCount,
    required this.companyDocumentEventCount,
    required this.employeeDocumentEventCount,
    required this.filteredEventCount,
  });

  factory CompanyDocumentAuditActivitySummary.fromEvents({
    required List<CompanyDocumentAuditEvent> allEvents,
    required List<CompanyDocumentAuditEvent> filteredEvents,
  }) {
    final employeeCount =
        allEvents.where((event) => event.type.isEmployeeDocumentEvent).length;

    return CompanyDocumentAuditActivitySummary(
      totalEventCount: allEvents.length,
      companyDocumentEventCount: allEvents.length - employeeCount,
      employeeDocumentEventCount: employeeCount,
      filteredEventCount: filteredEvents.length,
    );
  }
}
