import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_personal_records_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_personal_records_models.dart';
import 'employee_directory_provider.dart';

final employeePersonalRecordsProfileProvider = StateNotifierProvider.family<
  EmployeePersonalRecordsProfileNotifier,
  EmployeePersonalRecordsProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePersonalRecordsProfileNotifier(null);
  }

  return EmployeePersonalRecordsProfileNotifier(
    buildEmployeePersonalRecordsProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeEmergencyContactDraftProvider = StateNotifierProvider.family<
  EmployeeEmergencyContactDraftNotifier,
  EmployeeEmergencyContactDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeEmergencyContactDraftNotifier(null);
  }

  return EmployeeEmergencyContactDraftNotifier(
    buildEmployeeEmergencyContactDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeePersonalRecordsProfileNotifier
    extends StateNotifier<EmployeePersonalRecordsProfile?> {
  EmployeePersonalRecordsProfileNotifier(super.state);

  EmployeeEmergencyContactRecord addContact(
    EmployeeEmergencyContactDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee personal records profile is unavailable');
    }

    final priority = draft.primary ? 1 : profile.emergencyContacts.length + 1;
    final contact = draft.toContact(
      id: _nextContactId(profile),
      priority: priority,
    );
    final contacts =
        draft.primary
            ? [
              contact,
              ...profile.emergencyContacts.map(
                (existing) =>
                    existing.copyWith(priority: existing.priority + 1),
              ),
            ]
            : [contact, ...profile.emergencyContacts];

    state = profile.copyWith(emergencyContacts: contacts);
    return contact;
  }

  void verifyAddress(String addressId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      addresses:
          profile.addresses.map((address) {
            if (address.id == addressId) {
              return address.copyWith(
                lastVerifiedAt: profile.asOfDate,
                status: EmployeePersonalRecordStatus.verified,
              );
            }
            return address;
          }).toList(),
    );
  }

  void verifyContact(String contactId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      emergencyContacts:
          profile.emergencyContacts.map((contact) {
            if (contact.id == contactId) {
              return contact.copyWith(
                lastVerifiedAt: profile.asOfDate,
                status: EmployeePersonalRecordStatus.verified,
              );
            }
            return contact;
          }).toList(),
    );
  }

  void makePrimaryContact(String contactId) {
    final profile = state;
    if (profile == null) return;

    EmployeeEmergencyContactRecord? target;
    for (final contact in profile.emergencyContacts) {
      if (contact.id == contactId) {
        target = contact;
        break;
      }
    }
    if (target == null) return;
    final targetPriority = target.priority;

    state = profile.copyWith(
      emergencyContacts:
          profile.emergencyContacts.map((contact) {
            if (contact.id == contactId) {
              return contact.copyWith(priority: 1);
            }
            if (contact.priority < targetPriority) {
              return contact.copyWith(priority: contact.priority + 1);
            }
            return contact;
          }).toList(),
    );
  }

  String _nextContactId(EmployeePersonalRecordsProfile profile) {
    return 'EMC-${profile.employeeId}-${(profile.emergencyContacts.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeEmergencyContactDraftNotifier
    extends StateNotifier<EmployeeEmergencyContactDraft?> {
  final EmployeeEmergencyContactDraft? _initialDraft;

  EmployeeEmergencyContactDraftNotifier(super.state) : _initialDraft = state;

  void setFullName(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(fullName: value);
  }

  void setRelationship(EmployeeEmergencyContactRelationship value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(relationship: value);
  }

  void setPhone(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(phone: value);
  }

  void setEmail(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(email: value);
  }

  void setPrimary(bool value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(primary: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}
