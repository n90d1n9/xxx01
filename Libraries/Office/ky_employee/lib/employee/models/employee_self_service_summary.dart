import 'pay_stub.dart';
import 'request_time_off_draft.dart';
import 'time_off_request.dart';

class EmployeeSelfServiceSummary {
  final int payStubCount;
  final double totalGrossPay;
  final double totalNetPay;
  final double latestNetPay;
  final int timeOffRequestCount;
  final int pendingTimeOffCount;
  final int approvedTimeOffDays;

  const EmployeeSelfServiceSummary({
    required this.payStubCount,
    required this.totalGrossPay,
    required this.totalNetPay,
    required this.latestNetPay,
    required this.timeOffRequestCount,
    required this.pendingTimeOffCount,
    required this.approvedTimeOffDays,
  });

  factory EmployeeSelfServiceSummary.fromData({
    required List<PayStub> payStubs,
    required List<TimeOffRequest> timeOffRequests,
  }) {
    final totalGrossPay = payStubs.fold<double>(
      0,
      (total, stub) => total + stub.grossAmount,
    );
    final totalNetPay = payStubs.fold<double>(
      0,
      (total, stub) => total + stub.netAmount,
    );
    final sortedPayStubs = [...payStubs]
      ..sort((a, b) => b.payDate.compareTo(a.payDate));

    return EmployeeSelfServiceSummary(
      payStubCount: payStubs.length,
      totalGrossPay: totalGrossPay,
      totalNetPay: totalNetPay,
      latestNetPay: sortedPayStubs.isEmpty ? 0 : sortedPayStubs.first.netAmount,
      timeOffRequestCount: timeOffRequests.length,
      pendingTimeOffCount:
          timeOffRequests.where((request) => request.isPending).length,
      approvedTimeOffDays: timeOffRequests
          .where((request) => request.isApproved)
          .fold<int>(0, (total, request) => total + request.durationDays),
    );
  }
}

class EmployeeSelfServiceRiskSummary {
  final int pendingTimeOffRequests;
  final int pendingTimeOffDays;
  final int lowBalanceTypes;
  final int highDeductionPayStubs;
  final int totalAvailableTimeOffDays;

  const EmployeeSelfServiceRiskSummary({
    required this.pendingTimeOffRequests,
    required this.pendingTimeOffDays,
    required this.lowBalanceTypes,
    required this.highDeductionPayStubs,
    required this.totalAvailableTimeOffDays,
  });

  int get totalAlerts =>
      pendingTimeOffRequests + lowBalanceTypes + highDeductionPayStubs;

  factory EmployeeSelfServiceRiskSummary.fromData({
    required List<PayStub> payStubs,
    required List<TimeOffRequest> timeOffRequests,
    required List<TimeOffBalance> balances,
  }) {
    final pendingRequests = timeOffRequests.where(
      (request) => request.isPending,
    );

    return EmployeeSelfServiceRiskSummary(
      pendingTimeOffRequests: pendingRequests.length,
      pendingTimeOffDays: pendingRequests.fold<int>(
        0,
        (total, request) => total + request.durationDays,
      ),
      lowBalanceTypes:
          balances.where((balance) => balance.remainingDays <= 3).length,
      highDeductionPayStubs:
          payStubs.where((stub) => stub.netRate <= 0.8).length,
      totalAvailableTimeOffDays: balances.fold<int>(
        0,
        (total, balance) => total + balance.remainingDays,
      ),
    );
  }
}
