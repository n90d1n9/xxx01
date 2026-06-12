import 'employee_payroll_close_models.dart';
import 'employee_payroll_payment_models.dart';
import 'employee_payroll_run_console_models.dart';
import 'employee_payroll_run_models.dart';
import 'employee_payslip_delivery_models.dart';

/// Bulk payroll operation exposed by the directory payroll run console.
enum EmployeePayrollRunConsoleCommandType {
  prepareExport(
    'Prepare export',
    'Review and export eligible employee payroll runs.',
    'Prepare export',
  ),
  settlePayment(
    'Settle pay',
    'Schedule ready net pay instructions and mark them paid.',
    'Settle pay',
  ),
  publishPayslip(
    'Publish payslips',
    'Release ready payslips to self-service and archive.',
    'Publish',
  ),
  closePeriod(
    'Close period',
    'Post ready accounting journals and close payroll periods.',
    'Close',
  );

  final String label;
  final String description;
  final String actionLabel;

  const EmployeePayrollRunConsoleCommandType(
    this.label,
    this.description,
    this.actionLabel,
  );
}

/// Computed readiness for one bulk operation in the payroll run console.
class EmployeePayrollRunConsoleCommand {
  final EmployeePayrollRunConsoleCommandType type;
  final int eligibleCount;
  final int blockedCount;
  final int completedCount;

  const EmployeePayrollRunConsoleCommand({
    required this.type,
    required this.eligibleCount,
    required this.blockedCount,
    required this.completedCount,
  });

  bool get isEnabled => eligibleCount > 0;

  String get readinessLabel {
    if (eligibleCount > 0) {
      return '$eligibleCount ready';
    }
    if (blockedCount > 0) {
      return '$blockedCount blocked';
    }
    if (completedCount > 0) {
      return 'Complete';
    }
    return 'Not ready';
  }

  String get coverageLabel {
    return '$completedCount complete, $eligibleCount ready';
  }
}

/// Ordered command plan derived from the active payroll run coverage state.
class EmployeePayrollRunConsoleCommandPlan {
  final String runReference;
  final int selectedEmployeeCount;
  final int targetEmployeeCount;
  final List<EmployeePayrollRunConsoleCommand> commands;

  const EmployeePayrollRunConsoleCommandPlan({
    required this.runReference,
    required this.selectedEmployeeCount,
    required this.targetEmployeeCount,
    required this.commands,
  });

  factory EmployeePayrollRunConsoleCommandPlan.fromReview(
    EmployeePayrollRunConsoleReview review, {
    Set<String> targetEmployeeIds = const {},
  }) {
    if (!review.hasActiveRun) {
      return const EmployeePayrollRunConsoleCommandPlan(
        runReference: '',
        selectedEmployeeCount: 0,
        targetEmployeeCount: 0,
        commands: [],
      );
    }

    final rows = _targetRows(review.rows, targetEmployeeIds);
    return EmployeePayrollRunConsoleCommandPlan(
      runReference: review.activeRun!.runReference,
      selectedEmployeeCount: targetEmployeeIds.length,
      targetEmployeeCount: rows.length,
      commands: [
        EmployeePayrollRunConsoleCommand(
          type: EmployeePayrollRunConsoleCommandType.prepareExport,
          eligibleCount: rows.where(_canPrepareExport).length,
          blockedCount: rows.where(_blocksPrepareExport).length,
          completedCount: rows.where((row) => row.isExported).length,
        ),
        EmployeePayrollRunConsoleCommand(
          type: EmployeePayrollRunConsoleCommandType.settlePayment,
          eligibleCount: rows.where(_canSettlePayment).length,
          blockedCount: rows.where(_blocksPayment).length,
          completedCount: rows.where((row) => row.isPaymentPaid).length,
        ),
        EmployeePayrollRunConsoleCommand(
          type: EmployeePayrollRunConsoleCommandType.publishPayslip,
          eligibleCount: rows.where(_canPublishPayslip).length,
          blockedCount: rows.where(_blocksPayslip).length,
          completedCount: rows.where((row) => row.isPayslipPublished).length,
        ),
        EmployeePayrollRunConsoleCommand(
          type: EmployeePayrollRunConsoleCommandType.closePeriod,
          eligibleCount: rows.where(_canClosePeriod).length,
          blockedCount: rows.where(_blocksClose).length,
          completedCount: rows.where((row) => row.isClosed).length,
        ),
      ],
    );
  }

