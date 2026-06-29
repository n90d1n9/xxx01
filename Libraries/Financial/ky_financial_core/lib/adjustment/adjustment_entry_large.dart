// ----- RESPONSIVE LAYOUT CONSTANTS -----
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import 'adjustment_entry.dart';

class ResponsiveBreakpoints {
  static const double tablet = 768.0;
  static const double desktop = 1200.0;
}

// ----- LARGE SCREEN LAYOUT COMPONENTS -----

/// Wrapper that handles responsive behavior for the accounting screen
class ResponsiveAccountingScreen extends StatelessWidget {
  const ResponsiveAccountingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return const DesktopAccountingLayout();
        } else {
          // Fall back to the original mobile layout
          return const AccountingAdjustmentScreen();
        }
      },
    );
  }
}

/// Desktop-specific layout for wider screens
class DesktopAccountingLayout extends ConsumerWidget {
  const DesktopAccountingLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEntry = ref.watch(entryNotifierProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Adjustment Entry'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DesktopEntryHistoryDialog(),
              );
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Entry header and forms
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entry Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _HeaderField(
                                  label: 'Date',
                                  child: GestureDetector(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: currentEntry.date,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        ref
                                            .read(
                                              entryNotifierProvider.notifier,
                                            )
                                            .setDate(date);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat(
                                              'MM/dd/yyyy',
                                            ).format(currentEntry.date),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.calendar_today,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _HeaderField(
                                  label: 'Reference',
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: 'Reference Number',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    initialValue: currentEntry.referenceNumber,
                                    onChanged: (value) {
                                      ref
                                          .read(entryNotifierProvider.notifier)
                                          .setReferenceNumber(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _HeaderField(
                            label: 'Description',
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Enter adjustment description',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              initialValue: currentEntry.description,
                              maxLines: 3,
                              onChanged: (value) {
                                ref
                                    .read(entryNotifierProvider.notifier)
                                    .setDescription(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add line form directly on the left panel for desktop
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: DesktopAddEntryLineForm(accounts: accounts),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            width: 1,
            color: Colors.grey.shade200,
            height: double.infinity,
          ),

          // Right side: Entry lines and totals
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Journal Entry Lines',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      _EntryBalanceIndicator(entry: currentEntry),
                    ],
                  ),
                ),

                // Line header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Account',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Memo',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Debit',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Credit',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      const SizedBox(width: 90), // For action buttons
                    ],
                  ),
                ),

                // Entry lines list
                Expanded(
                  child: currentEntry.lines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No entry lines',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add lines using the form on the left',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: currentEntry.lines.length,
                          itemBuilder: (context, index) {
                            final line = currentEntry.lines[index];
                            return DesktopEntryLineItem(
                              line: line,
                              onEdit: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      DesktopEditEntryLineDialog(
                                        line: line,
                                        accounts: accounts,
                                      ),
                                );
                              },
                              onDelete: () {
                                ref
                                    .read(entryNotifierProvider.notifier)
                                    .removeLine(line.id);
                              },
                            );
                          },
                        ),
                ),

                // Entry totals
                if (currentEntry.lines.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: SizedBox(), // Account column
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Totals',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            NumberFormat.currency(symbol: '\$').format(
                              currentEntry.lines
                                  .where(
                                    (line) => line.entryType == EntryType.debit,
                                  )
                                  .fold(0.0, (sum, line) => sum + line.amount),
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            NumberFormat.currency(symbol: '\$').format(
                              currentEntry.lines
                                  .where(
                                    (line) =>
                                        line.entryType == EntryType.credit,
                                  )
                                  .fold(0.0, (sum, line) => sum + line.amount),
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 90),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Entry'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  // Confirm before clearing
                  if (currentEntry.lines.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Entry?'),
                        content: const Text(
                          'This will remove all entry lines. Continue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(entryNotifierProvider.notifier).clear();
                            },
                            child: const Text('CLEAR'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    ref.read(entryNotifierProvider.notifier).clear();
                  }
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Post Entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed:
                    !currentEntry.isBalanced || currentEntry.lines.isEmpty
                    ? null
                    : () {
                        // Save the entry to history
                        final historyNotifier = ref.read(
                          entryHistoryProvider.notifier,
                        );
                        historyNotifier.state = [
                          ...ref.read(entryHistoryProvider),
                          currentEntry.copyWith(isPosted: true),
                        ];

                        // Clear the current entry
                        ref.read(entryNotifierProvider.notifier).clear();

                        // Show confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Journal entry posted successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Desktop-specific entry line item
class DesktopEntryLineItem extends StatelessWidget {
  final AccountingEntryLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DesktopEntryLineItem({
    Key? key,
    required this.line,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                line.accountName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                line.memo ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                line.entryType == EntryType.debit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: line.entryType == EntryType.debit
                      ? FontWeight.w500
                      : null,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                line.entryType == EntryType.credit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: line.entryType == EntryType.credit
                      ? FontWeight.w500
                      : null,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Edit Line',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete Line',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Desktop-specific add entry line form that stays visible
class DesktopAddEntryLineForm extends ConsumerStatefulWidget {
  final List<Account> accounts;

  const DesktopAddEntryLineForm({Key? key, required this.accounts})
    : super(key: key);

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
            value: selectedAccountId,
            items: widget.accounts.map((account) {
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
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
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
}

// Desktop-specific edit entry line dialog
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
                items: widget.accounts.map((account) {
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

// Desktop-specific entry history dialog
class DesktopEntryHistoryDialog extends ConsumerWidget {
  const DesktopEntryHistoryDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryHistory = ref.watch(entryHistoryProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry History',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entryHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No entry history',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted entries will appear here',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: entryHistory.length,
                      itemBuilder: (context, index) {
                        final entry =
                            entryHistory[entryHistory.length - index - 1];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            title: Text(
                              entry.description ?? 'Journal Entry',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  DateFormat('MM/dd/yyyy').format(entry.date),
                                ),
                                const SizedBox(width: 16),
                                if (entry.referenceNumber != null &&
                                    entry.referenceNumber!.isNotEmpty)
                                  Text('Ref: ${entry.referenceNumber}'),
                                const Spacer(),
                                Text(
                                  NumberFormat.currency(symbol: '\$').format(
                                    entry.lines
                                        .where(
                                          (line) =>
                                              line.entryType == EntryType.debit,
                                        )
                                        .fold(
                                          0.0,
                                          (sum, line) => sum + line.amount,
                                        ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Header
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Account',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Memo',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Debit',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade600,
                                                ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Credit',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade600,
                                                ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Lines
                                    for (final line in entry.lines)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                line.accountName,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                line.memo ?? '',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                line.entryType ==
                                                        EntryType.debit
                                                    ? NumberFormat.currency(
                                                        symbol: '\$',
                                                      ).format(line.amount)
                                                    : '',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                line.entryType ==
                                                        EntryType.credit
                                                    ? NumberFormat.currency(
                                                        symbol: '\$',
                                                      ).format(line.amount)
                                                    : '',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    // Totals
                                    Container(
                                      padding: const EdgeInsets.only(top: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            flex: 2,
                                            child: SizedBox(),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Totals',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              NumberFormat.currency(
                                                symbol: '\$',
                                              ).format(
                                                entry.lines
                                                    .where(
                                                      (line) =>
                                                          line.entryType ==
                                                          EntryType.debit,
                                                    )
                                                    .fold(
                                                      0.0,
                                                      (sum, line) =>
                                                          sum + line.amount,
                                                    ),
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              NumberFormat.currency(
                                                symbol: '\$',
                                              ).format(
                                                entry.lines
                                                    .where(
                                                      (line) =>
                                                          line.entryType ==
                                                          EntryType.credit,
                                                    )
                                                    .fold(
                                                      0.0,
                                                      (sum, line) =>
                                                          sum + line.amount,
                                                    ),
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for entry header fields
class _HeaderField extends StatelessWidget {
  final String label;
  final Widget child;

  const _HeaderField({Key? key, required this.label, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
          ),
        ),
        child,
      ],
    );
  }
}

// Widget to show balance status (balanced/unbalanced)
class _EntryBalanceIndicator extends ConsumerWidget {
  final AccountingEntry entry;

  const _EntryBalanceIndicator({Key? key, required this.entry})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debitTotal = entry.lines
        .where((line) => line.entryType == EntryType.debit)
        .fold(0.0, (sum, line) => sum + line.amount);

    final creditTotal = entry.lines
        .where((line) => line.entryType == EntryType.credit)
        .fold(0.0, (sum, line) => sum + line.amount);

    final isBalanced = (debitTotal - creditTotal).abs() < 0.001;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green.shade100 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isBalanced
                ? 'Balanced'
                : 'Out of Balance: ${NumberFormat.currency(symbol: '\$').format((debitTotal - creditTotal).abs())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ----- MOBILE LAYOUT COMPONENTS -----

/// Original mobile layout for accounting adjustment screen
class AccountingAdjustmentScreen extends ConsumerWidget {
  const AccountingAdjustmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEntry = ref.watch(entryNotifierProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Adjustment Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EntryHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Entry header section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entry Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: currentEntry.date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              ref
                                  .read(entryNotifierProvider.notifier)
                                  .setDate(date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat(
                                    'MM/dd/yyyy',
                                  ).format(currentEntry.date),
                                ),
                                const Icon(Icons.calendar_today, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Reference',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          initialValue: currentEntry.referenceNumber,
                          onChanged: (value) {
                            ref
                                .read(entryNotifierProvider.notifier)
                                .setReferenceNumber(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    initialValue: currentEntry.description,
                    onChanged: (value) {
                      ref
                          .read(entryNotifierProvider.notifier)
                          .setDescription(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Entry lines list
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Entry Lines',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (currentEntry.lines.isNotEmpty)
                          MobileEntryBalanceStatus(entry: currentEntry),
                      ],
                    ),
                  ),
                  Expanded(
                    child: currentEntry.lines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No entry lines',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add a line',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: currentEntry.lines.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey.shade300),
                            itemBuilder: (context, index) {
                              final line = currentEntry.lines[index];
                              return MobileEntryLineItem(
                                line: line,
                                onEdit: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (context) =>
                                        MobileEditEntryLineSheet(
                                          line: line,
                                          accounts: accounts,
                                        ),
                                  );
                                },
                                onDelete: () {
                                  ref
                                      .read(entryNotifierProvider.notifier)
                                      .removeLine(line.id);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => MobileAddEntryLineSheet(accounts: accounts),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: !currentEntry.isBalanced || currentEntry.lines.isEmpty
                ? null
                : () {
                    // Save the entry to history
                    final historyNotifier = ref.read(
                      entryHistoryProvider.notifier,
                    );
                    historyNotifier.state = [
                      ...ref.read(entryHistoryProvider),
                      currentEntry.copyWith(isPosted: true),
                    ];

                    // Clear the current entry
                    ref.read(entryNotifierProvider.notifier).clear();

                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Journal entry posted successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            child: const Text('Post Journal Entry'),
          ),
        ),
      ),
    );
  }
}

// Additional mobile-specific widgets would be implemented here...
/// History screen for mobile layout
class EntryHistoryScreen extends ConsumerWidget {
  const EntryHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryHistory = ref.watch(entryHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Entry History')),
      body: entryHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No entry history',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted entries will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: entryHistory.length,
              itemBuilder: (context, index) {
                final entry = entryHistory[entryHistory.length - index - 1];
                return Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      entry.description ?? 'Journal Entry',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(DateFormat('MM/dd/yyyy').format(entry.date)),
                            const SizedBox(width: 12),
                            if (entry.referenceNumber != null &&
                                entry.referenceNumber!.isNotEmpty)
                              Text('Ref: ${entry.referenceNumber}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(
                            entry.lines
                                .where(
                                  (line) => line.entryType == EntryType.debit,
                                )
                                .fold(0.0, (sum, line) => sum + line.amount),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            for (final line in entry.lines)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            line.accountName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          if (line.memo != null &&
                                              line.memo!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                line.memo!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        line.entryType == EntryType.debit
                                            ? NumberFormat.currency(
                                                symbol: '\$',
                                              ).format(line.amount)
                                            : '',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        line.entryType == EntryType.credit
                                            ? NumberFormat.currency(
                                                symbol: '\$',
                                              ).format(line.amount)
                                            : '',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      flex: 5,
                                      child: Text('Total'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        NumberFormat.currency(
                                          symbol: '\$',
                                        ).format(
                                          entry.lines
                                              .where(
                                                (line) =>
                                                    line.entryType ==
                                                    EntryType.debit,
                                              )
                                              .fold(
                                                0.0,
                                                (sum, line) =>
                                                    sum + line.amount,
                                              ),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        NumberFormat.currency(
                                          symbol: '\$',
                                        ).format(
                                          entry.lines
                                              .where(
                                                (line) =>
                                                    line.entryType ==
                                                    EntryType.credit,
                                              )
                                              .fold(
                                                0.0,
                                                (sum, line) =>
                                                    sum + line.amount,
                                              ),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// Mobile widget to display balance status
class MobileEntryBalanceStatus extends StatelessWidget {
  final AccountingEntry entry;

  const MobileEntryBalanceStatus({Key? key, required this.entry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final debitTotal = entry.lines
        .where((line) => line.entryType == EntryType.debit)
        .fold(0.0, (sum, line) => sum + line.amount);

    final creditTotal = entry.lines
        .where((line) => line.entryType == EntryType.credit)
        .fold(0.0, (sum, line) => sum + line.amount);

    final isBalanced = (debitTotal - creditTotal).abs() < 0.001;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green.shade100 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isBalanced ? 'Balanced' : 'Out of Balance',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile entry line item in the list
class MobileEntryLineItem extends StatelessWidget {
  final AccountingEntryLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobileEntryLineItem({
    Key? key,
    required this.line,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.accountName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (line.memo != null && line.memo!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        line.memo!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                line.entryType == EntryType.debit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                line.entryType == EntryType.credit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                tooltip: 'Delete Line',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile bottom sheet for adding a new entry line
class MobileAddEntryLineSheet extends ConsumerStatefulWidget {
  final List<Account> accounts;

  const MobileAddEntryLineSheet({Key? key, required this.accounts})
    : super(key: key);

  @override
  ConsumerState<MobileAddEntryLineSheet> createState() =>
      _MobileAddEntryLineSheetState();
}

class _MobileAddEntryLineSheetState
    extends ConsumerState<MobileAddEntryLineSheet> {
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
                      'Add Journal Line',
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
                  items: widget.accounts.map((account) {
                    return DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(
                        '${account.code} - ${account.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
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

                // Amount field
                TextFormField(
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Line'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile bottom sheet for editing an existing entry line
class MobileEditEntryLineSheet extends ConsumerStatefulWidget {
  final AccountingEntryLine line;
  final List<Account> accounts;

  const MobileEditEntryLineSheet({
    Key? key,
    required this.line,
    required this.accounts,
  }) : super(key: key);

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
                  items: widget.accounts.map((account) {
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

                            // ref.read(entryNotifierProvider.notifier).updateLine(updatedLine);
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

void main() {
  runApp(
    ProviderScope(child: MaterialApp(home: const ResponsiveAccountingScreen())),
  );
}
