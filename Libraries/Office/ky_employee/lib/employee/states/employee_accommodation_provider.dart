import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_accommodation_seed_data.dart';
import '../models/employee_accommodation_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeAccommodationProfileProvider = StateNotifierProvider.family<
  EmployeeAccommodationProfileNotifier,
  EmployeeAccommodationProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAccommodationProfileNotifier(null);
  }

  return EmployeeAccommodationProfileNotifier(
    buildEmployeeAccommodationProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeAccommodationDraftProvider = StateNotifierProvider.family<
  EmployeeAccommodationDraftNotifier,
  EmployeeAccommodationDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAccommodationDraftNotifier(null);
  }

  return EmployeeAccommodationDraftNotifier(
    buildEmployeeAccommodationDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeAccommodationProfileNotifier
    extends StateNotifier<EmployeeAccommodationProfile?> {
  EmployeeAccommodationProfileNotifier(super.state);

  EmployeeAccommodationRecord submitDraft(EmployeeAccommodationDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee accommodation profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final record = draft.toRecord(id: _nextRecordId(profile));
    state = profile.copyWith(records: [record, ...profile.records]);
    return record;
  }

  void approveRequest(String recordId) {
    _updateRecord(recordId, (record) {
      if (!record.canApprove) return record;
      return record.copyWith(status: EmployeeAccommodationStatus.approved);
    });
  }

  void activateAccommodation(String recordId) {
    _updateRecord(recordId, (record) {
      if (!record.canActivate) return record;
      return record.copyWith(status: EmployeeAccommodationStatus.active);
    });
  }

  void completeReview(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId || !record.canReview) return record;
            return record.copyWith(
              reviewDate: profile.asOfDate.add(const Duration(days: 90)),
              status: EmployeeAccommodationStatus.active,
            );
          }).toList(),
    );
  }

  void expireAccommodation(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId || !record.canExpire) return record;
            return record.copyWith(
              endDate: profile.asOfDate,
              status: EmployeeAccommodationStatus.expired,
            );
          }).toList(),
    );
  }

  void declineRequest(String recordId) {
    _updateRecord(recordId, (record) {
      if (!record.canDecline) return record;
      return record.copyWith(status: EmployeeAccommodationStatus.declined);
    });
  }

  void _updateRecord(
    String recordId,
    EmployeeAccommodationRecord Function(EmployeeAccommodationRecord record)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return update(record);
          }).toList(),
    );
  }

  String _nextRecordId(EmployeeAccommodationProfile profile) {
    var index = profile.records.length + 1;
    while (true) {
      final id =
          'EAC-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.records.any((record) => record.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeAccommodationDraftNotifier
    extends StateNotifier<EmployeeAccommodationDraft?> {
  final EmployeeAccommodationDraft? _initialDraft;

  EmployeeAccommodationDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeAccommodationType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setStartDate(DateTime value) {
    state = state?.copyWith(startDate: _dateOnly(value));
  }

  void setReviewDate(DateTime value) {
    state = state?.copyWith(reviewDate: _dateOnly(value));
  }

  void setSensitivity(EmployeeAccommodationSensitivity value) {
    state = state?.copyWith(sensitivity: value);
  }

  void setSummary(String value) {
    state = state?.copyWith(summary: value);
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
