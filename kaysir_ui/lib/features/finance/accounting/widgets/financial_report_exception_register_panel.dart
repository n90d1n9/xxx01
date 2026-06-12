import 'package:flutter/material.dart';

import '../accounting_core/models/ledger_posting.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_review_exception.dart';
import '../services/financial_report_exception_resolution_service.dart';
import '../services/financial_report_review_exception_service.dart';
import 'financial_report_exception_register_components.dart';
import 'financial_report_exception_row.dart';
import 'financial_report_panel_components.dart';

class FinancialReportExceptionRegisterPanel extends StatelessWidget {
  const FinancialReportExceptionRegisterPanel({
    super.key,
    required this.pack,
    this.reviewExceptionService = const FinancialReportReviewExceptionService(),
    this.exceptionResolutionService =
        const FinancialReportExceptionResolutionService(),
    this.exceptionResolutions = const [],
    this.postedAdjustmentJournals = const [],
    this.onResolveException,
    this.resolutionActionLockedReason,
    required this.isDarkMode,
  });

  final FinancialReportPack pack;
  final FinancialReportReviewExceptionService reviewExceptionService;
  final FinancialReportExceptionResolutionService exceptionResolutionService;
  final List<FinancialReportExceptionResolution> exceptionResolutions;
  final List<LedgerPosting> postedAdjustmentJournals;
  final void Function(
    FinancialReportReviewException exception,
    FinancialReportExceptionResolutionStatus status,
  )?
  onResolveException;
  final String? resolutionActionLockedReason;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final exceptions = exceptionResolutionService.buildReviewItemsForExceptions(
      exceptions: reviewExceptionService.build(pack),
      resolutions: exceptionResolutions,
      postedAdjustmentJournals: postedAdjustmentJournals,
    );
    final blockerCount =
        exceptions.where((exception) => exception.blocksClose).length;

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialReportExceptionRegisterHeader(
            periodLabel: pack.periodLabel,
            exceptionCount: exceptions.length,
            blockerCount: blockerCount,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          if (exceptions.isEmpty)
            FinancialReportExceptionEmptyState(isDarkMode: isDarkMode)
          else
            ...exceptions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FinancialReportExceptionRow(
                  pack: pack,
                  item: item,
                  onResolveException: onResolveException,
                  resolutionActionLockedReason: resolutionActionLockedReason,
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
