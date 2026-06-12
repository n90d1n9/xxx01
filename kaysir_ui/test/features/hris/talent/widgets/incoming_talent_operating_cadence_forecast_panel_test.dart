import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_cadence_forecast_panel.dart';

void main() {
  testWidgets('talent cadence forecast panel exposes due windows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingCadenceBucketsProvider.overrideWithValue([
            _overdueBucket,
            _todayBucket,
          ]),
          incomingTalentOperatingCadenceForecastSummaryProvider
              .overrideWithValue(
                IncomingTalentOperatingCadenceForecastSummary.fromBuckets([
                  _overdueBucket,
                  _todayBucket,
                ]),
              ),
        ],
        child: _shell(const IncomingTalentOperatingCadenceForecastPanel()),
      ),
    );

    expect(find.text('Talent cadence forecast'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('2 workstreams'), findsOneWidget);
    expect(find.text('Recover 2 overdue talent cadence items.'), findsWidgets);
  });
}

Widget _shell(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

final _overdueBucket = IncomingTalentOperatingCadenceBucket(
  window: IncomingTalentOperatingCadenceWindow.overdue,
  risk: IncomingTalentOperatingCadenceRisk.critical,
  totalCount: 2,
  criticalCount: 1,
  watchCount: 1,
  routineCount: 0,
  overdueCount: 2,
  dueTodayCount: 0,
  ownerCount: 2,
  workstreamCount: 2,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 2 overdue talent cadence items.',
  itemIds: const ['risk-overdue', 'career-overdue'],
);

final _todayBucket = IncomingTalentOperatingCadenceBucket(
  window: IncomingTalentOperatingCadenceWindow.dueToday,
  risk: IncomingTalentOperatingCadenceRisk.watch,
  totalCount: 1,
  criticalCount: 0,
  watchCount: 1,
  routineCount: 0,
  overdueCount: 0,
  dueTodayCount: 1,
  ownerCount: 1,
  workstreamCount: 1,
  earliestDueDate: DateTime(2026, 6, 11),
  nextAction: 'Close 1 talent cadence item due today.',
  itemIds: const ['training-today'],
);