  bool get isSelectionScoped => selectedEmployeeCount > 0;

  String get scopeLabel {
    if (!isSelectionScoped) return 'All $targetEmployeeCount run employees';
    if (targetEmployeeCount == 0) {
      return '$selectedEmployeeCount selected, none in this run';
    }
    return '$targetEmployeeCount selected in run';
  }

  String get scopeDescription {
    if (!isSelectionScoped) {
      return 'Commands apply to every covered employee in $runReference.';
    }
    if (targetEmployeeCount == 0) {
      return 'Select employees covered by this payroll run to enable commands.';
    }
    return 'Commands apply only to the selected employee cohort.';
  }

  EmployeePayrollRunConsoleCommand? get primaryCommand {
    for (final command in commands) {
      if (command.isEnabled) return command;
    }
    return null;
  }

  bool get hasEnabledCommand => primaryCommand != null;
}

/// Result returned after a payroll run console command is executed.
class EmployeePayrollRunConsoleCommandResult {
  final EmployeePayrollRunConsoleCommandType type;
  final int completedCount;
  final int skippedCount;
  final List<String> errors;
  final String message;

  const EmployeePayrollRunConsoleCommandResult({
    required this.type,
    required this.completedCount,
    required this.skippedCount,
    required this.errors,
    required this.message,
  });

  bool get hasChanges => completedCount > 0;

  bool get hasErrors => errors.isNotEmpty;

  String get supportingLabel {
    if (hasErrors) return errors.first;
    if (skippedCount > 0) return '$skippedCount skipped';
    return 'Ready for the next payroll operation';
  }
}

bool _canPrepareExport(EmployeePayrollRunConsoleEmployeeRow row) {
  return row.runStatus == EmployeePayrollRunStatus.draft ||
      row.runStatus == EmployeePayrollRunStatus.ready;
}

bool _blocksPrepareExport(EmployeePayrollRunConsoleEmployeeRow row) {
  return !row.isExported && !_canPrepareExport(row);
}

bool _canSettlePayment(EmployeePayrollRunConsoleEmployeeRow row) {
  return row.paymentStatus == EmployeePayrollPaymentStatus.ready ||
      row.paymentStatus == EmployeePayrollPaymentStatus.scheduled;
}

bool _blocksPayment(EmployeePayrollRunConsoleEmployeeRow row) {
  return row.isExported && !row.isPaymentPaid && !_canSettlePayment(row);
}

bool _canPublishPayslip(EmployeePayrollRunConsoleEmployeeRow row) {
  return row.payslipStatus == EmployeePayslipDeliveryStatus.ready;
}

bool _blocksPayslip(EmployeePayrollRunConsoleEmployeeRow row) {
  return row.isExported && !row.isPayslipPublished && !_canPublishPayslip(row);
}

bool _canClosePeriod(EmployeePayrollRunConsoleEmployeeRow row) {
  return row.closeStatus == EmployeePayrollCloseStatus.ready ||
      row.closeStatus == EmployeePayrollCloseStatus.posted;
}

bool _blocksClose(EmployeePayrollRunConsoleEmployeeRow row) {
  return row.isExported && !row.isClosed && !_canClosePeriod(row);
}

List<EmployeePayrollRunConsoleEmployeeRow> _targetRows(
  List<EmployeePayrollRunConsoleEmployeeRow> rows,
  Set<String> targetEmployeeIds,
) {
  if (targetEmployeeIds.isEmpty) return rows;
  return rows
      .where((row) => targetEmployeeIds.contains(row.employeeId))
      .toList(growable: false);
}
