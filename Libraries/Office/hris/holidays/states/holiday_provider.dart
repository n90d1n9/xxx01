import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/holiday_seed_data.dart';
import '../models/holiday_audit_models.dart';
import '../models/holiday_communication_models.dart';
import '../models/holiday_coverage_models.dart';
import '../models/holiday_filter_models.dart';
import '../models/holiday_models.dart';
import '../models/holiday_policy_models.dart';
import '../models/holiday_publish_models.dart';
import '../models/holiday_release_approval_models.dart';
import '../models/holiday_release_package_models.dart';
import '../models/holiday_timeline_models.dart';
import '../models/holiday_workforce_impact_models.dart';
import 'holiday_audit_notifier.dart';
import 'holiday_release_approval_notifier.dart';

final holidayAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final holidayAuditTimestampProvider = Provider<DateTime>((ref) {
  return ref.watch(holidayAsOfDateProvider);
});

final holidayAuditLogProvider =
    StateNotifierProvider<HolidayAuditLogNotifier, List<HolidayAuditEntry>>((
      ref,
    ) {
      return HolidayAuditLogNotifier(
        timestampReader: () => ref.read(holidayAuditTimestampProvider),
      );
    });

final holidayAuditSummaryProvider = Provider<HolidayAuditSummary>((ref) {
  return HolidayAuditSummary.fromEntries(
    entries: ref.watch(holidayAuditLogProvider),
  );
});

final holidayRecordsProvider =
    StateNotifierProvider<HolidayCalendarNotifier, List<HolidayRecord>>((ref) {
      return HolidayCalendarNotifier(
        initialRecords: buildInitialHolidayRecords(
          ref.watch(holidayAsOfDateProvider),
        ),
        auditLog: ref.read(holidayAuditLogProvider.notifier),
      );
    });

class HolidayCalendarNotifier extends StateNotifier<List<HolidayRecord>> {
  final HolidayAuditLogNotifier auditLog;

  HolidayCalendarNotifier({
    required List<HolidayRecord> initialRecords,
    required this.auditLog,
  }) : super(_sortRecords(initialRecords));

  void addHoliday(HolidayRecord holiday) {
    state = _sortRecords([...state, holiday]);
    auditLog.recordCreated(holiday);
  }

  void updateHoliday(HolidayRecord holiday) {
    final previous = _findRecord(holiday.id);
    if (previous == null || previous == holiday) return;

    state = _sortRecords([
      for (final item in state)
        if (item.id == holiday.id) holiday else item,
    ]);
    auditLog.recordUpdated(previous: previous, current: holiday);
  }

  void deleteHoliday(String id) {
    final previous = _findRecord(id);
    if (previous == null) return;

    state = state.where((item) => item.id != id).toList();
    auditLog.recordDeleted(previous);
  }

  HolidayRecord? _findRecord(String id) {
    for (final item in state) {
      if (item.id == id) return item;
    }

    return null;
  }
}

final selectedHolidayTypeProvider = StateProvider<HolidayType?>((ref) => null);
final selectedHolidayQuickViewProvider =
    StateProvider<HolidayCalendarQuickView>(
      (ref) => HolidayCalendarQuickView.all,
    );
final holidaySearchQueryProvider = StateProvider<String>((ref) => '');

final filteredHolidayRecordsProvider = Provider<List<HolidayRecord>>((ref) {
  final selectedType = ref.watch(selectedHolidayTypeProvider);
  final selectedQuickView = ref.watch(selectedHolidayQuickViewProvider);
  final searchQuery = ref.watch(holidaySearchQueryProvider).trim();
  final asOfDate = ref.watch(holidayAsOfDateProvider);
  final policyIssueHolidayIds = ref.watch(holidayPolicyIssueHolidayIdsProvider);
  final holidays = ref.watch(holidayRecordsProvider);

  var filtered =
      holidays.where((item) {
        if (selectedType != null && item.type != selectedType) return false;
        if (!_matchesQuickView(
          item,
          selectedQuickView,
          asOfDate,
          policyIssueHolidayIds,
        )) {
          return false;
        }
        if (searchQuery.isNotEmpty && !_matchesSearch(item, searchQuery)) {
          return false;
        }

        return true;
      }).toList();

  return filtered;
});

final holidaySummaryProvider = Provider<HolidaySummary>((ref) {
  return HolidaySummary.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
  );
});

final holidayRiskSummaryProvider = Provider<HolidayRiskSummary>((ref) {
  return HolidayRiskSummary.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
  );
});

final holidayCoveragePlanProvider = Provider<HolidayCoveragePlan>((ref) {
  return HolidayCoveragePlan.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
  );
});

