import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_payroll_close_seed_data.dart';
import '../models/employee_payroll_close_models.dart';
import 'employee_payslip_delivery_provider.dart';
import 'employee_payroll_payment_provider.dart';
import 'employee_payroll_run_provider.dart';

final employeePayrollCloseProvider = StateNotifierProvider.family<
  EmployeePayrollCloseNotifier,
  EmployeePayrollCloseProfile?,
  String
>((ref, employeeId) {
  final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
  final payment = ref.watch(employeePayrollPaymentProvider(employeeId));
  final payslipDelivery = ref.watch(
    employeePayslipDeliveryProvider(employeeId),
  );

  if (payrollRun == null || payment == null || payslipDelivery == null) {
    return EmployeePayrollCloseNotifier(null);
  }

  return EmployeePayrollCloseNotifier(
    buildEmployeePayrollCloseProfile(
      payrollRun: payrollRun,
      payment: payment,
      payslipDelivery: payslipDelivery,
    ),
  );
});

final employeePayrollCloseDraftProvider = StateNotifierProvider.family<
  EmployeePayrollCloseDraftNotifier,
  EmployeePayrollCloseDraft?,
  String
>((ref, employeeId) {
  final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
  if (payrollRun == null) {
    return EmployeePayrollCloseDraftNotifier(null);
  }

  return EmployeePayrollCloseDraftNotifier(
    buildEmployeePayrollCloseDraft(payrollRun: payrollRun),
  );
});

class EmployeePayrollCloseNotifier
    extends StateNotifier<EmployeePayrollCloseProfile?> {
  EmployeePayrollCloseNotifier(super.state);

  void postJournal(EmployeePayrollCloseDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Payroll close is unavailable');
    }
    if (!profile.canPost) {
      throw StateError(profile.nextAction);
    }
    if (!draft.isReadyToPost) {
      throw StateError(draft.validationErrors.first);
    }

    state = profile.copyWith(
      status: EmployeePayrollCloseStatus.posted,
      journalBatchId: draft.journalBatchId.trim(),
      closeOwner: draft.owner.trim(),
      closeNote: draft.note.trim(),
      postedAt: profile.asOfDate,
      journalLines: _journalLinesFor(
        profile,
        EmployeePayrollJournalLineStatus.posted,
      ),
    );
  }

  void closePeriod() {
    final profile = state;
    if (profile == null) return;
    if (!profile.canClose) {
      throw StateError('Post payroll accounting journal before closing');
    }

    state = profile.copyWith(
      status: EmployeePayrollCloseStatus.closed,
      closedAt: profile.asOfDate,
      journalLines: _journalLinesFor(
        profile,
        EmployeePayrollJournalLineStatus.posted,
      ),
    );
  }

  void reopen() {
    final profile = state;
    if (profile == null ||
        profile.status == EmployeePayrollCloseStatus.closed) {
      return;
    }

    state = profile.copyWith(
      status:
          profile.blockingCount > 0
              ? EmployeePayrollCloseStatus.blocked
              : EmployeePayrollCloseStatus.ready,
      journalBatchId: '',
      closeOwner: '',
      closeNote: '',
      journalLines: _journalLinesFor(
        profile,
        profile.blockingCount > 0
            ? EmployeePayrollJournalLineStatus.blocked
            : EmployeePayrollJournalLineStatus.draft,
      ),
    );
  }

  List<EmployeePayrollJournalLine> _journalLinesFor(
    EmployeePayrollCloseProfile profile,
    EmployeePayrollJournalLineStatus status,
  ) {
    return profile.journalLines
        .map((line) => line.copyWith(status: status))
        .toList();
  }
}

class EmployeePayrollCloseDraftNotifier
    extends StateNotifier<EmployeePayrollCloseDraft?> {
  final EmployeePayrollCloseDraft? _initialDraft;

  EmployeePayrollCloseDraftNotifier(super.state) : _initialDraft = state;

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setJournalBatchId(String value) {
    state = state?.copyWith(journalBatchId: value);
  }

  void setNote(String value) {
    state = state?.copyWith(note: value);
  }

  void reset() {
    state = _initialDraft;
  }
}
