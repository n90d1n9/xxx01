// Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/ess_seed_data.dart';
import '../models/employee.dart';
import '../models/employee_self_service_summary.dart';
import '../models/ess_history_models.dart';
import '../models/pay_stub.dart';
import '../models/request_time_off_draft.dart';
import '../models/time_off_request.dart';

final employeeProvider = StateProvider<Employee>(
  (ref) => buildDefaultEmployee(),
);

final payStubsProvider = StateProvider<List<PayStub>>(
  (ref) => buildInitialPayStubs(),
);

final timeOffRequestsProvider = StateProvider<List<TimeOffRequest>>(
  (ref) => buildInitialTimeOffRequests(),
);

final payStubBreakdownsProvider = Provider<List<PayStubBreakdown>>((ref) {
  final stubs = [...ref.watch(payStubsProvider)]
    ..sort((a, b) => b.payDate.compareTo(a.payDate));
  return stubs.map(PayStubBreakdown.fromStub).toList();
});

final payHistorySummaryProvider = Provider<PayHistorySummary>((ref) {
  return PayHistorySummary.fromStubs(ref.watch(payStubsProvider));
});

final selectedTimeOffHistoryFilterProvider =
    StateProvider<TimeOffHistoryFilter>((ref) => TimeOffHistoryFilter.all);

final filteredTimeOffRequestsProvider = Provider<List<TimeOffRequest>>((ref) {
  final filter = ref.watch(selectedTimeOffHistoryFilterProvider);
  final requests = [...ref.watch(timeOffRequestsProvider)]
    ..sort((a, b) => b.startDate.compareTo(a.startDate));
  final status = filter.status;

  if (status == null) return requests;
  return requests.where((request) => request.status == status).toList();
});

final timeOffHistorySummaryProvider = Provider<TimeOffHistorySummary>((ref) {
  return TimeOffHistorySummary.fromRequests(ref.watch(timeOffRequestsProvider));
});

final requestTimeOffTodayProvider = Provider<DateTime>(
  (ref) => DateTime(2026, 5, 30),
);

final timeOffBalancesProvider = Provider<List<TimeOffBalance>>(
  (ref) => buildInitialTimeOffBalances(),
);

final requestTimeOffDraftProvider =
    StateNotifierProvider<RequestTimeOffDraftNotifier, RequestTimeOffDraft>((
      ref,
    ) {
      final today = ref.watch(requestTimeOffTodayProvider);
      final type = ref.watch(timeOffBalancesProvider).first.type;
      return RequestTimeOffDraftNotifier(today: today, initialType: type);
    });

final requestTimeOffReviewProvider = Provider<RequestTimeOffReview>((ref) {
  final draft = ref.watch(requestTimeOffDraftProvider);
  final balances = ref.watch(timeOffBalancesProvider);
  final balance = balances.firstWhere(
    (item) => item.type == draft.type,
    orElse: () => balances.first,
  );

  return RequestTimeOffReview(draft: draft, balance: balance);
});

class RequestTimeOffDraftNotifier extends StateNotifier<RequestTimeOffDraft> {
  RequestTimeOffDraftNotifier({
    required DateTime today,
    required String initialType,
  }) : _today = today,
       _initialType = initialType,
       super(
         RequestTimeOffDraft(
           type: initialType,
           startDate: today.add(const Duration(days: 7)),
           endDate: today.add(const Duration(days: 9)),
         ),
       );

  final DateTime _today;
  final String _initialType;

  void setType(String type) {
    state = state.copyWith(type: type);
  }

  void setStartDate(DateTime date) {
    final endDate = state.endDate.isBefore(date) ? date : state.endDate;
    state = state.copyWith(startDate: date, endDate: endDate);
  }

  void setEndDate(DateTime date) {
    final startDate = date.isBefore(state.startDate) ? date : state.startDate;
    state = state.copyWith(startDate: startDate, endDate: date);
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void reset() {
    state = RequestTimeOffDraft(
      type: _initialType,
      startDate: _today.add(const Duration(days: 7)),
      endDate: _today.add(const Duration(days: 9)),
    );
  }
}

final employeeSelfServiceSummaryProvider = Provider<EmployeeSelfServiceSummary>(
  (ref) {
    return EmployeeSelfServiceSummary.fromData(
      payStubs: ref.watch(payStubsProvider),
      timeOffRequests: ref.watch(timeOffRequestsProvider),
    );
  },
);

final employeeSelfServiceRiskSummaryProvider =
    Provider<EmployeeSelfServiceRiskSummary>((ref) {
      return EmployeeSelfServiceRiskSummary.fromData(
        payStubs: ref.watch(payStubsProvider),
        timeOffRequests: ref.watch(timeOffRequestsProvider),
        balances: ref.watch(timeOffBalancesProvider),
      );
    });
