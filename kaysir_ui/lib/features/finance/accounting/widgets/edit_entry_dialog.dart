// Desktop-specific edit entry line dialog
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/account.dart';
import '../models/account_entry.dart';
import '../models/account_entry_line.dart';
import '../states/entry_provider.dart';

class DesktopEditEntryLineDialog extends ConsumerStatefulWidget {
  final AccountingEntryLine line;
  final List<Account> accounts;

  const DesktopEditEntryLineDialog({
    Key? key,
    required this.line,
    required this.accounts,
  }) : super(key: key);

  @override
  ConsumerState<DesktopEditEntryLineDialog> createState() =>
      _DesktopEditEntryLineDialogState();
}

class _DesktopEditEntryLineDialogState
    extends ConsumerState<DesktopEditEntryLineDialog> {
  late String selectedAccountId;
  late EntryType entryType;
  late double amount;
  late String memo;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedAccountId = widget.line.accountId;
    entryType = widget.line.entryType;
    amount = widget.line.amount;
    memo = widget.line.memo ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final selectedAccount = widget.accounts.firstWhere(
      (a) => a.id == selectedAccountId,
      orElse: () => widget.accounts.first,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Entry Line',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                value: selectedAccountId,
                items:
                    widget.accounts.map((account) {
                      return DropdownMenuItem<String>(
                        value: account.id,
                        child: Text('${account.code} - ${account.name}'),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedAccountId = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an account';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
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
                      initialValue: amount.toString(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          amount = double.tryParse(value) ?? 0.0;
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade700),
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
              const SizedBox(height: 20),
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
                initialValue: memo,
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    memo = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    child: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    child: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final selectedAccount = widget.accounts.firstWhere(
                          (a) => a.id == selectedAccountId,
                        );

                        final updatedLine = widget.line.copyWith(
                          accountId: selectedAccount.id,
                          accountName: selectedAccount.name,
                          entryType: entryType,
                          amount: amount,
                          memo: memo.isNotEmpty ? memo : null,
                        );

                        ref
                            .read(entryNotifierProvider.notifier)
                            .updateLine(updatedLine.id, updatedLine);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
