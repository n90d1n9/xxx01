import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_quality_signoff_models.dart';
import 'employee_directory_quality_gate_provider.dart';

/// Stores the in-progress roster quality gate sign-off form.
final employeeDirectoryQualityGateSignoffDraftProvider = StateNotifierProvider<
  EmployeeDirectoryQualityGateSignoffDraftNotifier,
  EmployeeDirectoryQualityGateSignoffDraft
>((ref) => EmployeeDirectoryQualityGateSignoffDraftNotifier());

/// Stores roster quality gate sign-off history for the current directory view.
final employeeDirectoryQualityGateSignoffsProvider = StateNotifierProvider<
  EmployeeDirectoryQualityGateSignoffsNotifier,
  List<EmployeeDirectoryQualityGateSignoff>
>((ref) => EmployeeDirectoryQualityGateSignoffsNotifier());

/// Validates the sign-off draft against the current readiness gate.
final employeeDirectoryQualityGateSignoffReviewProvider =
    Provider<EmployeeDirectoryQualityGateSignoffReview>((ref) {
      return EmployeeDirectoryQualityGateSignoffReview.fromState(
        gate: ref.watch(employeeDirectoryQualityGateProvider),
        draft: ref.watch(employeeDirectoryQualityGateSignoffDraftProvider),
        signoffs: ref.watch(employeeDirectoryQualityGateSignoffsProvider),
      );
    });

/// Mutates reviewer input for roster quality gate sign-off.
class EmployeeDirectoryQualityGateSignoffDraftNotifier
    extends StateNotifier<EmployeeDirectoryQualityGateSignoffDraft> {
  EmployeeDirectoryQualityGateSignoffDraftNotifier()
    : super(const EmployeeDirectoryQualityGateSignoffDraft());

  void setReviewer(String value) {
    state = state.copyWith(reviewer: value);
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
  }

  void setAcceptReviewItems(bool value) {
    state = state.copyWith(acceptReviewItems: value);
  }

  void clear() {
    state = const EmployeeDirectoryQualityGateSignoffDraft();
  }
}

/// Maintains newest-first roster quality gate sign-off history.
class EmployeeDirectoryQualityGateSignoffsNotifier
    extends StateNotifier<List<EmployeeDirectoryQualityGateSignoff>> {
  EmployeeDirectoryQualityGateSignoffsNotifier() : super(const []);

  void add(EmployeeDirectoryQualityGateSignoff signoff) {
    state = [signoff, ...state].take(8).toList();
  }

  void clear() {
    state = const [];
  }
}
