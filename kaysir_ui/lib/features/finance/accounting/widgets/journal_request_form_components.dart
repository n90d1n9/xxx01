import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';
import '../models/journal_approval.dart';
import '../models/journal_request_form.dart';
import '../services/journal_request_service.dart';

/// Dialog for preparing a balanced journal request before approval review.
class JournalRequestDialog extends StatefulWidget {
  const JournalRequestDialog({
    required this.accounts,
    required this.service,
    required this.onSubmit,
    super.key,
  });

  final List<AccountingAccount> accounts;
  final JournalRequestService service;
  final ValueChanged<JournalApprovalRequest> onSubmit;

  @override
  State<JournalRequestDialog> createState() => _JournalRequestDialogState();
}

class _JournalRequestDialogState extends State<JournalRequestDialog> {
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _preparerController = TextEditingController(text: 'Accounting staff');
  final _reviewerController = TextEditingController(text: 'Controller');
  final _evidenceController = TextEditingController();
  final _lineStates = <_JournalRequestLineState>[];
  JournalSource _source = JournalSource.manualAdjustment;
  JournalRequestValidationResult? _validation;

  List<AccountingAccount> get _postingAccounts {
    return widget.accounts
        .where((account) => account.isActive && account.allowPosting)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    final accounts = _postingAccounts;
    _lineStates.addAll([
      _JournalRequestLineState(
        accountId: accounts.isEmpty ? null : accounts.first.id,
        side: JournalSide.debit,
      ),
      _JournalRequestLineState(
        accountId: accounts.length < 2 ? null : accounts[1].id,
        side: JournalSide.credit,
      ),
    ]);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _descriptionController.dispose();
    _preparerController.dispose();
    _reviewerController.dispose();
    _evidenceController.dispose();
    for (final line in _lineStates) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = _input();
    final balanceColor =
        input.difference.abs() <= widget.service.tolerance
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error;

    return AlertDialog(
      title: const Text('New journal request'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _JournalRequestHeaderFields(
                referenceController: _referenceController,
                descriptionController: _descriptionController,
                preparerController: _preparerController,
                reviewerController: _reviewerController,
                evidenceController: _evidenceController,
                source: _source,
                onSourceChanged: (value) => setState(() => _source = value),
              ),
              const SizedBox(height: 14),
              Text(
                'Journal lines',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < _lineStates.length; index++) ...[
                _JournalRequestLineEditor(
                  key: ValueKey('journal-request-line-editor-$index'),
                  index: index,
                  state: _lineStates[index],
                  accounts: _postingAccounts,
                  canRemove: _lineStates.length > 2,
                  onChanged: () => setState(() => _validation = null),
                  onRemove: () => _removeLine(index),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                key: const ValueKey('journal-request-add-line'),
                onPressed: _addLine,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add line'),
              ),
              const SizedBox(height: 12),
              _JournalRequestTotals(
                debitTotal: input.debitTotal,
                creditTotal: input.creditTotal,
                difference: input.difference,
                balanceColor: balanceColor,
              ),
              if (_validation case final validation?
                  when !validation.isValid) ...[
                const SizedBox(height: 12),
                _JournalRequestIssuePanel(validation: validation),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey('journal-request-submit'),
          onPressed: _submit,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Submit for review'),
        ),
      ],
    );
  }

  void _addLine() {
    setState(() {
      _lineStates.add(
        _JournalRequestLineState(
          accountId:
              _postingAccounts.isEmpty ? null : _postingAccounts.first.id,
          side: JournalSide.debit,
        ),
      );
      _validation = null;
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lineStates.removeAt(index).dispose();
      _validation = null;
    });
  }

  void _submit() {
    final input = _input();
    final validation = widget.service.validate(input, widget.accounts);
    if (!validation.isValid) {
      setState(() => _validation = validation);
      return;
    }

    widget.onSubmit(
      widget.service.createApprovalRequest(input, widget.accounts),
    );
    Navigator.of(context).pop();
  }

  JournalRequestInput _input() {
    return JournalRequestInput(
      reference: _referenceController.text,
      description: _descriptionController.text,
      source: _source,
      preparerName: _preparerController.text,
      reviewerName: _reviewerController.text,
      evidenceReference: _evidenceController.text,
      lines: [
        for (final line in _lineStates)
          JournalRequestLineInput(
            accountId: line.accountId,
            side: line.side,
            amount: _parseAmount(line.amountController.text),
            memo: line.memoController.text,
          ),
      ],
    );
  }
}

/// Header controls for journal request metadata and ownership.
class _JournalRequestHeaderFields extends StatelessWidget {
  const _JournalRequestHeaderFields({
    required this.referenceController,
    required this.descriptionController,
    required this.preparerController,
    required this.reviewerController,
    required this.evidenceController,
    required this.source,
    required this.onSourceChanged,
  });

