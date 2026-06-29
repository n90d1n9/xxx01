import 'report_generation_request.dart';
import 'report_type.dart';

enum ReportExportSensitivity {
  internal('Internal'),
  confidential('Confidential'),
  payrollSensitive('Payroll-sensitive');

  final String label;

  const ReportExportSensitivity(this.label);
}

class ReportExportComplianceSummary {
  final ReportExportSensitivity sensitivity;

  const ReportExportComplianceSummary({required this.sensitivity});

  factory ReportExportComplianceSummary.fromRequest({
    required ReportType report,
    required ReportGenerationRequest request,
  }) {
    if (_isPayrollSensitive(report)) {
      return const ReportExportComplianceSummary(
        sensitivity: ReportExportSensitivity.payrollSensitive,
      );
    }

    if (request.includeRawData) {
      return const ReportExportComplianceSummary(
        sensitivity: ReportExportSensitivity.confidential,
      );
    }

    return const ReportExportComplianceSummary(
      sensitivity: ReportExportSensitivity.internal,
    );
  }

  String get label => sensitivity.label;

  bool get needsCarefulHandling {
    return sensitivity != ReportExportSensitivity.internal;
  }
}

bool _isPayrollSensitive(ReportType report) {
  final searchable = '${report.name} ${report.description}'.toLowerCase();
  return _payrollKeywords.any(searchable.contains);
}

const _payrollKeywords = ['payroll', 'salary', 'compensation', 'benefit'];
