import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/bank_reconciliation.dart';
import '../services/bank_statement_import_service.dart';

enum BankStatementLineDirection { deposit, withdrawal }

class BankStatementDialogHeader extends StatelessWidget {
  const BankStatementDialogHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: icon,
          size: 44,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppTextCluster(
            title: title,
            subtitle: subtitle,
            titleStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class BankStatementLineDirectionField extends StatelessWidget {
  const BankStatementLineDirectionField({
    required this.direction,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final BankStatementLineDirection direction;
  final bool enabled;
  final ValueChanged<BankStatementLineDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<BankStatementLineDirection>(
      label: 'Type',
      value: direction,
      icon: Icons.swap_vert_rounded,
      enabled: enabled,
      options: const [
        AppSelectOption(
          value: BankStatementLineDirection.deposit,
          label: 'Deposit',
        ),
        AppSelectOption(
          value: BankStatementLineDirection.withdrawal,
          label: 'Withdrawal',
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class BankStatementLineAmountFields extends StatelessWidget {
  const BankStatementLineAmountFields({
    required this.direction,
    required this.amountController,
    required this.enabled,
    required this.onDirectionChanged,
    required this.amountValidator,
    super.key,
  });

  final BankStatementLineDirection direction;
  final TextEditingController amountController;
  final bool enabled;
  final ValueChanged<BankStatementLineDirection> onDirectionChanged;
  final FormFieldValidator<String> amountValidator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final directionField = BankStatementLineDirectionField(
          direction: direction,
          enabled: enabled,
          onChanged: onDirectionChanged,
        );
        final amountField = TextFormField(
          controller: amountController,
          enabled: enabled,
          decoration: bankStatementInputDecoration(
            context,
            label: 'Amount',
            icon: Icons.attach_money_rounded,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: amountValidator,
        );

        if (constraints.maxWidth < 420) {
          return Column(
            children: [directionField, const SizedBox(height: 12), amountField],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: directionField),
            const SizedBox(width: 12),
            Expanded(child: amountField),
          ],
        );
      },
    );
  }
}

class BankStatementImportSummary extends StatelessWidget {
  const BankStatementImportSummary({required this.result, super.key});

  final BankStatementImportResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final netColor =
        result.netMovement < 0 ? Colors.deepOrange : colorScheme.primary;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ImportMetric(
              label: 'Importable',
              value: result.lines.length.toString(),
              icon: Icons.check_circle_outline_rounded,
              color: colorScheme.primary,
            ),
            _ImportMetric(
              label: 'Net Movement',
              value: currency.format(result.netMovement),
              icon: Icons.account_balance_wallet_outlined,
              color:
                  result.lines.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : netColor,
            ),
            _ImportMetric(
              label: 'Deposits',
              value: result.depositCount.toString(),
              icon: Icons.south_west_rounded,
              color:
                  result.depositCount == 0
                      ? colorScheme.onSurfaceVariant
                      : Colors.teal.shade700,
            ),
            _ImportMetric(
              label: 'Withdrawals',
              value: result.withdrawalCount.toString(),
              icon: Icons.north_east_rounded,
              color:
                  result.withdrawalCount == 0
                      ? colorScheme.onSurfaceVariant
                      : Colors.deepOrange,
            ),
            _ImportMetric(
              label: 'Review',
              value: result.issues.length.toString(),
              icon: Icons.rule_folder_outlined,
              color:
                  result.issues.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class BankStatementImportPreview extends StatelessWidget {
  const BankStatementImportPreview({required this.lines, super.key});

  final List<BankStatementLine> lines;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd/yyyy');
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 48,
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
      ),
    );
  }
}

class BankStatementImportIssues extends StatelessWidget {
  const BankStatementImportIssues({required this.issues, super.key});

  final List<BankStatementImportIssue> issues;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.error.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            for (final issue in issues)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  issue.rowNumber == 0
                      ? issue.message
                      : 'Row ${issue.rowNumber}: ${issue.message}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

InputDecoration bankStatementInputDecoration(
  BuildContext context, {
  required String label,
  IconData? icon,
  String? hintText,
  bool alignLabelWithHint = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    labelText: label,
    hintText: hintText,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: icon == null ? null : Icon(icon, size: 18),
    filled: true,
    fillColor: colorScheme.surface,
    border: border,
    enabledBorder: border,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

class _ImportMetric extends StatelessWidget {
  const _ImportMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: AppInfoRow(
        title: value,
        subtitle: label,
        icon: icon,
        iconStyle: AppInfoRowIconStyle.badge,
        iconBoxSize: 34,
        iconSize: 17,
        contained: true,
        iconBackgroundColor: color.withValues(alpha: 0.12),
        iconForegroundColor: color,
        titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
