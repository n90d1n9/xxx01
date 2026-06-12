import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/services/chart_of_accounts_validator.dart';

/// Summary strip for chart-of-accounts setup health.
class ChartOfAccountsSummaryStrip extends StatelessWidget {
  const ChartOfAccountsSummaryStrip({
    required this.accounts,
    required this.validation,
    super.key,
  });

  final List<AccountingAccount> accounts;
  final ChartOfAccountsValidationResult validation;

  @override
  Widget build(BuildContext context) {
    final activeCount = accounts.where((account) => account.isActive).length;
    final postingCount =
        accounts
            .where((account) => account.isActive && account.allowPosting)
            .length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricTile(
          label: 'Accounts',
          value: accounts.length.toString(),
          icon: Icons.account_tree_rounded,
        ),
        _MetricTile(
          label: 'Active',
          value: activeCount.toString(),
          icon: Icons.check_circle_outline_rounded,
        ),
        _MetricTile(
          label: 'Postable',
          value: postingCount.toString(),
          icon: Icons.edit_note_rounded,
        ),
        _MetricTile(
          label: 'Issues',
          value: validation.issues.length.toString(),
          icon:
              validation.isValid
                  ? Icons.verified_outlined
                  : Icons.warning_amber_rounded,
          isWarning: !validation.isValid,
        ),
      ],
    );
  }
}

/// Search and command row for the chart-of-accounts workspace.
class ChartOfAccountsToolbar extends StatelessWidget {
  const ChartOfAccountsToolbar({
    required this.controller,
    required this.onQueryChanged,
    required this.onAddAccount,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onAddAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('chart-of-accounts-search'),
            decoration: const InputDecoration(
              labelText: 'Search code, name, type, tag',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            controller: controller,
            onChanged: onQueryChanged,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          key: const ValueKey('chart-of-accounts-add'),
          onPressed: onAddAccount,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add account'),
        ),
      ],
    );
  }
}

/// Validation issue panel for chart-of-accounts setup readiness.
class ChartOfAccountsValidationPanel extends StatelessWidget {
  const ChartOfAccountsValidationPanel({required this.validation, super.key});

  final ChartOfAccountsValidationResult validation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final issues = validation.issues;
    if (issues.isEmpty) {
      return DecoratedBox(
        key: const ValueKey('chart-of-accounts-validation-ok'),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.verified_rounded),
              SizedBox(width: 8),
              Expanded(child: Text('Chart setup is ready for posting.')),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      key: const ValueKey('chart-of-accounts-validation-issues'),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${validation.errorCount} error(s), '
              '${validation.warningCount} warning(s)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final issue in issues.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      issue.isError
                          ? Icons.error_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color:
                          issue.isError
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(issue.message)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grouped list section for one account type in the chart.
class ChartOfAccountsTypeSection extends StatelessWidget {
  const ChartOfAccountsTypeSection({
    required this.type,
    required this.accounts,
    required this.onToggleActive,
    super.key,
  });

  final AccountingAccountType type;
  final List<AccountingAccount> accounts;
  final ValueChanged<AccountingAccount> onToggleActive;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${type.label} (${accounts.length})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        for (final account in accounts)
          ChartOfAccountsRow(
            account: account,
            onToggleActive: () => onToggleActive(account),
          ),
      ],
    );
  }
}

/// Dense account row for CoA review and activation controls.
class ChartOfAccountsRow extends StatelessWidget {
  const ChartOfAccountsRow({
    required this.account,
    required this.onToggleActive,
    super.key,
  });

