import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_payroll_cutoff_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_payroll_cutoff_models.dart';
import 'employee_directory_provider.dart';
import 'employee_leave_provider.dart';
import 'employee_payroll_provider.dart';
import 'employee_timekeeping_provider.dart';

final employeePayrollCutoffReconciliationProvider =
    StateNotifierProvider.family<
      EmployeePayrollCutoffReconciliationNotifier,
      EmployeePayrollCutoffReconciliationProfile?,
      String
    >((ref, employeeId) {
      final member = _findMember(
        ref.watch(employeeDirectoryMembersProvider),
        employeeId,
      );
      final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
      final timekeeping = ref.watch(employeeTimekeepingProvider(employeeId));
      final leave = ref.watch(employeeLeaveProfileProvider(employeeId));

      if (member == null ||
          payroll == null ||
          timekeeping == null ||
          leave == null) {
        return EmployeePayrollCutoffReconciliationNotifier(null);
      }

      return EmployeePayrollCutoffReconciliationNotifier(
        buildEmployeePayrollCutoffReconciliationProfile(
          member: member,
          payroll: payroll,
          timekeeping: timekeeping,
          leave: leave,
        ),
      );
    });

final employeePayrollCutoffSignoffDraftProvider = StateNotifierProvider.family<
  EmployeePayrollCutoffSignoffDraftNotifier,
  EmployeePayrollCutoffSignoffDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePayrollCutoffSignoffDraftNotifier(null);
  }

  return EmployeePayrollCutoffSignoffDraftNotifier(
    buildEmployeePayrollCutoffSignoffDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeePayrollCutoffReconciliationNotifier
    extends StateNotifier<EmployeePayrollCutoffReconciliationProfile?> {
  EmployeePayrollCutoffReconciliationNotifier(super.state);

  void reviewItem(String itemId) {
    _updateItem(
      itemId,
      (item) =>
          item.isClosed
              ? item
              : item.copyWith(status: EmployeePayrollCutoffItemStatus.inReview),
    );
  }

  void resolveItem(String itemId) {
    _updateItem(
      itemId,
      (item) => item.copyWith(status: EmployeePayrollCutoffItemStatus.resolved),
    );
  }

  void waiveItem(String itemId) {
    _updateItem(
      itemId,
      (item) => item.copyWith(status: EmployeePayrollCutoffItemStatus.waived),
    );
  }

  void reopenItem(String itemId) {
    _updateItem(
      itemId,
      (item) => item.copyWith(status: EmployeePayrollCutoffItemStatus.open),
    );
  }

  EmployeePayrollCutoffSignoff submitSignoff(
    EmployeePayrollCutoffSignoffDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Payroll cutoff reconciliation is unavailable');
    }
    if (profile.blockingCount > 0) {
      throw StateError('Resolve blockers before payroll sign-off');
    }
    if (profile.openWarningCount > 0 && !draft.acceptOpenWarnings) {
      throw StateError('Accept or clear open warnings before sign-off');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final signoff = draft.toSignoff(
      id: _signoffId(profile),
      acceptedWarningCount: profile.openWarningCount,
    );
    state = profile.copyWith(signoff: signoff);
    return signoff;
  }

  void _updateItem(
    String itemId,
    EmployeePayrollCutoffItem Function(EmployeePayrollCutoffItem item) update,
  ) {
    final profile = state;
    if (profile == null || profile.signoff != null) return;

    state = profile.copyWith(
      items:
          profile.items.map((item) {
            if (item.id != itemId) return item;
            return update(item);
          }).toList(),
    );
  }

  String _signoffId(EmployeePayrollCutoffReconciliationProfile profile) {
    final date = profile.asOfDate;
    final stamp =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return 'PCS-${profile.employeeId}-$stamp';
  }
}

class EmployeePayrollCutoffSignoffDraftNotifier
    extends StateNotifier<EmployeePayrollCutoffSignoffDraft?> {
  final EmployeePayrollCutoffSignoffDraft? _initialDraft;

  EmployeePayrollCutoffSignoffDraftNotifier(super.state)
    : _initialDraft = state;

  void setReviewer(String value) {
    state = state?.copyWith(reviewer: value);
  }

  void setReviewDate(DateTime value) {
    state = state?.copyWith(
      reviewDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setNote(String value) {
    state = state?.copyWith(note: value);
  }

  void setAcceptOpenWarnings(bool value) {
    state = state?.copyWith(acceptOpenWarnings: value);
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
