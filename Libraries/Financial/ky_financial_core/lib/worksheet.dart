import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class AccountingEntry {
  final int id;
  final String account;
  final double debit;
  final double credit;
  final String description;
  final DateTime date;
  final String category;

  AccountingEntry({
    required this.id,
    required this.account,
    required this.debit,
    required this.credit,
    required this.description,
    required this.date,
    required this.category,
  });
}

// Providers
final accountingEntriesProvider =
    StateNotifierProvider<AccountingEntriesNotifier, List<AccountingEntry>>((
      ref,
    ) {
      return AccountingEntriesNotifier();
    });

final filteredEntriesProvider = Provider<List<AccountingEntry>>((ref) {
  final entries = ref.watch(accountingEntriesProvider);
  final filter = ref.watch(filterProvider);

  if (filter.isEmpty) return entries;

  return entries
      .where(
        (entry) =>
            entry.account.toLowerCase().contains(filter.toLowerCase()) ||
            entry.description.toLowerCase().contains(filter.toLowerCase()) ||
            entry.category.toLowerCase().contains(filter.toLowerCase()),
      )
      .toList();
});

final totalDebitsProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  return entries.fold(0, (sum, entry) => sum + entry.debit);
});

final totalCreditsProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  return entries.fold(0, (sum, entry) => sum + entry.credit);
});

final balanceProvider = Provider<double>((ref) {
  final totalDebits = ref.watch(totalDebitsProvider);
  final totalCredits = ref.watch(totalCreditsProvider);
  return totalDebits - totalCredits;
});

final filterProvider = StateProvider<String>((ref) => '');
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Notifiers
class AccountingEntriesNotifier extends StateNotifier<List<AccountingEntry>> {
  AccountingEntriesNotifier()
    : super([
        // Sample data
        AccountingEntry(
          id: 1,
          account: 'Cash',
          debit: 5000,
          credit: 0,
          description: 'Initial investment',
          date: DateTime.now().subtract(const Duration(days: 30)),
          category: 'Capital',
        ),
        AccountingEntry(
          id: 2,
          account: 'Equipment',
          debit: 2000,
          credit: 0,
          description: 'Office equipment purchase',
          date: DateTime.now().subtract(const Duration(days: 25)),
          category: 'Assets',
        ),
        AccountingEntry(
          id: 3,
          account: 'Accounts Payable',
          debit: 0,
          credit: 2000,
          description: 'Credit purchase of equipment',
          date: DateTime.now().subtract(const Duration(days: 25)),
          category: 'Liabilities',
        ),
        AccountingEntry(
          id: 4,
          account: 'Rent Expense',
          debit: 1500,
          credit: 0,
          description: 'Monthly office rent',
          date: DateTime.now().subtract(const Duration(days: 15)),
          category: 'Expenses',
        ),
        AccountingEntry(
          id: 5,
          account: 'Cash',
          debit: 0,
          credit: 1500,
          description: 'Rent payment',
          date: DateTime.now().subtract(const Duration(days: 15)),
          category: 'Expenses',
        ),
        AccountingEntry(
          id: 6,
          account: 'Sales Revenue',
          debit: 0,
          credit: 3500,
          description: 'Client payment for services',
          date: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Revenue',
        ),
        AccountingEntry(
          id: 7,
          account: 'Accounts Receivable',
          debit: 3500,
          credit: 0,
          description: 'Client invoice',
          date: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Assets',
        ),
      ]);

  void addEntry(AccountingEntry entry) {
    state = [...state, entry];
  }

  void removeEntry(int id) {
    state = state.where((entry) => entry.id != id).toList();
  }

  void updateEntry(AccountingEntry updatedEntry) {
    state = state
        .map((entry) => entry.id == updatedEntry.id ? updatedEntry : entry)
        .toList();
  }
}

// Main App
class AccountingWorksheetApp extends StatelessWidget {
  const AccountingWorksheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final isDarkMode = ref.watch(isDarkModeProvider);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Financial Worksheet',
            theme: isDarkMode
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            home: const AccountingWorksheetScreen(),
          );
        },
      ),
    );
  }
}

