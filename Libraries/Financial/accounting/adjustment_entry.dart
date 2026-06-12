import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// ----- MODELS -----

class AccountingEntry {
  final String id;
  final DateTime date;
  final String description;
  final String referenceNumber;
  final List<AccountingEntryLine> lines;
  final bool isPosted;

  AccountingEntry({
    String? id,
    required this.date,
    required this.description,
    required this.referenceNumber,
    required this.lines,
    this.isPosted = false,
  }) : id = id ?? const Uuid().v4();

  bool get isBalanced {
    double debits = 0;
    double credits = 0;
    for (var line in lines) {
      if (line.entryType == EntryType.debit) {
        debits += line.amount;
      } else {
        credits += line.amount;
      }
    }
    return (debits - credits).abs() < 0.001;
  }

  AccountingEntry copyWith({
    String? id,
    DateTime? date,
    String? description,
    String? referenceNumber,
    List<AccountingEntryLine>? lines,
    bool? isPosted,
  }) {
    return AccountingEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      lines: lines ?? this.lines,
      isPosted: isPosted ?? this.isPosted,
    );
  }
}

enum EntryType { debit, credit }

class AccountingEntryLine {
  final String id;
  final String accountId;
  final String accountName;
  final EntryType entryType;
  final double amount;
  final String? memo;

  AccountingEntryLine({
    String? id,
    required this.accountId,
    required this.accountName,
    required this.entryType,
    required this.amount,
    this.memo,
  }) : id = id ?? const Uuid().v4();

  AccountingEntryLine copyWith({
    String? id,
    String? accountId,
    String? accountName,
    EntryType? entryType,
    double? amount,
    String? memo,
  }) {
    return AccountingEntryLine(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
    );
  }
}

class Account {
  final String id;
  final String name;
  final String code;
  final AccountType type;

  Account({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });
}

enum AccountType { asset, liability, equity, revenue, expense }

// ----- PROVIDERS -----

final currentEntryProvider = StateProvider<AccountingEntry>((ref) {
  return AccountingEntry(
    date: DateTime.now(),
    description: '',
    referenceNumber: '',
    lines: [],
  );
});

final accountsProvider = Provider<List<Account>>((ref) {
  // In a real app, this would come from a repository or API
  return [
    Account(id: '1', name: 'Cash', code: '1000', type: AccountType.asset),
    Account(
      id: '2',
      name: 'Accounts Receivable',
      code: '1100',
      type: AccountType.asset,
    ),
    Account(id: '3', name: 'Inventory', code: '1200', type: AccountType.asset),
    Account(
      id: '4',
      name: 'Accounts Payable',
      code: '2000',
      type: AccountType.liability,
    ),
    Account(
      id: '5',
      name: 'Notes Payable',
      code: '2100',
      type: AccountType.liability,
    ),
    Account(
      id: '6',
      name: 'Retained Earnings',
      code: '3000',
      type: AccountType.equity,
    ),
    Account(
      id: '7',
      name: 'Sales Revenue',
      code: '4000',
      type: AccountType.revenue,
    ),
    Account(
      id: '8',
      name: 'Rent Expense',
      code: '5000',
      type: AccountType.expense,
    ),
    Account(
      id: '9',
      name: 'Utilities Expense',
      code: '5100',
      type: AccountType.expense,
    ),
    Account(
      id: '10',
      name: 'Salary Expense',
      code: '5200',
      type: AccountType.expense,
    ),
  ];
});

final entryHistoryProvider = StateProvider<List<AccountingEntry>>((ref) {
  // In a real app, this would come from a repository or API
  return [];
});

// ----- NOTIFIERS -----

class EntryNotifier extends StateNotifier<AccountingEntry> {
  EntryNotifier()
    : super(
        AccountingEntry(
          date: DateTime.now(),
          description: '',
          referenceNumber: '',
          lines: [],
        ),
      );

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setReferenceNumber(String referenceNumber) {
    state = state.copyWith(referenceNumber: referenceNumber);
  }

