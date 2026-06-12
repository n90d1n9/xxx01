import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_generation_job.dart';
import 'recent_report_export_details.dart';

class RecentReportExportTile extends StatelessWidget {
  final ReportGenerationJob job;
  final ValueChanged<ReportGenerationJob>? onDownload;
  final ValueChanged<ReportGenerationJob>? onRetry;

  const RecentReportExportTile({
    super.key,
    required this.job,
    this.onDownload,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = RecentReportExportDetails(job: job);
          final action = _RecentReportExportAction(
            job: job,
            onDownload: onDownload,
            onRetry: onRetry,
          );

          if (constraints.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ReportStatusIcon(job: job),
                    const SizedBox(width: 10),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ReportStatusPill(status: job.status),
                    const Spacer(),
                    action,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              _ReportStatusIcon(job: job),
              const SizedBox(width: 10),
              Expanded(child: details),
              const SizedBox(width: 12),
              _ReportStatusPill(status: job.status),
              const SizedBox(width: 8),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _RecentReportExportAction extends StatelessWidget {
  final ReportGenerationJob job;
  final ValueChanged<ReportGenerationJob>? onDownload;
  final ValueChanged<ReportGenerationJob>? onRetry;

  const _RecentReportExportAction({
    required this.job,
    this.onDownload,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (job.canDownload) {
      return IconButton(
        tooltip: 'Download ${job.fileName}',
        onPressed: onDownload == null ? null : () => onDownload!(job),
        icon: const Icon(Icons.download_rounded),
      );
    }

    if (job.canRetry) {
      return TextButton.icon(
        onPressed: onRetry == null ? null : () => onRetry!(job),
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Retry'),
      );
    }

    return const SizedBox(
      width: 34,
      height: 34,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _ReportStatusIcon extends StatelessWidget {
  final ReportGenerationJob job;

  const _ReportStatusIcon({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _statusColor(job.status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _statusIcon(job.status),
        color: _statusColor(job.status),
        size: 20,
      ),
    );
  }
}

class _ReportStatusPill extends StatelessWidget {
  final ReportGenerationStatus status;

  const _ReportStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return HrisStatusPill(label: status.label, color: _statusColor(status));
  }
}

IconData _statusIcon(ReportGenerationStatus status) {
  return switch (status) {
    ReportGenerationStatus.queued => Icons.schedule_rounded,
    ReportGenerationStatus.generating => Icons.sync_rounded,
    ReportGenerationStatus.ready => Icons.check_circle_outline_rounded,
    ReportGenerationStatus.failed => Icons.error_outline_rounded,
  };
}

Color _statusColor(ReportGenerationStatus status) {
  return switch (status) {
    ReportGenerationStatus.queued => HrisColors.muted,
    ReportGenerationStatus.generating => HrisColors.primary,
    ReportGenerationStatus.ready => Colors.green,
    ReportGenerationStatus.failed => Colors.red,
  };
}
