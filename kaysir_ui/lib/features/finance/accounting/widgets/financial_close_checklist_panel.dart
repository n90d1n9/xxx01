import 'package:flutter/material.dart';

import '../models/financial_close_checklist.dart';
import '../models/financial_period_close.dart';
import '../models/financial_period_close_audit.dart';
import '../models/financial_report_package_integrity.dart';
import 'financial_close_audit_timeline.dart';
import 'financial_close_checklist_components.dart';
import 'financial_close_record_components.dart';
import 'financial_report_panel_components.dart';

class FinancialCloseChecklistPanel extends StatelessWidget {
  const FinancialCloseChecklistPanel({
    super.key,
    required this.checklist,
    this.closeRecord,
    this.packageIntegrity,
    this.closeAuditTrail = const [],
    this.onClosePeriod,
    this.onReopenPeriod,
    required this.isDarkMode,
  });

  final FinancialCloseChecklist checklist;
  final FinancialPeriodCloseRecord? closeRecord;
  final FinancialReportPackageIntegrity? packageIntegrity;
  final List<FinancialPeriodCloseAuditEvent> closeAuditTrail;
  final VoidCallback? onClosePeriod;
  final VoidCallback? onReopenPeriod;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final isClosed = closeRecord?.status == FinancialPeriodCloseStatus.closed;

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialCloseChecklistSummary(
            checklist: checklist,
            isClosed: isClosed,
            isDarkMode: isDarkMode,
          ),
          if (closeRecord != null) ...[
            const SizedBox(height: 10),
            FinancialCloseRecordSummary(
              closeRecord: closeRecord!,
              isDarkMode: isDarkMode,
            ),
          ],
          if (_shouldShowIntegrityBanner) ...[
            const SizedBox(height: 10),
            FinancialReportPackageIntegrityBanner(
              integrity: packageIntegrity!,
              isDarkMode: isDarkMode,
            ),
          ],
          const SizedBox(height: 14),
          FinancialClosePeriodActions(
            checklist: checklist,
            closeRecord: closeRecord,
            onClosePeriod: onClosePeriod,
            onReopenPeriod: onReopenPeriod,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          FinancialCloseAuditTimeline(
            events: closeAuditTrail,
            isDarkMode: isDarkMode,
          ),
          if (closeAuditTrail.isNotEmpty) const SizedBox(height: 14),
          FinancialCloseChecklistItemGrid(
            items: checklist.items,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  bool get _shouldShowIntegrityBanner {
    final integrity = packageIntegrity;
    return integrity != null &&
        integrity.status != FinancialReportPackageIntegrityStatus.notClosed;
  }
}
