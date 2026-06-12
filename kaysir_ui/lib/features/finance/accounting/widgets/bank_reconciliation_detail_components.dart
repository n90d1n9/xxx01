import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../accounting_core/models/journal_entry.dart';
import '../models/bank_reconciliation.dart';
import '../models/bank_reconciliation_control_summary.dart';
import '../models/bank_reconciliation_journal_draft.dart';
import '../models/bank_reconciliation_resolution.dart';
import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_review.dart';
import 'reconciliation_detail_components.dart';

class BankReconciliationSectionHeader extends StatelessWidget {
  const BankReconciliationSectionHeader({
    required this.title,
    required this.trailing,
    this.icon,
    super.key,
  });

  final String title;
  final String trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              trailing,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BankReconciliationControlHealthPanel extends StatelessWidget {
  const BankReconciliationControlHealthPanel({
    required this.summary,
    required this.timingSummary,
    required this.timingReviewSummary,
    required this.dateFormat,
    required this.statusColor,
    super.key,
  });

  final BankReconciliationControlSummary summary;
  final BankReconciliationTimingRegisterSummary timingSummary;
  final BankReconciliationTimingReviewSummary timingReviewSummary;
  final DateFormat dateFormat;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      key: const Key('bank-reconciliation-control-health-strip'),
      color: statusColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: statusColor.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReconciliationMetricStrip(maxColumns: 4, metrics: _metrics),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.task_alt_rounded, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.nextAction,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (summary.hasStaleUnmatchedItems)
                      AppStatusPill(label: 'Stale item', color: statusColor),
                    if (timingSummary.overdueCount > 0)
                      const AppStatusPill(
                        label: 'Overdue timing',
                        color: Colors.redAccent,
                      )
                    else if (timingSummary.dueSoonCount > 0)
                      AppStatusPill(
                        label: 'Due soon timing',
                        color: Colors.amber.shade800,
                      ),
                    if (timingReviewSummary.unresolvedOverdueCount > 0)
                      const AppStatusPill(
                        label: 'Overdue review',
                        color: Colors.redAccent,
                      )
                    else if (timingReviewSummary.hasReviewGaps)
                      AppStatusPill(
                        label: 'Review gaps',
                        color: Colors.amber.shade800,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<ReconciliationMetricData> get _metrics {
    final nextDeadlineItem = timingSummary.nextDeadlineItem;

    return [
      ReconciliationMetricData(
        label: 'Control Status',
        value: summary.statusLabel,
        helper: 'Close readiness',
        icon: Icons.fact_check_outlined,
        accentColor: statusColor,
      ),
      ReconciliationMetricData(
        label: 'Suggested Journals',
        value: summary.suggestedJournalCount.toString(),
        helper: 'Adjustment drafts',
        icon: Icons.post_add_rounded,
        accentColor:
            summary.suggestedJournalCount > 0 ? statusColor : Colors.blueGrey,
      ),
      ReconciliationMetricData(
        label: 'Timing Items',
        value: summary.timingDifferenceCount.toString(),
        helper: 'Open timing gaps',
        icon: Icons.schedule_outlined,
        accentColor:
            summary.timingDifferenceCount > 0 ? statusColor : Colors.blueGrey,
      ),
      if (timingReviewSummary.hasItems)
        ReconciliationMetricData(
          label: 'Timing Review',
          value: timingReviewSummary.coverageLabel,
          helper: timingReviewSummary.nextActionLabel,
          icon: Icons.assignment_turned_in_outlined,
          accentColor: _reviewCoverageColor,
        ),
      if (summary.timingAging.hasItems)
        ReconciliationMetricData(
          label: 'Timing Aging',
          value: summary.timingAgingLabel,
          helper: 'Current / watch / stale',
          icon: Icons.history_toggle_off_rounded,
          accentColor: statusColor,
        ),
      if (timingSummary.hasDeadlineRisk)
        ReconciliationMetricData(
          label: 'Deadline Risk',
          value:
              '${timingSummary.overdueCount} overdue / '
              '${timingSummary.dueSoonCount} due soon',
          helper: 'Clear-by exposure',
          icon: Icons.event_busy_outlined,
          accentColor: _deadlineRiskColor,
        ),
      if (nextDeadlineItem != null)
        ReconciliationMetricData(
          label: 'Next Clear By',
          value:
              '${nextDeadlineItem.reference} by '
              '${dateFormat.format(nextDeadlineItem.clearByDate)}',
          helper: 'Earliest risk item',
          icon: Icons.event_available_outlined,
          accentColor: _deadlineRiskColor,
        ),
      ReconciliationMetricData(
        label: 'Oldest Open',
        value: summary.oldestUnmatchedAgeLabel,
        helper: 'Unmatched age',
        icon: Icons.timelapse_outlined,
        accentColor: summary.hasUnmatchedItems ? statusColor : Colors.blueGrey,
      ),
    ];
  }

  Color get _deadlineRiskColor {
    if (timingSummary.overdueCount > 0) {
      return Colors.redAccent;
    }
    if (timingSummary.dueSoonCount > 0) {
      return Colors.amber.shade800;
    }
    return statusColor;
  }

  Color get _reviewCoverageColor {
    if (timingReviewSummary.unresolvedOverdueCount > 0) {
      return Colors.redAccent;
    }
    if (timingReviewSummary.hasReviewGaps) {
      return Colors.amber.shade800;
    }
    return Colors.teal.shade700;
  }
}

class BankReconciliationTotalsPanel extends StatelessWidget {
  const BankReconciliationTotalsPanel({
    required this.reconciliation,
    required this.currency,
    required this.statusColor,
    super.key,
  });

  final BankReconciliation reconciliation;
  final NumberFormat currency;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return ReconciliationMetricStrip(
      maxColumns: 4,
      metrics: [
        ReconciliationMetricData(
          label: 'Statement',
          value: currency.format(reconciliation.statementMovement),
          helper: 'Imported bank evidence',
          icon: Icons.receipt_long_outlined,
          accentColor: Colors.teal.shade700,
        ),
        ReconciliationMetricData(
          label: 'GL Cash/Bank',
          value: currency.format(reconciliation.ledgerMovement),
          helper: 'Posted ledger movement',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Theme.of(context).colorScheme.primary,
        ),
        ReconciliationMetricData(
          label: 'Variance',
          value: currency.format(reconciliation.variance),
          helper:
              reconciliation.isBalanced ? 'Within tolerance' : 'Needs action',
          icon:
              reconciliation.isBalanced
                  ? Icons.verified_outlined
                  : Icons.warning_amber_rounded,
          accentColor: statusColor,
        ),
        ReconciliationMetricData(
          label: 'Unmatched',
          value: reconciliation.unmatchedCount.toString(),
          helper: 'Statement + ledger rows',
          icon: Icons.manage_search_outlined,
          accentColor:
              reconciliation.hasUnmatchedItems ? statusColor : Colors.blueGrey,
        ),
      ],
    );
  }
}

class BankStatementManagementTable extends StatelessWidget {
  const BankStatementManagementTable({
    required this.lines,
    required this.currency,
    required this.dateFormat,
    required this.onRemove,
    super.key,
  });

