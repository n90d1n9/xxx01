import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_schedule_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_schedule_models.dart';
import 'employee_directory_provider.dart';

final employeeScheduleProfileProvider = StateNotifierProvider.family<
  EmployeeScheduleProfileNotifier,
  EmployeeScheduleProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeScheduleProfileNotifier(null);
  }

  return EmployeeScheduleProfileNotifier(
    buildEmployeeScheduleProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeScheduleAdjustmentDraftProvider = StateNotifierProvider.family<
  EmployeeScheduleAdjustmentDraftNotifier,
  EmployeeScheduleAdjustmentDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeScheduleAdjustmentDraftNotifier(null);
  }

  return EmployeeScheduleAdjustmentDraftNotifier(
    buildEmployeeScheduleAdjustmentDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeScheduleProfileNotifier
    extends StateNotifier<EmployeeScheduleProfile?> {
  EmployeeScheduleProfileNotifier(super.state);

  EmployeeScheduleAdjustmentRequest addDraft(
    EmployeeScheduleAdjustmentDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee schedule profile is unavailable');
    }

    final request = draft.toRequest(id: _nextAdjustmentId(profile));
    state = profile.copyWith(adjustments: [request, ...profile.adjustments]);
    return request;
  }

  void approveAdjustment(String requestId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      adjustments:
          profile.adjustments.map((request) {
            if (request.id != requestId || !request.canApprove) return request;
            return request.copyWith(
              status: EmployeeScheduleAdjustmentStatus.approved,
            );
          }).toList(),
    );
  }

  void applyAdjustment(String requestId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      adjustments:
          profile.adjustments.map((request) {
            if (request.id != requestId || !request.canApply) return request;
            return request.copyWith(
              status: EmployeeScheduleAdjustmentStatus.applied,
            );
          }).toList(),
    );
  }

  void resolveSignal(String signalId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      attendanceSignals:
          profile.attendanceSignals.map((signal) {
            if (signal.id != signalId) return signal;
            return signal.copyWith(resolved: true);
          }).toList(),
    );
  }

  String _nextAdjustmentId(EmployeeScheduleProfile profile) {
    var index = profile.adjustments.length + 1;
    while (true) {
      final id =
          'ESA-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.adjustments.any((request) => request.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeScheduleAdjustmentDraftNotifier
    extends StateNotifier<EmployeeScheduleAdjustmentDraft?> {
  final EmployeeScheduleAdjustmentDraft? _initialDraft;

  EmployeeScheduleAdjustmentDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeScheduleAdjustmentType value) {
    state = state?.copyWith(type: value);
  }

  void setTargetDate(DateTime value) {
    state = state?.copyWith(
      targetDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setStartTime(String value) {
    state = state?.copyWith(startTimeLabel: value);
  }

  void setEndTime(String value) {
    state = state?.copyWith(endTimeLabel: value);
  }

  void setLocation(String value) {
    state = state?.copyWith(location: value);
  }

  void setReason(String value) {
    state = state?.copyWith(reason: value);
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
