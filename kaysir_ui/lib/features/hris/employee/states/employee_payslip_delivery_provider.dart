import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_payslip_delivery_seed_data.dart';
import '../models/employee_payslip_delivery_models.dart';
import '../models/employee_payroll_run_models.dart';
import 'employee_payroll_run_provider.dart';

final employeePayslipDeliveryProvider = StateNotifierProvider.family<
  EmployeePayslipDeliveryNotifier,
  EmployeePayslipDeliveryProfile?,
  String
>((ref, employeeId) {
  final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
  if (payrollRun == null) {
    return EmployeePayslipDeliveryNotifier(null);
  }

  return EmployeePayslipDeliveryNotifier(
    buildEmployeePayslipDeliveryProfile(payrollRun: payrollRun),
  );
});

final employeePayslipReleaseDraftProvider = StateNotifierProvider.family<
  EmployeePayslipReleaseDraftNotifier,
  EmployeePayslipReleaseDraft?,
  String
>((ref, employeeId) {
  final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
  if (payrollRun == null) {
    return EmployeePayslipReleaseDraftNotifier(null);
  }

  return EmployeePayslipReleaseDraftNotifier(
    buildEmployeePayslipReleaseDraft(payrollRun: payrollRun),
  );
});

class EmployeePayslipDeliveryNotifier
    extends StateNotifier<EmployeePayslipDeliveryProfile?> {
  EmployeePayslipDeliveryNotifier(super.state);

  void release(EmployeePayslipReleaseDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Payslip delivery is unavailable');
    }
    if (!profile.canRelease) {
      throw StateError(profile.nextAction);
    }
    if (!draft.isReadyToRelease) {
      throw StateError(draft.validationErrors.first);
    }

    state = profile.copyWith(
      status: EmployeePayslipDeliveryStatus.published,
      releaseOwner: draft.owner.trim(),
      releaseNote: draft.note.trim(),
      notifyEmployee: draft.notifyEmployee,
      archiveCopy: draft.archiveCopy,
      releasedAt: profile.asOfDate,
      channels: buildEmployeePayslipDeliveryChannels(
        status: EmployeePayslipDeliveryStatus.published,
        notifyEmployee: draft.notifyEmployee,
        archiveCopy: draft.archiveCopy,
      ),
    );
  }

  void suppress() {
    final profile = state;
    if (profile == null ||
        profile.status == EmployeePayslipDeliveryStatus.published) {
      return;
    }
    if (profile.runStatus != EmployeePayrollRunStatus.exported) {
      throw StateError(
        'Export payroll run before suppressing payslip delivery',
      );
    }

    state = profile.copyWith(
      status: EmployeePayslipDeliveryStatus.suppressed,
      channels: buildEmployeePayslipDeliveryChannels(
        status: EmployeePayslipDeliveryStatus.suppressed,
        notifyEmployee: profile.notifyEmployee,
        archiveCopy: profile.archiveCopy,
      ),
    );
  }

  void reopen() {
    final profile = state;
    if (profile == null) return;

    final status =
        profile.runStatus == EmployeePayrollRunStatus.exported &&
                profile.payslipVisible
            ? EmployeePayslipDeliveryStatus.ready
            : EmployeePayslipDeliveryStatus.blocked;

    state = profile.copyWith(
      status: status,
      releaseOwner: '',
      releaseNote: '',
      channels: buildEmployeePayslipDeliveryChannels(
        status: status,
        notifyEmployee: profile.notifyEmployee,
        archiveCopy: profile.archiveCopy,
      ),
    );
  }
}

class EmployeePayslipReleaseDraftNotifier
    extends StateNotifier<EmployeePayslipReleaseDraft?> {
  final EmployeePayslipReleaseDraft? _initialDraft;

  EmployeePayslipReleaseDraftNotifier(super.state) : _initialDraft = state;

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setNote(String value) {
    state = state?.copyWith(note: value);
  }

  void setNotifyEmployee(bool value) {
    state = state?.copyWith(notifyEmployee: value);
  }

  void setArchiveCopy(bool value) {
    state = state?.copyWith(archiveCopy: value);
  }

  void reset() {
    state = _initialDraft;
  }
}
