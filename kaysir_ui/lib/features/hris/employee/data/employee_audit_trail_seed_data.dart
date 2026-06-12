import '../models/employee_audit_trail_models.dart';
import '../models/employee_directory_models.dart';

EmployeeAuditTrailProfile buildEmployeeAuditTrailProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeAuditTrailProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    entries: _entriesFor(member, today),
  );
}

EmployeeAuditTrailDraft buildEmployeeAuditTrailDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeAuditTrailDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    source: EmployeeAuditTrailSource.profile,
    actionType: EmployeeAuditTrailActionType.note,
    severity: EmployeeAuditTrailSeverity.info,
    title: 'Manual audit note',
    detail: '',
    actor: 'People Operations',
    containsSensitiveData: false,
  );
}

List<EmployeeAuditTrailEntry> _entriesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final base = [
    EmployeeAuditTrailEntry(
      id: 'EAT-${member.id}-001',
      employeeId: member.id,
      employeeName: member.name,
      source: EmployeeAuditTrailSource.records,
      actionType: EmployeeAuditTrailActionType.verified,
      severity: EmployeeAuditTrailSeverity.info,
      reviewStatus: EmployeeAuditTrailReviewStatus.reviewed,
      title: 'Employment agreement verified',
      detail: 'Signed employment agreement was verified in the document vault.',
      actor: member.manager,
      occurredAt: today.subtract(const Duration(days: 18)),
      retentionUntil: today.add(const Duration(days: 365 * 7)),
      containsSensitiveData: true,
    ),
    EmployeeAuditTrailEntry(
      id: 'EAT-${member.id}-002',
      employeeId: member.id,
      employeeName: member.name,
      source: EmployeeAuditTrailSource.system,
      actionType: EmployeeAuditTrailActionType.updated,
      severity: EmployeeAuditTrailSeverity.notice,
      reviewStatus: EmployeeAuditTrailReviewStatus.logged,
      title: 'Profile completeness recalculated',
      detail:
          'Employee profile readiness was recalculated from live HRIS modules.',
      actor: 'HRIS automation',
      occurredAt: today.subtract(const Duration(days: 2)),
      retentionUntil: today.add(const Duration(days: 365 * 3)),
      containsSensitiveData: false,
    ),
  ];

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeAuditTrailEntry(
        id: 'EAT-${member.id}-003',
        employeeId: member.id,
        employeeName: member.name,
        source: EmployeeAuditTrailSource.pay,
        actionType: EmployeeAuditTrailActionType.escalated,
        severity: EmployeeAuditTrailSeverity.critical,
        reviewStatus: EmployeeAuditTrailReviewStatus.escalated,
        title: 'Compensation exception escalated',
        detail:
            'Pay-band exception was escalated for People and Finance review.',
        actor: 'People Operations',
        occurredAt: today.subtract(const Duration(days: 2)),
        retentionUntil: today.add(const Duration(days: 365 * 7)),
        containsSensitiveData: true,
      ),
      EmployeeAuditTrailEntry(
        id: 'EAT-${member.id}-004',
        employeeId: member.id,
        employeeName: member.name,
        source: EmployeeAuditTrailSource.work,
        actionType: EmployeeAuditTrailActionType.updated,
        severity: EmployeeAuditTrailSeverity.warning,
        reviewStatus: EmployeeAuditTrailReviewStatus.reviewRequired,
        title: 'Work permit evidence requested',
        detail:
            'Renewal packet requires refreshed authorization evidence before expiry.',
        actor: 'People Operations',
        occurredAt: today.subtract(const Duration(days: 1)),
        retentionUntil: today.add(const Duration(days: 365 * 7)),
        containsSensitiveData: true,
      ),
      ...base,
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeAuditTrailEntry(
        id: 'EAT-${member.id}-003',
        employeeId: member.id,
        employeeName: member.name,
        source: EmployeeAuditTrailSource.records,
        actionType: EmployeeAuditTrailActionType.created,
        severity: EmployeeAuditTrailSeverity.warning,
        reviewStatus: EmployeeAuditTrailReviewStatus.reviewRequired,
        title: 'Identity upload requested',
        detail:
            'Identity evidence upload is required before payroll can close.',
        actor: 'People Operations',
        occurredAt: today,
        retentionUntil: today.add(const Duration(days: 365 * 7)),
        containsSensitiveData: true,
      ),
      EmployeeAuditTrailEntry(
        id: 'EAT-${member.id}-004',
        employeeId: member.id,
        employeeName: member.name,
        source: EmployeeAuditTrailSource.work,
        actionType: EmployeeAuditTrailActionType.created,
        severity: EmployeeAuditTrailSeverity.notice,
        reviewStatus: EmployeeAuditTrailReviewStatus.logged,
        title: 'Contract issued for signature',
        detail: 'Employment agreement was issued through onboarding workflow.',
        actor: member.manager,
        occurredAt: today.subtract(const Duration(days: 1)),
        retentionUntil: today.add(const Duration(days: 365 * 7)),
        containsSensitiveData: true,
      ),
      ...base,
    ];
  }

  return base;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
