import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_workstream_pressure_tile.dart';

/// Cross-workstream pressure radar for talent operating work.
class IncomingTalentOperatingWorkstreamPressurePanel extends ConsumerWidget {
  const IncomingTalentOperatingWorkstreamPressurePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pressures = ref.watch(
      incomingTalentOperatingWorkstreamPressuresProvider,
    );
    final summary = ref.watch(
      incomingTalentOperatingWorkstreamPressureSummaryProvider,
    );
    final activePressures =
        pressures.where((pressure) => pressure.totalCount > 0).toList();

    return HrisSectionPanel(
      icon: Icons.radar_outlined,
      title: 'Talent workstream pressure',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent workstream pressure',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.activeWorkstreamCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalWorkstreamCount}',
            ),
            HrisMetricStripItem(
              label: 'Elevated',
              value: '${summary.elevatedWorkstreamCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueItemCount}',
            ),
          ],
        ),
        if (activePressures.isEmpty)
          const HrisListSurface(
            child: Text('No active talent workstream pressure to review.'),
          )
        else
          for (final pressure in activePressures.take(4))
            IncomingTalentOperatingWorkstreamPressureTile(pressure: pressure),
      ],
    );
  }
}

@Preview(name: 'Talent workstream pressure panel')
Widget incomingTalentOperatingWorkstreamPressurePanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingWorkstreamPressuresProvider.overrideWithValue([
        _previewCriticalPressure,
        _previewElevatedPressure,
      ]),
      incomingTalentOperatingWorkstreamPressureSummaryProvider
          .overrideWithValue(
            IncomingTalentOperatingWorkstreamPressureSummary.fromItems([
              _previewCriticalPressure,
              _previewElevatedPressure,
            ]),
          ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingWorkstreamPressurePanel(),
        ),
      ),
    ),
  );
}

final _previewCriticalPressure = IncomingTalentOperatingWorkstreamPressure(
  workstream: IncomingTalentOperatingWorkstream.riskCouncil,
  level: IncomingTalentOperatingWorkstreamPressureLevel.critical,
  totalCount: 4,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 1,
  overdueCount: 1,
  dueSoonCount: 1,
  ownerCount: 2,
  overloadedOwnerCount: 1,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 1 overdue risk council item.',
  itemIds: const ['risk-overdue', 'risk-follow-up'],
);

final _previewElevatedPressure = IncomingTalentOperatingWorkstreamPressure(
  workstream: IncomingTalentOperatingWorkstream.development,
  level: IncomingTalentOperatingWorkstreamPressureLevel.elevated,
  totalCount: 2,
  criticalCount: 0,
  watchCount: 2,
  routineCount: 0,
  overdueCount: 0,
  dueSoonCount: 2,
  ownerCount: 1,
  overloadedOwnerCount: 1,
  earliestDueDate: DateTime(2026, 6, 13),
  nextAction: 'Rebalance 1 overloaded development owner.',
  itemIds: const ['training-watch', 'career-watch'],
);
