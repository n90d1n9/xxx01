import 'report_export_retention_summary.dart';
import 'report_generation_job.dart';

enum ReportExportNextActionKind { wait, download, retry }

class ReportExportNextActionSummary {
  final ReportExportNextActionKind kind;
  final String label;

  const ReportExportNextActionSummary({
    required this.kind,
    required this.label,
  });

  factory ReportExportNextActionSummary.fromJob(ReportGenerationJob job) {
    return switch (job.status) {
      ReportGenerationStatus.queued => const ReportExportNextActionSummary(
        kind: ReportExportNextActionKind.wait,
        label: 'Queued for generation',
      ),
      ReportGenerationStatus.generating => const ReportExportNextActionSummary(
        kind: ReportExportNextActionKind.wait,
        label: 'Wait for completion',
      ),
      ReportGenerationStatus.ready => ReportExportNextActionSummary(
        kind: ReportExportNextActionKind.download,
        label: _downloadLabel(job),
      ),
      ReportGenerationStatus.failed => const ReportExportNextActionSummary(
        kind: ReportExportNextActionKind.retry,
        label: 'Retry generation',
      ),
    };
  }

  bool get isActionable {
    return kind == ReportExportNextActionKind.download ||
        kind == ReportExportNextActionKind.retry;
  }
}

String _downloadLabel(ReportGenerationJob job) {
  final expiryDateLabel =
      ReportExportRetentionSummary.fromJob(job).expiryDateLabel;
  if (expiryDateLabel == null) return 'Download report';

  return 'Download before $expiryDateLabel';
}
