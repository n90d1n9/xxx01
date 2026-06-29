import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);

  return entries.where((entry) {
    // Text filter
    final matchesText =
        filter.isEmpty ||
        entry.account.toLowerCase().contains(filter.toLowerCase()) ||
        entry.description.toLowerCase().contains(filter.toLowerCase()) ||
        entry.category.toLowerCase().contains(filter.toLowerCase());

    // Category filter
    final matchesCategory =
        selectedCategory == null || entry.category == selectedCategory;

    // Date range filter
    final matchesDateRange =
        dateRange == null ||
        (entry.date.isAfter(
              dateRange.start.subtract(const Duration(days: 1)),
            ) &&
            entry.date.isBefore(dateRange.end.add(const Duration(days: 1))));

    return matchesText && matchesCategory && matchesDateRange;
  }).toList();
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
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
final isDarkModeProvider = StateProvider<bool>((ref) => false);
final selectedEntryProvider = StateProvider<AccountingEntry?>((ref) => null);
final isDrawerExpandedProvider = StateProvider<bool>((ref) => true);

// Group entries by category
final categoriesProvider = Provider<List<String>>((ref) {
  final entries = ref.watch(accountingEntriesProvider);
  final categories = entries.map((e) => e.category).toSet().toList();
  categories.sort();
  return categories;
});

// Entries grouped by category for analytics
final entriesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  final Map<String, double> result = {};

  for (final entry in entries) {
    final netAmount = entry.debit - entry.credit;
    result[entry.category] = (result[entry.category] ?? 0) + netAmount;
  }

  return result;
});

// Notifiers
class AccountingEntriesNotifier extends StateNotifier<List<AccountingEntry>> {
  AccountingEntriesNotifier()
    : super([
        // Sample data with more entries for large screen testing
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
        AccountingEntry(
          id: 8,
          account: 'Utilities Expense',
          debit: 450,
          credit: 0,
          description: 'Monthly utilities',
          date: DateTime.now().subtract(const Duration(days: 10)),
          category: 'Expenses',
        ),
        AccountingEntry(
          id: 9,
          account: 'Cash',
          debit: 0,
          credit: 450,
          description: 'Payment for utilities',
          date: DateTime.now().subtract(const Duration(days: 10)),
          category: 'Expenses',
        ),
        AccountingEntry(
          id: 10,
          account: 'Office Supplies',
          debit: 300,
          credit: 0,
          description: 'Paper, ink, and other supplies',
          date: DateTime.now().subtract(const Duration(days: 8)),
          category: 'Expenses',
        ),
        AccountingEntry(
          id: 11,
          account: 'Cash',
          debit: 0,
          credit: 300,
          description: 'Payment for office supplies',
          date: DateTime.now().subtract(const Duration(days: 8)),
          category: 'Expenses',
        ),
        AccountingEntry(
          id: 12,
          account: 'Sales Revenue',
          debit: 0,
          credit: 4500,
          description: 'Client project completion',
          date: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Revenue',
        ),
        AccountingEntry(
          id: 13,
          account: 'Accounts Receivable',
          debit: 4500,
          credit: 0,
          description: 'Client invoice for completed project',
          date: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Assets',
        ),
        AccountingEntry(
          id: 14,
          account: 'Salary Expense',
          debit: 3000,
          credit: 0,
          description: 'Employee salaries',
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Expenses',
        ),
        AccountingEntry(
          id: 15,
          account: 'Cash',
          debit: 0,
          credit: 3000,
          description: 'Payment of employee salaries',
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Expenses',
        ),
      ]);

  void addEntry(AccountingEntry entry) {
    state = [...state, entry];
  }

  void removeEntry(int id) {
    state = state.where((entry) => entry.id != id).toList();
  }

