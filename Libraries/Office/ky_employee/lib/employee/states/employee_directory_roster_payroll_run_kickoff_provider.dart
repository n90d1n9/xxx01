import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_roster_payroll_run_kickoff_models.dart';
import 'employee_directory_roster_payroll_validation_provider.dart';

/// Stores the in-progress payroll run kickoff form.
final employeeDirectoryRosterPayrollRunKickoffDraftProvider =
    StateNotifierProvider<
      EmployeeDirectoryRosterPayrollRunKickoffDraftNotifier,
      EmployeeDirectoryRosterPayrollRunKickoffDraft
    >((ref) => EmployeeDirectoryRosterPayrollRunKickoffDraftNotifier());

/// Stores launched payroll run kickoff audit records.
final employeeDirectoryRosterPayrollRunKickoffRecordsProvider =
    StateNotifierProvider<
      EmployeeDirectoryRosterPayrollRunKickoffRecordsNotifier,
      List<EmployeeDirectoryRosterPayrollRunKickoffRecord>
    >((ref) => EmployeeDirectoryRosterPayrollRunKickoffRecordsNotifier());

/// Validates whether a payroll run can start from the latest import approval.
final employeeDirectoryRosterPayrollRunKickoffReviewProvider =
    Provider<EmployeeDirectoryRosterPayrollRunKickoffReview>((ref) {
      return EmployeeDirectoryRosterPayrollRunKickoffReview.fromState(
        validationReview: ref.watch(
          employeeDirectoryRosterPayrollValidationReviewProvider,
        ),
        draft: ref.watch(employeeDirectoryRosterPayrollRunKickoffDraftProvider),
        records: ref.watch(
          employeeDirectoryRosterPayrollRunKickoffRecordsProvider,
        ),
      );
    });

/// Mutates payroll run kickoff input.
class EmployeeDirectoryRosterPayrollRunKickoffDraftNotifier
    extends StateNotifier<EmployeeDirectoryRosterPayrollRunKickoffDraft> {
  EmployeeDirectoryRosterPayrollRunKickoffDraftNotifier()
    : super(const EmployeeDirectoryRosterPayrollRunKickoffDraft());

  void setRunReference(String value) {
    state = state.copyWith(runReference: value);
  }

  void setRunOwner(String value) {
    state = state.copyWith(runOwner: value);
  }

  void setKickoffNote(String value) {
    state = state.copyWith(kickoffNote: value);
  }

  void setConfirmFundingWindow(bool value) {
    state = state.copyWith(confirmFundingWindow: value);
  }

  void setConfirmPayslipHold(bool value) {
    state = state.copyWith(confirmPayslipHold: value);
  }

  void setConfirmAuditArchive(bool value) {
    state = state.copyWith(confirmAuditArchive: value);
  }

  void clear() {
    state = const EmployeeDirectoryRosterPayrollRunKickoffDraft();
  }
}

/// Maintains newest-first payroll run kickoff records.
class EmployeeDirectoryRosterPayrollRunKickoffRecordsNotifier
    extends
        StateNotifier<List<EmployeeDirectoryRosterPayrollRunKickoffRecord>> {
  EmployeeDirectoryRosterPayrollRunKickoffRecordsNotifier() : super(const []);

  void add(EmployeeDirectoryRosterPayrollRunKickoffRecord record) {
    state = [record, ...state].take(8).toList();
  }

  void clear() {
    state = const [];
  }
}
