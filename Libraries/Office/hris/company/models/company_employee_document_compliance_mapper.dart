import '../../employee/models/employee_compliance_models.dart';
import 'company_document_requirement.dart';
import 'company_employee_document_gap.dart';

EmployeeComplianceDocumentDraft buildEmployeeComplianceDocumentDraftFromGap({
  required CompanyEmployeeDocumentGap gap,
  required EmployeeComplianceDocumentDraft baseDraft,
  required int sequenceNumber,
}) {
  final owner =
      gap.ownerName.trim().isEmpty ? 'People Operations' : gap.ownerName.trim();

  return baseDraft.copyWith(
    title: _titleFor(gap, sequenceNumber),
    type: _typeFor(gap.stage),
    owner: owner,
    dueDate: _dateOnly(gap.dueDate),
    expiresAt: null,
    notes: _notesFor(gap, sequenceNumber),
    correlationId: gap.id,
  );
}

bool employeeComplianceRecordMatchesCompanyGap({
  required EmployeeComplianceDocumentRecord record,
  required CompanyEmployeeDocumentGap gap,
}) {
  if (record.correlationId.trim().isNotEmpty) {
    return record.correlationId == gap.id;
  }

  return record.employeeId == gap.employeeId &&
      record.title.startsWith(
        '${companyEmployeeDocumentEvidenceTitlePrefixForGap(gap)} ',
      );
}

String companyEmployeeDocumentEvidenceTitlePrefixForGap(
  CompanyEmployeeDocumentGap gap,
) {
  final requirement =
      gap.requirementName.trim().isEmpty
          ? 'Employee document evidence'
          : gap.requirementName.trim();
  return '$requirement evidence';
}

String _titleFor(CompanyEmployeeDocumentGap gap, int sequenceNumber) {
  return '${companyEmployeeDocumentEvidenceTitlePrefixForGap(gap)} $sequenceNumber';
}

EmployeeComplianceDocumentType _typeFor(CompanyDocumentRequirementStage stage) {
  switch (stage) {
    case CompanyDocumentRequirementStage.preboarding:
    case CompanyDocumentRequirementStage.onboarding:
      return EmployeeComplianceDocumentType.identity;
    case CompanyDocumentRequirementStage.probation:
      return EmployeeComplianceDocumentType.performance;
    case CompanyDocumentRequirementStage.activeEmployment:
      return EmployeeComplianceDocumentType.policy;
    case CompanyDocumentRequirementStage.offboarding:
    case CompanyDocumentRequirementStage.postEmployment:
      return EmployeeComplianceDocumentType.agreement;
  }
}

String _notesFor(CompanyEmployeeDocumentGap gap, int sequenceNumber) {
  return 'Verified company ${gap.stage.label.toLowerCase()} evidence item $sequenceNumber for ${gap.entityName}.';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
