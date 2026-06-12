import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/vendor_statement.dart';

class VendorStatementSummaryGrid extends StatelessWidget {
  const VendorStatementSummaryGrid({
    required this.statement,
    required this.currency,
    super.key,
  });

  final VendorStatement statement;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppMetricGrid(
      minTileWidth: 150,
      maxColumns: 5,
      metrics: [
        AppMetricGridItem(
          title: 'Outstanding',
          value: currency.format(statement.outstandingAmount),
          icon: Icons.account_balance_wallet_outlined,
          accentColor: colorScheme.primary,
        ),
        AppMetricGridItem(
          title: 'Overdue',
          value: currency.format(statement.overdueAmount),
          icon: Icons.warning_amber_rounded,
          accentColor: colorScheme.error,
        ),
        AppMetricGridItem(
          title: 'Billed',
          value: currency.format(statement.totalBilled),
          icon: Icons.receipt_long_outlined,
          accentColor: Colors.indigo.shade600,
        ),
        AppMetricGridItem(
          title: 'Paid',
          value: currency.format(statement.totalPaid),
          icon: Icons.payments_outlined,
          accentColor: Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Open Bills',
          value: statement.openBillCount.toString(),
          icon: Icons.pending_actions_outlined,
          accentColor: Colors.orange.shade700,
        ),
      ],
    );
  }
}

class VendorStatementLineList extends StatelessWidget {
  const VendorStatementLineList({
    required this.statement,
    required this.currency,
    super.key,
  });

  final VendorStatement statement;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          statement.lines.isEmpty
              ? const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No payable activity',
                message: 'Bills and payments for this vendor will appear here.',
              )
              : Scrollbar(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: statement.lines.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 8),
                  itemBuilder:
                      (context, index) => _VendorStatementLineTile(
                        line: statement.lines[index],
                        currency: currency,
                      ),
                ),
              ),
    );
  }
}

class _VendorStatementLineTile extends StatelessWidget {
  const _VendorStatementLineTile({required this.line, required this.currency});

  final VendorStatementLine line;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = _styleForLine(context, line.type);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconBadge(
              icon: style.icon,
              size: 40,
              backgroundColor: style.color.withValues(alpha: 0.12),
              foregroundColor: style.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        line.reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppStatusPill(
                        label: style.label,
                        icon: style.icon,
                        color: style.color,
                        maxWidth: 130,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${dateFormat.format(line.date)} - ${line.description}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _VendorStatementAmountBlock(line: line, currency: currency),
          ],
        ),
      ),
    );
  }
}

class _VendorStatementAmountBlock extends StatelessWidget {
  const _VendorStatementAmountBlock({
    required this.line,
    required this.currency,
  });

  final VendorStatementLine line;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _primaryAmountLabel(line),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _primaryAmount(line),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Balance ${currency.format(line.balance)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _primaryAmountLabel(VendorStatementLine line) {
    return line.paymentAmount > 0 ? 'Payment' : 'Charge';
  }

  String _primaryAmount(VendorStatementLine line) {
    final amount =
        line.paymentAmount > 0 ? line.paymentAmount : line.chargeAmount;
    if (amount == 0) {
      return '-';
    }
    return currency.format(amount);
  }
}

class _VendorStatementLineStyle {
  const _VendorStatementLineStyle({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

_VendorStatementLineStyle _styleForLine(
  BuildContext context,
  VendorStatementLineType type,
) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (type) {
    case VendorStatementLineType.bill:
      return _VendorStatementLineStyle(
        label: 'Bill',
        icon: Icons.receipt_long_outlined,
        color: colorScheme.primary,
      );
    case VendorStatementLineType.payment:
      return _VendorStatementLineStyle(
        label: 'Payment',
        icon: Icons.payments_outlined,
        color: Colors.green.shade700,
      );
  }
}
