import '../models/report_generation_request.dart';
import '../models/report_type.dart';

abstract class ReportGenerationService {
  Future<void> generate(ReportType report, ReportGenerationRequest request);
}

class DelayedReportGenerationService implements ReportGenerationService {
  final Duration delay;

  const DelayedReportGenerationService({required this.delay});

  @override
  Future<void> generate(
    ReportType report,
    ReportGenerationRequest request,
  ) async {
    await Future<void>.delayed(delay);
  }
}
