import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_timekeeping_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_timekeeping_models.dart';
import 'employee_directory_provider.dart';

final employeeTimekeepingProvider = StateNotifierProvider.family<
  EmployeeTimekeepingNotifier,
  EmployeeTimekeepingProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeTimekeepingNotifier(null);
  }

  return EmployeeTimekeepingNotifier(
    buildEmployeeTimekeepingProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeTimekeepingExceptionDraftProvider = StateNotifierProvider.family<
  EmployeeTimekeepingExceptionDraftNotifier,
  EmployeeTimekeepingExceptionDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeTimekeepingExceptionDraftNotifier(null);
  }

  return EmployeeTimekeepingExceptionDraftNotifier(
    buildEmployeeTimekeepingExceptionDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeTimekeepingNotifier
    extends StateNotifier<EmployeeTimekeepingProfile?> {
  EmployeeTimekeepingNotifier(super.state);

  EmployeeTimekeepingException addException(
    EmployeeTimekeepingExceptionDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee timekeeping profile is unavailable');
    }

    final exception = draft.toException(id: _nextExceptionId(profile));
    state = profile.copyWith(exceptions: [exception, ...profile.exceptions]);
    return exception;
  }

  void approveEntry(String entryId, String approver) {
    _updateEntry(
      entryId,
      (entry) => entry.copyWith(
        status: EmployeeTimesheetEntryStatus.approved,
        approvedBy: approver.trim().isEmpty ? 'People Operations' : approver,
      ),
    );
  }

  void rejectEntry(String entryId, String note) {
    _updateEntry(
      entryId,
      (entry) => entry.copyWith(
        status: EmployeeTimesheetEntryStatus.rejected,
        note: note.trim().isEmpty ? entry.note : note.trim(),
      ),
    );
  }

  void markPayrollReady(String entryId) {
    _updateEntry(
      entryId,
      (entry) =>
          entry.isApproved
              ? entry.copyWith(
                status: EmployeeTimesheetEntryStatus.payrollReady,
              )
              : entry,
    );
  }

  void adjustOvertime(String entryId, double overtimeHours) {
    _updateEntry(
      entryId,
      (entry) => entry.copyWith(overtimeHours: overtimeHours),
    );
  }

  void reviewException(String exceptionId) {
    _updateException(
      exceptionId,
      (exception) => exception.copyWith(
        status: EmployeeTimekeepingExceptionStatus.inReview,
      ),
    );
  }

  void resolveException(String exceptionId) {
    _updateException(
      exceptionId,
      (exception) => exception.copyWith(
        status: EmployeeTimekeepingExceptionStatus.resolved,
        payrollImpact: false,
      ),
    );
  }

  void waiveException(String exceptionId) {
    _updateException(
      exceptionId,
      (exception) => exception.copyWith(
        status: EmployeeTimekeepingExceptionStatus.waived,
        payrollImpact: false,
      ),
    );
  }

  void _updateEntry(
    String entryId,
    EmployeeTimesheetEntry Function(EmployeeTimesheetEntry entry) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      entries:
          profile.entries.map((entry) {
            if (entry.id != entryId) return entry;
            return update(entry);
          }).toList(),
    );
  }

  void _updateException(
    String exceptionId,
    EmployeeTimekeepingException Function(
      EmployeeTimekeepingException exception,
    )
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      exceptions:
          profile.exceptions.map((exception) {
            if (exception.id != exceptionId) return exception;
            return update(exception);
          }).toList(),
    );
  }

  String _nextExceptionId(EmployeeTimekeepingProfile profile) {
    return 'ETK-${profile.employeeId}-${(profile.exceptions.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeTimekeepingExceptionDraftNotifier
    extends StateNotifier<EmployeeTimekeepingExceptionDraft?> {
  final EmployeeTimekeepingExceptionDraft? _initialDraft;

  EmployeeTimekeepingExceptionDraftNotifier(super.state)
    : _initialDraft = state;

  void setType(EmployeeTimekeepingExceptionType value) {
    state = state?.copyWith(type: value);
  }

  void setWorkDate(DateTime value) {
    state = state?.copyWith(
      workDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setSeverity(EmployeeTimekeepingExceptionSeverity value) {
    state = state?.copyWith(severity: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setMinutesImpact(int value) {
    state = state?.copyWith(minutesImpact: value);
  }

  void setPayrollImpact(bool value) {
    state = state?.copyWith(payrollImpact: value);
  }

  void setNote(String value) {
    state = state?.copyWith(note: value);
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
