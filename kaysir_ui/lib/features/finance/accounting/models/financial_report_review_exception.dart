enum FinancialReportReviewExceptionSeverity { material, blocking, review }

extension FinancialReportReviewExceptionSeverityLabel
    on FinancialReportReviewExceptionSeverity {
  String get label {
    switch (this) {
      case FinancialReportReviewExceptionSeverity.material:
        return 'Material';
      case FinancialReportReviewExceptionSeverity.blocking:
        return 'Blocking';
      case FinancialReportReviewExceptionSeverity.review:
        return 'Review';
    }
  }
}

class FinancialReportReviewException {
  final String id;
  final String sourceComplianceId;
  final String title;
  final String description;
  final String standardReference;
  final FinancialReportReviewExceptionSeverity severity;
  final double? variance;
  final double? comparativeVariance;
  final double? materialityThreshold;
  final String? materialityBasis;

  const FinancialReportReviewException({
    required this.id,
    required this.sourceComplianceId,
    required this.title,
    required this.description,
    required this.standardReference,
    required this.severity,
    this.variance,
    this.comparativeVariance,
    this.materialityThreshold,
    this.materialityBasis,
  });

  bool get blocksClose {
    return severity == FinancialReportReviewExceptionSeverity.material ||
        severity == FinancialReportReviewExceptionSeverity.blocking;
  }

  bool get hasVarianceEvidence {
    return variance != null || comparativeVariance != null;
  }
}
