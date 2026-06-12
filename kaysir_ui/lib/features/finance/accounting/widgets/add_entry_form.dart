// Desktop-specific add entry line form that stays visible
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/account.dart';
import '../models/account_entry.dart';
import '../models/account_entry_line.dart';
import '../states/entry_provider.dart';

class DesktopAddEntryLineForm extends ConsumerStatefulWidget {
  final List<Account> accounts;

  const DesktopAddEntryLineForm({super.key, required this.accounts});

  @override
  ConsumerState<DesktopAddEntryLineForm> createState() =>
      _DesktopAddEntryLineFormState();
}

class _DesktopAddEntryLineFormState
    extends ConsumerState<DesktopAddEntryLineForm> {
  String? selectedAccountId;
  EntryType entryType = EntryType.debit;
  double? amount;
  String memo = '';
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      selectedAccountId = null;
      entryType = EntryType.debit;
      amount = null;
      memo = '';
      _amountController.clear();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = ref.watch(entryNotifierProvider);
    final balancingType = currentEntry.requiredBalancingType;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Entry Line', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),

          // Account dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Account',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            initialValue: selectedAccountId,
            items:
                widget.accounts.map((account) {
                  return DropdownMenuItem<String>(
                    value: account.id,
                    child: Text('${account.code} - ${account.name}'),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedAccountId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an account';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Amount and entry type
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      amount = double.tryParse(value);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be > 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Type',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SegmentedButton<EntryType>(
                    segments: const [
                      ButtonSegment<EntryType>(
                        value: EntryType.debit,
                        label: Text('Debit'),
                      ),
                      ButtonSegment<EntryType>(
                        value: EntryType.credit,
                        label: Text('Credit'),
                      ),
                    ],
                    selected: {entryType},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        entryType = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          if (currentEntry.lines.isNotEmpty && balancingType != null) ...[
            const SizedBox(height: 12),
            _buildBalanceShortcut(
              context,
              currentEntry,
              balancingType,
              currencyFormat,
            ),
          ],
          const SizedBox(height: 20),

          // Memo field
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Memo (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                memo = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Line'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    selectedAccountId != null &&
                    amount != null) {
                  final selectedAccount = widget.accounts.firstWhere(
                    (a) => a.id == selectedAccountId,
                  );

                  final line = AccountingEntryLine(
                    accountId: selectedAccount.id,
                    accountName: selectedAccount.name,
                    entryType: entryType,
                    amount: amount!,
                    memo: memo.isNotEmpty ? memo : null,
                  );

                  ref.read(entryNotifierProvider.notifier).addLine(line);
                  _resetForm();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceShortcut(
    BuildContext context,
    AccountingEntry currentEntry,
    EntryType balancingType,
    NumberFormat currencyFormat,
  ) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.balance_rounded, size: 18),
      label: Text(
        'Use balancing amount: ${balancingType.name} ${currencyFormat.format(currentEntry.requiredBalancingAmount)}',
      ),
      onPressed: () {
        setState(() {
          entryType = balancingType;
          amount = currentEntry.requiredBalancingAmount;
          _amountController.text = currentEntry.requiredBalancingAmount
              .toStringAsFixed(2);
        });
      },
    );
  }
}
