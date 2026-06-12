import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_generation_job.dart';
import '../models/report_generation_request.dart';
import '../models/report_type.dart';
import 'recent_report_exports.dart';
import 'report_generation_dialog.dart';
import 'report_generation_feedback.dart';
import 'report_launcher_card.dart';

typedef ReportGenerationHandler =
    Future<void> Function(ReportType report, ReportGenerationRequest request);

class ReportLauncherSection extends StatelessWidget {
  final List<ReportType> reportTypes;
  final List<ReportGenerationJob> recentJobs;
  final ReportGenerationHandler? onGenerate;
  final ValueChanged<ReportGenerationJob>? onDownload;
  final ValueChanged<List<ReportGenerationJob>>? onDownloadReady;
  final ValueChanged<ReportGenerationJob>? onRetry;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onClearFinished;

  const ReportLauncherSection({
    super.key,
    required this.reportTypes,
    this.recentJobs = const [],
    this.onGenerate,
    this.onDownload,
    this.onDownloadReady,
    this.onRetry,
    this.onRetryFailed,
    this.onClearFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HrisColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.file_download_outlined,
                color: HrisColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Reports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Standard HR analytics exports',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (reportTypes.isEmpty)
          const HrisEmptyState(message: 'No reports configured yet')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth >= 1000
                      ? 4
                      : constraints.maxWidth >= 640
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: columns == 1 ? 2.9 : 1.45,
                ),
                itemCount: reportTypes.length,
                itemBuilder: (context, index) {
                  final report = reportTypes[index];
                  return ReportLauncherCard(
                    report: report,
                    onTap: () => _openReportDialog(context, report),
                  );
                },
              );
            },
          ),
        if (recentJobs.isNotEmpty) ...[
          const SizedBox(height: 16),
          RecentReportExports(
            jobs: recentJobs,
            onDownload: onDownload,
            onDownloadReady: onDownloadReady,
            onRetry: onRetry,
            onRetryFailed: onRetryFailed,
            onClearFinished: onClearFinished,
          ),
        ],
      ],
    );
  }

  Future<void> _openReportDialog(
    BuildContext context,
    ReportType report,
  ) async {
    final request = await showDialog<ReportGenerationRequest>(
      context: context,
      builder: (context) => ReportGenerationDialog(report: report),
    );

    if (request == null) return;

    if (onGenerate != null) {
      await onGenerate!(report, request);
      return;
    }

    if (!context.mounted) return;
    await showReportGenerationFeedback(context, report, request);
  }
}
