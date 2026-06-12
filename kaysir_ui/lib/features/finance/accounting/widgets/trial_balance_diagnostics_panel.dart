import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../models/trial_balance.dart';
import 'trial_balance_diagnostic_details_dialog.dart';

/// Compact diagnostics panel for trial balance blockers and warnings.
class TrialBalanceDiagnosticsPanel extends StatelessWidget {
  const TrialBalanceDiagnosticsPanel({
    required this.report,
    this.onReviewLedger,
    super.key,
  });

  final TrialBalanceReport report;
  final ValueChanged<TrialBalanceDiagnostic>? onReviewLedger;

  @override
  Widget build(BuildContext context) {
    if (!report.hasDiagnostics) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: const ValueKey('trial-balance-diagnostics-panel'),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Review diagnostics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _CountPill(
                  label: '${report.blockerCount} blocker',
                  color: colorScheme.error,
                ),
                const SizedBox(width: 8),
                _CountPill(
                  label: '${report.warningCount} warning',
                  color: colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final diagnostic in report.diagnostics)
              _DiagnosticRow(
                diagnostic: diagnostic,
                onReviewLedger: onReviewLedger,
              ),
          ],
        ),
      ),
    );
  }
}

/// One compact diagnostic row with optional drill-down action.
class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({required this.diagnostic, this.onReviewLedger});

  final TrialBalanceDiagnostic diagnostic;
  final ValueChanged<TrialBalanceDiagnostic>? onReviewLedger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color =
        diagnostic.isBlocker ? colorScheme.error : colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            diagnostic.isBlocker
                ? Icons.error_outline_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        diagnostic.title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (diagnostic.amount != null)
                      Text(
                        _formatIdr(diagnostic.amount!),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    else if (diagnostic.count != null)
                      Text(
                        '${diagnostic.count}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  diagnostic.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (diagnostic.hasDetails) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: ValueKey(
                        'trial-balance-diagnostic-details-${diagnostic.id}',
                      ),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder:
                              (context) => TrialBalanceDiagnosticDetailsDialog(
                                diagnostic: diagnostic,
                                onReviewLedger: onReviewLedger,
                              ),
                        );
                      },
                      icon: const Icon(Icons.manage_search_rounded, size: 16),
                      label: const Text('Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
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

/// Small count badge used in the trial balance diagnostics header.
class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

String _formatIdr(double value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);
}

@Preview(name: 'Trial balance diagnostics panel')
Widget trialBalanceDiagnosticsPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TrialBalanceDiagnosticsPanel(
          report: TrialBalanceReport(
            transactions: const [],
            rows: const [],
            summary: const TrialBalanceSummary(
              accountCount: 0,
              totalDebits: 100,
              totalCredits: 80,
              variance: 20,
              isBalanced: false,
            ),
            closeChecks: const [],
            diagnostics: const [
              TrialBalanceDiagnostic(
                id: 'trial-balance-variance',
                title: 'Trial balance variance',
                message:
                    'Closing debit and credit balances do not tie. Review unmatched journals.',
                severity: TrialBalanceDiagnosticSeverity.blocker,
                amount: 20,
                affectedAccounts: ['1000 Cash', '4000 Revenue'],
              ),
              TrialBalanceDiagnostic(
                id: 'missing-references',
                title: 'Missing references',
                message: '2 ledger row(s) need source references.',
                severity: TrialBalanceDiagnosticSeverity.warning,
                count: 2,
                affectedAccounts: ['1000 Cash'],
                affectedTransactionIds: ['JE-2026-001', 'JE-2026-002'],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
