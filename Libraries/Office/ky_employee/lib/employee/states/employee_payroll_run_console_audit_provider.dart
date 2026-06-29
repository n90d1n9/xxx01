import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_payroll_run_console_audit_models.dart';
import '../models/employee_payroll_run_console_command_models.dart';

/// Stores run-level payroll console audit events.
final employeePayrollRunConsoleAuditProvider = StateNotifierProvider<
  EmployeePayrollRunConsoleAuditNotifier,
  List<EmployeePayrollRunConsoleAuditEvent>
>((ref) => EmployeePayrollRunConsoleAuditNotifier());

/// Summarizes run-level payroll console audit events.
final employeePayrollRunConsoleAuditSummaryProvider =
    Provider<EmployeePayrollRunConsoleAuditSummary>((ref) {
      return EmployeePayrollRunConsoleAuditSummary(
        events: ref.watch(employeePayrollRunConsoleAuditProvider),
      );
    });

/// Mutates the payroll console audit timeline.
class EmployeePayrollRunConsoleAuditNotifier
    extends StateNotifier<List<EmployeePayrollRunConsoleAuditEvent>> {
  EmployeePayrollRunConsoleAuditNotifier() : super(const []);

  EmployeePayrollRunConsoleAuditEvent recordCommand({
    required EmployeePayrollRunConsoleCommandResult result,
    required EmployeePayrollRunConsoleCommandPlan plan,
    required String operatorName,
    required DateTime occurredAt,
  }) {
    final event = EmployeePayrollRunConsoleAuditEvent.fromCommandResult(
      id: _nextId(),
      result: result,
      plan: plan,
      operatorName: operatorName,
      occurredAt: occurredAt,
    );
    state = [event, ...state].take(24).toList(growable: false);
    return event;
  }

  void clear() {
    state = const [];
  }

  String _nextId() {
    return 'payroll-console-audit-${state.length + 1}';
  }
}
