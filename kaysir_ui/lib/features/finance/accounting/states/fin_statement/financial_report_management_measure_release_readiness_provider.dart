import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_management_measure_release_readiness.dart';
import '../../services/financial_report_management_measure_release_readiness_service.dart';
import 'financial_report_management_measure_provider.dart';
import 'financial_report_management_measure_reconciliation_provider.dart';

final financialReportManagementMeasureReleaseReadinessServiceProvider =
    Provider<FinancialReportManagementMeasureReleaseReadinessService>((ref) {
      return const FinancialReportManagementMeasureReleaseReadinessService();
    });

final currentFinancialReportManagementMeasureReleaseReadinessProvider =
    Provider<FinancialReportManagementMeasureReleaseReadinessSummary>((ref) {
      return ref
          .watch(
            financialReportManagementMeasureReleaseReadinessServiceProvider,
          )
          .summarize(
            reconciliations: ref.watch(
              currentFinancialReportManagementMeasureReconciliationsProvider,
            ),
            auditEvents: ref.watch(
              currentFinancialReportManagementMeasureAuditProvider,
            ),
          );
    });
