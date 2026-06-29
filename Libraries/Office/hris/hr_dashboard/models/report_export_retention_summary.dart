import 'report_generation_job.dart';

class ReportExportRetentionSummary {
  static const retentionWindow = Duration(days: 7);

  final DateTime? expiresAt;

  const ReportExportRetentionSummary({this.expiresAt});

  factory ReportExportRetentionSummary.fromJob(ReportGenerationJob job) {
    if (!job.canDownload) return const ReportExportRetentionSummary();

    final retentionStartsAt = job.completedAt ?? job.requestedAt;
    return ReportExportRetentionSummary(
      expiresAt: retentionStartsAt.add(retentionWindow),
    );
  }

  bool get hasExpiry => expiresAt != null;

  String? get expiryLabel {
    final dateLabel = expiryDateLabel;
    if (dateLabel == null) return null;

    return 'Expires $dateLabel';
  }

  String? get expiryDateLabel {
    final expiry = expiresAt;
    if (expiry == null) return null;

    return _formatMonthDay(expiry);
  }
}

String _formatMonthDay(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[value.month - 1]} ${value.day}';
}
