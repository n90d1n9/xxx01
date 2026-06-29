import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_record_action_models.dart';
import 'employee_directory_provider.dart';

final employeeRecordActionDraftProvider = StateNotifierProvider.family<
  EmployeeRecordActionDraftNotifier,
  EmployeeRecordActionDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final members = ref.watch(employeeDirectoryMembersProvider);

  for (final member in members) {
    if (member.id == employeeId) {
      return EmployeeRecordActionDraftNotifier(
        EmployeeRecordActionDraft.fromMember(
          member: member,
          asOfDate: asOfDate,
        ),
      );
    }
  }

  return EmployeeRecordActionDraftNotifier(null);
});

class EmployeeRecordActionDraftNotifier
    extends StateNotifier<EmployeeRecordActionDraft?> {
  EmployeeRecordActionDraftNotifier(super.state);

  void setActionType(EmployeeRecordActionType value) {
    state = state?.copyWith(actionType: value);
  }

  void setTargetPosition(String value) {
    state = state?.copyWith(targetPosition: value);
  }

  void setTargetDepartment(String value) {
    state = state?.copyWith(targetDepartment: value);
  }

  void setTargetManager(String value) {
    state = state?.copyWith(targetManager: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state?.copyWith(effectiveDate: value);
  }

  void setReason(String value) {
    state = state?.copyWith(reason: value);
  }

  void clearEffectiveDate() {
    state = state?.copyWith(clearEffectiveDate: true);
  }

  void reset() {
    final draft = state;
    if (draft == null) return;
    state = EmployeeRecordActionDraft(
      employeeId: draft.employeeId,
      employeeName: draft.employeeName,
      actionType: EmployeeRecordActionType.promotion,
      currentPosition: draft.currentPosition,
      currentDepartment: draft.currentDepartment,
      currentManager: draft.currentManager,
      targetPosition: draft.currentPosition,
      targetDepartment: draft.currentDepartment,
      targetManager: draft.currentManager,
      effectiveDate: null,
      reason: '',
      asOfDate: draft.asOfDate,
    );
  }
}

final employeeRecordActionRequestsProvider = StateNotifierProvider<
  EmployeeRecordActionRequestsNotifier,
  List<EmployeeRecordActionRequest>
>((ref) => EmployeeRecordActionRequestsNotifier());

class EmployeeRecordActionRequestsNotifier
    extends StateNotifier<List<EmployeeRecordActionRequest>> {
  EmployeeRecordActionRequestsNotifier() : super(const []);

  EmployeeRecordActionRequest submitDraft(EmployeeRecordActionDraft draft) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final request = draft.toRequest(
      id: _nextRequestId(),
      createdAt: draft.asOfDate,
    );
    state = [request, ...state];
    return request;
  }

  void approve(String id) {
    state =
        state.map((request) {
          if (request.id != id || !request.canApprove) return request;
          return request.copyWith(status: EmployeeRecordActionStatus.approved);
        }).toList();
  }

  void markApplied(String id) {
    state =
        state.map((request) {
          if (request.id != id || !request.canApply) return request;
          return request.copyWith(status: EmployeeRecordActionStatus.applied);
        }).toList();
  }

  String _nextRequestId() {
    final sequence =
        state
            .map((request) => int.tryParse(request.id.replaceAll('ERA-', '')))
            .whereType<int>()
            .fold<int>(0, (max, value) => value > max ? value : max) +
        1;
    return 'ERA-${sequence.toString().padLeft(3, '0')}';
  }
}

final employeeRecordActionsForEmployeeProvider =
    Provider.family<List<EmployeeRecordActionRequest>, String>((
      ref,
      employeeId,
    ) {
      return ref
          .watch(employeeRecordActionRequestsProvider)
          .where((request) => request.employeeId == employeeId)
          .toList();
    });

final employeeRecordActionSummaryProvider =
    Provider.family<EmployeeRecordActionSummary, String>((ref, employeeId) {
      return EmployeeRecordActionSummary.fromRequests(
        ref.watch(employeeRecordActionsForEmployeeProvider(employeeId)),
      );
    });
