import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_quality_fix_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_quality_provider.dart';

/// Stores the in-progress remediation fields for the quality fix workspace.
final employeeDirectoryQualityFixDraftProvider = StateNotifierProvider<
  EmployeeDirectoryQualityFixDraftNotifier,
  EmployeeDirectoryQualityFixDraft
>((ref) => EmployeeDirectoryQualityFixDraftNotifier());

/// Derives selected issue, validation errors, and submit readiness for a fix.
final employeeDirectoryQualityFixReviewProvider =
    Provider<EmployeeDirectoryQualityFixReview>((ref) {
      return EmployeeDirectoryQualityFixReview.fromState(
        report: ref.watch(employeeDirectoryQualityReportProvider),
        members: ref.watch(employeeDirectoryMembersProvider),
        draft: ref.watch(employeeDirectoryQualityFixDraftProvider),
        asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
      );
    });

/// Mutates the selected quality issue and its targeted remediation input.
class EmployeeDirectoryQualityFixDraftNotifier
    extends StateNotifier<EmployeeDirectoryQualityFixDraft> {
  EmployeeDirectoryQualityFixDraftNotifier()
    : super(const EmployeeDirectoryQualityFixDraft());

  void selectIssue(String issueKey) {
    state = EmployeeDirectoryQualityFixDraft(issueKey: issueKey);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPhone(String value) {
    state = state.copyWith(phone: value);
  }

  void setManager(String value) {
    state = state.copyWith(manager: value);
  }

  void setDepartment(String value) {
    state = state.copyWith(department: value);
  }

  void setLocation(String value) {
    state = state.copyWith(location: value);
  }

  void setJoiningDate(String value) {
    state = state.copyWith(joiningDate: value);
  }

  void setAuditNote(String value) {
    state = state.copyWith(auditNote: value);
  }

  void clear() {
    state = const EmployeeDirectoryQualityFixDraft();
  }
}
