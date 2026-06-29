import '../models/employee_directory_models.dart';
import '../models/employee_document_vault_models.dart';

EmployeeDocumentVaultProfile buildEmployeeDocumentVaultProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeDocumentVaultProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    records: _recordsFor(member, today),
  );
}

EmployeeDocumentVaultDraft buildEmployeeDocumentVaultDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeDocumentVaultDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    category: EmployeeDocumentVaultCategory.custom,
    access: EmployeeDocumentVaultAccess.employeeVisible,
    title: 'Employment document',
    owner: 'People Operations',
    expiresAt: null,
    summary: '',
  );
}

List<EmployeeDocumentVaultRecord> _recordsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeDocumentVaultRecord(
        id: 'EDV-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeDocumentVaultCategory.identity,
        status: EmployeeDocumentVaultStatus.needsUpload,
        access: EmployeeDocumentVaultAccess.employeeVisible,
        title: 'Government ID evidence',
        owner: 'People Operations',
        source: 'Onboarding checklist',
        uploadedAt: today,
        expiresAt: null,
        verifiedAt: null,
        summary: 'Employee must upload identity evidence before payroll close.',
      ),
      EmployeeDocumentVaultRecord(
        id: 'EDV-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeDocumentVaultCategory.contract,
        status: EmployeeDocumentVaultStatus.pendingReview,
        access: EmployeeDocumentVaultAccess.hrOnly,
        title: 'Signed employment agreement',
        owner: member.manager,
        source: 'Contract lifecycle',
        uploadedAt: today.subtract(const Duration(days: 1)),
        expiresAt: null,
        verifiedAt: null,
        summary: 'Signed agreement is uploaded and waiting for HR review.',
      ),
    ];
  }

  final baseRecords = [
    EmployeeDocumentVaultRecord(
      id: 'EDV-${member.id}-001',
      employeeId: member.id,
      employeeName: member.name,
      category: EmployeeDocumentVaultCategory.identity,
      status: EmployeeDocumentVaultStatus.verified,
      access: EmployeeDocumentVaultAccess.employeeVisible,
      title: 'Government ID',
      owner: 'People Operations',
      source: 'Personal records',
      uploadedAt: today.subtract(const Duration(days: 620)),
      expiresAt: today.add(const Duration(days: 1200)),
      verifiedAt: today.subtract(const Duration(days: 610)),
      summary: 'Identity document is verified and available to the employee.',
    ),
    EmployeeDocumentVaultRecord(
      id: 'EDV-${member.id}-002',
      employeeId: member.id,
      employeeName: member.name,
      category: EmployeeDocumentVaultCategory.contract,
      status: EmployeeDocumentVaultStatus.verified,
      access: EmployeeDocumentVaultAccess.hrOnly,
      title: 'Employment agreement',
      owner: member.manager,
      source: 'Contract lifecycle',
      uploadedAt: member.joiningDate,
      expiresAt: null,
      verifiedAt: member.joiningDate.add(const Duration(days: 1)),
      summary: 'Signed employment agreement is verified and archived.',
    ),
  ];

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      ...baseRecords,
      EmployeeDocumentVaultRecord(
        id: 'EDV-${member.id}-003',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeDocumentVaultCategory.workAuthorization,
        status: EmployeeDocumentVaultStatus.expiringSoon,
        access: EmployeeDocumentVaultAccess.restricted,
        title: 'Work permit renewal packet',
        owner: 'People Operations',
        source: 'Work authorization',
        uploadedAt: today.subtract(const Duration(days: 330)),
        expiresAt: today.add(const Duration(days: 28)),
        verifiedAt: today.subtract(const Duration(days: 320)),
        summary:
            'Renewal packet needs refreshed evidence before permit expiry.',
      ),
    ];
  }

  if (member.location == 'Singapore') {
    return [
      ...baseRecords,
      EmployeeDocumentVaultRecord(
        id: 'EDV-${member.id}-003',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeDocumentVaultCategory.payrollTax,
        status: EmployeeDocumentVaultStatus.verified,
        access: EmployeeDocumentVaultAccess.hrOnly,
        title: 'Tax residency declaration',
        owner: 'Payroll Operations',
        source: 'Payroll and tax',
        uploadedAt: today.subtract(const Duration(days: 90)),
        expiresAt: today.add(const Duration(days: 275)),
        verifiedAt: today.subtract(const Duration(days: 88)),
        summary: 'Tax residency declaration is verified for local payroll.',
      ),
    ];
  }

  return baseRecords;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
