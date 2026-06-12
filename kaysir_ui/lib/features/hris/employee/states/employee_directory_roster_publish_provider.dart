import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_quality_gate_provider.dart';
import 'employee_directory_quality_signoff_provider.dart';

/// Stores the in-progress roster publish packet form.
final employeeDirectoryRosterPublishDraftProvider = StateNotifierProvider<
  EmployeeDirectoryRosterPublishDraftNotifier,
  EmployeeDirectoryRosterPublishDraft
>((ref) => EmployeeDirectoryRosterPublishDraftNotifier());

/// Stores roster publish release history for the active directory workspace.
final employeeDirectoryRosterReleasesProvider = StateNotifierProvider<
  EmployeeDirectoryRosterReleasesNotifier,
  List<EmployeeDirectoryRosterRelease>
>((ref) => EmployeeDirectoryRosterReleasesNotifier());

/// Validates the roster publish draft against gate and sign-off governance.
final employeeDirectoryRosterPublishReviewProvider =
    Provider<EmployeeDirectoryRosterPublishReview>((ref) {
      final signoffs = ref.watch(employeeDirectoryQualityGateSignoffsProvider);

      return EmployeeDirectoryRosterPublishReview.fromState(
        gate: ref.watch(employeeDirectoryQualityGateProvider),
        latestSignoff: signoffs.isEmpty ? null : signoffs.first,
        draft: ref.watch(employeeDirectoryRosterPublishDraftProvider),
        releases: ref.watch(employeeDirectoryRosterReleasesProvider),
        members: ref.watch(employeeDirectoryMembersProvider),
        asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
      );
    });

/// Mutates HR input for roster publish packet preparation.
class EmployeeDirectoryRosterPublishDraftNotifier
    extends StateNotifier<EmployeeDirectoryRosterPublishDraft> {
  EmployeeDirectoryRosterPublishDraftNotifier()
    : super(const EmployeeDirectoryRosterPublishDraft());

  void setPreparedBy(String value) {
    state = state.copyWith(preparedBy: value);
  }

  void setReleaseNote(String value) {
    state = state.copyWith(releaseNote: value);
  }

  void setConfirmPayrollHandoff(bool value) {
    state = state.copyWith(confirmPayrollHandoff: value);
  }

  void clear() {
    state = const EmployeeDirectoryRosterPublishDraft();
  }
}

/// Maintains newest-first roster release packet history.
class EmployeeDirectoryRosterReleasesNotifier
    extends StateNotifier<List<EmployeeDirectoryRosterRelease>> {
  EmployeeDirectoryRosterReleasesNotifier() : super(const []);

  void add(EmployeeDirectoryRosterRelease release) {
    state = [release, ...state].take(8).toList();
  }

  void clear() {
    state = const [];
  }
}
