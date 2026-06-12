import '../models/financial_report_pack.dart';
import '../models/financial_report_review_exception.dart';

class FinancialReportReviewExceptionService {
  static const blockingComplianceIds = {
    'position-equation',
    'cash-reconciliation',
    'bank-reconciliation',
    'equity-roll-forward',
    'comprehensive-income-tie-out',
    'chart-mapping',
  };

  const FinancialReportReviewExceptionService();

  List<FinancialReportReviewException> build(FinancialReportPack pack) {
    final exceptions = <FinancialReportReviewException>[];
    for (final item in pack.complianceItems) {
      final severity = _severityFor(item);
      if (severity == null) {
        continue;
      }
      exceptions.add(
        FinancialReportReviewException(
          id: '${item.id}-${severity.name}',
          sourceComplianceId: item.id,
          title: item.title,
          description: _descriptionFor(item, severity),
          standardReference: item.standardReference,
          severity: severity,
          variance: item.variance,
          comparativeVariance: item.comparativeVariance,
          materialityThreshold: item.materialityThreshold,
          materialityBasis: item.materialityBasis,
        ),
      );
    }
    return exceptions..sort(_compare);
  }

  FinancialReportReviewExceptionSeverity? _severityFor(
    FinancialReportComplianceItem item,
  ) {
    if (item.isMaterialVariance) {
      return FinancialReportReviewExceptionSeverity.material;
    }
    if (item.isSatisfied) {
      return null;
    }
    if (blockingComplianceIds.contains(item.id)) {
      return FinancialReportReviewExceptionSeverity.blocking;
    }
    return FinancialReportReviewExceptionSeverity.review;
  }

  String _descriptionFor(
    FinancialReportComplianceItem item,
    FinancialReportReviewExceptionSeverity severity,
  ) {
    switch (severity) {
      case FinancialReportReviewExceptionSeverity.material:
        return '${item.description} Variance exceeds materiality and needs adjustment or documented approval before close.';
      case FinancialReportReviewExceptionSeverity.blocking:
        return '${item.description} Resolve this cross-statement check before close.';
      case FinancialReportReviewExceptionSeverity.review:
        return '${item.description} Complete or document this review before external reporting.';
    }
  }

  int _compare(
    FinancialReportReviewException left,
    FinancialReportReviewException right,
  ) {
    final severity = _rank(left.severity).compareTo(_rank(right.severity));
    if (severity != 0) {
      return severity;
    }
    return left.sourceComplianceId.compareTo(right.sourceComplianceId);
  }

  int _rank(FinancialReportReviewExceptionSeverity severity) {
    switch (severity) {
      case FinancialReportReviewExceptionSeverity.material:
        return 0;
      case FinancialReportReviewExceptionSeverity.blocking:
        return 1;
      case FinancialReportReviewExceptionSeverity.review:
        return 2;
    }
  }
}
