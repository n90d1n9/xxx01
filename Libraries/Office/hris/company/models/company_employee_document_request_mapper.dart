import '../../employee/models/employee_document_request_models.dart';
import 'company_document_requirement.dart';
import 'company_employee_document_gap.dart';

EmployeeDocumentRequestDraft buildEmployeeDocumentRequestDraftFromGap({
  required CompanyEmployeeDocumentGap gap,
  required EmployeeDocumentRequestDraft baseDraft,
  required DateTime actionAsOfDate,
}) {
  final owner = _ownerFor(gap);

  return baseDraft.copyWith(
    type: EmployeeDocumentRequestType.custom,
    title: companyEmployeeDocumentRequestTitleForGap(gap),
    requestedBy: owner,
    owner: owner,
    dueDate: _normalizedDueDate(
      gapDueDate: gap.dueDate,
      actionAsOfDate: actionAsOfDate,
      draftAsOfDate: baseDraft.asOfDate,
    ),
    purpose: _purposeFor(gap),
    deliveryMethod: EmployeeDocumentDeliveryMethod.portal,
    requiresAcknowledgement: false,
    correlationId: gap.id,
  );
}

bool employeeDocumentRequestMatchesCompanyGap({
  required EmployeeDocumentRequest request,
  required CompanyEmployeeDocumentGap gap,
}) {
  if (request.correlationId.trim().isNotEmpty) {
    return request.correlationId == gap.id;
  }

  return request.employeeId == gap.employeeId &&
      request.type == EmployeeDocumentRequestType.custom &&
      request.title == companyEmployeeDocumentRequestTitleForGap(gap) &&
      request.owner == _ownerFor(gap) &&
      request.requestedBy == _ownerFor(gap) &&
      !request.requiresAcknowledgement;
}

String companyEmployeeDocumentRequestTitleForGap(
  CompanyEmployeeDocumentGap gap,
) {
  final requirement =
      gap.requirementName.trim().isEmpty
          ? 'Employee document evidence'
          : gap.requirementName.trim();
  return '$requirement request';
}

String _ownerFor(CompanyEmployeeDocumentGap gap) {
  return gap.ownerName.trim().isEmpty
      ? 'People Operations'
      : gap.ownerName.trim();
}

String _purposeFor(CompanyEmployeeDocumentGap gap) {
  final missing =
      gap.missingDocumentCount == 1
          ? '1 missing document'
          : '${gap.missingDocumentCount} missing documents';
  return 'Collect $missing for ${gap.stage.label.toLowerCase()} evidence under ${gap.entityName}.';
}

DateTime _normalizedDueDate({
  required DateTime gapDueDate,
  required DateTime actionAsOfDate,
  required DateTime draftAsOfDate,
}) {
  final today = _latestDateOnly(actionAsOfDate, draftAsOfDate);
  final dueDate = _dateOnly(gapDueDate);
  if (dueDate.isBefore(today)) {
    return today.add(const Duration(days: 3));
  }
  return dueDate;
}

DateTime _latestDateOnly(DateTime first, DateTime second) {
  final firstDate = _dateOnly(first);
  final secondDate = _dateOnly(second);
  return firstDate.isAfter(secondDate) ? firstDate : secondDate;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
