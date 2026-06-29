import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/hr_action_seed_data.dart';
import '../models/hr_action_models.dart';
import 'people_ops_provider.dart';

final peopleOpsHrActionDraftProvider = StateNotifierProvider<
  PeopleOpsHrActionDraftNotifier,
  HrActionFormDraft
>((ref) {
  return PeopleOpsHrActionDraftNotifier(ref.watch(peopleOpsAsOfDateProvider));
});

class PeopleOpsHrActionDraftNotifier extends StateNotifier<HrActionFormDraft> {
  PeopleOpsHrActionDraftNotifier(DateTime asOfDate)
    : super(HrActionFormDraft.empty(asOfDate));

  void setEmployeeName(String value) {
    state = state.copyWith(employeeName: value);
  }

  void setDepartment(String value) {
    state = state.copyWith(department: value);
  }

  void setActionType(HrActionType value) {
    state = state.copyWith(actionType: value);
  }

  void setTargetRole(String value) {
    state = state.copyWith(targetRole: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state.copyWith(effectiveDate: value);
  }

  void setManagerName(String value) {
    state = state.copyWith(managerName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setReason(String value) {
    state = state.copyWith(reason: value);
  }

  void setPayrollReviewRequired(bool value) {
    state = state.copyWith(payrollReviewRequired: value);
  }

  void setPriority(HrActionPriority value) {
    state = state.copyWith(priority: value);
  }

  void clear() {
    state = HrActionFormDraft.empty(state.asOfDate);
  }
}

final peopleOpsHrActionRequestsProvider = StateNotifierProvider<
  PeopleOpsHrActionQueueNotifier,
  List<HrActionRequest>
>((ref) {
  final asOfDate = ref.watch(peopleOpsAsOfDateProvider);
  return PeopleOpsHrActionQueueNotifier(
    buildPeopleOpsHrActionRequests(asOfDate),
  );
});

class PeopleOpsHrActionQueueNotifier
    extends StateNotifier<List<HrActionRequest>> {
  PeopleOpsHrActionQueueNotifier(super.state);

  HrActionRequest submitDraft(HrActionFormDraft draft) {
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

  void advanceStatus(String id) {
    state =
        state.map((request) {
          if (request.id != id) return request;
          return request.copyWith(status: _nextStatus(request.status));
        }).toList();
  }

  void blockRequest(String id) {
    state =
        state.map((request) {
          if (request.id != id || request.status == HrActionStatus.approved) {
            return request;
          }
          return request.copyWith(status: HrActionStatus.blocked);
        }).toList();
  }

  String _nextRequestId() {
    final sequence =
        state
            .map((request) => int.tryParse(request.id.replaceAll('HR-', '')))
            .whereType<int>()
            .fold<int>(1000, (max, value) => value > max ? value : max) +
        1;
    return 'HR-$sequence';
  }
}

final filteredPeopleOpsHrActionRequestsProvider =
    Provider<List<HrActionRequest>>((ref) {
      final selectedDepartment = ref.watch(peopleOpsDepartmentProvider);
      final riskOnly = ref.watch(peopleOpsRiskOnlyProvider);

      return ref.watch(peopleOpsHrActionRequestsProvider).where((request) {
        final departmentMatches =
            selectedDepartment == peopleOpsAllDepartments ||
            request.department == selectedDepartment;
        final riskMatches = !riskOnly || request.needsAttention;
        return departmentMatches && riskMatches;
      }).toList();
    });

final peopleOpsHrActionQueueSummaryProvider = Provider<HrActionQueueSummary>((
  ref,
) {
  return HrActionQueueSummary.fromRequests(
    requests: ref.watch(filteredPeopleOpsHrActionRequestsProvider),
    asOfDate: ref.watch(peopleOpsAsOfDateProvider),
  );
});

HrActionStatus _nextStatus(HrActionStatus status) {
  return switch (status) {
    HrActionStatus.submitted => HrActionStatus.inReview,
    HrActionStatus.inReview => HrActionStatus.approved,
    HrActionStatus.blocked => HrActionStatus.inReview,
    HrActionStatus.approved => HrActionStatus.approved,
  };
}
