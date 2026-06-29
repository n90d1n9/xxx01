import 'report_generation_request.dart';
import 'report_type.dart';

enum ReportGenerationStatus {
  queued('Queued'),
  generating('Generating'),
  ready('Ready'),
  failed('Failed');

  final String label;

  const ReportGenerationStatus(this.label);

  bool get isActive {
    return this == ReportGenerationStatus.queued ||
        this == ReportGenerationStatus.generating;
  }
}

class ReportGenerationJob {
  final String id;
  final ReportType report;
  final ReportGenerationRequest request;
  final ReportGenerationStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? failureMessage;

  const ReportGenerationJob({
    required this.id,
    required this.report,
    required this.request,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.failureMessage,
  });

  String get fileName => request.exportFileNameFor(report);

  bool get canDownload => status == ReportGenerationStatus.ready;

  bool get canRetry => status == ReportGenerationStatus.failed;

  ReportGenerationJob copyWith({
    ReportGenerationStatus? status,
    DateTime? completedAt,
    String? failureMessage,
  }) {
    return ReportGenerationJob(
      id: id,
      report: report,
      request: request,
      status: status ?? this.status,
      requestedAt: requestedAt,
      completedAt: completedAt ?? this.completedAt,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReportGenerationJob &&
            other.id == id &&
            other.report == report &&
            other.request == request &&
            other.status == status &&
            other.requestedAt == requestedAt &&
            other.completedAt == completedAt &&
            other.failureMessage == failureMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      report,
      request,
      status,
      requestedAt,
      completedAt,
      failureMessage,
    );
  }
}
