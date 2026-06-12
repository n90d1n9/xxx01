import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/bank_reconciliation.dart';
import '../models/bank_reconciliation_control_summary.dart';
import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_register_filter.dart';
import '../models/bank_reconciliation_timing_review.dart';
import '../states/bank_reconciliation_provider.dart';
import 'bank_reconciliation_detail_dialog.dart';
import 'bank_statement_import_dialog.dart';
import 'bank_statement_line_dialog.dart';

class BankReconciliationCard extends ConsumerWidget {
  const BankReconciliationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.watch(bankReconciliationProvider);
    final controlSummary = ref.watch(bankReconciliationControlSummaryProvider);
    final timingRegister = ref.watch(bankReconciliationTimingRegisterProvider);
    final timingSummary = BankReconciliationTimingRegisterSummary.fromItems(
      timingRegister,
    );
    final timingReviewSummary = BankReconciliationTimingReviewSummary.fromItems(
      items: timingRegister,
      reviews: ref.watch(bankReconciliationTimingReviewsProvider),
    );
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    final statusColor = _statusColor(controlSummary.severity);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.account_balance_rounded, color: statusColor),
                Text(
                  'Bank Reconciliation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppStatusPill(
                  label: controlSummary.statusLabel,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                AppActionButton(
                  label: 'Add Statement',
                  icon: Icons.add_rounded,
                  compact: true,
                  onPressed: () => _addStatementLine(context, ref),
                ),
                AppActionButton(
                  label: 'Import CSV',
                  icon: Icons.upload_file_rounded,
                  variant: AppActionButtonVariant.secondary,
                  compact: true,
                  onPressed: () => _importStatementLines(context, ref),
                ),
                AppActionButton(
                  label: 'Detail',
                  icon: Icons.open_in_new_rounded,
                  variant: AppActionButtonVariant.secondary,
                  compact: true,
                  onPressed: () => _showDetail(context),
                ),
                if (reconciliation.statementLines.isNotEmpty)
                  AppActionButton(
                    label: 'Clear',
                    icon: Icons.delete_outline_rounded,
                    variant: AppActionButtonVariant.text,
                    compact: true,
                    onPressed: () => _clearStatementLines(ref),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 720;
                final metrics = [
                  _MetricData(
                    label: 'Statement',
                    value: currency.format(reconciliation.statementMovement),
                  ),
                  _MetricData(
                    label: 'GL Cash/Bank',
                    value: currency.format(reconciliation.ledgerMovement),
                  ),
                  _MetricData(
                    label: 'Variance',
                    value: currency.format(reconciliation.variance),
                    valueColor: statusColor,
                  ),
                  _MetricData(
                    label: 'Unmatched',
                    value: reconciliation.unmatchedCount.toString(),
                    valueColor:
                        reconciliation.hasUnmatchedItems ? statusColor : null,
                  ),
                  _MetricData(
                    label: 'Journal Actions',
                    value: controlSummary.suggestedJournalCount.toString(),
                    valueColor:
                        controlSummary.suggestedJournalCount > 0
                            ? statusColor
                            : null,
                  ),
                  if (controlSummary.timingAging.hasItems)
                    _MetricData(
                      label: 'Timing Aging',
                      value: controlSummary.timingAgingLabel,
                      valueColor: statusColor,
                    ),
                  if (timingSummary.deadlineRiskCount > 0)
                    _MetricData(
                      label: 'Deadline Risk',
                      value:
                          '${timingSummary.overdueCount} overdue / '
                          '${timingSummary.dueSoonCount} due soon',
                      valueColor: _deadlineRiskColor(
                        timingSummary,
                        statusColor,
                      ),
                      tooltip: 'Review timing deadline risk',
                      onTap:
                          () => _showDetail(
                            context,
                            initialTimingFilter:
                                BankReconciliationTimingRegisterFilter
                                    .deadlineRisk,
                          ),
                    ),
                  if (timingReviewSummary.hasItems)
                    _MetricData(
                      label: 'Timing Review',
                      value: timingReviewSummary.coverageLabel,
                      valueColor: _timingReviewColor(
                        timingReviewSummary,
                        statusColor,
                      ),
                      tooltip: 'Review timing evidence',
                      onTap: () => _showDetail(context),
                    ),
                  _MetricData(
                    label: 'Oldest Open',
                    value: controlSummary.oldestUnmatchedAgeLabel,
                    valueColor:
                        controlSummary.hasUnmatchedItems ? statusColor : null,
                  ),
                ];

                if (isCompact) {
                  return Column(
                    children: [
                      for (final metric in metrics) ...[
                        _ReconciliationMetric(metric: metric),
                        if (metric != metrics.last) const SizedBox(height: 10),
                      ],
                    ],
                  );
                }

                const spacing = 12.0;
                final columns = constraints.maxWidth < 980 ? 3 : 4;
                final tileWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                    columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        width: tileWidth,
                        child: _ReconciliationMetric(metric: metric),
                      ),
                  ],
                );
              },
            ),
            if (controlSummary.requiresAttention) ...[
              const SizedBox(height: 12),
              _ControlActionBanner(
                summary: controlSummary,
                timingSummary: timingSummary,
                timingReviewSummary: timingReviewSummary,
                color: statusColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addStatementLine(BuildContext context, WidgetRef ref) async {
    final line = await showDialog<BankStatementLine>(
      context: context,
      builder: (context) => const BankStatementLineDialog(),
    );
    if (line == null) {
      return;
    }
    ref.read(bankStatementLinesProvider.notifier).addLine(line);
  }

  Future<void> _importStatementLines(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final lines = await showDialog<List<BankStatementLine>>(
      context: context,
      builder:
          (context) => BankStatementImportDialog(
            service: ref.read(bankStatementImportServiceProvider),
            existingLines: ref.read(bankStatementLinesProvider),
          ),
    );
    if (lines == null || lines.isEmpty) {
      return;
    }
    ref.read(bankStatementLinesProvider.notifier).addLines(lines);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported ${lines.length} statement line(s)')),
    );
  }

  void _clearStatementLines(WidgetRef ref) {
    ref.read(bankStatementLinesProvider.notifier).clear();
  }

  void _showDetail(
    BuildContext context, {
    BankReconciliationTimingRegisterFilter initialTimingFilter =
        BankReconciliationTimingRegisterFilter.all,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => BankReconciliationDetailDialog(
            initialTimingFilter: initialTimingFilter,
          ),
    );
  }

  Color _statusColor(BankReconciliationControlSeverity severity) {
    switch (severity) {
      case BankReconciliationControlSeverity.needsEvidence:
        return Colors.blueGrey;
      case BankReconciliationControlSeverity.ready:
        return Colors.teal;
      case BankReconciliationControlSeverity.postAdjustments:
        return Colors.deepOrange;
      case BankReconciliationControlSeverity.timingReview:
        return Colors.amber.shade800;
      case BankReconciliationControlSeverity.investigate:
        return Colors.redAccent;
    }
  }

  Color _deadlineRiskColor(
    BankReconciliationTimingRegisterSummary summary,
    Color fallback,
  ) {
    if (summary.overdueCount > 0) {
      return Colors.redAccent;
    }
    if (summary.dueSoonCount > 0) {
      return Colors.amber.shade800;
    }
    return fallback;
  }

  Color _timingReviewColor(
    BankReconciliationTimingReviewSummary summary,
    Color fallback,
  ) {
    if (summary.unresolvedOverdueCount > 0) {
      return Colors.redAccent;
    }
    if (summary.hasReviewGaps) {
      return Colors.amber.shade800;
    }
    if (summary.hasItems) {
      return Colors.teal.shade700;
    }
    return fallback;
  }
}

