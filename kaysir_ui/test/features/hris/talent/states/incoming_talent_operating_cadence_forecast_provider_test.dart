import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent cadence forecast groups inbox items by due window', () {
    final asOfDate = DateTime(2026, 6, 11);
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(asOfDate),
        incomingTalentOperatingInboxItemsProvider.overrideWithValue([
          _item(
            id: 'overdue-critical',
            source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
            priority: IncomingTalentOperatingInboxPriority.critical,
            ownerName: 'Ari Talent Partner',
            dueDate: asOfDate.subtract(const Duration(days: 1)),
          ),
          _item(
            id: 'today-watch',
            source: IncomingTalentOperatingInboxSource.trainingSession,
            priority: IncomingTalentOperatingInboxPriority.watch,
            ownerName: 'Bima HRBP',
            dueDate: asOfDate,
          ),
          _item(
            id: 'week-routine',
            source:
                IncomingTalentOperatingInboxSource.successionCoverageFollowUp,
            priority: IncomingTalentOperatingInboxPriority.routine,
            ownerName: 'Citra HRBP',
            dueDate: asOfDate.add(const Duration(days: 3)),
          ),
          _item(
            id: 'two-week-critical',
            source: IncomingTalentOperatingInboxSource.promotionStabilization,
            priority: IncomingTalentOperatingInboxPriority.critical,
            ownerName: 'Dewi HRBP',
            dueDate: asOfDate.add(const Duration(days: 10)),
          ),
          _item(
            id: 'later-routine',
            source: IncomingTalentOperatingInboxSource.careerPathReview,
            priority: IncomingTalentOperatingInboxPriority.routine,
            ownerName: 'Eka HRBP',
            dueDate: asOfDate.add(const Duration(days: 20)),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final buckets = container.read(
      incomingTalentOperatingCadenceBucketsProvider,
    );
    final summary = container.read(
      incomingTalentOperatingCadenceForecastSummaryProvider,
    );

    expect(buckets, hasLength(5));
    expect(buckets.first.window, IncomingTalentOperatingCadenceWindow.overdue);
    expect(buckets.first.risk, IncomingTalentOperatingCadenceRisk.critical);
    expect(buckets.first.totalCount, 1);
    expect(buckets.first.criticalCount, 1);
    expect(buckets.first.overdueCount, 1);
    expect(buckets.first.workstreamCount, 1);
    expect(buckets.first.nextAction, 'Recover 1 overdue talent cadence item.');
    expect(buckets[1].window, IncomingTalentOperatingCadenceWindow.dueToday);
    expect(buckets[1].risk, IncomingTalentOperatingCadenceRisk.watch);
    expect(buckets[1].dueTodayCount, 1);
    expect(buckets[2].window, IncomingTalentOperatingCadenceWindow.next7Days);
    expect(buckets[3].window, IncomingTalentOperatingCadenceWindow.next14Days);
    expect(buckets[3].risk, IncomingTalentOperatingCadenceRisk.critical);
    expect(buckets[4].window, IncomingTalentOperatingCadenceWindow.later);
    expect(summary.windowCount, 5);
    expect(summary.activeWindowCount, 5);
    expect(summary.criticalWindowCount, 2);
    expect(summary.watchWindowCount, 2);
    expect(summary.totalItemCount, 5);
    expect(summary.criticalItemCount, 2);
    expect(summary.overdueItemCount, 1);
    expect(summary.dueTodayItemCount, 1);
    expect(summary.nextAction, 'Recover 1 overdue talent cadence item.');
  });
}

IncomingTalentOperatingInboxItem _item({
  required String id,
  required IncomingTalentOperatingInboxSource source,
  required IncomingTalentOperatingInboxPriority priority,
  required String ownerName,
  required DateTime dueDate,
}) {
  return IncomingTalentOperatingInboxItem(
    id: id,
    source: source,
    priority: priority,
    title: 'Talent cadence item',
    subjectName: 'Talent profile',
    department: 'People Operations',
    ownerName: ownerName,
    statusLabel: 'Open',
    nextAction: 'Complete the cadence item.',
    dueDate: dueDate,
  );
}
