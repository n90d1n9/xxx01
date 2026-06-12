import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/leave_seed_data.dart';
import '../models/leave_request.dart';

final leaveRequestsProvider =
    StateNotifierProvider<LeaveRequestNotifier, List<LeaveRequest>>((ref) {
      return LeaveRequestNotifier(
        initialRequests: buildInitialLeaveRequests(
          ref.watch(leaveAsOfDateProvider),
        ),
      );
    });

class LeaveRequestNotifier extends StateNotifier<List<LeaveRequest>> {
  LeaveRequestNotifier({required List<LeaveRequest> initialRequests})
    : super(initialRequests);

  void addLeaveRequest(LeaveRequest request) {
    state = [...state, request];
  }

  void updateLeaveRequest(LeaveRequest request) {
    state = [
      for (final item in state)
        if (item.id == request.id) request else item,
    ];
  }

  void deleteLeaveRequest(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final selectedLeaveTypeProvider = StateProvider<String>((ref) => 'Vacation');

final leaveBalanceDaysProvider = Provider<int>((ref) => 15);

final leaveAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final leaveSummaryProvider = Provider<LeaveSummary>((ref) {
  return LeaveSummary.fromRequests(
    requests: ref.watch(leaveRequestsProvider),
    balanceDays: ref.watch(leaveBalanceDaysProvider),
  );
});

final leaveRiskSummaryProvider = Provider<LeaveRiskSummary>((ref) {
  return LeaveRiskSummary.fromRequests(
    requests: ref.watch(leaveRequestsProvider),
    balanceDays: ref.watch(leaveBalanceDaysProvider),
    asOfDate: ref.watch(leaveAsOfDateProvider),
  );
});
