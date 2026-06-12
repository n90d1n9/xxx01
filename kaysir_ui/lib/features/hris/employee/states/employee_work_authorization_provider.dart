import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_work_authorization_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_work_authorization_models.dart';
import 'employee_directory_provider.dart';

final employeeWorkAuthorizationProfileProvider = StateNotifierProvider.family<
  EmployeeWorkAuthorizationProfileNotifier,
  EmployeeWorkAuthorizationProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeWorkAuthorizationProfileNotifier(null);
  }

  return EmployeeWorkAuthorizationProfileNotifier(
    buildEmployeeWorkAuthorizationProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeWorkAuthorizationDraftProvider = StateNotifierProvider.family<
  EmployeeWorkAuthorizationDraftNotifier,
  EmployeeWorkAuthorizationDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeWorkAuthorizationDraftNotifier(null);
  }

  return EmployeeWorkAuthorizationDraftNotifier(
    buildEmployeeWorkAuthorizationDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeWorkAuthorizationProfileNotifier
    extends StateNotifier<EmployeeWorkAuthorizationProfile?> {
  EmployeeWorkAuthorizationProfileNotifier(super.state);

  EmployeeWorkAuthorizationRecord submitDraft(
    EmployeeWorkAuthorizationDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee work authorization profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final record = draft.toRecord(id: _nextRecordId(profile));
    state = profile.copyWith(records: [record, ...profile.records]);
    return record;
  }

  void verifyEvidence(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId || !record.canVerifyEvidence) {
              return record;
            }

            final nextStatus =
                record.status ==
                            EmployeeWorkAuthorizationStatus.pendingReview ||
                        record.status == EmployeeWorkAuthorizationStatus.missing
                    ? EmployeeWorkAuthorizationStatus.valid
                    : record.status;

            return record.copyWith(
              status: nextStatus,
              evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.verified,
              reviewDate: profile.asOfDate.add(const Duration(days: 180)),
            );
          }).toList(),
    );
  }

  void startRenewal(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId || !record.canStartRenewal) {
              return record;
            }
            return record.copyWith(
              status: EmployeeWorkAuthorizationStatus.renewalDue,
              reviewDate: profile.asOfDate.add(const Duration(days: 14)),
              notes: '${record.notes} Renewal started.',
            );
          }).toList(),
    );
  }

  void markValid(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId || !record.canMarkValid) return record;
            final nextExpiry =
                record.isExpiringSoon(profile.asOfDate) ||
                        record.isExpired(profile.asOfDate)
                    ? profile.asOfDate.add(const Duration(days: 365))
                    : record.expiryDate;
            return record.copyWith(
              status: EmployeeWorkAuthorizationStatus.valid,
              evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.verified,
              expiryDate: nextExpiry,
              reviewDate: profile.asOfDate.add(const Duration(days: 180)),
            );
          }).toList(),
    );
  }

  void renew(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return record.copyWith(
              status: EmployeeWorkAuthorizationStatus.valid,
              evidenceStatus: EmployeeWorkAuthorizationEvidenceStatus.verified,
              expiryDate: profile.asOfDate.add(const Duration(days: 365)),
              reviewDate: profile.asOfDate.add(const Duration(days: 300)),
              notes: '${record.notes} Renewal completed.',
            );
          }).toList(),
    );
  }

  void suspend(String recordId) {
    _updateRecord(
      recordId,
      (record) =>
          record.copyWith(status: EmployeeWorkAuthorizationStatus.suspended),
    );
  }

  void _updateRecord(
    String recordId,
    EmployeeWorkAuthorizationRecord Function(
      EmployeeWorkAuthorizationRecord record,
    )
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

  String _nextRecordId(EmployeeWorkAuthorizationProfile profile) {
    var index = profile.records.length + 1;
    while (true) {
      final id =
          'EWA-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.records.any((record) => record.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeWorkAuthorizationDraftNotifier
    extends StateNotifier<EmployeeWorkAuthorizationDraft?> {
  final EmployeeWorkAuthorizationDraft? _initialDraft;

  EmployeeWorkAuthorizationDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeWorkAuthorizationType value) {
    state = state?.copyWith(type: value);
  }

  void setSponsorship(EmployeeWorkAuthorizationSponsorship value) {
    state = state?.copyWith(sponsorship: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setCountry(String value) {
    state = state?.copyWith(country: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setExpiryDate(DateTime value) {
    state = state?.copyWith(expiryDate: _dateOnly(value));
  }

  void setReviewDate(DateTime value) {
    state = state?.copyWith(reviewDate: _dateOnly(value));
  }

  void setNotes(String value) {
    state = state?.copyWith(notes: value);
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
