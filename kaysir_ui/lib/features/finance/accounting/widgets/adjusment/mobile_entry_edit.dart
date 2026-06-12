import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/account.dart';
import '../../models/account_entry.dart';
import '../../models/account_entry_line.dart';
import '../../states/entry_provider.dart';

class MobileEditEntryLineSheet extends ConsumerStatefulWidget {
  final AccountingEntryLine line;
  final List<Account> accounts;

  const MobileEditEntryLineSheet({
    super.key,
    required this.line,
    required this.accounts,
  });

  @override
  ConsumerState<MobileEditEntryLineSheet> createState() =>
      _MobileEditEntryLineSheetState();
}

class _MobileEditEntryLineSheetState
    extends ConsumerState<MobileEditEntryLineSheet> {
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
    // Calculate bottom inset for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
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
                      'Edit Journal Line',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

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
                  value: selectedAccountId,
                  items:
                      widget.accounts.map((account) {
                        return DropdownMenuItem<String>(
                          value: account.id,
                          child: Text(
                            '${account.code} - ${account.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
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

                // Amount field
                TextFormField(
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
                const SizedBox(height: 20),

                // Entry type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entry Type',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                  initialValue: memo,
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      memo = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
