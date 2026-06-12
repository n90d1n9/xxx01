import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'journal_entry_large.dart';

// Models
class Account {
  final String id;
  final String code;
  final String name;
  final AccountType type;

  Account({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
  });
}

enum AccountType { asset, liability, equity, revenue, expense }

class JournalEntry {
  final String id;
  final DateTime date;
  final String reference;
  final String description;
  final List<JournalLine> lines;
  final JournalType type;

  JournalEntry({
    required this.id,
    required this.date,
    required this.reference,
    required this.description,
    required this.lines,
    required this.type,
  });

  double get totalDebit => lines.fold(0, (sum, line) => sum + line.debit);
  double get totalCredit => lines.fold(0, (sum, line) => sum + line.credit);
  bool get isBalanced => totalDebit == totalCredit;
}

class JournalLine {
  final String id;
  final Account account;
  final double debit;
  final double credit;
  final String description;

  JournalLine({
    required this.id,
    required this.account,
    required this.debit,
    required this.credit,
    required this.description,
  });
}

enum JournalType { general, sales, purchase, cash }

// Providers
final journalTypeProvider = StateProvider<JournalType>(
  (ref) => JournalType.general,
);

final accountsProvider = Provider<List<Account>>(
  (ref) => [
    Account(id: '1', code: '1000', name: 'Cash', type: AccountType.asset),
    Account(
      id: '2',
      code: '1100',
      name: 'Accounts Receivable',
      type: AccountType.asset,
    ),
    Account(
      id: '3',
      code: '2000',
      name: 'Accounts Payable',
      type: AccountType.liability,
    ),
    Account(
      id: '4',
      code: '4000',
      name: 'Sales Revenue',
      type: AccountType.revenue,
    ),
    Account(
      id: '5',
      code: '5000',
      name: 'Cost of Goods Sold',
      type: AccountType.expense,
    ),
    // Add more accounts as needed
  ],
);

final filteredAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsProvider);
  final searchQuery = ref.watch(accountSearchProvider);

  if (searchQuery.isEmpty) return accounts;

  return accounts.where((account) {
    return account.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        account.code.contains(searchQuery);
  }).toList();
});

final accountSearchProvider = StateProvider<String>((ref) => '');

final currentJournalEntryProvider =
    StateNotifierProvider<JournalEntryNotifier, JournalEntry>((ref) {
      return JournalEntryNotifier(ref);
    });

class JournalEntryNotifier extends StateNotifier<JournalEntry> {
  final Ref _ref;

  JournalEntryNotifier(this._ref)
    : super(
        JournalEntry(
          id: const Uuid().v4(),
          date: DateTime.now(),
          reference: '',
          description: '',
          lines: [],
          type: JournalType.general,
        ),
      );

  void updateType(JournalType type) {
    state = JournalEntry(
      id: state.id,
      date: state.date,
      reference: state.reference,
      description: state.description,
      lines: state.lines,
      type: type,
    );
  }

  void updateDate(DateTime date) {
    state = JournalEntry(
      id: state.id,
      date: date,
      reference: state.reference,
      description: state.description,
      lines: state.lines,
      type: state.type,
    );
  }

  void updateReference(String reference) {
    state = JournalEntry(
      id: state.id,
      date: state.date,
      reference: reference,
      description: state.description,
      lines: state.lines,
      type: state.type,
    );
  }

  void updateDescription(String description) {
    state = JournalEntry(
      id: state.id,
      date: state.date,
      reference: state.reference,
      description: description,
      lines: state.lines,
      type: state.type,
    );
  }

  void addLine() {
    final newLine = JournalLine(
      id: const Uuid().v4(),
      account: _ref.read(accountsProvider)[0],
      debit: 0,
      credit: 0,
      description: '',
    );

    state = JournalEntry(
      id: state.id,
      date: state.date,
      reference: state.reference,
      description: state.description,
      lines: [...state.lines, newLine],
      type: state.type,
    );
  }

  void updateLine(
    String lineId, {
    Account? account,
    double? debit,
    double? credit,
    String? description,
  }) {
    final updatedLines = state.lines.map((line) {
      if (line.id == lineId) {
        return JournalLine(
          id: line.id,
          account: account ?? line.account,
          debit: debit ?? line.debit,
          credit: credit ?? line.credit,
          description: description ?? line.description,
        );
      }
      return line;
    }).toList();

    state = JournalEntry(
      id: state.id,
      date: state.date,
      reference: state.reference,
      description: state.description,
      lines: updatedLines,
      type: state.type,
    );
  }

  void removeLine(String lineId) {
    state = JournalEntry(
      id: state.id,
      date: state.date,
      reference: state.reference,
      description: state.description,
      lines: state.lines.where((line) => line.id != lineId).toList(),
      type: state.type,
    );
  }

  void autoBalance() {
    if (state.lines.isEmpty) return;

    final difference = state.totalDebit - state.totalCredit;
    if (difference == 0) return;

    final lastLine = state.lines.last;

    if (difference > 0) {
      // Need to add to credit
      updateLine(lastLine.id, credit: lastLine.credit + difference);
    } else {
      // Need to add to debit
      updateLine(lastLine.id, debit: lastLine.debit + difference.abs());
    }
  }

