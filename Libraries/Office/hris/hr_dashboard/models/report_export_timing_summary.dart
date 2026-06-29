import 'report_generation_job.dart';

class ReportExportTimingSummary {
  final String startedLabel;
  final String statusLabel;
  final String? durationLabel;

  const ReportExportTimingSummary({
    required this.startedLabel,
    required this.statusLabel,
    this.durationLabel,
  });

  factory ReportExportTimingSummary.fromJob(ReportGenerationJob job) {
    final completedAt = job.completedAt;

    return ReportExportTimingSummary(
      startedLabel: 'Started ${_formatTime(job.requestedAt)}',
      statusLabel: _statusLabel(job.status, completedAt),
      durationLabel:
          completedAt == null
              ? null
              : '${_formatDuration(completedAt.difference(job.requestedAt))} runtime',
    );
  }

  List<String> get labels {
    return [
      startedLabel,
      statusLabel,
      if (durationLabel != null) durationLabel!,
    ];
  }
}

String _statusLabel(ReportGenerationStatus status, DateTime? completedAt) {
  return switch (status) {
    ReportGenerationStatus.queued => 'Waiting in queue',
    ReportGenerationStatus.generating => 'Generating now',
    ReportGenerationStatus.ready =>
      completedAt == null ? 'Ready' : 'Completed ${_formatTime(completedAt)}',
    ReportGenerationStatus.failed =>
      completedAt == null ? 'Failed' : 'Failed ${_formatTime(completedAt)}',
  };
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDuration(Duration duration) {
  final normalized = duration.isNegative ? Duration.zero : duration;
  final hours = normalized.inHours;
  final minutes = normalized.inMinutes.remainder(60);

  if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
  if (hours > 0) return '${hours}h';
  if (minutes > 0) return '${minutes}m';
  return '<1m';
}
