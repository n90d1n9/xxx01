import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import '../states/talent_provider.dart';
import 'incoming_talent_operating_inbox_tile.dart';

/// Cross-HRIS operating inbox for time-sensitive talent work.
class IncomingTalentOperatingInboxPanel extends ConsumerWidget {
  const IncomingTalentOperatingInboxPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(incomingTalentOperatingInboxItemsProvider);
    final summary = ref.watch(incomingTalentOperatingInboxSummaryProvider);
    final asOfDate = ref.watch(talentAsOfDateProvider);

    return HrisSectionPanel(
      icon: Icons.inbox_outlined,
      title: 'Talent operating inbox',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent operating inbox items',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Items', value: '${summary.totalCount}'),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('No active talent operating work needs attention.'),
          )
        else
          for (final item in items.take(5))
            IncomingTalentOperatingInboxTile(item: item, asOfDate: asOfDate),
      ],
    );
  }
}

@Preview(name: 'Talent operating inbox panel')
Widget incomingTalentOperatingInboxPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingInboxItemsProvider.overrideWithValue([
        _previewCriticalItem,
        _previewWatchItem,
      ]),
      incomingTalentOperatingInboxSummaryProvider.overrideWithValue(
        IncomingTalentOperatingInboxSummary.fromItems(
          items: [_previewCriticalItem, _previewWatchItem],
          asOfDate: DateTime(2026, 6, 11),
        ),
      ),
      talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 11)),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingInboxPanel(),
        ),
      ),
    ),
  );
}

final _previewCriticalItem = IncomingTalentOperatingInboxItem(
  id: 'risk-follow-up:preview',
  source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
  priority: IncomingTalentOperatingInboxPriority.critical,
  title: 'Create risk council follow-up',
  subjectName: 'Alya Maheswari',
  department: 'People Operations',
  ownerName: 'People Operations Talent Partner',
  statusLabel: 'Escalated',
  nextAction:
      'Create the owner follow-up and capture council commitment evidence.',
  dueDate: DateTime(2026, 6, 10),
);

final _previewWatchItem = IncomingTalentOperatingInboxItem(
  id: 'training-session:preview',
  source: IncomingTalentOperatingInboxSource.trainingSession,
  priority: IncomingTalentOperatingInboxPriority.watch,
  title: 'Engineering growth accelerator',
  subjectName: 'Leadership',
  department: 'Engineering',
  ownerName: 'Rani Prasetya',
  statusLabel: 'Scheduled',
  nextAction: 'Confirm manager evidence checkpoint after session.',
  dueDate: DateTime(2026, 6, 14),
);
