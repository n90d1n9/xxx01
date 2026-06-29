import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_bulk_profile_update_models.dart';

final employeeDirectoryBulkProfileUpdateDraftProvider = StateNotifierProvider<
  EmployeeDirectoryBulkProfileUpdateDraftNotifier,
  EmployeeDirectoryBulkProfileUpdateDraft
>((ref) => EmployeeDirectoryBulkProfileUpdateDraftNotifier());

class EmployeeDirectoryBulkProfileUpdateDraftNotifier
    extends StateNotifier<EmployeeDirectoryBulkProfileUpdateDraft> {
  EmployeeDirectoryBulkProfileUpdateDraftNotifier()
    : super(const EmployeeDirectoryBulkProfileUpdateDraft());

  void setManager(String value) {
    state = state.copyWith(
      manager: value,
      previewApproved: false,
      previewApprovalSignature: '',
    );
  }

  void setDepartment(String value) {
    state = state.copyWith(
      department: value,
      previewApproved: false,
      previewApprovalSignature: '',
    );
  }

  void setLocation(String value) {
    state = state.copyWith(
      location: value,
      previewApproved: false,
      previewApprovalSignature: '',
    );
  }

  void setAuditNote(String value) {
    state = state.copyWith(
      auditNote: value,
      previewApproved: false,
      previewApprovalSignature: '',
    );
  }

  void setPreviewApproved(bool value, {String approvalSignature = ''}) {
    state = state.copyWith(
      previewApproved: value,
      previewApprovalSignature: value ? approvalSignature : '',
    );
  }

  void clear() {
    state = const EmployeeDirectoryBulkProfileUpdateDraft();
  }
}
