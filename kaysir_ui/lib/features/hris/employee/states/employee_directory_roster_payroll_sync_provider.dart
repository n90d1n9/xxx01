import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_roster_payroll_sync_models.dart';
import 'employee_directory_roster_diff_provider.dart';
import 'employee_directory_roster_handoff_provider.dart';

/// Stores the in-progress roster payroll sync reconciliation form.
final employeeDirectoryRosterPayrollSyncDraftProvider = StateNotifierProvider<
  EmployeeDirectoryRosterPayrollSyncDraftNotifier,
  EmployeeDirectoryRosterPayrollSyncDraft
>((ref) => EmployeeDirectoryRosterPayrollSyncDraftNotifier());

/// Stores payroll sync audit history by roster release packet.
final employeeDirectoryRosterPayrollSyncRecordsProvider = StateNotifierProvider<
  EmployeeDirectoryRosterPayrollSyncRecordsNotifier,
  List<EmployeeDirectoryRosterPayrollSyncRecord>
>((ref) => EmployeeDirectoryRosterPayrollSyncRecordsNotifier());

/// Validates payroll sync readiness for the latest roster release packet.
final employeeDirectoryRosterPayrollSyncReviewProvider =
    Provider<EmployeeDirectoryRosterPayrollSyncReview>((ref) {
      return EmployeeDirectoryRosterPayrollSyncReview.fromState(
        diffReview: ref.watch(employeeDirectoryRosterDiffReviewProvider),
        handoffReview: ref.watch(employeeDirectoryRosterHandoffReviewProvider),
        draft: ref.watch(employeeDirectoryRosterPayrollSyncDraftProvider),
        records: ref.watch(employeeDirectoryRosterPayrollSyncRecordsProvider),
      );
    });

/// Mutates payroll reconciliation input for roster release sync.
class EmployeeDirectoryRosterPayrollSyncDraftNotifier
    extends StateNotifier<EmployeeDirectoryRosterPayrollSyncDraft> {
  EmployeeDirectoryRosterPayrollSyncDraftNotifier()
    : super(const EmployeeDirectoryRosterPayrollSyncDraft());

  void setSyncedBy(String value) {
    state = state.copyWith(syncedBy: value);
  }

  void setSyncNote(String value) {
    state = state.copyWith(syncNote: value);
  }

  void setConfirmPayrollImpactReview(bool value) {
    state = state.copyWith(confirmPayrollImpactReview: value);
  }

  void setConfirmControlTotals(bool value) {
    state = state.copyWith(confirmControlTotals: value);
  }

  void clear() {
    state = const EmployeeDirectoryRosterPayrollSyncDraft();
  }
}

/// Maintains newest-first payroll sync records.
class EmployeeDirectoryRosterPayrollSyncRecordsNotifier
    extends StateNotifier<List<EmployeeDirectoryRosterPayrollSyncRecord>> {
  EmployeeDirectoryRosterPayrollSyncRecordsNotifier() : super(const []);

  void add(EmployeeDirectoryRosterPayrollSyncRecord record) {
    state = [record, ...state].take(8).toList();
  }

  void clear() {
    state = const [];
  }
}