  final AccountingAccount account;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: ValueKey('chart-of-accounts-row-${account.id}'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              child: Text(
                account.code,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _InfoChip(label: account.normalBalance.label),
                      _InfoChip(label: account.effectiveReportSection.label),
                      _InfoChip(label: account.cashFlowCategory.label),
                      if (account.taxTag case final taxTag?)
                        _InfoChip(label: taxTag),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusChip(
              label: account.isActive ? 'Active' : 'Inactive',
              isPositive: account.isActive,
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip:
                  account.isActive ? 'Deactivate account' : 'Activate account',
              onPressed: onToggleActive,
              icon: Icon(
                account.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for creating a chart-of-accounts record.
class ChartOfAccountsAccountDialog extends StatefulWidget {
  const ChartOfAccountsAccountDialog({
    required this.existingAccounts,
    required this.onSubmit,
    super.key,
  });

  final List<AccountingAccount> existingAccounts;
  final ValueChanged<AccountingAccount> onSubmit;

  @override
  State<ChartOfAccountsAccountDialog> createState() =>
      _ChartOfAccountsAccountDialogState();
}

class _ChartOfAccountsAccountDialogState
    extends State<ChartOfAccountsAccountDialog> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _currencyController = TextEditingController(text: 'IDR');
  final _taxTagController = TextEditingController();
  AccountingAccountType _type = AccountingAccountType.asset;
  AccountingReportSection? _reportSection;
  AccountingCashFlowCategory _cashFlowCategory =
      AccountingCashFlowCategory.none;
  bool _allowPosting = true;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _currencyController.dispose();
    _taxTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add account'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorText case final errorText?) ...[
                Text(
                  errorText,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 10),
              ],
              TextField(
                key: const ValueKey('chart-of-accounts-code-field'),
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Account code',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey('chart-of-accounts-name-field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AccountingAccountType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Account type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final type in AccountingAccountType.values)
                    DropdownMenuItem(value: type, child: Text(type.label)),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _type = value;
                    _reportSection = value.defaultReportSection;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AccountingReportSection>(
                initialValue: _reportSection ?? _type.defaultReportSection,
                decoration: const InputDecoration(
                  labelText: 'Report section',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final section in AccountingReportSection.values)
                    DropdownMenuItem(
                      value: section,
                      child: Text(section.label),
                    ),
                ],
                onChanged: (value) => setState(() => _reportSection = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AccountingCashFlowCategory>(
                initialValue: _cashFlowCategory,
                decoration: const InputDecoration(
                  labelText: 'Cash-flow category',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final category in AccountingCashFlowCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _cashFlowCategory = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _currencyController,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _taxTagController,
                decoration: const InputDecoration(
                  labelText: 'Tax tag',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _allowPosting,
                title: const Text('Allow direct posting'),
                onChanged: (value) => setState(() => _allowPosting = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('chart-of-accounts-save-account'),
          onPressed: _submit,
          child: const Text('Save account'),
        ),
      ],
    );
  }

  void _submit() {
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    if (code.isEmpty || name.isEmpty) {
      setState(() => _errorText = 'Enter an account code and name.');
      return;
    }
    if (widget.existingAccounts.any((account) => account.code == code)) {
      setState(() => _errorText = 'Account code already exists.');
      return;
    }

    widget.onSubmit(
      AccountingAccount(
        id: 'custom-$code',
        code: code,
        name: name,
        type: _type,
        allowPosting: _allowPosting,
        reportSection: _reportSection ?? _type.defaultReportSection,
        cashFlowCategory: _cashFlowCategory,
        currencyCode: _currencyController.text.trim().toUpperCase(),
        taxTag:
            _taxTagController.text.trim().isEmpty
                ? null
                : _taxTagController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isWarning ? colorScheme.error : colorScheme.primary;

    return SizedBox(
      width: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelMedium),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor:
          isPositive
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest,
    );
  }
}

@Preview(name: 'Chart of accounts components')
Widget chartOfAccountsComponentsPreview() {
  const accounts = [
    AccountingAccount(
      id: 'cash',
      code: '1000',
      name: 'Cash and bank',
      type: AccountingAccountType.asset,
      cashFlowCategory: AccountingCashFlowCategory.operating,
    ),
    AccountingAccount(
      id: 'revenue',
      code: '4000',
      name: 'Sales revenue',
      type: AccountingAccountType.revenue,
      taxTag: 'PPN keluaran / revenue',
    ),
  ];

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ChartOfAccountsSummaryStrip(
              accounts: accounts,
              validation: ChartOfAccountsValidationResult(issues: const []),
            ),
            const SizedBox(height: 12),
            ChartOfAccountsTypeSection(
              type: AccountingAccountType.asset,
              accounts: [accounts.first],
              onToggleActive: (_) {},
            ),
          ],
        ),
      ),
    ),
  );
}
