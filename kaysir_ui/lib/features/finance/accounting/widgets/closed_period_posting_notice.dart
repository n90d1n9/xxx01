import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_period_close.dart';

class ClosedPeriodPostingNotice extends StatelessWidget {
  final FinancialPeriodCloseRecord? closeRecord;
  final String actionLabel;
  final EdgeInsetsGeometry margin;

  const ClosedPeriodPostingNotice({
    required this.closeRecord,
    required this.actionLabel,
    this.margin = const EdgeInsets.only(top: 12),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final record = closeRecord;
    if (record == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final periodEnd = record.periodEnd;
    final closedThrough =
        periodEnd == null
            ? record.periodLabel
            : DateFormat('MMM d, yyyy').format(periodEnd);

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.62),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.22)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_clock_outlined, color: colorScheme.error),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Closed period',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.periodLabel} is locked through $closedThrough. Reopen the period before you $actionLabel.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
