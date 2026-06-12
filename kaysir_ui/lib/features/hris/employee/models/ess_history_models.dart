import 'pay_stub.dart';
import 'time_off_request.dart';

enum TimeOffHistoryFilter { all, approved, pending, rejected }

extension TimeOffHistoryFilterLabel on TimeOffHistoryFilter {
  String get label {
    switch (this) {
      case TimeOffHistoryFilter.all:
        return 'All';
      case TimeOffHistoryFilter.approved:
        return 'Approved';
      case TimeOffHistoryFilter.pending:
        return 'Pending';
      case TimeOffHistoryFilter.rejected:
        return 'Rejected';
    }
  }

  String? get status {
    switch (this) {
      case TimeOffHistoryFilter.all:
        return null;
      case TimeOffHistoryFilter.approved:
        return 'Approved';
      case TimeOffHistoryFilter.pending:
        return 'Pending';
      case TimeOffHistoryFilter.rejected:
        return 'Rejected';
    }
  }
}

class PayStubDeduction {
  final String label;
  final double amount;

  const PayStubDeduction({required this.label, required this.amount});
}

class PayStubBreakdown {
  final PayStub stub;
  final List<PayStubDeduction> deductions;

  const PayStubBreakdown({required this.stub, required this.deductions});

  factory PayStubBreakdown.fromStub(PayStub stub) {
    final totalDeductions = stub.totalDeductions;
    final fixedLines = [
      PayStubDeduction(label: 'Federal Tax', amount: totalDeductions * 0.42),
      PayStubDeduction(label: 'State Tax', amount: totalDeductions * 0.14),
      PayStubDeduction(
        label: 'Social Security',
        amount: totalDeductions * 0.17,
      ),
      PayStubDeduction(label: 'Medicare', amount: totalDeductions * 0.04),
      PayStubDeduction(
        label: 'Retirement Contribution',
        amount: totalDeductions * 0.14,
      ),
    ];
    final allocated = fixedLines.fold<double>(
      0,
      (total, line) => total + line.amount,
    );

    return PayStubBreakdown(
      stub: stub,
      deductions: [
        ...fixedLines,
        PayStubDeduction(
          label: 'Benefits & Adjustments',
          amount: totalDeductions - allocated,
        ),
      ],
    );
  }
}

class PayHistorySummary {
  final int stubCount;
  final double totalGrossPay;
  final double totalNetPay;
  final double totalDeductions;
  final double averageNetPay;
  final DateTime? latestPayDate;

  const PayHistorySummary({
    required this.stubCount,
    required this.totalGrossPay,
    required this.totalNetPay,
    required this.totalDeductions,
    required this.averageNetPay,
    required this.latestPayDate,
  });

  factory PayHistorySummary.fromStubs(List<PayStub> stubs) {
    final sortedStubs = [...stubs]
      ..sort((a, b) => b.payDate.compareTo(a.payDate));
    final totalGrossPay = stubs.fold<double>(
      0,
      (total, stub) => total + stub.grossAmount,
    );
    final totalNetPay = stubs.fold<double>(
      0,
      (total, stub) => total + stub.netAmount,
    );

    return PayHistorySummary(
      stubCount: stubs.length,
      totalGrossPay: totalGrossPay,
      totalNetPay: totalNetPay,
      totalDeductions: stubs.fold<double>(
        0,
        (total, stub) => total + stub.totalDeductions,
      ),
      averageNetPay: stubs.isEmpty ? 0 : totalNetPay / stubs.length,
      latestPayDate: sortedStubs.isEmpty ? null : sortedStubs.first.payDate,
    );
  }
}

class TimeOffHistorySummary {
  final int requestCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int totalRequestedDays;
  final int approvedDays;
  final DateTime? nextPendingDate;

  const TimeOffHistorySummary({
    required this.requestCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.totalRequestedDays,
    required this.approvedDays,
    required this.nextPendingDate,
  });

  factory TimeOffHistorySummary.fromRequests(List<TimeOffRequest> requests) {
    final pendingRequests = requests.where((request) => request.isPending);
    final sortedPending =
        pendingRequests.toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return TimeOffHistorySummary(
      requestCount: requests.length,
      pendingCount: requests.where((request) => request.isPending).length,
      approvedCount: requests.where((request) => request.isApproved).length,
      rejectedCount:
          requests.where((request) => request.status == 'Rejected').length,
      totalRequestedDays: requests.fold<int>(
        0,
        (total, request) => total + request.durationDays,
      ),
      approvedDays: requests
          .where((request) => request.isApproved)
          .fold<int>(0, (total, request) => total + request.durationDays),
      nextPendingDate:
          sortedPending.isEmpty ? null : sortedPending.first.startDate,
    );
  }
}
