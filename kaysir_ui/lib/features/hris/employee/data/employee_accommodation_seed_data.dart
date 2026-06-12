import '../models/employee_accommodation_models.dart';
import '../models/employee_directory_models.dart';

EmployeeAccommodationProfile buildEmployeeAccommodationProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeAccommodationProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    records: _recordsFor(member, today),
  );
}

EmployeeAccommodationDraft buildEmployeeAccommodationDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeAccommodationDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeAccommodationType.ergonomic,
    title: 'Workplace support request',
    owner: member.manager,
    startDate: today.add(const Duration(days: 7)),
    reviewDate: today.add(const Duration(days: 37)),
    sensitivity: EmployeeAccommodationSensitivity.confidential,
    summary: '',
  );
}

List<EmployeeAccommodationRecord> _recordsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeAccommodationRecord(
        id: 'EAC-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeAccommodationType.schedule,
        title: 'Focused work schedule support',
        owner: member.manager,
        requestedAt: today.subtract(const Duration(days: 120)),
        startDate: today.subtract(const Duration(days: 90)),
        reviewDate: today.subtract(const Duration(days: 1)),
        endDate: null,
        status: EmployeeAccommodationStatus.reviewDue,
        sensitivity: EmployeeAccommodationSensitivity.confidential,
        summary:
            'Focused work blocks and meeting-load adjustments need review.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeAccommodationRecord(
        id: 'EAC-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeAccommodationType.workplaceAccess,
        title: 'Workspace access setup',
        owner: 'People Operations',
        requestedAt: today.subtract(const Duration(days: 3)),
        startDate: today.add(const Duration(days: 2)),
        reviewDate: today.add(const Duration(days: 45)),
        endDate: null,
        status: EmployeeAccommodationStatus.approved,
        sensitivity: EmployeeAccommodationSensitivity.standard,
        summary:
            'Approved workspace access adjustment awaiting facilities activation.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeAccommodationRecord(
        id: 'EAC-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeAccommodationType.ergonomic,
        title: 'Ergonomic workstation support',
        owner: 'People Operations',
        requestedAt: today.subtract(const Duration(days: 80)),
        startDate: today.subtract(const Duration(days: 70)),
        reviewDate: today.add(const Duration(days: 40)),
        endDate: null,
        status: EmployeeAccommodationStatus.active,
        sensitivity: EmployeeAccommodationSensitivity.standard,
        summary:
            'Ergonomic setup active with follow-up review scheduled next month.',
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
