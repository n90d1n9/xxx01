import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../accounting_path.dart';
import '../models/financial_report_disclosure_review.dart';
import '../states/fin_statement/financial_period_close_provider.dart';
import '../states/fin_statement/financial_provider.dart';
import '../states/fin_statement/financial_report_disclosure_review_provider.dart';
import '../states/fin_statement/financial_report_pack_provider.dart';
import '../widgets/financial_report_disclosure_review_components.dart';

class FinancialReportNotesCenterScreen extends ConsumerWidget {
  const FinancialReportNotesCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(financialReportPackProvider);
    final period = ref.watch(selectedFinancialPeriodProvider);
    final reviewItems = ref.watch(
      currentFinancialReportDisclosureReviewItemsProvider,
    );
    final reviewService = ref.watch(
      financialReportDisclosureReviewServiceProvider,
    );
    final closeRecord = ref.watch(currentFinancialPeriodCloseRecordProvider);
    final locked = closeRecord?.isClosed ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final unresolvedCount = reviewService.unresolvedRequiredCount(reviewItems);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Financial Notes'),
        actions: [
          IconButton(
            tooltip: 'Report pack',
            onPressed: () => context.go(AccountingPath.reportPack),
            icon: const Icon(Icons.inventory_2_rounded),
          ),
          IconButton(
            tooltip: 'Period close',
            onPressed: () => context.go(AccountingPath.periodClose),
            icon: const Icon(Icons.lock_clock_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FinancialReportDisclosureReviewHeader(
            periodLabel: period.label,
            frameworkName: pack.frameworkName,
            totalCount: reviewItems.length,
            unresolvedCount: unresolvedCount,
            approvedCount: reviewService.approvedCount(reviewItems),
            reviewRatio: reviewService.reviewRatio(reviewItems),
            locked: locked,
          ),
          const SizedBox(height: 14),
          FinancialReportDisclosureReviewList(
            items: reviewItems,
            locked: locked,
            onResolve:
                locked
                    ? null
                    : (item, status) =>
                        _saveResolution(context, ref, item, status),
            onClear:
                locked ? null : (item) => _clearResolution(context, ref, item),
          ),
        ],
      ),
    );
  }

  void _saveResolution(
    BuildContext context,
    WidgetRef ref,
    FinancialReportDisclosureReviewItem item,
    FinancialReportDisclosureResolutionStatus status,
  ) {
    final periodKey = ref.read(
      currentFinancialReportDisclosureReviewPeriodKeyProvider,
    );
    final resolution = FinancialReportDisclosureResolution(
      requirementId: item.id,
      status: status,
      reviewer: 'Current user',
      reviewedAt: DateTime.now(),
      note: _noteForStatus(status, item.requirement.title),
      evidenceReference: 'NOTE-${item.requirement.noteNumber}',
    );

    ref
        .read(financialReportDisclosureReviewProvider.notifier)
        .upsertResolution(periodKey: periodKey, resolution: resolution);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.requirement.title} marked ${status.label}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearResolution(
    BuildContext context,
    WidgetRef ref,
    FinancialReportDisclosureReviewItem item,
  ) {
    final periodKey = ref.read(
      currentFinancialReportDisclosureReviewPeriodKeyProvider,
    );
    ref
        .read(financialReportDisclosureReviewProvider.notifier)
        .removeResolution(periodKey: periodKey, requirementId: item.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.requirement.title} review cleared.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _noteForStatus(
    FinancialReportDisclosureResolutionStatus status,
    String title,
  ) {
    switch (status) {
      case FinancialReportDisclosureResolutionStatus.prepared:
        return '$title disclosure prepared from the generated report pack.';
      case FinancialReportDisclosureResolutionStatus.approved:
        return '$title disclosure approved for the current reporting period.';
      case FinancialReportDisclosureResolutionStatus.deferred:
        return '$title disclosure deferred pending additional support.';
    }
  }
}
