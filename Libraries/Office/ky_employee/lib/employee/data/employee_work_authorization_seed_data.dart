import '../models/employee_directory_models.dart';
import '../models/employee_work_authorization_models.dart';

EmployeeWorkAuthorizationProfile buildEmployeeWorkAuthorizationProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeWorkAuthorizationProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    records: _recordsFor(member, today),
  );
}

EmployeeWorkAuthorizationDraft buildEmployeeWorkAuthorizationDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeWorkAuthorizationDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeWorkAuthorizationType.workVisa,
    sponsorship: EmployeeWorkAuthorizationSponsorship.companySponsored,
    title: 'Work authorization review',
    country: member.location,
    owner: 'People Operations',
    expiryDate: today.add(const Duration(days: 365)),
    reviewDate: today.add(const Duration(days: 300)),
    notes: '',
  );
}

List<EmployeeWorkAuthorizationRecord> _recordsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeWorkAuthorizationRecord(
        id: 'EWA-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeWorkAuthorizationType.workVisa,
        status: EmployeeWorkAuthorizationStatus.renewalDue,
        sponsorship: EmployeeWorkAuthorizationSponsorship.companySponsored,
        evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.expiring,
        title: 'Work visa renewal',
        country: member.location,
        owner: 'People Operations',
        documentNumberMasked: 'WV-****-1482',
        issuedAt: today.subtract(const Duration(days: 330)),
        expiryDate: today.add(const Duration(days: 28)),
        reviewDate: today.subtract(const Duration(days: 1)),
        notes:
            'Renewal package needs manager confirmation and employee evidence.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeWorkAuthorizationRecord(
        id: 'EWA-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeWorkAuthorizationType.workVisa,
        status: EmployeeWorkAuthorizationStatus.pendingReview,
        sponsorship: EmployeeWorkAuthorizationSponsorship.companySponsored,
        evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.pendingUpload,
        title: 'Initial right-to-work evidence',
        country: member.location,
        owner: 'People Operations',
        documentNumberMasked: 'WV-****-NEW',
        issuedAt: today,
        expiryDate: today.add(const Duration(days: 365)),
        reviewDate: today.add(const Duration(days: 3)),
        notes: 'Collect right-to-work evidence before first payroll close.',
      ),
    ];
  }

  if (member.location == 'Singapore') {
    return [
      EmployeeWorkAuthorizationRecord(
        id: 'EWA-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeWorkAuthorizationType.permanentResident,
        status: EmployeeWorkAuthorizationStatus.valid,
        sponsorship: EmployeeWorkAuthorizationSponsorship.employeeManaged,
        evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.verified,
        title: 'Permanent resident authorization',
        country: 'Singapore',
        owner: member.manager,
        documentNumberMasked: 'PR-****-0321',
        issuedAt: today.subtract(const Duration(days: 700)),
        expiryDate: today.add(const Duration(days: 900)),
        reviewDate: today.add(const Duration(days: 180)),
        notes:
            'Permanent resident authorization verified for local employment.',
      ),
    ];
  }

  return [
    EmployeeWorkAuthorizationRecord(
      id: 'EWA-${member.id}-001',
      employeeId: member.id,
      employeeName: member.name,
      type: EmployeeWorkAuthorizationType.citizen,
      status: EmployeeWorkAuthorizationStatus.valid,
      sponsorship: EmployeeWorkAuthorizationSponsorship.notRequired,
      evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.verified,
      title: 'Local right-to-work evidence',
      country: member.location,
      owner: 'People Operations',
      documentNumberMasked: 'ID-****-${member.id.padLeft(4, '0')}',
      issuedAt: today.subtract(const Duration(days: 900)),
      expiryDate: today.add(const Duration(days: 1200)),
      reviewDate: today.add(const Duration(days: 365)),
      notes: 'Local right-to-work record is verified and current.',
    ),
  ];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