  final TextEditingController referenceController;
  final TextEditingController descriptionController;
  final TextEditingController preparerController;
  final TextEditingController reviewerController;
  final TextEditingController evidenceController;
  final JournalSource source;
  final ValueChanged<JournalSource> onSourceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('journal-request-reference'),
                controller: referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<JournalSource>(
                key: const ValueKey('journal-request-source'),
                initialValue: source,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final source in [
                    JournalSource.manualAdjustment,
                    JournalSource.periodClose,
                  ])
                    DropdownMenuItem(
                      value: source,
                      child: Text(
                        source.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  onSourceChanged(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          key: const ValueKey('journal-request-description'),
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('journal-request-preparer'),
                controller: preparerController,
                decoration: const InputDecoration(
                  labelText: 'Preparer',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                key: const ValueKey('journal-request-reviewer'),
                controller: reviewerController,
                decoration: const InputDecoration(
                  labelText: 'Reviewer',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          key: const ValueKey('journal-request-evidence'),
          controller: evidenceController,
          decoration: const InputDecoration(
            labelText: 'Evidence reference',
            prefixIcon: Icon(Icons.attachment_rounded),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

/// Single editable debit or credit line in the journal request form.
class _JournalRequestLineEditor extends StatelessWidget {
  const _JournalRequestLineEditor({
    required this.index,
    required this.state,
    required this.accounts,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final int index;
  final _JournalRequestLineState state;
  final List<AccountingAccount> accounts;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('journal-request-line-$index-account'),
                    initialValue: state.accountId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      for (final account in accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(
                            '${account.code} - ${account.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      state.accountId = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<JournalSide>(
                    key: ValueKey('journal-request-line-$index-side'),
                    initialValue: state.side,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Side',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      for (final side in JournalSide.values)
                        DropdownMenuItem(value: side, child: Text(side.label)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      state.side = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 150,
                  child: TextField(
                    key: ValueKey('journal-request-line-$index-amount'),
                    controller: state.amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  key: ValueKey('journal-request-line-$index-remove'),
                  tooltip: 'Remove line',
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: ValueKey('journal-request-line-$index-memo'),
              controller: state.memoController,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: 'Line memo',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Totals panel for debit, credit, and out-of-balance difference.
class _JournalRequestTotals extends StatelessWidget {
  const _JournalRequestTotals({
    required this.debitTotal,
    required this.creditTotal,
    required this.difference,
    required this.balanceColor,
  });

  final double debitTotal;
  final double creditTotal;
  final double difference;
  final Color balanceColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _TotalChip(label: 'Debit', value: _formatIdr(debitTotal)),
        _TotalChip(label: 'Credit', value: _formatIdr(creditTotal)),
        _TotalChip(
          label: 'Difference',
          value: _formatIdr(difference.abs()),
          color: balanceColor,
        ),
      ],
    );
  }
}

/// Validation issue panel shown after an unsuccessful request submission.
class _JournalRequestIssuePanel extends StatelessWidget {
  const _JournalRequestIssuePanel({required this.validation});

  final JournalRequestValidationResult validation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: const ValueKey('journal-request-issue-panel'),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${validation.issues.length} issue(s) to fix',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            for (final issue in validation.issues.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: colorScheme.error,
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

class _TotalChip extends StatelessWidget {
  const _TotalChip({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '$label: $value',
          style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _JournalRequestLineState {
  _JournalRequestLineState({required this.accountId, required this.side});

  String? accountId;
  JournalSide side;
  final amountController = TextEditingController();
  final memoController = TextEditingController();

  void dispose() {
    amountController.dispose();
    memoController.dispose();
  }
}

double _parseAmount(String value) {
  final normalized = value.replaceAll(RegExp(r'[^0-9.-]'), '');
  return double.tryParse(normalized) ?? 0;
}

String _formatIdr(double value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);
}

@Preview(name: 'Journal request dialog')
Widget journalRequestDialogPreview() {
  final accounts = [
    const AccountingAccount(
      id: 'cash',
      code: '1000',
      name: 'Cash',
      type: AccountingAccountType.asset,
    ),
    const AccountingAccount(
      id: 'expense',
      code: '5000',
      name: 'Rent Expense',
      type: AccountingAccountType.expense,
    ),
  ];

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: JournalRequestDialog(
          accounts: accounts,
          service: JournalRequestService(
            now: () => DateTime(2026, 6, 11),
            nextId: () => 'preview',
          ),
          onSubmit: (_) {},
        ),
      ),
    ),
  );
}
