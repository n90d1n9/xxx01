import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_review_exception.dart';
import 'financial_report_exception_register_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportExceptionRow extends StatelessWidget {
  const FinancialReportExceptionRow({
    required this.pack,
    required this.item,
    this.onResolveException,
    this.resolutionActionLockedReason,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportPack pack;
  final FinancialReportExceptionReviewItem item;
  final void Function(
    FinancialReportReviewException exception,
    FinancialReportExceptionResolutionStatus status,
  )?
  onResolveException;
  final String? resolutionActionLockedReason;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final exception = item.exception;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final color = financialReportExceptionSeverityColor(
      exception.severity,
      isDarkMode,
    );
    final amountText = _varianceText(pack, exception);
    final materialityText = _materialityText(pack, exception);
    final resolution = item.resolution;

    return FinancialReportTintedSurface(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      fillAlpha: 0.08,
      borderAlpha: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FinancialReportExceptionSeverityPill(
                severity: exception.severity,
                color: color,
                isDarkMode: isDarkMode,
              ),
              Text(
                exception.standardReference,
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.blocksClose)
                FinancialReportExceptionPill(
                  label: 'Blocks close',
                  color: color,
                  isDarkMode: isDarkMode,
                ),
              if (item.resolution != null)
                FinancialReportExceptionPill(
                  label: item.resolution!.status.label,
                  color:
                      item.isResolved
                          ? (isDarkMode
                              ? const Color(0xFF4ECCA3)
                              : Colors.teal.shade700)
                          : color,
                  isDarkMode: isDarkMode,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exception.title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            exception.description,
            style: TextStyle(color: mutedColor, fontSize: 12),
          ),
          if (amountText != null ||
              materialityText != null ||
              resolution != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (amountText != null)
                  FinancialReportExceptionEvidencePill(
                    icon: Icons.difference_rounded,
                    label: amountText,
                    isDarkMode: isDarkMode,
                  ),
                if (materialityText != null)
                  FinancialReportExceptionEvidencePill(
                    icon: Icons.rule_rounded,
                    label: materialityText,
                    isDarkMode: isDarkMode,
                  ),
                if (resolution != null) ...[
                  FinancialReportExceptionEvidencePill(
                    icon: Icons.verified_user_rounded,
                    label: _resolutionText(resolution),
                    isDarkMode: isDarkMode,
                  ),
                  if (resolution.adjustmentPostingId != null)
                    FinancialReportExceptionEvidencePill(
                      icon: Icons.receipt_long_rounded,
                      label: 'Posting ${resolution.adjustmentPostingId}',
                      isDarkMode: isDarkMode,
                    ),
                  FinancialReportExceptionEvidencePill(
                    icon: Icons.event_available_rounded,
                    label: _resolutionDateText(resolution),
                    isDarkMode: isDarkMode,
                  ),
                  FinancialReportExceptionEvidencePill(
                    icon: Icons.notes_rounded,
                    label: _resolutionNoteText(resolution),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ],
            ),
          ],
          if (resolutionActionLockedReason != null &&
              onResolveException == null &&
              !item.isResolved) ...[
            const SizedBox(height: 10),
            _LockedResolutionNotice(
              message: resolutionActionLockedReason!,
              isDarkMode: isDarkMode,
            ),
          ],
          if (onResolveException != null && !item.isResolved) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed:
                      () => onResolveException!(
                        exception,
                        FinancialReportExceptionResolutionStatus.approved,
                      ),
                  icon: const Icon(Icons.verified_rounded, size: 18),
                  label: const Text('Approve'),
                ),
                FilledButton.tonalIcon(
                  onPressed:
                      () => onResolveException!(
                        exception,
                        FinancialReportExceptionResolutionStatus.adjusted,
                      ),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Record adjustment'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      () => onResolveException!(
                        exception,
                        FinancialReportExceptionResolutionStatus.deferred,
                      ),
                  icon: const Icon(Icons.schedule_send_rounded, size: 18),
                  label: const Text('Defer'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LockedResolutionNotice extends StatelessWidget {
  const _LockedResolutionNotice({
    required this.message,
    required this.isDarkMode,
  });

  final String message;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? Colors.grey.shade300 : Colors.blueGrey.shade700;
    return FinancialReportTintedSurface(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      backgroundColor: isDarkMode ? Colors.white10 : Colors.blueGrey.shade50,
      borderAlpha: isDarkMode ? 0.18 : 0.16,
      child: Row(
        children: [
          Icon(Icons.lock_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _resolutionText(FinancialReportExceptionResolution resolution) {
  final reference = resolution.adjustmentReference;
  final reviewer = resolution.reviewer.trim();
  final owner = reviewer.isEmpty ? 'reviewed' : 'by $reviewer';
  if (reference == null || reference.trim().isEmpty) {
    return '${resolution.status.label} $owner';
  }
  return '${resolution.status.label} $owner - $reference';
}

String _resolutionDateText(FinancialReportExceptionResolution resolution) {
  return DateFormat('MMM d, yyyy HH:mm').format(resolution.resolvedAt);
}

String _resolutionNoteText(FinancialReportExceptionResolution resolution) {
  final note = resolution.note.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (note.length <= 72) {
    return note;
  }
  return '${note.substring(0, 69)}...';
}

String? _varianceText(
  FinancialReportPack pack,
  FinancialReportReviewException exception,
) {
  if (!exception.hasVarianceEvidence) {
    return null;
  }

  final values = <String>[];
  final variance = exception.variance;
  if (variance != null) {
    values.add('Current ${_money(pack, variance)}');
  }
  final comparativeVariance = exception.comparativeVariance;
  if (comparativeVariance != null) {
    values.add('Comparative ${_money(pack, comparativeVariance)}');
  }
  return values.join(' | ');
}

String? _materialityText(
  FinancialReportPack pack,
  FinancialReportReviewException exception,
) {
  final threshold = exception.materialityThreshold;
  if (threshold == null) {
    return null;
  }
  final basis = exception.materialityBasis;
  if (basis == null || basis.isEmpty) {
    return 'Threshold ${_money(pack, threshold)}';
  }
  return 'Threshold ${_money(pack, threshold)} ($basis)';
}

String _money(FinancialReportPack pack, double value) {
  return NumberFormat.currency(
    symbol: '${pack.presentationCurrency} ',
    decimalDigits: 0,
  ).format(value);
}
