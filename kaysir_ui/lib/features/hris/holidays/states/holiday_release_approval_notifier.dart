import 'package:flutter_riverpod/legacy.dart';

class HolidayReleaseApprovalDecisionNotifier
    extends StateNotifier<Set<String>> {
  HolidayReleaseApprovalDecisionNotifier() : super(const {});

  void approveStep(String stepId) {
    state = {...state, stepId};
  }

  void revokeStep(String stepId) {
    state = {...state}..remove(stepId);
  }

  void clear() {
    state = const {};
  }
}
