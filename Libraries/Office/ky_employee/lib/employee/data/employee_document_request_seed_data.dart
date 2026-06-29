import '../models/employee_directory_models.dart';
import '../models/employee_document_request_models.dart';

EmployeeDocumentRequestProfile buildEmployeeDocumentRequestProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeDocumentRequestProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    requests: _requestsFor(member, today),
  );
}

EmployeeDocumentRequestDraft buildEmployeeDocumentRequestDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeDocumentRequestDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeDocumentRequestType.employmentLetter,
    title: 'Employment letter request',
    requestedBy: member.name,
    owner: 'People Operations',
    dueDate: today.add(const Duration(days: 7)),
    purpose: '',
    deliveryMethod: EmployeeDocumentDeliveryMethod.portal,
    requiresAcknowledgement: false,
  );
}

List<EmployeeDocumentRequest> _requestsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeDocumentRequest(
        id: 'EDR-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeDocumentRequestType.policyAcknowledgement,
        title: 'Updated product data handling policy',
        requestedBy: 'People Operations',
        owner: 'HR Compliance',
        requestedAt: today.subtract(const Duration(days: 10)),
        dueDate: today.subtract(const Duration(days: 2)),
        purpose: 'Acknowledge policy refresh after role scope update.',
        deliveryMethod: EmployeeDocumentDeliveryMethod.portal,
        requiresAcknowledgement: true,
        status: EmployeeDocumentRequestStatus.issued,
        acknowledgedAt: null,
      ),
      EmployeeDocumentRequest(
        id: 'EDR-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeDocumentRequestType.contractAddendum,
        title: 'Role scope addendum',
        requestedBy: member.manager,
        owner: 'People Operations',
        requestedAt: today.subtract(const Duration(days: 1)),
        dueDate: today.add(const Duration(days: 4)),
        purpose: 'Prepare contract addendum for revised product ownership.',
        deliveryMethod: EmployeeDocumentDeliveryMethod.pdf,
        requiresAcknowledgement: true,
        status: EmployeeDocumentRequestStatus.reviewing,
        acknowledgedAt: null,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeDocumentRequest(
        id: 'EDR-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeDocumentRequestType.employmentLetter,
        title: 'First-day employment verification',
        requestedBy: member.name,
        owner: 'People Operations',
        requestedAt: today,
        dueDate: today.add(const Duration(days: 3)),
        purpose: 'Provide onboarding employment verification letter.',
        deliveryMethod: EmployeeDocumentDeliveryMethod.portal,
        requiresAcknowledgement: false,
        status: EmployeeDocumentRequestStatus.requested,
        acknowledgedAt: null,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeDocumentRequest(
        id: 'EDR-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeDocumentRequestType.salaryCertificate,
        title: 'Salary certificate for loan application',
        requestedBy: member.name,
        owner: 'Payroll Operations',
        requestedAt: today.subtract(const Duration(days: 15)),
        dueDate: today.subtract(const Duration(days: 10)),
        purpose: 'Salary certificate issued for employee bank application.',
        deliveryMethod: EmployeeDocumentDeliveryMethod.pdf,
        requiresAcknowledgement: false,
        status: EmployeeDocumentRequestStatus.issued,
        acknowledgedAt: null,
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
