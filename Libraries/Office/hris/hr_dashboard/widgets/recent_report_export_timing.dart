import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_timing_summary.dart';
import '../models/report_generation_job.dart';

class RecentReportExportTiming extends StatelessWidget {
  final ReportGenerationJob job;

  const RecentReportExportTiming({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final summary = ReportExportTimingSummary.fromJob(job);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in summary.labels) _ReportTimingPill(label: label),
      ],
    );
  }
}

class _ReportTimingPill extends StatelessWidget {
  final String label;

  const _ReportTimingPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, color: HrisColors.muted, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
