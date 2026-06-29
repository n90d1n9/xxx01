import '../models/employee_directory_models.dart';
import '../models/employee_personal_records_models.dart';

EmployeePersonalRecordsProfile buildEmployeePersonalRecordsProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeePersonalRecordsProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    addresses: _addressesFor(member, asOfDate),
    emergencyContacts: _contactsFor(member, asOfDate),
  );
}

EmployeeEmergencyContactDraft buildEmployeeEmergencyContactDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeEmergencyContactDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    fullName: '',
    relationship: EmployeeEmergencyContactRelationship.parent,
    phone: '',
    email: '',
    primary: false,
  );
}

List<EmployeeAddressRecord> _addressesFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  final onboarding = member.status == EmployeeDirectoryStatus.onboarding;
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;
  final city = member.location;

  return [
    EmployeeAddressRecord(
      id: '${member.id}-address-home',
      employeeId: member.id,
      type: EmployeeAddressType.home,
      label: 'Primary residence',
      line1: '${100 + int.parse(member.id) * 7} Jalan Merdeka',
      city: city,
      region: _regionFor(city),
      country: 'Indonesia',
      postalCode: _postalCodeFor(city),
      lastVerifiedAt:
          watchlist
              ? today.subtract(const Duration(days: 420))
              : today.subtract(const Duration(days: 90)),
      status:
          onboarding
              ? EmployeePersonalRecordStatus.pending
              : watchlist
              ? EmployeePersonalRecordStatus.reviewDue
              : EmployeePersonalRecordStatus.verified,
    ),
    EmployeeAddressRecord(
      id: '${member.id}-address-mailing',
      employeeId: member.id,
      type: EmployeeAddressType.mailing,
      label: 'Mailing address',
      line1: '${200 + int.parse(member.id) * 9} HRIS Mail Center',
      city: city,
      region: _regionFor(city),
      country: 'Indonesia',
      postalCode: _postalCodeFor(city),
      lastVerifiedAt: today.subtract(const Duration(days: 120)),
      status:
          onboarding
              ? EmployeePersonalRecordStatus.missing
              : EmployeePersonalRecordStatus.verified,
    ),
  ];
}

List<EmployeeEmergencyContactRecord> _contactsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeEmergencyContactRecord(
        id: '${member.id}-contact-primary',
        employeeId: member.id,
        fullName: 'Morgan Wilson',
        relationship: EmployeeEmergencyContactRelationship.parent,
        phone: '+62 812 5555 0105',
        email: 'morgan.wilson@example.com',
        priority: 1,
        lastVerifiedAt: today,
        status: EmployeePersonalRecordStatus.pending,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeEmergencyContactRecord(
        id: '${member.id}-contact-primary',
        employeeId: member.id,
        fullName: 'Mina Kim',
        relationship: EmployeeEmergencyContactRelationship.spouse,
        phone: '+62 812 5555 0104',
        email: 'mina.kim@example.com',
        priority: 1,
        lastVerifiedAt: today.subtract(const Duration(days: 410)),
        status: EmployeePersonalRecordStatus.reviewDue,
      ),
    ];
  }

  return [
    EmployeeEmergencyContactRecord(
      id: '${member.id}-contact-primary',
      employeeId: member.id,
      fullName: '${_firstName(member.name)} household',
      relationship:
          member.isHighPerformer
              ? EmployeeEmergencyContactRelationship.spouse
              : EmployeeEmergencyContactRelationship.sibling,
      phone: '+62 812 5555 010${member.id}',
      email: '${_firstName(member.name).toLowerCase()}.contact@example.com',
      priority: 1,
      lastVerifiedAt: today.subtract(const Duration(days: 80)),
      status: EmployeePersonalRecordStatus.verified,
    ),
  ];
}

String _firstName(String name) {
  return name.split(' ').first;
}

String _regionFor(String city) {
  return switch (city) {
    'Jakarta' => 'DKI Jakarta',
    'Bandung' => 'West Java',
    'Surabaya' => 'East Java',
    'Singapore' => 'Central Region',
    _ => 'Nusantara',
  };
}

String _postalCodeFor(String city) {
  return switch (city) {
    'Jakarta' => '10110',
    'Bandung' => '40111',
    'Surabaya' => '60241',
    'Singapore' => '188064',
    _ => '00000',
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
