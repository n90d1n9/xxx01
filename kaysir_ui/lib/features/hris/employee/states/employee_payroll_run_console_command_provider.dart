import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_payroll_close_models.dart';
import '../models/employee_payroll_payment_models.dart';
import '../models/employee_payroll_run_console_command_models.dart';
import '../models/employee_payroll_run_console_models.dart';
import '../models/employee_payroll_run_models.dart';
import '../models/employee_payslip_delivery_models.dart';
import 'employee_directory_provider.dart';
import 'employee_payroll_close_provider.dart';
import 'employee_payroll_payment_provider.dart';
import 'employee_payroll_run_console_audit_provider.dart';
import 'employee_payroll_run_console_provider.dart';
import 'employee_payroll_run_provider.dart';
import 'employee_payslip_delivery_provider.dart';

/// Stores the latest directory payroll run console command result.
final employeePayrollRunConsoleCommandResultProvider =
    StateProvider<EmployeePayrollRunConsoleCommandResult?>((ref) => null);

/// Coordinates bulk payroll run operations from the directory console.
final employeePayrollRunConsoleCommandControllerProvider =
    Provider<EmployeePayrollRunConsoleCommandController>(
      EmployeePayrollRunConsoleCommandController.new,
    );

/// Runs validated payroll operations across the active directory run.
class EmployeePayrollRunConsoleCommandController {
  final Ref _ref;

  const EmployeePayrollRunConsoleCommandController(this._ref);

  EmployeePayrollRunConsoleCommandResult run(
    EmployeePayrollRunConsoleCommandType type, {
    Set<String> targetEmployeeIds = const {},
  }) {
    final review = _ref.read(employeePayrollRunConsoleProvider);
    if (!review.hasActiveRun) {
      return _store(
        EmployeePayrollRunConsoleCommandResult(
          type: type,
          completedCount: 0,
          skippedCount: 0,
          errors: const [],
          message: 'Launch payroll run before running console actions.',
        ),
      );
    }

    final rows = _targetRows(review.rows, targetEmployeeIds);
    if (targetEmployeeIds.isNotEmpty && rows.isEmpty) {
      return _storeWithAudit(
        EmployeePayrollRunConsoleCommandResult(
          type: type,
          completedCount: 0,
          skippedCount: 0,
          errors: const [],
          message:
              '${type.label} has no selected employees in this payroll run.',
        ),
        review: review,
        targetEmployeeIds: targetEmployeeIds,
      );
    }

    final result = switch (type) {
      EmployeePayrollRunConsoleCommandType.prepareExport => _runForRows(
        rows: rows,
        type: type,
        action: (row) => _prepareAndExport(review, row),
      ),
      EmployeePayrollRunConsoleCommandType.settlePayment => _runForRows(
        rows: rows,
        type: type,
        action: _settlePayment,
      ),
      EmployeePayrollRunConsoleCommandType.publishPayslip => _runForRows(
        rows: rows,
        type: type,
        action: _publishPayslip,
      ),
      EmployeePayrollRunConsoleCommandType.closePeriod => _runForRows(
        rows: rows,
        type: type,
        action: _closePeriod,
      ),
    };
    return _storeWithAudit(
      result,
      review: review,
      targetEmployeeIds: targetEmployeeIds,
    );
  }

  EmployeePayrollRunConsoleCommandResult _runForRows({
    required List<EmployeePayrollRunConsoleEmployeeRow> rows,
    required EmployeePayrollRunConsoleCommandType type,
    required bool Function(EmployeePayrollRunConsoleEmployeeRow row) action,
  }) {
    var completedCount = 0;
    var skippedCount = 0;
    final errors = <String>[];

    for (final row in rows) {
      try {
        if (action(row)) {
          completedCount++;
        } else {
          skippedCount++;
        }
      } catch (error) {
        skippedCount++;
        errors.add('${row.employeeName}: ${_errorMessage(error)}');
      }
    }

    return EmployeePayrollRunConsoleCommandResult(
      type: type,
      completedCount: completedCount,
      skippedCount: skippedCount,
      errors: errors,
      message: _messageFor(
        type: type,
        completedCount: completedCount,
        skippedCount: skippedCount,
        errors: errors,
      ),
    );
  }

  bool _prepareAndExport(
    EmployeePayrollRunConsoleReview review,
    EmployeePayrollRunConsoleEmployeeRow row,
  ) {
    final notifier = _ref.read(
      employeePayrollRunProvider(row.employeeId).notifier,
    );
    final profile = _ref.read(employeePayrollRunProvider(row.employeeId));
    if (profile == null ||
        profile.status == EmployeePayrollRunStatus.exported) {
      return false;
    }

    var exportProfile = profile;
    if (profile.status == EmployeePayrollRunStatus.draft) {
      final draft = _ref.read(
        employeePayrollRunReviewDraftProvider(row.employeeId),
      );
      if (draft == null) return false;

      notifier.markReviewed(
        draft.copyWith(
          note: 'Payroll run reviewed from directory console.',
          payslipVisible: true,
        ),
      );
      final reviewedProfile = _ref.read(
        employeePayrollRunProvider(row.employeeId),
      );
      if (reviewedProfile == null) return false;
      exportProfile = reviewedProfile;
    }

    if (exportProfile.status != EmployeePayrollRunStatus.ready) return false;

    notifier.exportRun(review.activeRun!.runReference);
    return true;
  }

