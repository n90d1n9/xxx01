import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_payroll_run_console_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_roster_payroll_run_kickoff_provider.dart';
import 'employee_payroll_close_provider.dart';
import 'employee_payroll_payment_provider.dart';
import 'employee_payroll_run_provider.dart';
import 'employee_payslip_delivery_provider.dart';

/// Aggregates launched directory payroll runs with employee execution status.
final employeePayrollRunConsoleProvider =
    Provider<EmployeePayrollRunConsoleReview>((ref) {
      final records = ref.watch(
        employeeDirectoryRosterPayrollRunKickoffRecordsProvider,
      );
      if (records.isEmpty) {
        return const EmployeePayrollRunConsoleReview(records: [], rows: []);
      }

      final members = ref.watch(employeeDirectoryMembersProvider);
      final rows = members
          .map((member) {
            return EmployeePayrollRunConsoleEmployeeRow.fromState(
              member: member,
              payrollRun: ref.watch(employeePayrollRunProvider(member.id)),
              payment: ref.watch(employeePayrollPaymentProvider(member.id)),
              payslip: ref.watch(employeePayslipDeliveryProvider(member.id)),
              close: ref.watch(employeePayrollCloseProvider(member.id)),
            );
          })
          .toList(growable: false);

      return EmployeePayrollRunConsoleReview(records: records, rows: rows);
    });