final holidayPolicyReviewProvider = Provider<HolidayPolicyReview>((ref) {
  return HolidayPolicyReview.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
  );
});

final holidayPolicyIssueHolidayIdsProvider = Provider<Set<String>>((ref) {
  return {
    for (final issue in ref.watch(holidayPolicyReviewProvider).issues)
      for (final holiday in issue.affectedHolidays) holiday.id,
  };
});

final holidayCalendarViewCountsProvider = Provider<HolidayCalendarViewCounts>((
  ref,
) {
  return HolidayCalendarViewCounts.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
    policyIssueHolidayIds: ref.watch(holidayPolicyIssueHolidayIdsProvider),
  );
});

final holidayCommunicationPlanProvider = Provider<HolidayCommunicationPlan>((
  ref,
) {
  return HolidayCommunicationPlan.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
    policyIssueHolidayIds: ref.watch(holidayPolicyIssueHolidayIdsProvider),
  );
});

final holidayPublishReadinessProvider = Provider<HolidayPublishReadiness>((
  ref,
) {
  return HolidayPublishReadiness.fromSignals(
    summary: ref.watch(holidaySummaryProvider),
    risks: ref.watch(holidayRiskSummaryProvider),
    coveragePlan: ref.watch(holidayCoveragePlanProvider),
    policyReview: ref.watch(holidayPolicyReviewProvider),
    communicationPlan: ref.watch(holidayCommunicationPlanProvider),
  );
});

final holidayReleaseApprovalDecisionsProvider =
    StateNotifierProvider<HolidayReleaseApprovalDecisionNotifier, Set<String>>((
      ref,
    ) {
      return HolidayReleaseApprovalDecisionNotifier();
    });

final holidayReleaseApprovalPlanProvider = Provider<HolidayReleaseApprovalPlan>(
  (ref) {
    return HolidayReleaseApprovalPlan.fromReadiness(
      readiness: ref.watch(holidayPublishReadinessProvider),
      approvedStepIds: ref.watch(holidayReleaseApprovalDecisionsProvider),
    );
  },
);

final holidayReleasePackageProvider = Provider<HolidayReleasePackage>((ref) {
  return HolidayReleasePackage.fromSignals(
    summary: ref.watch(holidaySummaryProvider),
    readiness: ref.watch(holidayPublishReadinessProvider),
    approvalPlan: ref.watch(holidayReleaseApprovalPlanProvider),
    coveragePlan: ref.watch(holidayCoveragePlanProvider),
    policyReview: ref.watch(holidayPolicyReviewProvider),
    communicationPlan: ref.watch(holidayCommunicationPlanProvider),
    auditSummary: ref.watch(holidayAuditSummaryProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
  );
});

final holidayTimelineProvider = Provider<HolidayTimeline>((ref) {
  return HolidayTimeline.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
  );
});

final holidayWorkforceImpactProvider = Provider<HolidayWorkforceImpact>((ref) {
  return HolidayWorkforceImpact.fromHolidays(
    holidays: ref.watch(holidayRecordsProvider),
    asOfDate: ref.watch(holidayAsOfDateProvider),
  );
});

List<HolidayRecord> _sortRecords(Iterable<HolidayRecord> records) {
  final sorted = records.toList();
  sorted.sort((a, b) {
    final compared = a.effectiveDate.compareTo(b.effectiveDate);
    if (compared != 0) return compared;

    return a.name.compareTo(b.name);
  });
  return sorted;
}

bool _matchesQuickView(
  HolidayRecord holiday,
  HolidayCalendarQuickView view,
  DateTime asOfDate,
  Set<String> policyIssueHolidayIds,
) {
  return switch (view) {
    HolidayCalendarQuickView.all => true,
    HolidayCalendarQuickView.upcoming => holiday.isUpcomingWithin(asOfDate, 60),
    HolidayCalendarQuickView.coverage => holiday.requiresCoveragePlan,
    HolidayCalendarQuickView.policyIssues => policyIssueHolidayIds.contains(
      holiday.id,
    ),
    HolidayCalendarQuickView.unpaidCustom =>
      holiday.type == HolidayType.custom && !holiday.isPaid,
  };
}

bool _matchesSearch(HolidayRecord holiday, String searchQuery) {
  final query = searchQuery.toLowerCase();
  final searchable =
      [
        holiday.name,
        holiday.type.label,
        holiday.scope,
        holiday.description,
        _isoDate(holiday.date),
        if (holiday.observedDate != null) _isoDate(holiday.observedDate!),
      ].join(' ').toLowerCase();

  return searchable.contains(query);
}

String _isoDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
