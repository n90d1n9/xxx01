import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_payroll_payment_seed_data.dart';
import '../models/employee_payroll_payment_models.dart';
import 'employee_payroll_provider.dart';
import 'employee_payroll_run_provider.dart';

final employeePayrollPaymentProvider = StateNotifierProvider.family<
  EmployeePayrollPaymentNotifier,
  EmployeePayrollPaymentProfile?,
  String
>((ref, employeeId) {
  final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
  final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
  if (payrollRun == null || payroll == null) {
    return EmployeePayrollPaymentNotifier(null);
  }

  return EmployeePayrollPaymentNotifier(
    buildEmployeePayrollPaymentProfile(
      payrollRun: payrollRun,
      payroll: payroll,
    ),
  );
});

final employeePayrollPaymentDraftProvider = StateNotifierProvider.family<
  EmployeePayrollPaymentDraftNotifier,
  EmployeePayrollPaymentDraft?,
  String
>((ref, employeeId) {
  final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
  if (payrollRun == null) {
    return EmployeePayrollPaymentDraftNotifier(null);
  }

  return EmployeePayrollPaymentDraftNotifier(
    buildEmployeePayrollPaymentDraft(payrollRun: payrollRun),
  );
});

class EmployeePayrollPaymentNotifier
    extends StateNotifier<EmployeePayrollPaymentProfile?> {
  EmployeePayrollPaymentNotifier(super.state);

  void schedule(EmployeePayrollPaymentDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Payroll payment is unavailable');
    }
    if (!profile.canSchedule) {
      throw StateError(profile.nextAction);
    }
    if (!draft.isReadyToSchedule) {
      throw StateError(draft.validationErrors.first);
    }

    state = profile.copyWith(
      status: EmployeePayrollPaymentStatus.scheduled,
      paymentOwner: draft.owner.trim(),
      paymentNote: draft.note.trim(),
      paymentReference: draft.reference.trim(),
      scheduledFor: draft.scheduledFor,
      instructions: _instructionsFor(
        profile,
        EmployeePayrollPaymentInstructionStatus.scheduled,
      ),
    );
  }

  void markPaid() {
    final profile = state;
    if (profile == null) return;
    if (!profile.canMarkPaid) {
      throw StateError('Schedule payroll payment before marking it paid');
    }

    state = profile.copyWith(
      status: EmployeePayrollPaymentStatus.paid,
      paidAt: profile.asOfDate,
      instructions: _instructionsFor(
        profile,
        EmployeePayrollPaymentInstructionStatus.paid,
      ),
    );
  }

  void hold() {
    final profile = state;
    if (profile == null ||
        profile.status == EmployeePayrollPaymentStatus.paid) {
      return;
    }
    if (profile.status == EmployeePayrollPaymentStatus.blocked) {
      throw StateError(profile.nextAction);
    }

    state = profile.copyWith(
      status: EmployeePayrollPaymentStatus.held,
      instructions: _instructionsFor(
        profile,
        EmployeePayrollPaymentInstructionStatus.held,
      ),
    );
  }

  void reopen() {
    final profile = state;
    if (profile == null ||
        profile.status == EmployeePayrollPaymentStatus.paid) {
      return;
    }

    state = profile.copyWith(
      status:
          profile.blockingCount > 0
              ? EmployeePayrollPaymentStatus.blocked
              : EmployeePayrollPaymentStatus.ready,
      paymentOwner: '',
      paymentNote: '',
      paymentReference: '',
      instructions: _instructionsFor(
        profile,
        profile.blockingCount > 0
            ? EmployeePayrollPaymentInstructionStatus.blocked
            : EmployeePayrollPaymentInstructionStatus.ready,
      ),
    );
  }

  List<EmployeePayrollPaymentInstruction> _instructionsFor(
    EmployeePayrollPaymentProfile profile,
    EmployeePayrollPaymentInstructionStatus status,
  ) {
    return profile.instructions
        .map(
          (instruction) => EmployeePayrollPaymentInstruction(
            id: instruction.id,
            method: instruction.method,
            status: status,
            title: instruction.title,
            detail: _detailFor(status),
            amount: instruction.amount,
            currencyCode: instruction.currencyCode,
            bankName: instruction.bankName,
            maskedAccount: instruction.maskedAccount,
            routingCode: instruction.routingCode,
            sortOrder: instruction.sortOrder,
          ),
        )
        .toList();
  }

  String _detailFor(EmployeePayrollPaymentInstructionStatus status) {
    return switch (status) {
      EmployeePayrollPaymentInstructionStatus.blocked =>
        'Payment instruction is blocked by payroll readiness.',
      EmployeePayrollPaymentInstructionStatus.ready =>
        'Payment instruction is ready to schedule.',
      EmployeePayrollPaymentInstructionStatus.scheduled =>
        'Payment instruction has been scheduled for settlement.',
      EmployeePayrollPaymentInstructionStatus.paid =>
        'Payment instruction has settled.',
      EmployeePayrollPaymentInstructionStatus.held =>
        'Payment instruction is on hold for payroll operations review.',
    };
  }
}

class EmployeePayrollPaymentDraftNotifier
    extends StateNotifier<EmployeePayrollPaymentDraft?> {
  final EmployeePayrollPaymentDraft? _initialDraft;

  EmployeePayrollPaymentDraftNotifier(super.state) : _initialDraft = state;

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setNote(String value) {
    state = state?.copyWith(note: value);
  }

  void setReference(String value) {
    state = state?.copyWith(reference: value);
  }

  void setScheduledFor(DateTime value) {
    state = state?.copyWith(scheduledFor: value);
  }

  void reset() {
    state = _initialDraft;
  }
}
