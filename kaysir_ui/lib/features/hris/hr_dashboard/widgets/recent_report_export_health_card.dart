import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_filter.dart';
import '../models/report_export_queue_health_insight.dart';

class RecentReportExportHealthCard extends StatelessWidget {
  final ReportExportQueueHealthInsight insight;
  final ValueChanged<ReportExportQueueFilter>? onFocusFilter;

  const RecentReportExportHealthCard({
    super.key,
    required this.insight,
    this.onFocusFilter,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(insight.tone);
    final suggestedFilter = insight.suggestedFilter;
    final canFocus = suggestedFilter != null && onFocusFilter != null;
    final action =
        canFocus
            ? OutlinedButton.icon(
              key: const Key('recent-export-health-focus'),
              onPressed: () => onFocusFilter!(suggestedFilter),
              icon: const Icon(Icons.filter_alt_outlined, size: 18),
              label: Text(insight.actionLabel!),
            )
            : null;

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = _HealthContent(insight: insight, color: color);
          final isNarrow = constraints.maxWidth < 640;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_iconFor(insight.tone), color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    isNarrow || action == null
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            content,
                            if (action != null) ...[
                              const SizedBox(height: 12),
                              action,
                            ],
                          ],
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: content),
                            const SizedBox(width: 12),
                            action,
                          ],
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HealthContent extends StatelessWidget {
  final ReportExportQueueHealthInsight insight;
  final Color color;

  const _HealthContent({required this.insight, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Export queue health',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            HrisStatusPill(label: insight.label, color: color),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          insight.headline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          insight.detail,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

Color _colorFor(ReportExportQueueHealthTone tone) {
  return switch (tone) {
    ReportExportQueueHealthTone.attention => Colors.red,
    ReportExportQueueHealthTone.ready => Colors.green,
    ReportExportQueueHealthTone.active => HrisColors.primary,
    ReportExportQueueHealthTone.clear => HrisColors.muted,
  };
}

IconData _iconFor(ReportExportQueueHealthTone tone) {
  return switch (tone) {
    ReportExportQueueHealthTone.attention =>
      Icons.notification_important_outlined,
    ReportExportQueueHealthTone.ready => Icons.download_done_rounded,
    ReportExportQueueHealthTone.active => Icons.sync_rounded,
    ReportExportQueueHealthTone.clear => Icons.inbox_outlined,
  };
}
