import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_period_close_workflow.dart';
import '../../services/financial_period_close_workflow_service.dart';
import 'financial_close_checklist_provider.dart';
import 'financial_period_close_audit_provider.dart';
import 'financial_period_close_provider.dart';
import 'financial_provider.dart';
import 'period_closing_entry_provider.dart';

final financialPeriodCloseWorkflowServiceProvider =
    Provider<FinancialPeriodCloseWorkflowService>((ref) {
      return const FinancialPeriodCloseWorkflowService();
    });

final currentFinancialPeriodCloseWorkflowProvider =
    Provider<FinancialPeriodCloseWorkflowSnapshot>((ref) {
      final period = ref.watch(selectedFinancialPeriodProvider);
      return ref
          .watch(financialPeriodCloseWorkflowServiceProvider)
          .build(
            periodLabel: period.label,
            periodStart: period.startDate,
            periodEnd: period.endDate,
            checklist: ref.watch(financialCloseChecklistProvider),
            closingEntryPreview: ref.watch(
              currentPeriodClosingEntryPreviewProvider,
            ),
            closingEntryPosted: ref.watch(
              currentPeriodClosingEntryPostedProvider,
            ),
            closeRecord: ref.watch(currentFinancialPeriodCloseRecordProvider),
            auditTrail: ref.watch(currentFinancialPeriodCloseAuditProvider),
          );
    });
