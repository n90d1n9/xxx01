import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_cadence_forecast_tile.dart';

/// Due-date cadence forecast for active talent operating work.
class IncomingTalentOperatingCadenceForecastPanel extends ConsumerWidget {
  const IncomingTalentOperatingCadenceForecastPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buckets = ref.watch(incomingTalentOperatingCadenceBucketsProvider);
    final summary = ref.watch(
      incomingTalentOperatingCadenceForecastSummaryProvider,
    );
    final activeBuckets =
        buckets.where((bucket) => bucket.totalCount > 0).toList();

    return HrisSectionPanel(
      icon: Icons.calendar_month_outlined,
      title: 'Talent cadence forecast',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent cadence forecast',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Windows',
              value: '${summary.activeWindowCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalWindowCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueItemCount}',
            ),
            HrisMetricStripItem(
              label: 'Today',
              value: '${summary.dueTodayItemCount}',
            ),
          ],
        ),
        if (activeBuckets.isEmpty)
          const HrisListSurface(
            child: Text('No active cadence windows need review.'),
          )
        else
          for (final bucket in activeBuckets.take(5))
            IncomingTalentOperatingCadenceForecastTile(bucket: bucket),
      ],
    );
  }
}

@Preview(name: 'Talent cadence forecast panel')
Widget incomingTalentOperatingCadenceForecastPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingCadenceBucketsProvider.overrideWithValue([
        _previewOverdueBucket,
        _previewTodayBucket,
      ]),
      incomingTalentOperatingCadenceForecastSummaryProvider.overrideWithValue(
        IncomingTalentOperatingCadenceForecastSummary.fromBuckets([
          _previewOverdueBucket,
          _previewTodayBucket,
        ]),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingCadenceForecastPanel(),
        ),
      ),
    ),
  );
}

final _previewOverdueBucket = IncomingTalentOperatingCadenceBucket(
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

final _previewTodayBucket = IncomingTalentOperatingCadenceBucket(
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
