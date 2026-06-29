import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_roster_payroll_import_models.dart';
import 'employee_directory_roster_payroll_sync_provider.dart';

/// Stores the in-progress roster payroll import packet form.
final employeeDirectoryRosterPayrollImportDraftProvider = StateNotifierProvider<
  EmployeeDirectoryRosterPayrollImportDraftNotifier,
  EmployeeDirectoryRosterPayrollImportDraft
>((ref) => EmployeeDirectoryRosterPayrollImportDraftNotifier());

/// Stores staged payroll import packets by roster release.
final employeeDirectoryRosterPayrollImportBatchesProvider =
    StateNotifierProvider<
      EmployeeDirectoryRosterPayrollImportBatchesNotifier,
      List<EmployeeDirectoryRosterPayrollImportBatch>
    >((ref) => EmployeeDirectoryRosterPayrollImportBatchesNotifier());

/// Validates whether the latest synced roster can be staged for payroll import.
final employeeDirectoryRosterPayrollImportReviewProvider =
    Provider<EmployeeDirectoryRosterPayrollImportReview>((ref) {
      return EmployeeDirectoryRosterPayrollImportReview.fromState(
        syncReview: ref.watch(employeeDirectoryRosterPayrollSyncReviewProvider),
        draft: ref.watch(employeeDirectoryRosterPayrollImportDraftProvider),
        batches: ref.watch(employeeDirectoryRosterPayrollImportBatchesProvider),
      );
    });

/// Mutates payroll import staging input.
class EmployeeDirectoryRosterPayrollImportDraftNotifier
    extends StateNotifier<EmployeeDirectoryRosterPayrollImportDraft> {
  EmployeeDirectoryRosterPayrollImportDraftNotifier()
    : super(const EmployeeDirectoryRosterPayrollImportDraft());

  void setBatchLabel(String value) {
    state = state.copyWith(batchLabel: value);
  }

  void setPreparedBy(String value) {
    state = state.copyWith(preparedBy: value);
  }

  void setImportNote(String value) {
    state = state.copyWith(importNote: value);
  }

  void setConfirmColumnMapping(bool value) {
    state = state.copyWith(confirmColumnMapping: value);
  }

  void setConfirmAttentionProfiles(bool value) {
    state = state.copyWith(confirmAttentionProfiles: value);
  }

  void setConfirmPreviewControls(bool value) {
    state = state.copyWith(confirmPreviewControls: value);
  }

  void clear() {
    state = const EmployeeDirectoryRosterPayrollImportDraft();
  }
}

/// Maintains newest-first payroll import packet history.
class EmployeeDirectoryRosterPayrollImportBatchesNotifier
    extends StateNotifier<List<EmployeeDirectoryRosterPayrollImportBatch>> {
  EmployeeDirectoryRosterPayrollImportBatchesNotifier() : super(const []);

  void add(EmployeeDirectoryRosterPayrollImportBatch batch) {
    state = [batch, ...state].take(8).toList();
  }

  void clear() {
    state = const [];
  }
}