  bool _settlePayment(EmployeePayrollRunConsoleEmployeeRow row) {
    final notifier = _ref.read(
      employeePayrollPaymentProvider(row.employeeId).notifier,
    );
    var profile = _ref.read(employeePayrollPaymentProvider(row.employeeId));
    if (profile == null ||
        profile.status == EmployeePayrollPaymentStatus.paid) {
      return false;
    }

    if (profile.status == EmployeePayrollPaymentStatus.ready) {
      final draft = _ref.read(
        employeePayrollPaymentDraftProvider(row.employeeId),
      );
      if (draft == null) return false;

      notifier.schedule(
        draft.copyWith(note: 'Payment scheduled from payroll run console.'),
      );
      final scheduledProfile = _ref.read(
        employeePayrollPaymentProvider(row.employeeId),
      );
      if (scheduledProfile == null) return false;
      profile = scheduledProfile;
    }

    if (profile.status != EmployeePayrollPaymentStatus.scheduled) return false;

    notifier.markPaid();
    return true;
  }

  bool _publishPayslip(EmployeePayrollRunConsoleEmployeeRow row) {
    final notifier = _ref.read(
      employeePayslipDeliveryProvider(row.employeeId).notifier,
    );
    final profile = _ref.read(employeePayslipDeliveryProvider(row.employeeId));
    if (profile == null ||
        profile.status == EmployeePayslipDeliveryStatus.published ||
        profile.status != EmployeePayslipDeliveryStatus.ready) {
      return false;
    }

    final draft = _ref.read(
      employeePayslipReleaseDraftProvider(row.employeeId),
    );
    if (draft == null) return false;

    notifier.release(
      draft.copyWith(
        note: 'Payslip release approved from payroll run console.',
      ),
    );
    return true;
  }

  bool _closePeriod(EmployeePayrollRunConsoleEmployeeRow row) {
    final notifier = _ref.read(
      employeePayrollCloseProvider(row.employeeId).notifier,
    );
    var profile = _ref.read(employeePayrollCloseProvider(row.employeeId));
    if (profile == null ||
        profile.status == EmployeePayrollCloseStatus.closed) {
      return false;
    }

    if (profile.status == EmployeePayrollCloseStatus.ready) {
      final draft = _ref.read(
        employeePayrollCloseDraftProvider(row.employeeId),
      );
      if (draft == null) return false;

      notifier.postJournal(
        draft.copyWith(
          note: 'Accounting handoff posted from payroll run console.',
        ),
      );
      final postedProfile = _ref.read(
        employeePayrollCloseProvider(row.employeeId),
      );
      if (postedProfile == null) return false;
      profile = postedProfile;
    }

    if (profile.status != EmployeePayrollCloseStatus.posted) return false;

    notifier.closePeriod();
    return true;
  }

  EmployeePayrollRunConsoleCommandResult _store(
    EmployeePayrollRunConsoleCommandResult result,
  ) {
    _ref.read(employeePayrollRunConsoleCommandResultProvider.notifier).state =
        result;
    return result;
  }

  EmployeePayrollRunConsoleCommandResult _storeWithAudit(
    EmployeePayrollRunConsoleCommandResult result, {
    required EmployeePayrollRunConsoleReview review,
    required Set<String> targetEmployeeIds,
  }) {
    final stored = _store(result);
    final activeRun = review.activeRun;
    if (activeRun == null) return stored;

    final plan = EmployeePayrollRunConsoleCommandPlan.fromReview(
      review,
      targetEmployeeIds: targetEmployeeIds,
    );
    _ref
        .read(employeePayrollRunConsoleAuditProvider.notifier)
        .recordCommand(
          result: stored,
          plan: plan,
          operatorName: activeRun.runOwner,
          occurredAt: _ref.read(employeeDirectoryAsOfDateProvider),
        );
    return stored;
  }

  String _messageFor({
    required EmployeePayrollRunConsoleCommandType type,
    required int completedCount,
    required int skippedCount,
    required List<String> errors,
  }) {
    if (completedCount == 0) {
      if (errors.isNotEmpty) return '${type.label} could not update employees.';
      return '${type.label} has no eligible employees.';
    }

    final employeeLabel = completedCount == 1 ? 'employee' : 'employees';
    final actionLabel = switch (type) {
      EmployeePayrollRunConsoleCommandType.prepareExport =>
        'prepared and exported',
      EmployeePayrollRunConsoleCommandType.settlePayment => 'settled',
      EmployeePayrollRunConsoleCommandType.publishPayslip => 'published',
      EmployeePayrollRunConsoleCommandType.closePeriod => 'closed',
    };
    final suffix = skippedCount > 0 ? ', $skippedCount skipped.' : '.';
    return '$completedCount $employeeLabel $actionLabel$suffix';
  }

  String _errorMessage(Object error) {
    if (error is StateError) return error.message;
    return error.toString();
  }
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