  void clear() {
    state = JournalEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      reference: '',
      description: '',
      lines: [],
      type: state.type,
    );
  }
}

// Screens
class JournalEntryScreen extends ConsumerWidget {
  const JournalEntryScreen({Key? key}) : super(key: key);

  /* @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalEntry = ref.watch(currentJournalEntryProvider);
    final journalType = ref.watch(journalTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed:
                journalEntry.isBalanced
                    ? () {
                      // Save logic would go here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Journal entry saved')),
                      );
                      ref.read(currentJournalEntryProvider.notifier).clear();
                    }
                    : null,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: JournalEntryHeader(journalEntry: journalEntry),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            'Journal Type',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<JournalType>(
                            value: journalType,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                ref.read(journalTypeProvider.notifier).state =
                                    newValue;
                                ref
                                    .read(currentJournalEntryProvider.notifier)
                                    .updateType(newValue);
                              }
                            },
                            items:
                                JournalType.values.map((type) {
                                  return DropdownMenuItem<JournalType>(
                                    value: type,
                                    child: Text(
                                      type.toString().split('.').last,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: JournalLinesHeader(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < journalEntry.lines.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: JournalLineItem(
                    line: journalEntry.lines[index],
                    index: index,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }, childCount: journalEntry.lines.length),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: JournalLinesFooter(journalEntry: journalEntry),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => ref.read(currentJournalEntryProvider.notifier).addLine(),
        child: const Icon(Icons.add),
      ),
    );
  } */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalEntry = ref.watch(currentJournalEntryProvider);
    final journalType = ref.watch(journalTypeProvider);
    final isLargeScreen = LayoutConstants.isLargeScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: journalEntry.isBalanced
                ? () {
                    // Save logic would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Journal entry saved')),
                    );
                    ref.read(currentJournalEntryProvider.notifier).clear();
                  }
                : null,
          ),
        ],
      ),
      body: isLargeScreen
          ? _buildLargeScreenLayout(context, journalEntry, journalType, ref)
          : _buildStandardLayout(context, journalEntry, journalType, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(currentJournalEntryProvider.notifier).addLine(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLargeScreenLayout(
    BuildContext context,
    JournalEntry journalEntry,
    JournalType journalType,
    WidgetRef ref,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - Header and Journal Type
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JournalEntryHeader(journalEntry: journalEntry),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              'Journal Type',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<JournalType>(
                              value: journalType,
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  ref.read(journalTypeProvider.notifier).state =
                                      newValue;
                                  ref
                                      .read(
                                        currentJournalEntryProvider.notifier,
                                      )
                                      .updateType(newValue);
                                }
                              },
                              items: JournalType.values.map((type) {
                                return DropdownMenuItem<JournalType>(
                                  value: type,
                                  child: Text(type.toString().split('.').last),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Add a summary panel
                if (journalEntry.lines.isNotEmpty)
                  _buildSummaryPanel(context, journalEntry),
                const SizedBox(height: 32),
                // Recent activity panel (sample)
                _buildRecentActivityPanel(context),
              ],
            ),
          ),
        ),
        // Right panel - Journal lines
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: JournalLinesHeader(),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: journalEntry.lines.length,
                  itemBuilder: (context, index) {
                    return JournalLineItem(
                      line: journalEntry.lines[index],
                      index: index,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: JournalLinesFooter(journalEntry: journalEntry),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandardLayout(
    BuildContext context,
    JournalEntry journalEntry,
    JournalType journalType,
    WidgetRef ref,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: JournalEntryHeader(journalEntry: journalEntry),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          'Journal Type',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<JournalType>(
                          value: journalType,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              ref.read(journalTypeProvider.notifier).state =
                                  newValue;
                              ref
                                  .read(currentJournalEntryProvider.notifier)
                                  .updateType(newValue);
                            }
                          },
                          items: JournalType.values.map((type) {
                            return DropdownMenuItem<JournalType>(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: JournalLinesHeader(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < journalEntry.lines.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: JournalLineItem(
                  line: journalEntry.lines[index],
                  index: index,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }, childCount: journalEntry.lines.length),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: JournalLinesFooter(journalEntry: journalEntry),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPanel(BuildContext context, JournalEntry journalEntry) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Debit:'),
                Text(
                  NumberFormat("#,##0.00").format(journalEntry.totalDebit),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Credit:'),
                Text(
                  NumberFormat("#,##0.00").format(journalEntry.totalCredit),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:'),
                journalEntry.isBalanced
                    ? const Text(
                        'Balanced',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text(
                        'Not Balanced',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
            if (!journalEntry.isBalanced) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Difference:'),
                  Text(
                    NumberFormat("#,##0.00").format(
                      (journalEntry.totalDebit - journalEntry.totalCredit)
                          .abs(),
                    ),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityPanel(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Entries',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Invoice Payment - ABC Corp'),
              subtitle: const Text('General • 10 Apr 2025'),
              trailing: const Text('\$1,200.00'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            const Divider(),
            ListTile(
              title: const Text('Inventory Purchase'),
              subtitle: const Text('Purchase • 09 Apr 2025'),
              trailing: const Text('\$3,450.00'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            const Divider(),
            ListTile(
              title: const Text('Utility Expenses'),
              subtitle: const Text('Cash • 08 Apr 2025'),
              trailing: const Text('\$520.00'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // View all entries logic
                },
                child: const Text('View All Entries'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalEntryHeader extends ConsumerWidget {
  final JournalEntry journalEntry;

  const JournalEntryHeader({Key? key, required this.journalEntry})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: journalEntry.reference,
                      decoration: const InputDecoration(
                        labelText: 'Reference Number',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        ref
                            .read(currentJournalEntryProvider.notifier)
                            .updateReference(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: journalEntry.date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          ref
                              .read(currentJournalEntryProvider.notifier)
                              .updateDate(pickedDate);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(journalEntry.date),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: journalEntry.description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  ref
                      .read(currentJournalEntryProvider.notifier)
                      .updateDescription(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JournalLinesHeader extends StatelessWidget {
  const JournalLinesHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Expanded(
              flex: 5,
              child: Text(
                'Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              flex: 3,
              child: Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                'Debit',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                'Credit',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 48), // Space for the action button
          ],
        ),
      ),
    );
  }
}

class JournalLineItem extends ConsumerWidget {
  final JournalLine line;
  final int index;

  const JournalLineItem({Key? key, required this.line, required this.index})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: AccountSelector(
                lineId: line.id,
                currentAccount: line.account,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  initialValue: line.description,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(currentJournalEntryProvider.notifier)
                        .updateLine(line.id, description: value);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  initialValue: line.debit > 0 ? line.debit.toString() : '',
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    ref
                        .read(currentJournalEntryProvider.notifier)
                        .updateLine(
                          line.id,
                          debit: amount,
                          // If debit is entered, clear credit
                          credit: amount > 0 ? 0.0 : line.credit,
                        );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  initialValue: line.credit > 0 ? line.credit.toString() : '',
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    ref
                        .read(currentJournalEntryProvider.notifier)
                        .updateLine(
                          line.id,
                          credit: amount,
                          // If credit is entered, clear debit
                          debit: amount > 0 ? 0.0 : line.debit,
                        );
                  },
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  ref
                      .read(currentJournalEntryProvider.notifier)
                      .removeLine(line.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSelector extends ConsumerStatefulWidget {
  final String lineId;
  final Account currentAccount;

  const AccountSelector({
    Key? key,
    required this.lineId,
    required this.currentAccount,
  }) : super(key: key);

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller.text =
        "${widget.currentAccount.code} - ${widget.currentAccount.name}";
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void didUpdateWidget(AccountSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAccount.id != widget.currentAccount.id) {
      _controller.text =
          "${widget.currentAccount.code} - ${widget.currentAccount.name}";
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4,
            child: AccountSearchList(
              lineId: widget.lineId,
              onSelect: (account) {
                _controller.text = "${account.code} - ${account.name}";
                _focusNode.unfocus();
              },
            ),
          ),
        ),
      ),
    );

    ref.read(accountSearchProvider.notifier).state = '';
    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
          onChanged: (value) {
            ref.read(accountSearchProvider.notifier).state = value;
          },
          readOnly: false,
        ),
      ),
    );
  }
}

class AccountSearchList extends ConsumerWidget {
  final String lineId;
  final Function(Account) onSelect;

  const AccountSearchList({
    Key? key,
    required this.lineId,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAccounts = ref.watch(filteredAccountsProvider);

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredAccounts.length,
        itemBuilder: (context, index) {
          final account = filteredAccounts[index];
          return ListTile(
            dense: true,
            title: Text("${account.code} - ${account.name}"),
            subtitle: Text(account.type.toString().split('.').last),
            onTap: () {
              ref
                  .read(currentJournalEntryProvider.notifier)
                  .updateLine(lineId, account: account);
              onSelect(account);
            },
          );
        },
      ),
    );
  }
}

class JournalLinesFooter extends ConsumerWidget {
  final JournalEntry journalEntry;

  const JournalLinesFooter({Key? key, required this.journalEntry})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDebit = journalEntry.totalDebit;
    final totalCredit = journalEntry.totalCredit;
    final difference = totalDebit - totalCredit;
    final isBalanced = journalEntry.isBalanced;

    return Column(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      flex: 8,
                      child: Text(
                        'Totals',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        NumberFormat("#,##0.00").format(totalDebit),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        NumberFormat("#,##0.00").format(totalCredit),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                if (!isBalanced) ...[
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                        flex: 8,
                        child: Text(
                          'Difference',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          NumberFormat("#,##0.00").format(difference.abs()),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (!isBalanced && journalEntry.lines.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(Icons.balance),
            label: const Text('Auto Balance'),
            onPressed: () {
              ref.read(currentJournalEntryProvider.notifier).autoBalance();
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Main
void main() {
  runApp(const ProviderScope(child: EnhancedMyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounting Journal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const JournalEntryScreen(),
    );
  }
}
