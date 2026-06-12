import 'package:flutter/material.dart';

import '../accounting_core/models/journal_entry.dart';
import '../helper/format_currency.dart';
import '../models/period_closing_entry.dart';
import 'financial_report_panel_components.dart';

class PeriodClosingEntryPreviewPanel extends StatelessWidget {
  final PeriodClosingEntryPreview preview;
  final bool isPosted;
  final VoidCallback? onPostClosingEntry;
  final bool isDarkMode;

  const PeriodClosingEntryPreviewPanel({
    super.key,
    required this.preview,
    this.isPosted = false,
    this.onPostClosingEntry,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final accent = isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
    final warningColor = Colors.orange.shade700;
    final postedColor = isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey;
    final draft = preview.draft;
    final canPost = preview.canPost && !isPosted;

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, color: accent),
                  const SizedBox(width: 10),
                  Text(
                    'Draft Closing Entry',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              _StatusPill(
                icon:
                    isPosted
                        ? Icons.task_alt_rounded
                        : preview.canPost
                        ? Icons.check_circle_rounded
                        : Icons.pending_actions_rounded,
                label:
                    isPosted
                        ? 'Posted'
                        : preview.canPost
                        ? 'Ready'
                        : 'Review',
                color:
                    isPosted
                        ? postedColor
                        : preview.canPost
                        ? accent
                        : warningColor,
                isDarkMode: isDarkMode,
              ),
              if (onPostClosingEntry != null)
                Tooltip(
                  message:
                      isPosted
                          ? 'Closing entry is already posted'
                          : 'Post closing entry',
                  child: ElevatedButton.icon(
                    onPressed: canPost ? onPostClosingEntry : null,
                    icon: Icon(
                      isPosted ? Icons.done_rounded : Icons.publish_rounded,
                    ),
                    label: Text(isPosted ? 'Posted' : 'Post'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AmountTile(
                label: 'Revenue to close',
                amount: preview.totalRevenue,
                isDarkMode: isDarkMode,
              ),
              _AmountTile(
                label: 'Expenses to close',
                amount: preview.totalExpenses,
                isDarkMode: isDarkMode,
              ),
              _AmountTile(
                label: preview.netIncome >= 0 ? 'Net income' : 'Net loss',
                amount: preview.netIncome,
                isDarkMode: isDarkMode,
                emphasize: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (preview.warnings.isNotEmpty)
            ...preview.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: warningColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(color: mutedColor, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (draft != null)
            _DraftLinesTable(
              draft: draft,
              retainedEarningsName:
                  preview.retainedEarningsAccount?.name ?? 'Retained Earnings',
              isDarkMode: isDarkMode,
            ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDarkMode;
  final bool emphasize;

  const _AmountTile({
    required this.label,
    required this.amount,
    required this.isDarkMode,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final valueColor =
        emphasize
            ? amount >= 0
                ? (isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700)
                : (isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700)
            : textColor;

    return SizedBox(
      width: 190,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatCurrency(amount),
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftLinesTable extends StatelessWidget {
  final JournalDraft draft;
  final String retainedEarningsName;
  final bool isDarkMode;

  const _DraftLinesTable({
    required this.draft,
    required this.retainedEarningsName,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final borderColor = isDarkMode ? Colors.white10 : Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusPill(
              icon: Icons.receipt_long_rounded,
              label: draft.reference,
              color: isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey,
              isDarkMode: isDarkMode,
            ),
            _StatusPill(
              icon: Icons.account_balance_wallet_rounded,
              label: retainedEarningsName,
              color: isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _LineHeader(isDarkMode: isDarkMode),
              ...draft.lines
                  .take(6)
                  .map(
                    (line) =>
                        _JournalLineRow(line: line, isDarkMode: isDarkMode),
                  ),
              if (draft.lines.length > 6)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '+${draft.lines.length - 6} more lines',
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              Divider(height: 1, color: borderColor),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Balanced total',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatCurrency(draft.debitTotal),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineHeader extends StatelessWidget {
  final bool isDarkMode;

  const _LineHeader({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Account',
              style: TextStyle(color: mutedColor, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'Debit',
              textAlign: TextAlign.right,
              style: TextStyle(color: mutedColor, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'Credit',
              textAlign: TextAlign.right,
              style: TextStyle(color: mutedColor, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalLineRow extends StatelessWidget {
  final JournalLineDraft line;
  final bool isDarkMode;

  const _JournalLineRow({required this.line, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final borderColor = isDarkMode ? Colors.white10 : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.accountName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor),
            ),
          ),
          _AmountCell(
            amount: line.side == JournalSide.debit ? line.amount : null,
            color: mutedColor,
          ),
          _AmountCell(
            amount: line.side == JournalSide.credit ? line.amount : null,
            color: mutedColor,
          ),
        ],
      ),
    );
  }
}

class _AmountCell extends StatelessWidget {
  final double? amount;
  final Color color;

  const _AmountCell({required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Text(
        amount == null ? '-' : formatCurrency(amount!),
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDarkMode;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
