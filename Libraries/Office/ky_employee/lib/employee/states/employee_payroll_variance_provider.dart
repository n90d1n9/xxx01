import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_payroll_variance_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_payroll_variance_models.dart';
import 'employee_compensation_provider.dart';
import 'employee_directory_provider.dart';
import 'employee_leave_provider.dart';
import 'employee_payroll_cutoff_provider.dart';
import 'employee_payroll_provider.dart';
import 'employee_reimbursement_provider.dart';
import 'employee_timekeeping_provider.dart';

final employeePayrollVarianceProvider = StateNotifierProvider.family<
  EmployeePayrollVarianceNotifier,
  EmployeePayrollVarianceProfile?,
  String
>((ref, employeeId) {
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  final compensationPackage = ref.watch(
    employeeCompensationPackageProvider(employeeId),
  );
  final compensationSummary = ref.watch(
    employeeCompensationReviewSummaryProvider(employeeId),
  );
  final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
  final timekeeping = ref.watch(employeeTimekeepingProvider(employeeId));
  final leave = ref.watch(employeeLeaveProfileProvider(employeeId));
  final reimbursement = ref.watch(
    employeeReimbursementProfileProvider(employeeId),
  );
  final cutoff = ref.watch(
    employeePayrollCutoffReconciliationProvider(employeeId),
  );

  if (member == null ||
      compensationPackage == null ||
      payroll == null ||
      timekeeping == null ||
      leave == null ||
      reimbursement == null ||
      cutoff == null) {
    return EmployeePayrollVarianceNotifier(null);
  }

  return EmployeePayrollVarianceNotifier(
    buildEmployeePayrollVarianceProfile(
      member: member,
      compensationPackage: compensationPackage,
      compensationSummary: compensationSummary,
      payroll: payroll,
      timekeeping: timekeeping,
      leave: leave,
      reimbursement: reimbursement,
      cutoff: cutoff,
    ),
  );
});

final employeePayrollVarianceAdjustmentDraftProvider =
    StateNotifierProvider.family<
      EmployeePayrollVarianceAdjustmentDraftNotifier,
      EmployeePayrollVarianceAdjustmentDraft?,
      String
    >((ref, employeeId) {
      final member = _findMember(
        ref.watch(employeeDirectoryMembersProvider),
        employeeId,
      );
      final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
      if (member == null || payroll == null) {
        return EmployeePayrollVarianceAdjustmentDraftNotifier(null);
      }

      return EmployeePayrollVarianceAdjustmentDraftNotifier(
        buildEmployeePayrollVarianceAdjustmentDraft(
          member: member,
          payroll: payroll,
        ),
      );
    });

class EmployeePayrollVarianceNotifier
    extends StateNotifier<EmployeePayrollVarianceProfile?> {
  EmployeePayrollVarianceNotifier(super.state);

  EmployeePayrollVarianceLine addAdjustment(
    EmployeePayrollVarianceAdjustmentDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee payroll variance profile is unavailable');
    }

    final line = draft.toLine(
      id: _nextAdjustmentId(profile),
      baselineGrossPay: profile.baselineGrossPay,
    );
    state = profile.copyWith(
      lines: [
        line,
        ...profile.lines.where((item) => item.id != 'variance-clear'),
      ],
    );
    return line;
  }

  void reviewLine(String lineId) {
    _updateLine(
      lineId,
      (line) =>
          line.isClosed
              ? line
              : line.copyWith(status: EmployeePayrollVarianceStatus.reviewed),
    );
  }

  void approveLine(String lineId) {
    _updateLine(
      lineId,
      (line) => line.copyWith(status: EmployeePayrollVarianceStatus.approved),
    );
  }

  void excludeLine(String lineId) {
    _updateLine(
      lineId,
      (line) => line.copyWith(status: EmployeePayrollVarianceStatus.excluded),
    );
  }

  void reopenLine(String lineId) {
    _updateLine(
      lineId,
      (line) => line.copyWith(status: EmployeePayrollVarianceStatus.open),
    );
  }

  void _updateLine(
    String lineId,
    EmployeePayrollVarianceLine Function(EmployeePayrollVarianceLine line)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      lines:
          profile.lines.map((line) {
            if (line.id != lineId) return line;
            return update(line);
          }).toList(),
    );
  }

  String _nextAdjustmentId(EmployeePayrollVarianceProfile profile) {
    var index = profile.manualAdjustmentCount + 1;
    while (true) {
      final id =
          'EPV-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.lines.any((line) => line.id == id)) return id;
      index++;
    }
  }
}

class EmployeePayrollVarianceAdjustmentDraftNotifier
    extends StateNotifier<EmployeePayrollVarianceAdjustmentDraft?> {
  final EmployeePayrollVarianceAdjustmentDraft? _initialDraft;

  EmployeePayrollVarianceAdjustmentDraftNotifier(super.state)
    : _initialDraft = state;

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setAmount(double value) {
    state = state?.copyWith(amount: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setReason(String value) {
    state = state?.copyWith(reason: value);
  }

  void setTaxableImpact(bool value) {
    state = state?.copyWith(taxableImpact: value);
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