  void updateEntry(AccountingEntry updatedEntry) {
    state =
        state
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
            theme:
                isDarkMode
                    ? ThemeData.dark(useMaterial3: true).copyWith(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: Colors.indigo,
                        brightness: Brightness.dark,
                      ),
                    )
                    : ThemeData.light(useMaterial3: true).copyWith(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: Colors.indigo,
                        brightness: Brightness.light,
                      ),
                    ),
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
    final isDrawerExpanded = ref.watch(isDrawerExpandedProvider);
    final selectedEntry = ref.watch(selectedEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Worksheet'),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed:
                () => ref.read(isDarkModeProvider.notifier).state = !isDarkMode,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context, ref),
            tooltip: 'Select date range',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
            tooltip: 'Filter entries',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
            tooltip: 'More options',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on a large screen (tablet or desktop)
          final isLargeScreen = constraints.maxWidth > 1000;

          if (isLargeScreen) {
            // Large screen layout with side panel
            return Row(
              children: [
                // Left sidebar - always visible on large screens
                SideNavigationPanel(
                  width: isDrawerExpanded ? 280 : 80,
                  isExpanded: isDrawerExpanded,
                  onToggleExpanded: () {
                    ref.read(isDrawerExpandedProvider.notifier).state =
                        !isDrawerExpanded;
                  },
                ),

                // Main content area
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const FinancialSummaryWidget(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Expanded(child: SearchFilterBar()),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Entry'),
                              onPressed:
                                  () => _showAddEntryDialog(context, ref),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const WorksheetHeaderRow(),
                      const Expanded(child: WorksheetEntriesList()),
                    ],
                  ),
                ),

                // Right panel for selected entry details or analytics
                if (selectedEntry != null)
                  Expanded(
                    flex: 2,
                    child: EntryDetailPanel(entry: selectedEntry),
                  )
                else
                  const Expanded(flex: 2, child: AnalyticsPanel()),
              ],
            );
          } else {
            // Default layout for smaller screens
            return Column(
              children: [
                const SizedBox(height: 8),
                const FinancialSummaryWidget(),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SearchFilterBar(),
                ),
                const SizedBox(height: 8),
                const WorksheetHeaderRow(),
                const Expanded(child: WorksheetEntriesList()),
              ],
            );
          }
        },
      ),
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          // Only show drawer on smaller screens
          return constraints.maxWidth <= 1000
              ? const NavigationDrawer()
              : const SizedBox.shrink();
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          // Only show FAB on smaller screens
          return constraints.maxWidth <= 1000
              ? FloatingActionButton(
                onPressed: () => _showAddEntryDialog(context, ref),
                child: const Icon(Icons.add),
              )
              : const SizedBox.shrink();
        },
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
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      ref.read(selectedDateRangeProvider.notifier).state = newDateRange;
    }
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final categories = ref.read(categoriesProvider);
    final selectedCategory = ref.read(selectedCategoryProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Entries'),
          content: SizedBox(
            width: 400, // Wider dialog for large screens
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                const Text('Filter by category:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All Categories'),
                      selected: selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    ...categories.map(
                      (category) => FilterChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                category;
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(filterProvider.notifier).state = '';
                ref.read(selectedCategoryProvider.notifier).state = null;
                Navigator.of(context).pop();
              },
              child: const Text('Clear All Filters'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
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
                leading: const Icon(Icons.print),
                title: const Text('Print Worksheet'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Print feature would be implemented here'),
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
    final categories = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Entry'),
          content: SizedBox(
            width: 500, // Wider dialog for large screens
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: accountController,
                          decoration: const InputDecoration(
                            labelText: 'Account',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return categories;
                            }
                            return categories.where(
                              (category) => category.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            categoryController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            categoryController.addListener(() {
                              textEditingController.text =
                                  categoryController.text;
                            });
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                hintText: 'Select or type category',
                              ),
                              onChanged: (value) {
                                categoryController.text = value;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: debitController,
                          decoration: const InputDecoration(
                            labelText: 'Debit Amount',
                            prefixIcon: Icon(Icons.arrow_upward),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: creditController,
                          decoration: const InputDecoration(
                            labelText: 'Credit Amount',
                            prefixIcon: Icon(Icons.arrow_downward),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
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
            ElevatedButton(
              onPressed: () {
                try {
                  final entries = ref.read(accountingEntriesProvider);
                  final newId =
                      entries.isEmpty
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

                  // Show snackbar confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Entry for "${accountController.text}" added successfully',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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

// Widgets for large screen layout
class SideNavigationPanel extends ConsumerWidget {
  final double width;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const SideNavigationPanel({
    super.key,
    required this.width,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.menu),
                title: isExpanded ? const Text('Navigation') : null,
                trailing: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  ),
                  onPressed: onToggleExpanded,
                  tooltip: isExpanded ? 'Collapse' : 'Expand',
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      selected: selectedCategory == null,
                      leading: const Icon(Icons.home),
                      title: isExpanded ? const Text('All Entries') : null,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            null;
                      },
                    ),
                    const SizedBox(height: 8),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'CATEGORIES',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ...categories.map(
                      (category) => ListTile(
                        selected: selectedCategory == category,
                        leading: const Icon(Icons.label),
                        title: isExpanded ? Text(category) : null,
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: isExpanded ? const Text('Settings') : null,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings would be implemented here'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: isExpanded ? const Text('Help') : null,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help documentation would be shown here'),
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

class NavigationDrawer extends ConsumerWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Worksheet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accounting & Finance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            selected: selectedCategory == null,
            leading: const Icon(Icons.home),
            title: const Text('All Entries'),
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'CATEGORIES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...categories.map(
            (category) => ListTile(
              selected: selectedCategory == category,
              leading: const Icon(Icons.label),
              title: Text(category),
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = category;
                Navigator.pop(context);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics would be shown here')),
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings would be implemented here'),
                ),
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help documentation would be shown here'),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class EntryDetailPanel extends ConsumerWidget {
  final AccountingEntry entry;

  const EntryDetailPanel({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(selectedEntryProvider.notifier).state = null;
                  },
                  tooltip: 'Close',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            LabelValueRow(label: 'Account', value: entry.account),
            const SizedBox(height: 16),
            LabelValueRow(
              label: 'Description',
              value: entry.description,
              isMultiLine: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LabelValueRow(
                    label: 'Date',
                    value: DateFormat('MMM d, y').format(entry.date),
                  ),
                ),
                Expanded(
                  child: LabelValueRow(
                    label: 'Category',
                    value: entry.category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child:
                      entry.debit > 0
                          ? LabelValueRow(
                            label: 'Debit Amount',
                            value: formatter.format(entry.debit),
                            valueColor: Colors.green,
                          )
                          : const LabelValueRow(
                            label: 'Debit Amount',
                            value: '-',
                          ),
                ),
                Expanded(
                  child:
                      entry.credit > 0
                          ? LabelValueRow(
                            label: 'Credit Amount',
                            value: formatter.format(entry.credit),
                            valueColor: Colors.red,
                          )
                          : const LabelValueRow(
                            label: 'Credit Amount',
                            value: '-',
                          ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Entry'),
                    onPressed: () => _showEditDialog(context, ref),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Entry'),
                    onPressed: () => _confirmDelete(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Text(
              'Related Transactions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildRelatedTransactions(context, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedTransactions(BuildContext context, WidgetRef ref) {
    final allEntries = ref.watch(accountingEntriesProvider);
    final relatedEntries =
        allEntries
            .where(
              (e) =>
                  e.id != entry.id &&
                  (e.account == entry.account ||
                      e.category == entry.category ||
                      (e.date.day == entry.date.day &&
                          e.date.month == entry.date.month &&
                          e.date.year == entry.date.year)),
            )
            .toList();

    if (relatedEntries.isEmpty) {
      return const Center(child: Text('No related transactions found'));
    }

    return ListView.builder(
      itemCount: relatedEntries.length,
      itemBuilder: (context, index) {
        final relatedEntry = relatedEntries[index];
        final formatter = NumberFormat.currency(symbol: '\$');

        return ListTile(
          title: Text(relatedEntry.account),
          subtitle: Text(
            '${DateFormat('MMM d').format(relatedEntry.date)} - ${relatedEntry.description}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            relatedEntry.debit > 0
                ? formatter.format(relatedEntry.debit)
                : formatter.format(relatedEntry.credit),
            style: TextStyle(
              color: relatedEntry.debit > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            ref.read(selectedEntryProvider.notifier).state = relatedEntry;
          },
        );
      },
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
    final categories = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: SizedBox(
            width: 500, // Wider dialog for large screens
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: accountController,
                          decoration: const InputDecoration(
                            labelText: 'Account',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return categories;
                            }
                            return categories.where(
                              (category) => category.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            categoryController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            textEditingController.text =
                                categoryController.text;
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                hintText: 'Select or type category',
                              ),
                              onChanged: (value) {
                                categoryController.text = value;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: debitController,
                          decoration: const InputDecoration(
                            labelText: 'Debit Amount',
                            prefixIcon: Icon(Icons.arrow_upward),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: creditController,
                          decoration: const InputDecoration(
                            labelText: 'Credit Amount',
                            prefixIcon: Icon(Icons.arrow_downward),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
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
            ElevatedButton(
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
                  ref.read(selectedEntryProvider.notifier).state = updatedEntry;
                  Navigator.of(context).pop();

                  // Show snackbar confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Entry for "${accountController.text}" updated successfully',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete the entry for "${entry.account}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(accountingEntriesProvider.notifier)
                    .removeEntry(entry.id);
                ref.read(selectedEntryProvider.notifier).state = null;
                Navigator.of(context).pop();

                // Show snackbar confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entry for "${entry.account}" deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref
                            .read(accountingEntriesProvider.notifier)
                            .addEntry(entry);
                      },
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class LabelValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiLine;
  final Color? valueColor;

  const LabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.isMultiLine = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: valueColor),
          maxLines: isMultiLine ? null : 1,
          overflow: isMultiLine ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class AnalyticsPanel extends ConsumerWidget {
  const AnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesByCategory = ref.watch(entriesByCategoryProvider);
    final formatter = NumberFormat.currency(symbol: '\$');
    final dateRange = ref.watch(selectedDateRangeProvider);
    final dateRangeText =
        dateRange != null
            ? '${DateFormat('MMM d, y').format(dateRange.start)} - ${DateFormat('MMM d, y').format(dateRange.end)}'
            : 'All Time';

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Analytics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  dateRangeText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child:
                  entriesByCategory.isEmpty
                      ? const Center(
                        child: Text('No data available for analysis'),
                      )
                      : _buildCategoryAnalysis(
                        context,
                        entriesByCategory,
                        formatter,
                      ),
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: _buildSummaryChart(context, entriesByCategory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalysis(
    BuildContext context,
    Map<String, double> entriesByCategory,
    NumberFormat formatter,
  ) {
    final sortedEntries =
        entriesByCategory.entries.toList()
          ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return ListView.builder(
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final percentValue =
            entriesByCategory.values.fold(
                      0.0,
                      (sum, value) => sum + value.abs(),
                    ) !=
                    0
                ? entry.value.abs() /
                    entriesByCategory.values.fold(
                      0.0,
                      (sum, value) => sum + value.abs(),
                    )
                : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    formatter.format(entry.value),
                    style: TextStyle(
                      color: entry.value >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentValue,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  entry.value >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(percentValue * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryChart(
    BuildContext context,
    Map<String, double> entriesByCategory,
  ) {
    // This would be integrated with a charting library like fl_chart
    // Here we're just mocking the chart display with a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pie_chart, size: 64),
          const SizedBox(height: 16),
          Text(
            'Category Distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'A detailed chart would be implemented here',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
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
    final dateRangeText =
        dateRange != null
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 900;

          if (isWideScreen) {
            // Horizontal layout for wider screens
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateRangeText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
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
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          balance >= 0
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          balance >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: balance >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Net Balance: ${formatter.format(balance)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: balance >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Default vertical layout for narrower screens
            return Column(
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        balance >= 0
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
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: balance >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
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

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by account, description or category',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            filter.isNotEmpty
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
            flex: 3,
            child: Text(
              'Account/Description',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Category',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Debit',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Credit',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 80), // Space for actions
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
    final selectedEntry = ref.watch(selectedEntryProvider);
    final isSelected = selectedEntry != null && selectedEntry.id == entry.id;

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
        if (isSelected) {
          ref.read(selectedEntryProvider.notifier).state = null;
        }
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: Text(
                'Are you sure you want to delete entry for "${entry.account}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      child: InkWell(
        onTap: () {
          ref.read(selectedEntryProvider.notifier).state = entry;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.account,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  entry.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(DateFormat('MMM d, y').format(entry.date)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  entry.debit > 0 ? formatter.format(entry.debit) : '',
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  entry.credit > 0 ? formatter.format(entry.credit) : '',
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(context, ref),
                      tooltip: 'Edit entry',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _confirmDelete(context, ref),
                      tooltip: 'Delete entry',
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
    final categories = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: SizedBox(
            width: 500, // Wider dialog for large screens
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: accountController,
                          decoration: const InputDecoration(
                            labelText: 'Account',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return categories;
                            }
                            return categories.where(
                              (category) => category.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            categoryController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            textEditingController.text =
                                categoryController.text;
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                hintText: 'Select or type category',
                              ),
                              onChanged: (value) {
                                categoryController.text = value;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: debitController,
                          decoration: const InputDecoration(
                            labelText: 'Debit Amount',
                            prefixIcon: Icon(Icons.arrow_upward),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: creditController,
                          decoration: const InputDecoration(
                            labelText: 'Credit Amount',
                            prefixIcon: Icon(Icons.arrow_downward),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
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
            ElevatedButton(
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
                  ref.read(selectedEntryProvider.notifier).state = updatedEntry;
                  Navigator.of(context).pop();

                  // Show snackbar confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Entry for "${accountController.text}" updated successfully',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete the entry for "${entry.account}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(accountingEntriesProvider.notifier)
                    .removeEntry(entry.id);
                if (ref.read(selectedEntryProvider)?.id == entry.id) {
                  ref.read(selectedEntryProvider.notifier).state = null;
                }
                Navigator.of(context).pop();

                // Show snackbar confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entry for "${entry.account}" deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref
                            .read(accountingEntriesProvider.notifier)
                            .addEntry(entry);
                      },
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Main function to run the app
void main() {
  runApp(const AccountingWorksheetApp());
}
