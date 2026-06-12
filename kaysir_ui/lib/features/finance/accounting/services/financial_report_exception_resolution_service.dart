import '../accounting_core/models/journal_entry.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_review_exception.dart';
import 'financial_report_review_exception_service.dart';

class FinancialReportExceptionResolutionService {
  final FinancialReportReviewExceptionService reviewExceptionService;

  const FinancialReportExceptionResolutionService({
    this.reviewExceptionService = const FinancialReportReviewExceptionService(),
  });

  List<FinancialReportExceptionReviewItem> buildReviewItems({
    required FinancialReportPack pack,
    List<FinancialReportExceptionResolution> resolutions = const [],
    List<LedgerPosting> postedAdjustmentJournals = const [],
  }) {
    return buildReviewItemsForExceptions(
      exceptions: reviewExceptionService.build(pack),
      resolutions: resolutions,
      postedAdjustmentJournals: postedAdjustmentJournals,
    );
  }

  List<FinancialReportExceptionReviewItem> buildReviewItemsForExceptions({
    required List<FinancialReportReviewException> exceptions,
    List<FinancialReportExceptionResolution> resolutions = const [],
    List<LedgerPosting> postedAdjustmentJournals = const [],
  }) {
    final resolutionsByException = {
      for (final resolution in resolutions) resolution.exceptionId: resolution,
    };
    return [
      for (final exception in exceptions)
        FinancialReportExceptionReviewItem(
          exception: exception,
          resolution: resolutionsByException[exception.id],
          adjustmentEvidenceIsPosted: _hasPostedAdjustmentEvidence(
            resolutionsByException[exception.id],
            postedAdjustmentJournals,
          ),
        ),
    ];
  }

  FinancialReportExceptionReviewItem? itemForCompliance({
    required String complianceId,
    required List<FinancialReportExceptionReviewItem> items,
  }) {
    for (final item in items) {
      if (item.sourceComplianceId == complianceId) {
        return item;
      }
    }
    return null;
  }

  bool _hasPostedAdjustmentEvidence(
    FinancialReportExceptionResolution? resolution,
    List<LedgerPosting> postedAdjustmentJournals,
  ) {
    if (resolution == null ||
        resolution.status !=
            FinancialReportExceptionResolutionStatus.adjusted) {
      return true;
    }
    final postingId = resolution.adjustmentPostingId;
    if (postingId == null || postingId.trim().isEmpty) {
      return false;
    }
    for (final posting in postedAdjustmentJournals) {
      if (posting.id == postingId &&
          posting.source == JournalSource.manualAdjustment &&
          (posting.debitTotal - posting.creditTotal).abs() < 0.01) {
        return true;
      }
    }
    return false;
  }
}
