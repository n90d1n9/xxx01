import 'report_generation_job.dart';

enum ReportExportQueueDateStatusKind { failed, active, ready }

class ReportExportQueueDateStatusCount {
  final ReportExportQueueDateStatusKind kind;
  final int count;

  const ReportExportQueueDateStatusCount({
    required this.kind,
    required this.count,
  });

  String get label {
    return switch (kind) {
      ReportExportQueueDateStatusKind.failed =>
        '$count ${count == 1 ? 'retry' : 'retries'}',
      ReportExportQueueDateStatusKind.active => '$count in progress',
      ReportExportQueueDateStatusKind.ready => '$count ready',
    };
  }
}

class ReportExportQueueDateSection {
  final DateTime date;
  final List<ReportGenerationJob> jobs;

  const ReportExportQueueDateSection({required this.date, required this.jobs});

  String get label => _formatDate(date);

  String get countLabel =>
      '${jobs.length} ${jobs.length == 1 ? 'export' : 'exports'}';

  List<ReportGenerationJob> get readyJobs {
    return _whereJob((job) => job.canDownload);
  }

  List<ReportGenerationJob> get retryableJobs {
    return _whereJob((job) => job.canRetry);
  }

  bool get hasDownloadableExports => readyJobs.isNotEmpty;

  bool get hasRetryableExports => retryableJobs.isNotEmpty;

  String get downloadReadyLabel => 'Download day ($readyCount)';

  String get retryFailedLabel => 'Retry day ($failedCount)';

  int get readyCount => _countStatus(ReportGenerationStatus.ready);

  int get activeCount {
    return jobs.where((job) => job.status.isActive).length;
  }

  int get failedCount => _countStatus(ReportGenerationStatus.failed);

  List<ReportExportQueueDateStatusCount> get statusCounts {
    return [
      if (failedCount > 0)
        ReportExportQueueDateStatusCount(
          kind: ReportExportQueueDateStatusKind.failed,
          count: failedCount,
        ),
      if (activeCount > 0)
        ReportExportQueueDateStatusCount(
          kind: ReportExportQueueDateStatusKind.active,
          count: activeCount,
        ),
      if (readyCount > 0)
        ReportExportQueueDateStatusCount(
          kind: ReportExportQueueDateStatusKind.ready,
          count: readyCount,
        ),
    ];
  }

  static List<ReportExportQueueDateSection> fromJobs(
    Iterable<ReportGenerationJob> jobs,
  ) {
    final sections = <ReportExportQueueDateSection>[];
    DateTime? activeDate;
    final activeJobs = <ReportGenerationJob>[];

    void closeSection() {
      final date = activeDate;
      if (date == null || activeJobs.isEmpty) return;

      sections.add(
        ReportExportQueueDateSection(
          date: date,
          jobs: List.unmodifiable(activeJobs),
        ),
      );
      activeJobs.clear();
    }

    for (final job in jobs) {
      final jobDate = _dateOnly(job.requestedAt);
      if (activeDate != null && !_isSameDate(activeDate, jobDate)) {
        closeSection();
      }

      activeDate = jobDate;
      activeJobs.add(job);
    }

    closeSection();
    return sections;
  }

  int _countStatus(ReportGenerationStatus status) {
    return jobs.where((job) => job.status == status).length;
  }

  List<ReportGenerationJob> _whereJob(
    bool Function(ReportGenerationJob job) matches,
  ) {
    return [
      for (final job in jobs)
        if (matches(job)) job,
    ];
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDate(DateTime value) {
  return '${_months[value.month - 1]} ${value.day}, ${value.year}';
}

const _months = [
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
