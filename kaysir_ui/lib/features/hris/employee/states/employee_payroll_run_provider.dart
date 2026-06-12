import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_payroll_run_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_payroll_run_models.dart';
import 'employee_directory_provider.dart';
import 'employee_payroll_cutoff_provider.dart';
import 'employee_payroll_provider.dart';
import 'employee_payroll_run_launch_context_provider.dart';
import 'employee_payroll_variance_provider.dart';

/// Resolves and mutates employee payroll run previews.
final employeePayrollRunProvider = StateNotifierProvider.family<
  EmployeePayrollRunNotifier,
  EmployeePayrollRunProfile?,
  String
>((ref, employeeId) {
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
  final cutoff = ref.watch(
    employeePayrollCutoffReconciliationProvider(employeeId),
  );
  final variance = ref.watch(employeePayrollVarianceProvider(employeeId));
  final launchContext = ref.watch(employeePayrollRunLaunchContextProvider);

  if (member == null || payroll == null || cutoff == null || variance == null) {
    return EmployeePayrollRunNotifier(null);
  }

  return EmployeePayrollRunNotifier(
    buildEmployeePayrollRunProfile(
      member: member,
      payroll: payroll,
      cutoff: cutoff,
      variance: variance,
      launchContext: launchContext,
    ),
  );
});

/// Stores review input for a single employee payroll run preview.
final employeePayrollRunReviewDraftProvider = StateNotifierProvider.family<
  EmployeePayrollRunReviewDraftNotifier,
  EmployeePayrollRunReviewDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePayrollRunReviewDraftNotifier(null);
  }

  return EmployeePayrollRunReviewDraftNotifier(
    buildEmployeePayrollRunReviewDraft(member: member, asOfDate: asOfDate),
  );
});

/// Applies review and export transitions to an employee payroll run preview.
class EmployeePayrollRunNotifier
    extends StateNotifier<EmployeePayrollRunProfile?> {
  EmployeePayrollRunNotifier(super.state);

  void markReviewed(EmployeePayrollRunReviewDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee payroll run is unavailable');
    }
    if (!profile.canReview) {
      throw StateError('Clear payroll run blockers before review');
    }
    if (!draft.isReadyToReview) {
      throw StateError(draft.validationErrors.first);
    }

    state = profile.copyWith(
      status: EmployeePayrollRunStatus.ready,
      reviewer: draft.reviewer.trim(),
      reviewNote: draft.note.trim(),
      payslipVisible: draft.payslipVisible,
    );
  }

  void exportRun(String batchId) {
    final profile = state;
    if (profile == null) return;
    if (!profile.canExport) {
      throw StateError('Review payroll run before export');
    }

    final resolvedBatchId =
        batchId.trim().isEmpty ? _defaultBatchId(profile) : batchId.trim();
    state = profile.copyWith(
      status: EmployeePayrollRunStatus.exported,
      exportBatchId: resolvedBatchId,
      exportedAt: profile.asOfDate,
    );
  }

  void reopenReview() {
    final profile = state;
    if (profile == null ||
        profile.status == EmployeePayrollRunStatus.exported) {
      return;
    }

    state = profile.copyWith(
      status:
          profile.blockerCount > 0
              ? EmployeePayrollRunStatus.blocked
              : EmployeePayrollRunStatus.draft,
      reviewer: '',
      reviewNote: '',
      payslipVisible: false,
      exportBatchId: '',
    );
  }

  String _defaultBatchId(EmployeePayrollRunProfile profile) {
    final launchContext = profile.launchContext;
    if (launchContext != null) return launchContext.runReference;

    final payDate = profile.payDate;
    return 'PAY-${payDate.year}${payDate.month.toString().padLeft(2, '0')}';
  }
}

/// Mutates employee payroll run review draft fields.
class EmployeePayrollRunReviewDraftNotifier
    extends StateNotifier<EmployeePayrollRunReviewDraft?> {
  final EmployeePayrollRunReviewDraft? _initialDraft;

  EmployeePayrollRunReviewDraftNotifier(super.state) : _initialDraft = state;

  void setReviewer(String value) {
    state = state?.copyWith(reviewer: value);
  }

  void setNote(String value) {
    state = state?.copyWith(note: value);
  }

  void setPayslipVisible(bool value) {
    state = state?.copyWith(payslipVisible: value);
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
    if (member.id == employeeId) return member;
  }
  return null;
}
