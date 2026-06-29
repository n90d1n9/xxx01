import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_roster_payroll_validation_models.dart';
import 'employee_directory_roster_payroll_import_provider.dart';

/// Stores the in-progress payroll import validation form.
final employeeDirectoryRosterPayrollValidationDraftProvider =
    StateNotifierProvider<
      EmployeeDirectoryRosterPayrollValidationDraftNotifier,
      EmployeeDirectoryRosterPayrollValidationDraft
    >((ref) => EmployeeDirectoryRosterPayrollValidationDraftNotifier());

/// Stores payroll import validation audit records.
final employeeDirectoryRosterPayrollValidationRecordsProvider =
    StateNotifierProvider<
      EmployeeDirectoryRosterPayrollValidationRecordsNotifier,
      List<EmployeeDirectoryRosterPayrollValidationRecord>
    >((ref) => EmployeeDirectoryRosterPayrollValidationRecordsNotifier());

/// Validates whether the latest staged import packet can be approved.
final employeeDirectoryRosterPayrollValidationReviewProvider = Provider<
  EmployeeDirectoryRosterPayrollValidationReview
>((ref) {
  return EmployeeDirectoryRosterPayrollValidationReview.fromState(
    importReview: ref.watch(employeeDirectoryRosterPayrollImportReviewProvider),
    draft: ref.watch(employeeDirectoryRosterPayrollValidationDraftProvider),
    records: ref.watch(employeeDirectoryRosterPayrollValidationRecordsProvider),
  );
});

/// Mutates payroll import validation input.
class EmployeeDirectoryRosterPayrollValidationDraftNotifier
    extends StateNotifier<EmployeeDirectoryRosterPayrollValidationDraft> {
  EmployeeDirectoryRosterPayrollValidationDraftNotifier()
    : super(const EmployeeDirectoryRosterPayrollValidationDraft());

  void setValidatedBy(String value) {
    state = state.copyWith(validatedBy: value);
  }

  void setValidationNote(String value) {
    state = state.copyWith(validationNote: value);
  }

  void setConfirmFileLoaded(bool value) {
    state = state.copyWith(confirmFileLoaded: value);
  }

  void setConfirmValidationItems(bool value) {
    state = state.copyWith(confirmValidationItems: value);
  }

  void setConfirmPayrollRunControls(bool value) {
    state = state.copyWith(confirmPayrollRunControls: value);
  }

  void clear() {
    state = const EmployeeDirectoryRosterPayrollValidationDraft();
  }
}

/// Maintains newest-first payroll import validation approvals.
class EmployeeDirectoryRosterPayrollValidationRecordsNotifier
    extends
        StateNotifier<List<EmployeeDirectoryRosterPayrollValidationRecord>> {
  EmployeeDirectoryRosterPayrollValidationRecordsNotifier() : super(const []);

  void add(EmployeeDirectoryRosterPayrollValidationRecord record) {
    state = [record, ...state].take(8).toList();
  }

  void clear() {
    state = const [];
  }
}