  void addLine(AccountingEntryLine line) {
    state = state.copyWith(lines: [...state.lines, line]);
  }

  void updateLine(String lineId, AccountingEntryLine updatedLine) {
    final updatedLines = state.lines
        .map((line) => line.id == lineId ? updatedLine : line)
        .toList();
    state = state.copyWith(lines: updatedLines);
  }

  void removeLine(String lineId) {
    final updatedLines = state.lines
        .where((line) => line.id != lineId)
        .toList();
    state = state.copyWith(lines: updatedLines);
  }

  void clear() {
    state = AccountingEntry(
      date: DateTime.now(),
      description: '',
      referenceNumber: '',
      lines: [],
    );
  }
}

final entryNotifierProvider =
    StateNotifierProvider<EntryNotifier, AccountingEntry>((ref) {
      return EntryNotifier();
    });

// ----- UI COMPONENTS -----

class AccountingAdjustmentScreen extends ConsumerWidget {
  const AccountingAdjustmentScreen({Key? key}) : super(key: key);

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
              // Show entry history
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const EntryHistorySheet(),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Entry header section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                      .read(entryNotifierProvider.notifier)
                                      .setDate(date);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: _HeaderField(
                            label: 'Reference',
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Reference Number',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
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
                    const SizedBox(height: 16),
                    _HeaderField(
                      label: 'Description',
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter adjustment description',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        initialValue: currentEntry.description,
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

              // Entry lines section
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Entry Lines',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            _EntryBalanceIndicator(entry: currentEntry),
                          ],
                        ),
                      ),
                      // Line header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Account',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Debit',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Credit',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 40), // For action buttons
                          ],
                        ),
                      ),

                      // Entry lines list
                      Expanded(
                        child: currentEntry.lines.isEmpty
                            ? const Center(
                                child: Text(
                                  'No entry lines. Add a new line to begin.',
                                ),
                              )
                            : ListView.builder(
                                itemCount: currentEntry.lines.length,
                                itemBuilder: (context, index) {
                                  final line = currentEntry.lines[index];
                                  return EntryLineItem(
                                    line: line,
                                    onEdit: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) =>
                                            EditEntryLineSheet(
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
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Totals',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  NumberFormat.currency(symbol: '\$').format(
                                    currentEntry.lines
                                        .where(
                                          (line) =>
                                              line.entryType == EntryType.debit,
                                        )
                                        .fold(
                                          0.0,
                                          (sum, line) => sum + line.amount,
                                        ),
                                  ),
                                  style: Theme.of(context).textTheme.titleSmall,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  NumberFormat.currency(symbol: '\$').format(
                                    currentEntry.lines
                                        .where(
                                          (line) =>
                                              line.entryType ==
                                              EntryType.credit,
                                        )
                                        .fold(
                                          0.0,
                                          (sum, line) => sum + line.amount,
                                        ),
                                  ),
                                  style: Theme.of(context).textTheme.titleSmall,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Line'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          AddEntryLineSheet(accounts: accounts),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Post Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                              content: Text(
                                'Journal entry posted successfully',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _EntryBalanceIndicator extends StatelessWidget {
  final AccountingEntry entry;

  const _EntryBalanceIndicator({Key? key, required this.entry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entry.lines.isEmpty) {
      return const SizedBox.shrink();
    }

    double debits = entry.lines
        .where((line) => line.entryType == EntryType.debit)
        .fold(0.0, (sum, line) => sum + line.amount);

    double credits = entry.lines
        .where((line) => line.entryType == EntryType.credit)
        .fold(0.0, (sum, line) => sum + line.amount);

    double difference = (debits - credits).abs();

    bool isBalanced = difference < 0.001;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isBalanced
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBalanced ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning,
            color: isBalanced ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isBalanced
                ? 'Balanced'
                : 'Unbalanced: ${NumberFormat.currency(symbol: '\$').format(difference)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isBalanced ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class EntryLineItem extends StatelessWidget {
  final AccountingEntryLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EntryLineItem({
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Expanded(
              flex: 3,
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
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        line.memo!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
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
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEntryLineSheet extends ConsumerStatefulWidget {
  final List<Account> accounts;

  const AddEntryLineSheet({Key? key, required this.accounts}) : super(key: key);

  @override
  ConsumerState<AddEntryLineSheet> createState() => _AddEntryLineSheetState();
}

class _AddEntryLineSheetState extends ConsumerState<AddEntryLineSheet> {
  String? selectedAccountId;
  EntryType entryType = EntryType.debit;
  double amount = 0.0;
  String memo = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final selectedAccount = selectedAccountId != null
        ? widget.accounts.firstWhere((a) => a.id == selectedAccountId)
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                    'Add Entry Line',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentedButton<EntryType>(
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Memo (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        selectedAccount != null) {
                      final line = AccountingEntryLine(
                        accountId: selectedAccount.id,
                        accountName: selectedAccount.name,
                        entryType: entryType,
                        amount: amount,
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
    );
  }
}

class EditEntryLineSheet extends ConsumerStatefulWidget {
  final AccountingEntryLine line;
  final List<Account> accounts;

  const EditEntryLineSheet({
    Key? key,
    required this.line,
    required this.accounts,
  }) : super(key: key);

  @override
  ConsumerState<EditEntryLineSheet> createState() => _EditEntryLineSheetState();
}

class _EditEntryLineSheetState extends ConsumerState<EditEntryLineSheet> {
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                    'Edit Entry Line',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentedButton<EntryType>(
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Memo (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final updatedLine = widget.line.copyWith(
                        accountId: selectedAccountId,
                        accountName: selectedAccount.name,
                        entryType: entryType,
                        amount: amount,
                        memo: memo.isNotEmpty ? memo : null,
                      );

                      ref
                          .read(entryNotifierProvider.notifier)
                          .updateLine(widget.line.id, updatedLine);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Update Line'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntryHistorySheet extends ConsumerWidget {
  const EntryHistorySheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entryHistoryProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Journal Entry History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text('No journal entries have been posted yet.'),
                  )
                : ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry =
                          entries[entries.length -
                              1 -
                              index]; // Show newest first
                      return ListTile(
                        title: Text(
                          entry.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Ref: ${entry.referenceNumber} • ${DateFormat('MM/dd/yyyy').format(entry.date)}',
                        ),
                        trailing: Text(
                          NumberFormat.currency(symbol: '\$').format(
                            entry.lines
                                .where(
                                  (line) => line.entryType == EntryType.debit,
                                )
                                .fold(0.0, (sum, line) => sum + line.amount),
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () {
                          // Show entry details
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) =>
                                EntryDetailsSheet(entry: entry),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class EntryDetailsSheet extends StatelessWidget {
  final AccountingEntry entry;

  const EntryDetailsSheet({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Ref: ${entry.referenceNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Date: ${DateFormat('MM/dd/yyyy').format(entry.date)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Line header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Account',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Debit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Credit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // Entry lines list
          Expanded(
            child: ListView.builder(
              itemCount: entry.lines.length,
              itemBuilder: (context, index) {
                final line = entry.lines[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.accountName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            if (line.memo != null && line.memo!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  line.memo!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                  maxLines: 1,
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
                    ],
                  ),
                );
              },
            ),
          ),

          // Entry totals
          Container(
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
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Totals',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatter.format(
                      entry.lines
                          .where((line) => line.entryType == EntryType.debit)
                          .fold(0.0, (sum, line) => sum + line.amount),
                    ),
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatter.format(
                      entry.lines
                          .where((line) => line.entryType == EntryType.credit)
                          .fold(0.0, (sum, line) => sum + line.amount),
                    ),
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----- MAIN APP -----

class AccountingApp extends StatelessWidget {
  const AccountingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Accounting Adjustments',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AccountingAdjustmentScreen(),
      ),
    );
  }
}

void main() {
  runApp(const AccountingApp());
}
