import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile for one due-date window in the talent operating cadence forecast.
class IncomingTalentOperatingCadenceForecastTile extends StatelessWidget {
  final IncomingTalentOperatingCadenceBucket bucket;

  const IncomingTalentOperatingCadenceForecastTile({
    super.key,
    required this.bucket,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingCadenceRiskColor(bucket.risk);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_windowIcon(bucket.window), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bucket.window.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${bucket.totalCount} cadence ${_plural(bucket.totalCount, 'item')} across ${bucket.ownerCount} ${_plural(bucket.ownerCount, 'owner')}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: bucket.risk.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: bucket.pressureRatio,
            color: color,
            label: '${(bucket.pressureRatio * 100).round()}% cadence pressure',
          ),
          const SizedBox(height: 10),
          Text(
            bucket.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(bucket.earliestDueDate),
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${bucket.criticalCount} critical',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${bucket.overdueCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.today_outlined,
                label: '${bucket.dueTodayCount} today',
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label:
                    '${bucket.workstreamCount} ${_plural(bucket.workstreamCount, 'workstream')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingCadenceRiskColor(
  IncomingTalentOperatingCadenceRisk risk,
) {
  return switch (risk) {
    IncomingTalentOperatingCadenceRisk.critical => const Color(0xFFDC2626),
    IncomingTalentOperatingCadenceRisk.watch => const Color(0xFFD97706),
    IncomingTalentOperatingCadenceRisk.steady => const Color(0xFF15803D),
  };
}

IconData _windowIcon(IncomingTalentOperatingCadenceWindow window) {
  return switch (window) {
    IncomingTalentOperatingCadenceWindow.overdue =>
      Icons.report_problem_outlined,
    IncomingTalentOperatingCadenceWindow.dueToday => Icons.today_outlined,
    IncomingTalentOperatingCadenceWindow.next7Days =>
      Icons.calendar_view_week_outlined,
    IncomingTalentOperatingCadenceWindow.next14Days =>
      Icons.date_range_outlined,
    IncomingTalentOperatingCadenceWindow.later => Icons.event_note_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent cadence forecast tile')
Widget incomingTalentOperatingCadenceForecastTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingCadenceForecastTile(
          bucket: _previewBucket,
        ),
      ),
    ),
  );
}

final _previewBucket = IncomingTalentOperatingCadenceBucket(
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