class _ControlActionBanner extends StatelessWidget {
  final BankReconciliationControlSummary summary;
  final BankReconciliationTimingRegisterSummary timingSummary;
  final BankReconciliationTimingReviewSummary timingReviewSummary;
  final Color color;

  const _ControlActionBanner({
    required this.summary,
    required this.timingSummary,
    required this.timingReviewSummary,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.priority_high_rounded, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summary.nextAction,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (summary.hasStaleUnmatchedItems)
                    AppStatusPill(label: 'Stale item', color: color),
                  if (summary.timingAging.hasWatchItems)
                    AppStatusPill(label: 'Watch timing', color: color),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconciliationMetric extends StatelessWidget {
  final _MetricData metric;

  const _ReconciliationMetric({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(8);

    final metricTile = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(metric.label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                metric.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: metric.valueColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (metric.onTap == null) {
      return metricTile;
    }

    return Tooltip(
      message: metric.tooltip ?? 'Open detail',
      child: Semantics(
        button: true,
        label: metric.tooltip ?? '${metric.label} ${metric.value}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: metric.onTap,
            child: metricTile,
          ),
        ),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final Color? valueColor;
  final String? tooltip;
  final VoidCallback? onTap;

  const _MetricData({
    required this.label,
    required this.value,
    this.valueColor,
    this.tooltip,
    this.onTap,
  });
}