  final List<BankStatementLine> lines;
  final NumberFormat currency;
  final DateFormat dateFormat;
  final ValueChanged<BankStatementLine> onRemove;

  @override
  Widget build(BuildContext context) {
    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Action')),
        ],
        rows: [
          for (final line in lines)
            DataRow(
              cells: [
                DataCell(Text(dateFormat.format(line.date))),
                DataCell(Text(line.reference ?? '-')),
                DataCell(Text(line.description)),
                DataCell(Text(currency.format(line.amount))),
                DataCell(
                  IconButton(
                    tooltip: 'Remove statement line',
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => onRemove(line),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class BankResolutionActionTable extends StatelessWidget {
  const BankResolutionActionTable({
    required this.actions,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<BankReconciliationResolutionAction> actions;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Suggested Action')),
        ],
        rows: [
          for (final action in actions)
            DataRow(
              cells: [
                DataCell(Text(action.type.label)),
                DataCell(Text(dateFormat.format(action.date))),
                DataCell(Text(action.reference)),
                DataCell(Text(currency.format(action.amount))),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(action.title),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class BankJournalDraftSuggestionTable extends StatelessWidget {
  const BankJournalDraftSuggestionTable({
    required this.suggestions,
    required this.currency,
    required this.onPost,
    super.key,
  });

  final List<BankReconciliationJournalDraftSuggestion> suggestions;
  final NumberFormat currency;
  final ValueChanged<BankReconciliationJournalDraftSuggestion> onPost;

  @override
  Widget build(BuildContext context) {
    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Action')),
          DataColumn(label: Text('Debit')),
          DataColumn(label: Text('Credit')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Status')),
        ],
        rows: [
          for (final suggestion in suggestions)
            DataRow(
              cells: [
                DataCell(Text(suggestion.action.reference)),
                DataCell(
                  TextButton.icon(
                    icon: const Icon(Icons.post_add_rounded),
                    label: const Text('Post'),
                    onPressed:
                        suggestion.isPostable ? () => onPost(suggestion) : null,
                  ),
                ),
                DataCell(Text(_lineAccount(suggestion, debit: true))),
                DataCell(Text(_lineAccount(suggestion, debit: false))),
                DataCell(Text(currency.format(suggestion.action.amount.abs()))),
                DataCell(
                  AppStatusPill(
                    label: _statusText(suggestion),
                    color: _statusColor(suggestion),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _lineAccount(
    BankReconciliationJournalDraftSuggestion suggestion, {
    required bool debit,
  }) {
    final draft = suggestion.draft;
    if (draft == null) {
      return '-';
    }

    final side = debit ? JournalSide.debit : JournalSide.credit;
    for (final line in draft.lines) {
      if (line.side == side) {
        return line.accountName;
      }
    }
    return '-';
  }

  Color _statusColor(BankReconciliationJournalDraftSuggestion suggestion) {
    if (suggestion.isPosted) {
      return Colors.teal;
    }
    if (suggestion.isReady) {
      return Colors.blueGrey;
    }
    return Colors.deepOrange;
  }

  String _statusText(BankReconciliationJournalDraftSuggestion suggestion) {
    if (suggestion.issues.isEmpty) {
      return suggestion.statusLabel;
    }
    return suggestion.issues.join(', ');
  }
}

class BankMatchReconciliationTable extends StatelessWidget {
  const BankMatchReconciliationTable({
    required this.matches,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<BankReconciliationMatch> matches;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No matched bank activity',
        icon: Icons.link_off_outlined,
      );
    }

    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Statement Date')),
          DataColumn(label: Text('Statement Ref')),
          DataColumn(label: Text('Ledger Ref')),
          DataColumn(label: Text('Match')),
          DataColumn(label: Text('Amount'), numeric: true),
        ],
        rows: [
          for (final match in matches)
            DataRow(
              cells: [
                DataCell(Text(dateFormat.format(match.statementLine.date))),
                DataCell(Text(match.statementLine.reference ?? '-')),
                DataCell(Text(match.ledgerLine.reference)),
                DataCell(Text(match.matchType.label)),
                DataCell(Text(currency.format(match.statementLine.amount))),
              ],
            ),
        ],
      ),
    );
  }
}

class BankStatementReconciliationTable extends StatelessWidget {
  const BankStatementReconciliationTable({
    required this.lines,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<BankStatementLine> lines;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No unmatched statement lines',
        icon: Icons.receipt_long_outlined,
      );
    }

    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount'), numeric: true),
        ],
        rows: [
          for (final line in lines)
            DataRow(
              cells: [
                DataCell(Text(dateFormat.format(line.date))),
                DataCell(Text(line.reference ?? '-')),
                DataCell(Text(line.description)),
                DataCell(Text(currency.format(line.amount))),
              ],
            ),
        ],
      ),
    );
  }
}

class BankLedgerReconciliationTable extends StatelessWidget {
  const BankLedgerReconciliationTable({
    required this.lines,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<BankLedgerReconciliationLine> lines;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No unmatched cash ledger rows',
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Account')),
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Amount'), numeric: true),
        ],
        rows: [
          for (final line in lines)
            DataRow(
              cells: [
                DataCell(Text(dateFormat.format(line.date))),
                DataCell(Text(line.account)),
                DataCell(Text(line.reference)),
                DataCell(Text(currency.format(line.signedAmount))),
              ],
            ),
        ],
      ),
    );
  }
}