// Main Screen
class AccountingWorksheetScreen extends ConsumerWidget {
  const AccountingWorksheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Worksheet'),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                ref.read(isDarkModeProvider.notifier).state = !isDarkMode,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const FinancialSummaryWidget(),
          const SizedBox(height: 8),
          const SearchFilterBar(),
          const SizedBox(height: 8),
          const WorksheetHeaderRow(),
          const Expanded(child: WorksheetEntriesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final initialDateRange =
        ref.read(selectedDateRangeProvider) ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      ref.read(selectedDateRangeProvider.notifier).state = newDateRange;
    }
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Entries'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Filter by text',
                  hintText: 'Enter account, description or category',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  ref.read(filterProvider.notifier).state = value;
                },
                controller: TextEditingController(
                  text: ref.read(filterProvider),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(filterProvider.notifier).state = '';
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export Data'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export feature would be implemented here'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('Import Data'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import feature would be implemented here'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Generate Reports'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Reports feature would be implemented here',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings would be implemented here'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEntryDialog(BuildContext context, WidgetRef ref) {
    final accountController = TextEditingController();
    final descriptionController = TextEditingController();
    final debitController = TextEditingController();
    final creditController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: accountController,
                  decoration: const InputDecoration(labelText: 'Account'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: debitController,
                  decoration: const InputDecoration(labelText: 'Debit Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: creditController,
                  decoration: const InputDecoration(labelText: 'Credit Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  final entries = ref.read(accountingEntriesProvider);
                  final newId = entries.isEmpty
                      ? 1
                      : entries
                                .map((e) => e.id)
                                .reduce((a, b) => a > b ? a : b) +
                            1;

                  final newEntry = AccountingEntry(
                    id: newId,
                    account: accountController.text,
                    debit: double.tryParse(debitController.text) ?? 0,
                    credit: double.tryParse(creditController.text) ?? 0,
                    description: descriptionController.text,
                    date: DateTime.now(),
                    category: categoryController.text,
                  );

                  ref
                      .read(accountingEntriesProvider.notifier)
                      .addEntry(newEntry);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding entry: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Widgets
class FinancialSummaryWidget extends ConsumerWidget {
  const FinancialSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDebits = ref.watch(totalDebitsProvider);
    final totalCredits = ref.watch(totalCreditsProvider);
    final balance = ref.watch(balanceProvider);
    final entries = ref.watch(filteredEntriesProvider);

    final dateRange = ref.watch(selectedDateRangeProvider);
    final dateRangeText = dateRange != null
        ? '${DateFormat('MMM d, y').format(dateRange.start)} - ${DateFormat('MMM d, y').format(dateRange.end)}'
        : 'All Time';

    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                dateRangeText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                context,
                'Total Entries',
                entries.length.toString(),
                Icons.list_alt,
              ),
              _buildSummaryItem(
                context,
                'Total Debits',
                formatter.format(totalDebits),
                Icons.arrow_upward,
              ),
              _buildSummaryItem(
                context,
                'Total Credits',
                formatter.format(totalCredits),
                Icons.arrow_downward,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: balance >= 0
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  balance >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: balance >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Net Balance: ${formatter.format(balance)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class SearchFilterBar extends ConsumerWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by account, description or category',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: filter.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => ref.read(filterProvider.notifier).state = '',
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          ref.read(filterProvider.notifier).state = value;
        },
        controller: TextEditingController(text: filter)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: filter.length),
          ),
      ),
    );
  }
}

class WorksheetHeaderRow extends StatelessWidget {
  const WorksheetHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Account/Description',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Date',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Debit',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Credit',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48), // Space for actions
        ],
      ),
    );
  }
}

class WorksheetEntriesList extends ConsumerWidget {
  const WorksheetEntriesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(filteredEntriesProvider);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No entries found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add new entries or adjust your filters',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return EntryListTile(entry: entry);
      },
    );
  }
}

class EntryListTile extends ConsumerWidget {
  final AccountingEntry entry;

  const EntryListTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Dismissible(
      key: Key('entry-${entry.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(accountingEntriesProvider.notifier).removeEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry for ${entry.account} removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(accountingEntriesProvider.notifier).addEntry(entry);
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.account,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                DateFormat('MMM d, y').format(entry.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                entry.debit > 0 ? formatter.format(entry.debit) : '',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: entry.debit > 0 ? Colors.green : null,
                ),
              ),
            ),
            Expanded(
              child: Text(
                entry.credit > 0 ? formatter.format(entry.credit) : '',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: entry.credit > 0 ? Colors.red : null,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showEditDialog(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final accountController = TextEditingController(text: entry.account);
    final descriptionController = TextEditingController(
      text: entry.description,
    );
    final debitController = TextEditingController(
      text: entry.debit > 0 ? entry.debit.toString() : '',
    );
    final creditController = TextEditingController(
      text: entry.credit > 0 ? entry.credit.toString() : '',
    );
    final categoryController = TextEditingController(text: entry.category);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: accountController,
                  decoration: const InputDecoration(labelText: 'Account'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: debitController,
                  decoration: const InputDecoration(labelText: 'Debit Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: creditController,
                  decoration: const InputDecoration(labelText: 'Credit Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  final updatedEntry = AccountingEntry(
                    id: entry.id,
                    account: accountController.text,
                    debit: double.tryParse(debitController.text) ?? 0,
                    credit: double.tryParse(creditController.text) ?? 0,
                    description: descriptionController.text,
                    date: entry.date,
                    category: categoryController.text,
                  );

                  ref
                      .read(accountingEntriesProvider.notifier)
                      .updateEntry(updatedEntry);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating entry: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(const AccountingWorksheetApp());
}
