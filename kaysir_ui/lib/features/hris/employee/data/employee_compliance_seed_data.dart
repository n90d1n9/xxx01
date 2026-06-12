import '../models/employee_compliance_models.dart';
import '../models/employee_directory_models.dart';

List<EmployeeComplianceDocumentRecord> buildEmployeeComplianceRecords({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final records = [
    _record(
      id: '${member.id}-identity',
      employeeId: member.id,
      title: 'Identity verification',
      type: EmployeeComplianceDocumentType.identity,
      owner: 'HR Operations',
      dueDate: member.joiningDate.add(const Duration(days: 3)),
      uploadedAt: member.joiningDate,
      status: EmployeeComplianceDocumentStatus.verified,
      notes: 'Identity document verified during hiring.',
    ),
    _record(
      id: '${member.id}-agreement',
      employeeId: member.id,
      title: 'Employment agreement',
      type: EmployeeComplianceDocumentType.agreement,
      owner: 'People Operations',
      dueDate: member.joiningDate,
      uploadedAt: member.joiningDate,
      status: EmployeeComplianceDocumentStatus.verified,
      notes: 'Signed agreement stored in employee file.',
    ),
  ];

  if (member.location == 'Singapore') {
    records.add(
      _record(
        id: '${member.id}-work-permit',
        employeeId: member.id,
        title: 'Work permit renewal',
        type: EmployeeComplianceDocumentType.workPermit,
        owner: 'Mobility',
        dueDate: today.add(const Duration(days: 20)),
        expiresAt: today.add(const Duration(days: 35)),
        uploadedAt: today.subtract(const Duration(days: 330)),
        status: EmployeeComplianceDocumentStatus.verified,
        notes: 'Renewal package should be prepared before expiry.',
      ),
    );
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    records.addAll([
      _record(
        id: '${member.id}-tax',
        employeeId: member.id,
        title: 'Payroll tax documents',
        type: EmployeeComplianceDocumentType.tax,
        owner: 'Payroll',
        dueDate: today.subtract(const Duration(days: 1)),
        uploadedAt: today.subtract(const Duration(days: 2)),
        status: EmployeeComplianceDocumentStatus.pending,
        notes: 'New hire payroll tax documents need review.',
      ),
      _record(
        id: '${member.id}-policy',
        employeeId: member.id,
        title: 'Policy acknowledgement',
        type: EmployeeComplianceDocumentType.policy,
        owner: 'Hiring Manager',
        dueDate: today.add(const Duration(days: 4)),
        uploadedAt: today,
        status: EmployeeComplianceDocumentStatus.pending,
        notes: 'Employee handbook acknowledgement pending.',
      ),
    ]);
  } else if (member.status == EmployeeDirectoryStatus.watchlist) {
    records.addAll([
      _record(
        id: '${member.id}-coaching',
        employeeId: member.id,
        title: 'Manager coaching notes',
        type: EmployeeComplianceDocumentType.performance,
        owner: member.manager,
        dueDate: today.add(const Duration(days: 5)),
        uploadedAt: today.subtract(const Duration(days: 1)),
        status: EmployeeComplianceDocumentStatus.pending,
        notes: 'Manager coaching evidence requires HRBP verification.',
      ),
      _record(
        id: '${member.id}-pip',
        employeeId: member.id,
        title: 'Performance improvement plan',
        type: EmployeeComplianceDocumentType.performance,
        owner: 'HR Business Partner',
        dueDate: today.add(const Duration(days: 7)),
        uploadedAt: today.subtract(const Duration(days: 2)),
        status: EmployeeComplianceDocumentStatus.rejected,
        notes: 'Plan needs clearer milestones and manager signature.',
      ),
    ]);
  } else if (member.isHighPerformer) {
    records.add(
      _record(
        id: '${member.id}-growth-plan',
        employeeId: member.id,
        title: 'Growth and retention plan',
        type: EmployeeComplianceDocumentType.performance,
        owner: member.manager,
        dueDate: today.add(const Duration(days: 14)),
        uploadedAt: today.subtract(const Duration(days: 3)),
        status: EmployeeComplianceDocumentStatus.pending,
        notes: 'Growth plan ready for people partner review.',
      ),
    );
  }

  return records;
}

EmployeeComplianceDocumentDraft buildEmployeeComplianceDocumentDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeComplianceDocumentDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    title: '',
    type: EmployeeComplianceDocumentType.certification,
    owner: 'HR Operations',
    dueDate: today.add(const Duration(days: 7)),
    expiresAt: null,
    notes: '',
  );
}

EmployeeComplianceDocumentRecord _record({
  required String id,
  required String employeeId,
  required String title,
  required EmployeeComplianceDocumentType type,
  required String owner,
  required DateTime dueDate,
  required DateTime uploadedAt,
  required EmployeeComplianceDocumentStatus status,
  required String notes,
  DateTime? expiresAt,
}) {
  return EmployeeComplianceDocumentRecord(
    id: id,
    employeeId: employeeId,
    title: title,
    type: type,
    owner: owner,
    dueDate: _dateOnly(dueDate),
    expiresAt: expiresAt == null ? null : _dateOnly(expiresAt),
    uploadedAt: _dateOnly(uploadedAt),
    status: status,
    notes: notes,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
