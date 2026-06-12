import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_summary.dart';

class RecentReportExportSummaryStrip extends StatelessWidget {
  final ReportExportQueueSummary summary;

  const RecentReportExportSummaryStrip({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            constraints.maxWidth >= 486
                ? 152.0
                : (constraints.maxWidth - 20) / 3;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ReportExportSummaryMetric(
              width: itemWidth,
              icon: Icons.check_circle_outline_rounded,
              value: summary.readyCount,
              label: 'Ready exports',
              color: Colors.green,
            ),
            _ReportExportSummaryMetric(
              width: itemWidth,
              icon: Icons.sync_rounded,
              value: summary.activeCount,
              label: 'In progress',
              color:
                  summary.hasActiveExports
                      ? HrisColors.primary
                      : HrisColors.muted,
            ),
            _ReportExportSummaryMetric(
              width: itemWidth,
              icon: Icons.error_outline_rounded,
              value: summary.failedCount,
              label: 'Needs retry',
              color: summary.hasFailedExports ? Colors.red : HrisColors.muted,
            ),
          ],
        );
      },
    );
  }
}

class _ReportExportSummaryMetric extends StatelessWidget {
  final double width;
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _ReportExportSummaryMetric({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
