import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_close_checklist.dart';
import '../models/financial_period_close.dart';
import '../models/financial_report_package_integrity.dart';
import 'financial_close_checklist_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportPackageIntegrityBanner extends StatelessWidget {
  const FinancialReportPackageIntegrityBanner({
    required this.integrity,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportPackageIntegrity integrity;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final status = integrity.status;
    final color = switch (status) {
      FinancialReportPackageIntegrityStatus.verified =>
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700,
      FinancialReportPackageIntegrityStatus.changed => Colors.red.shade700,
      FinancialReportPackageIntegrityStatus.missingFingerprint =>
        Colors.orange.shade700,
      FinancialReportPackageIntegrityStatus.notClosed => Colors.blueGrey,
    };
    final icon = switch (status) {
      FinancialReportPackageIntegrityStatus.verified =>
        Icons.verified_user_rounded,
      FinancialReportPackageIntegrityStatus.changed =>
        Icons.report_problem_rounded,
      FinancialReportPackageIntegrityStatus.missingFingerprint =>
        Icons.fingerprint_rounded,
      FinancialReportPackageIntegrityStatus.notClosed =>
        Icons.info_outline_rounded,
    };
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return FinancialReportTintedSurface(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      fillAlpha: 0.08,
      borderAlpha: 0.22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  integrity.detail,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                if (integrity.closedShortHash != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Closed ${integrity.closedShortHash} | Current ${integrity.currentShortHash}',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialCloseRecordSummary extends StatelessWidget {
  const FinancialCloseRecordSummary({
    required this.closeRecord,
    required this.isDarkMode,
    super.key,
  });

  final FinancialPeriodCloseRecord closeRecord;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final statusColor =
        closeRecord.status == FinancialPeriodCloseStatus.closed
            ? (isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700)
            : Colors.orange.shade700;
    final closedAt = closeRecord.closedAt;
    final reopenedAt = closeRecord.reopenedAt;
    final formatter = DateFormat('MMM d, yyyy HH:mm');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FinancialCloseStatusPill(
          label: closeRecord.status.label,
          color: statusColor,
          isDarkMode: isDarkMode,
        ),
        if (closedAt != null)
          FinancialCloseStatusPill(
            label: 'Closed ${formatter.format(closedAt)}',
            color: mutedColor,
            isDarkMode: isDarkMode,
          ),
        if (closeRecord.closedBy != null)
          FinancialCloseStatusPill(
            label: 'By ${closeRecord.closedBy}',
            color: mutedColor,
            isDarkMode: isDarkMode,
          ),
        if (reopenedAt != null)
          FinancialCloseStatusPill(
            label: 'Reopened ${formatter.format(reopenedAt)}',
            color: Colors.orange.shade700,
            isDarkMode: isDarkMode,
          ),
        if (closeRecord.reportPackageShortHash != null)
          FinancialCloseStatusPill(
            label: 'Package ${closeRecord.reportPackageShortHash}',
            color: isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey,
            isDarkMode: isDarkMode,
          ),
        if (closeRecord.closingEntryEvidenceLabel != null)
          FinancialCloseStatusPill(
            label: 'Closing ${closeRecord.closingEntryEvidenceLabel}',
            color: isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700,
            isDarkMode: isDarkMode,
          ),
      ],
    );
  }
}

class FinancialClosePeriodActions extends StatelessWidget {
  const FinancialClosePeriodActions({
    required this.checklist,
    required this.closeRecord,
    required this.onClosePeriod,
    required this.onReopenPeriod,
    required this.isDarkMode,
    super.key,
  });

  final FinancialCloseChecklist checklist;
  final FinancialPeriodCloseRecord? closeRecord;
  final VoidCallback? onClosePeriod;
  final VoidCallback? onReopenPeriod;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final isClosed = closeRecord?.status == FinancialPeriodCloseStatus.closed;
    final canClose = !checklist.hasBlockers && !isClosed;
    final canReopen = isClosed;
    final primaryColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: canClose ? onClosePeriod : null,
          icon: const Icon(Icons.lock_rounded, size: 18),
          label: const Text('Close Period'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        OutlinedButton.icon(
          onPressed: canReopen ? onReopenPeriod : null,
          icon: const Icon(Icons.lock_open_rounded, size: 18),
          label: const Text('Reopen'),
        ),
      ],
    );
  }
}
