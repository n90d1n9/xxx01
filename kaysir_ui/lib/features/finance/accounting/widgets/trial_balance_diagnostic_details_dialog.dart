import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/trial_balance.dart';

/// Dialog that lists the ledger rows or accounts behind one diagnostic.
class TrialBalanceDiagnosticDetailsDialog extends StatelessWidget {
  const TrialBalanceDiagnosticDetailsDialog({
    required this.diagnostic,
    this.onReviewLedger,
    super.key,
  });

  final TrialBalanceDiagnostic diagnostic;
  final ValueChanged<TrialBalanceDiagnostic>? onReviewLedger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color =
        diagnostic.isBlocker ? colorScheme.error : colorScheme.tertiary;

    return AlertDialog(
      key: const ValueKey('trial-balance-diagnostic-details-dialog'),
      icon: Icon(
        diagnostic.isBlocker
            ? Icons.error_outline_rounded
            : Icons.info_outline_rounded,
        color: color,
      ),
      title: Text(diagnostic.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diagnostic.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (diagnostic.count != null) ...[
                const SizedBox(height: 10),
                _DiagnosticMetricPill(
                  label: '${diagnostic.count} item(s) flagged',
                  color: color,
                ),
              ],
              if (diagnostic.affectedAccounts.isNotEmpty) ...[
                const SizedBox(height: 16),
                _DiagnosticDetailSection(
                  title: 'Affected accounts',
                  values: diagnostic.affectedAccounts,
                ),
              ],
              if (diagnostic.affectedTransactionIds.isNotEmpty) ...[
                const SizedBox(height: 16),
                _DiagnosticDetailSection(
                  title: 'Ledger rows',
                  values: diagnostic.affectedTransactionIds,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (onReviewLedger != null && diagnostic.hasDetails)
          FilledButton.icon(
            key: const ValueKey('trial-balance-review-ledger-action'),
            onPressed: () {
              Navigator.of(context).pop();
              onReviewLedger?.call(diagnostic);
            },
            icon: const Icon(Icons.receipt_long_rounded, size: 18),
            label: const Text('Review in ledger'),
          ),
      ],
    );
  }
}

/// Compact metric badge for the selected diagnostic detail dialog.
class _DiagnosticMetricPill extends StatelessWidget {
  const _DiagnosticMetricPill({required this.label, required this.color});

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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

/// Wrap-based list section for affected accounts or ledger rows.
class _DiagnosticDetailSection extends StatelessWidget {
  const _DiagnosticDetailSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              values
                  .map(
                    (value) => DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.70,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        child: Text(
                          value,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

@Preview(name: 'Trial balance diagnostic details dialog')
Widget trialBalanceDiagnosticDetailsDialogPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: TrialBalanceDiagnosticDetailsDialog(
          diagnostic: TrialBalanceDiagnostic(
            id: 'missing-references',
            title: 'Missing references',
            message:
                '2 ledger row(s) need source references before close evidence is complete.',
            severity: TrialBalanceDiagnosticSeverity.warning,
            count: 2,
            affectedAccounts: ['1000 Cash', '1100 Bank'],
            affectedTransactionIds: ['JE-2026-001', 'JE-2026-002'],
          ),
        ),
      ),
    ),
  );
}
