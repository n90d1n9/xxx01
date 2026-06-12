import '../models/leave_request.dart';

List<LeaveRequest> buildInitialLeaveRequests(DateTime asOfDate) {
  return [
    LeaveRequest(
      id: '1',
      startDate: asOfDate.add(const Duration(days: 5)),
      endDate: asOfDate.add(const Duration(days: 7)),
      reason: 'Family vacation',
      status: LeaveStatus.pending,
      leaveType: 'Vacation',
    ),
    LeaveRequest(
      id: '2',
      startDate: asOfDate.add(const Duration(days: 15)),
      endDate: asOfDate.add(const Duration(days: 16)),
      reason: 'Medical appointment',
      status: LeaveStatus.approved,
      leaveType: 'Sick Leave',
    ),
  ];
}
