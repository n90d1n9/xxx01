import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_decision_record.dart';
import '../services/project_decision_sla_tracker_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// SLA tracker panel for open decision due dates and timing risk.
class ProjectDecisionSlaTrackerPanel extends StatefulWidget {
  const ProjectDecisionSlaTrackerPanel({
    required this.summary,
    this.maxBuckets = 5,
    super.key,
  });

  final ProjectDecisionSlaTrackerSummary summary;
  final int maxBuckets;

  @override
  State<ProjectDecisionSlaTrackerPanel> createState() =>
      _ProjectDecisionSlaTrackerPanelState();
}

/// Keeps SLA brief copy state local to the timing presentation.
class _ProjectDecisionSlaTrackerPanelState
    extends State<ProjectDecisionSlaTrackerPanel> {
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleBuckets =
        summary.buckets
            .where((bucket) => !bucket.isEmpty)
            .take(widget.maxBuckets)
            .toList();
    final briefText = summary.briefText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.subtitle,
          icon: summary.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.signal.label,
            icon: summary.signal.icon,
            color: signalColor,
            maxWidth: 124,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Overdue',
              value: summary.overdueCount.toString(),
              icon: ProjectDecisionSlaBucket.overdue.icon,
              accentColor:
                  summary.overdueCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Breached',
            ),
            AppMetricGridItem(
              title: 'Today',
              value: summary.dueTodayCount.toString(),
              icon: ProjectDecisionSlaBucket.dueToday.icon,
              accentColor:
                  summary.dueTodayCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Same-day',
            ),
            AppMetricGridItem(
              title: 'Next 7d',
              value: summary.dueSoonCount.toString(),
              icon: ProjectDecisionSlaBucket.dueSoon.icon,
              accentColor:
                  summary.dueSoonCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Due soon',
            ),
            AppMetricGridItem(
              title: 'On track',
              value: summary.onTrackCount.toString(),
              icon: ProjectDecisionSlaBucket.onTrack.icon,
              accentColor: Colors.green.shade700,
              helper: 'Timed',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleBuckets.isEmpty)
          const AppInfoRow(
            title: 'No open decision SLA lanes',
            subtitle: 'All decision records are already closed or approved.',
            icon: Icons.verified_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleBuckets.length; index++) ...[
            _DecisionSlaBucketTile(bucket: visibleBuckets[index]),
            if (index != visibleBuckets.length - 1) const SizedBox(height: 10),
          ],
        if (briefText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'SLA brief',
            text: briefText,
            icon: Icons.event_note_outlined,
            copied: _briefCopied,
            onCopy: () => _copyBrief(briefText),
          ),
        ],
      ],
    );
  }

  Future<void> _copyBrief(String briefText) async {
    setState(() => _briefCopied = true);
    await Clipboard.setData(ClipboardData(text: briefText));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('SLA brief copied')));
  }
}

/// SLA lane row with primary decision, timing, owner, and status signal.
class _DecisionSlaBucketTile extends StatelessWidget {
  const _DecisionSlaBucketTile({required this.bucket});

  final ProjectDecisionSlaBucketSummary bucket;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bucketColor = bucket.bucket.color(colorScheme);
    final signalColor = bucket.signal.color(colorScheme);
    final primary = bucket.primaryItem;

    return AppInfoRow(
      title: bucket.bucket.label,
      subtitle:
          primary == null
              ? bucket.detail
              : '${bucket.detail} Owner: ${primary.record.owner} - '
                  '${primary.record.status.label}.',
      icon: bucket.bucket.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: bucketColor.withValues(alpha: 0.12),
      iconForegroundColor: bucketColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: bucket.signal.label,
        icon: bucket.signal.icon,
        color: signalColor,
        maxWidth: 124,
      ),
    );
  }
}

@Preview(name: 'Project decision SLA tracker panel')
Widget projectDecisionSlaTrackerPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionSlaTrackerPanel(
          summary: workspace.decisionSlaTrackerSummary,
        ),
      ),
    ),
  );
}
