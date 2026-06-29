import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_summary.dart';

class RecentReportExportsHeader extends StatelessWidget {
  final ReportExportQueueSummary summary;
  final VoidCallback? onDownloadReady;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onClearFinished;

  const RecentReportExportsHeader({
    super.key,
    required this.summary,
    this.onDownloadReady,
    this.onRetryFailed,
    this.onClearFinished,
  });

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        const Icon(Icons.history_rounded, color: HrisColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Recent exports',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        HrisStatusPill(label: summary.trackedLabel, color: HrisColors.primary),
      ],
    );
    final actions = _RecentReportExportHeaderActions(
      summary: summary,
      onDownloadReady: onDownloadReady,
      onRetryFailed: onRetryFailed,
      onClearFinished: onClearFinished,
    );

    if (!actions.hasActions) return title;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 920) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 8), actions],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 10),
            actions,
          ],
        );
      },
    );
  }
}

class _RecentReportExportHeaderActions extends StatelessWidget {
  final ReportExportQueueSummary summary;
  final VoidCallback? onDownloadReady;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onClearFinished;

  const _RecentReportExportHeaderActions({
    required this.summary,
    this.onDownloadReady,
    this.onRetryFailed,
    this.onClearFinished,
  });

  bool get hasActions =>
      (summary.hasDownloadableExports && onDownloadReady != null) ||
      (summary.hasFailedExports && onRetryFailed != null) ||
      (summary.hasFinishedExports && onClearFinished != null);

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (summary.hasDownloadableExports && onDownloadReady != null)
        _HeaderActionButton(
          icon: Icons.download_rounded,
          label: summary.downloadReadyLabel,
          onPressed: onDownloadReady,
        ),
      if (summary.hasFailedExports && onRetryFailed != null)
        _HeaderActionButton(
          icon: Icons.refresh_rounded,
          label: summary.retryFailedLabel,
          onPressed: onRetryFailed,
        ),
      if (summary.hasFinishedExports && onClearFinished != null)
        _HeaderActionButton(
          icon: Icons.done_all_rounded,
          label: summary.clearFinishedLabel,
          onPressed: onClearFinished,
        ),
    ];

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 17),
      label: Text(label),
    );
  }
}
