import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/report_generation_job.dart';
import '../models/report_generation_request.dart';
import '../models/report_type.dart';
import '../services/report_generation_service.dart';

final reportGenerationDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

final reportGenerationClockProvider = Provider<DateTime Function()>(
  (ref) => () => DateTime.now(),
);

final reportGenerationHistoryLimitProvider = Provider<int>((ref) => 5);

final reportGenerationServiceProvider = Provider<ReportGenerationService>((
  ref,
) {
  return DelayedReportGenerationService(
    delay: ref.watch(reportGenerationDelayProvider),
  );
});

final reportGenerationJobsProvider = StateNotifierProvider<
  ReportGenerationController,
  List<ReportGenerationJob>
>((ref) => ReportGenerationController(ref));

class ReportGenerationController
    extends StateNotifier<List<ReportGenerationJob>> {
  final Ref _ref;
  int _sequence = 0;

  ReportGenerationController(this._ref) : super(const []);

  Future<ReportGenerationJob> submit(
    ReportType report,
    ReportGenerationRequest request,
  ) async {
    final job = ReportGenerationJob(
      id: 'report-job-${++_sequence}',
      report: report,
      request: request,
      status: ReportGenerationStatus.queued,
      requestedAt: _now(),
    );

    _prepend(job);
    _updateStatus(job.id, ReportGenerationStatus.generating);

    try {
      await _ref
          .read(reportGenerationServiceProvider)
          .generate(report, request);
      _updateStatus(job.id, ReportGenerationStatus.ready, completedAt: _now());
    } catch (error) {
      _updateStatus(
        job.id,
        ReportGenerationStatus.failed,
        completedAt: _now(),
        failureMessage: error.toString(),
      );
    }

    return state.firstWhere((candidate) => candidate.id == job.id);
  }

  Future<ReportGenerationJob> retry(ReportGenerationJob job) {
    return submit(job.report, job.request);
  }

  Future<List<ReportGenerationJob>> retryFailed() {
    final failedJobs = state.where((job) => job.canRetry).toList();
    return Future.wait([for (final job in failedJobs) retry(job)]);
  }

  void clearCompleted() {
    state = state.where((job) => job.status.isActive).toList();
  }

  DateTime _now() => _ref.read(reportGenerationClockProvider)();

  void _prepend(ReportGenerationJob job) {
    final limit = _ref.read(reportGenerationHistoryLimitProvider);
    state = [job, ...state].take(limit).toList();
  }

  void _updateStatus(
    String id,
    ReportGenerationStatus status, {
    DateTime? completedAt,
    String? failureMessage,
  }) {
    state = [
      for (final job in state)
        if (job.id == id)
          job.copyWith(
            status: status,
            completedAt: completedAt,
            failureMessage: failureMessage,
          )
        else
          job,
    ];
  }
}
