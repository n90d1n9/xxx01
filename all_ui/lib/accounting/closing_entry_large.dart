// closing_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class ClosingEntry {
  final String id;
  final String account;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final String description;

  ClosingEntry({
    required this.id,
    required this.account,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.description,
  });
}

// Providers
final closingEntriesProvider =
    StateNotifierProvider<ClosingEntriesNotifier, List<ClosingEntry>>((ref) {
      return ClosingEntriesNotifier();
    });

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedFiscalYearProvider = StateProvider<int>(
  (ref) => DateTime.now().year,
);

final filteredEntriesProvider = Provider<List<ClosingEntry>>((ref) {
  final entries = ref.watch(closingEntriesProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return entries.where((entry) {
    return entry.date.year == selectedDate.year &&
        entry.date.month == selectedDate.month;
  }).toList();
});

final fiscalYearEntriesProvider = Provider<List<ClosingEntry>>((ref) {
  final entries = ref.watch(closingEntriesProvider);
  final fiscalYear = ref.watch(selectedFiscalYearProvider);

  return entries.where((entry) => entry.date.year == fiscalYear).toList();
});

final monthlyTotalsProvider = Provider<Map<int, Map<String, double>>>((ref) {
  final entries = ref.watch(fiscalYearEntriesProvider);
  final Map<int, Map<String, double>> result = {};

  for (var i = 1; i <= 12; i++) {
    final monthEntries = entries.where((e) => e.date.month == i).toList();
    final debits = monthEntries
        .where((e) => e.isDebit)
        .fold(0.0, (sum, e) => sum + e.amount);
    final credits = monthEntries
        .where((e) => !e.isDebit)
        .fold(0.0, (sum, e) => sum + e.amount);

    result[i] = {
      'debits': debits,
      'credits': credits,
      'balance': debits - credits,
    };
  }

  return result;
});

final totalDebitsProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  return entries.where((e) => e.isDebit).fold(0, (sum, e) => sum + e.amount);
});

final totalCreditsProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  return entries.where((e) => !e.isDebit).fold(0, (sum, e) => sum + e.amount);
});

final selectedEntryProvider = StateProvider<String?>((ref) => null);

// Notifier
class ClosingEntriesNotifier extends StateNotifier<List<ClosingEntry>> {
  ClosingEntriesNotifier()
    : super([
        ClosingEntry(
          id: '1',
          account: 'Revenue',
          amount: 50000.00,
          isDebit: true,
          date: DateTime.now(),
          description: 'Close revenue accounts',
        ),
        ClosingEntry(
          id: '2',
          account: 'Income Summary',
          amount: 50000.00,
          isDebit: false,
          date: DateTime.now(),
          description: 'Close revenue accounts',
        ),
        ClosingEntry(
          id: '3',
          account: 'Income Summary',
          amount: 35000.00,
          isDebit: true,
          date: DateTime.now().subtract(const Duration(days: 1)),
          description: 'Close expense accounts',
        ),
        ClosingEntry(
          id: '4',
          account: 'Expenses',
          amount: 35000.00,
          isDebit: false,
          date: DateTime.now().subtract(const Duration(days: 1)),
          description: 'Close expense accounts',
        ),
        // Add more sample data across different months
        ClosingEntry(
          id: '5',
          account: 'Revenue',
          amount: 45000.00,
          isDebit: true,
          date: DateTime(DateTime.now().year, DateTime.now().month - 1, 15),
          description: 'Close previous month revenue',
        ),
        ClosingEntry(
          id: '6',
          account: 'Income Summary',
          amount: 45000.00,
          isDebit: false,
          date: DateTime(DateTime.now().year, DateTime.now().month - 1, 15),
          description: 'Close previous month revenue',
        ),
        ClosingEntry(
          id: '7',
          account: 'Income Summary',
          amount: 30000.00,
          isDebit: true,
          date: DateTime(DateTime.now().year, DateTime.now().month - 1, 16),
          description: 'Close previous month expenses',
        ),
        ClosingEntry(
          id: '8',
          account: 'Expenses',
          amount: 30000.00,
          isDebit: false,
          date: DateTime(DateTime.now().year, DateTime.now().month - 1, 16),
          description: 'Close previous month expenses',
        ),
      ]);

  void addEntry(ClosingEntry entry) {
    state = [...state, entry];
  }

  void removeEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }

  void updateEntry(ClosingEntry updatedEntry) {
    state =
        state
            .map((entry) => entry.id == updatedEntry.id ? updatedEntry : entry)
            .toList();
  }
}

// Screen
class ClosingEntryScreen extends ConsumerStatefulWidget {
  const ClosingEntryScreen({super.key});

  @override
  ConsumerState<ClosingEntryScreen> createState() => _ClosingEntryScreenState();
}

class _ClosingEntryScreenState extends ConsumerState<ClosingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDebit = true;
  bool _isAddingEntry = false;
  bool _isEditingEntry = false;

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      if (_isEditingEntry) {
        final selectedEntryId = ref.read(selectedEntryProvider);
        if (selectedEntryId != null) {
          final entries = ref.read(closingEntriesProvider);
          final existingEntry = entries.firstWhere(
            (e) => e.id == selectedEntryId,
          );

          ref
              .read(closingEntriesProvider.notifier)
              .updateEntry(
                ClosingEntry(
                  id: existingEntry.id,
                  account: _accountController.text,
                  amount: amount,
                  isDebit: _isDebit,
                  date: ref.read(selectedDateProvider),
                  description: _descriptionController.text,
                ),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Closing entry updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ref
            .read(closingEntriesProvider.notifier)
            .addEntry(
              ClosingEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                account: _accountController.text,
                amount: amount,
                isDebit: _isDebit,
                date: ref.read(selectedDateProvider),
                description: _descriptionController.text,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Closing entry added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _resetForm();
    }
  }

  void _resetForm() {
    _accountController.clear();
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _isDebit = true;
      _isAddingEntry = false;
      _isEditingEntry = false;
    });
    ref.read(selectedEntryProvider.notifier).state = null;
  }

  void _editEntry(ClosingEntry entry) {
    _accountController.text = entry.account;
    _amountController.text = entry.amount.toString();
    _descriptionController.text = entry.description;

    setState(() {
      _isDebit = entry.isDebit;
      _isAddingEntry = true;
      _isEditingEntry = true;
    });

    ref.read(selectedEntryProvider.notifier).state = entry.id;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Accounting Closing Entries',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: ref.read(selectedDateProvider),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF6366F1),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
                ref.read(selectedFiscalYearProvider.notifier).state =
                    picked.year;
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: screenWidth < 800 ? _buildDrawer() : null,
      body:
          isLargeScreen
              ? _buildLargeScreenLayout()
              : isMediumScreen
              ? _buildMediumScreenLayout()
              : _buildSmallScreenLayout(),
      floatingActionButton:
          screenWidth < 800 || _isAddingEntry
              ? FloatingActionButton(
                backgroundColor: const Color(0xFF6366F1),
                onPressed: () {
                  if (_isAddingEntry) {
                    _resetForm();
                  } else {
                    setState(() {
                      _isAddingEntry = true;
                    });
                  }
                },
                child: Icon(
                  _isAddingEntry ? Icons.close : Icons.add,
                  color: Colors.white,
                ),
              )
              : null,
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        // Left sidebar
        SizedBox(width: 250, child: _buildDrawer(isPermanent: true)),

        // Main content
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildSummaryCards(),
              _buildDateSelector(),
              Expanded(child: _buildEntriesList()),
            ],
          ),
        ),

        // Right sidebar for form
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(-3, 0),
                ),
              ],
            ),
            child:
                _isAddingEntry
                    ? _buildEntryForm()
                    : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.post_add,
                            size: 64,
                            color: Color(0xFFD1D5DB),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Select an entry to edit or',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Entry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isAddingEntry = true;
                                _isEditingEntry = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediumScreenLayout() {
    return Row(
      children: [
        // Left sidebar
        SizedBox(width: 220, child: _buildDrawer(isPermanent: true)),

        // Main content
        Expanded(
          child:
              _isAddingEntry
                  ? _buildEntryForm()
                  : Column(
                    children: [
                      _buildSummaryCards(),
                      _buildDateSelector(),
                      Expanded(child: _buildEntriesList()),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout() {
    return _isAddingEntry
        ? _buildEntryForm()
        : Column(
          children: [
            _buildSummaryCards(),
            _buildDateSelector(),
            Expanded(child: _buildEntriesList()),
          ],
        );
  }

  Widget _buildDrawer({bool isPermanent = false}) {
    final fiscalYear = ref.watch(selectedFiscalYearProvider);
    final monthlyTotals = ref.watch(monthlyTotalsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Drawer(
      elevation: isPermanent ? 0 : 16,
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isPermanent)
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accounting',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Closing Entries',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            if (isPermanent)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accounting',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Closing Entries',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fiscal Year $fiscalYear',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<int>(
                            value: fiscalYear,
                            icon: const Icon(Icons.arrow_drop_down),
                            underline: const SizedBox(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                ref
                                    .read(selectedFiscalYearProvider.notifier)
                                    .state = newValue;
                              }
                            },
                            items:
                                List<int>.generate(
                                  5,
                                  (i) => DateTime.now().year - 2 + i,
                                ).map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'MONTHLY SUMMARIES',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final monthIndex = index + 1;
                  final isSelected = selectedDate.month == monthIndex;
                  final hasEntries =
                      (monthlyTotals[monthIndex]?['debits'] ?? 0.0) > 0 ||
                      (monthlyTotals[monthIndex]?['credits'] ?? 0.0) > 0;
                  final isBalanced =
                      (monthlyTotals[monthIndex]?['balance'] ?? 0.0) == 0.0;

                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor: const Color(0xFFEEF2FF),
                    leading: Icon(
                      hasEntries
                          ? isBalanced
                              ? Icons.check_circle
                              : Icons.warning
                          : Icons.radio_button_unchecked,
                      color:
                          hasEntries
                              ? isBalanced
                                  ? Colors.green
                                  : Colors.orange
                              : Colors.grey,
                      size: 20,
                    ),
                    title: Text(
                      months[index],
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF4F46E5) : null,
                      ),
                    ),
                    subtitle:
                        hasEntries
                            ? Text(
                              '${NumberFormat.currency(symbol: '\$').format(monthlyTotals[monthIndex]?['debits'] ?? 0)}',
                              style: const TextStyle(fontSize: 12),
                            )
                            : null,
                    trailing:
                        hasEntries
                            ? Text(
                              isBalanced ? 'Balanced' : 'Unbalanced',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isBalanced ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                            : const Text(
                              'No entries',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                    onTap: () {
                      final newDate = DateTime(fiscalYear, monthIndex, 1);
                      ref.read(selectedDateProvider.notifier).state = newDate;
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                // Navigate to help
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalDebits = ref.watch(totalDebitsProvider);
    final totalCredits = ref.watch(totalCreditsProvider);
    final formatter = NumberFormat.currency(symbol: '\$');
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16),
      child:
          screenWidth > 800
              ? Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard('Current Period Summary', [
                      _buildSummaryItem(
                        'Total Debits',
                        formatter.format(totalDebits),
                        Icons.arrow_upward,
                      ),
                      _buildSummaryItem(
                        'Total Credits',
                        formatter.format(totalCredits),
                        Icons.arrow_downward,
                      ),
                      _buildSummaryItem(
                        'Difference',
                        formatter.format((totalDebits - totalCredits).abs()),
                        totalDebits == totalCredits
                            ? Icons.check_circle
                            : Icons.warning,
                        isBalanced: totalDebits == totalCredits,
                      ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard('Quick Actions', [
                      _buildActionButton(
                        'New Journal Entry',
                        Icons.post_add,
                        () {
                          setState(() {
                            _isAddingEntry = true;
                            _isEditingEntry = false;
                          });
                        },
                      ),
                      _buildActionButton(
                        'Generate Report',
                        Icons.summarize,
                        () {
                          // Generate report logic
                        },
                      ),
                      _buildActionButton(
                        'Fiscal Year End Process',
                        Icons.calendar_today,
                        () {
                          // Year end process
                        },
                      ),
                    ]),
                  ),
                ],
              )
              : _buildSummaryCard('Current Period Summary', [
                _buildSummaryItem(
                  'Total Debits',
                  formatter.format(totalDebits),
                  Icons.arrow_upward,
                ),
                _buildSummaryItem(
                  'Total Credits',
                  formatter.format(totalCredits),
                  Icons.arrow_downward,
                ),
                _buildSummaryItem(
                  'Difference',
                  formatter.format((totalDebits - totalCredits).abs()),
                  totalDebits == totalCredits
                      ? Icons.check_circle
                      : Icons.warning,
                  isBalanced: totalDebits == totalCredits,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'New Entry',
                        Icons.post_add,
                        () {
                          setState(() {
                            _isAddingEntry = true;
                            _isEditingEntry = false;
                          });
                        },
                        small: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton('Report', Icons.summarize, () {
                        // Generate report logic
                      }, small: true),
                    ),
                  ],
                ),
              ]),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon, {
    bool isBalanced = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  title == 'Difference'
                      ? (isBalanced ? Colors.green : Colors.red)
                      : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool small = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: small ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: small ? 18 : 24, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: small ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final selectedDate = ref.watch(selectedDateProvider);
    final formatter = DateFormat('MMMM yyyy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
                selectedDate.day,
              );
            },
          ),
          Text(
            formatter.format(selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
                selectedDate.day,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    final entries = ref.watch(filteredEntriesProvider);

    if (entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No closing entries for this period',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Closing Entries',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildEntryCard(entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(ClosingEntry entry) {
    final formatter = NumberFormat.currency(symbol: '\$');
    final screenWidth = MediaQuery.of(context).size.width;
    final selectedEntryId = ref.watch(selectedEntryProvider);
    final isSelected = selectedEntryId == entry.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (screenWidth > 1200) {
            _editEntry(entry);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              screenWidth > 800
                  ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.account,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    entry.isDebit
                                        ? const Color(0xFFEBF4FF)
                                        : const Color(0xFFFFF5F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                entry.isDebit ? 'Debit' : 'Credit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      entry.isDebit
                                          ? const Color(0xFF1E40AF)
                                          : const Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          formatter.format(entry.amount),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          DateFormat('MMM d, yyyy').format(entry.date),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      screenWidth > 1200
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                onPressed: () => _editEntry(entry),
                                tooltip: 'Edit Entry',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ref
                                      .read(closingEntriesProvider.notifier)
                                      .removeEntry(entry.id);
                                },
                                tooltip: 'Delete Entry',
                              ),
                            ],
                          )
                          : const SizedBox(width: 0),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.account,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  entry.isDebit
                                      ? const Color(0xFFEBF4FF)
                                      : const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.isDebit ? 'Debit' : 'Credit',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    entry.isDebit
                                        ? const Color(0xFF1E40AF)
                                        : const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(entry.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            formatter.format(entry.amount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            onPressed: () => _editEntry(entry),
                            tooltip: 'Edit Entry',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              ref
                                  .read(closingEntriesProvider.notifier)
                                  .removeEntry(entry.id);
                            },
                            tooltip: 'Delete Entry',
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildEntryForm() {
    final selectedEntryId = ref.watch(selectedEntryProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditingEntry ? 'Edit Closing Entry' : 'Add Closing Entry',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: 'Account',
                hintText: 'e.g. Revenue, Expenses, Income Summary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.account_balance),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an account';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 5000.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Close revenue accounts for the fiscal period',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.description),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Entry Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildEntryTypeOption(
                    title: 'Debit',
                    icon: Icons.arrow_upward,
                    iconColor: const Color(0xFF1E40AF),
                    backgroundColor: const Color(0xFFEBF4FF),
                    isSelected: _isDebit,
                    onTap: () {
                      setState(() {
                        _isDebit = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEntryTypeOption(
                    title: 'Credit',
                    icon: Icons.arrow_downward,
                    iconColor: const Color(0xFFB91C1C),
                    backgroundColor: const Color(0xFFFFF5F5),
                    isSelected: !_isDebit,
                    onTap: () {
                      setState(() {
                        _isDebit = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_isEditingEntry ? Icons.save : Icons.add),
                    label: Text(
                      _isEditingEntry ? 'Update Entry' : 'Save Entry',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitForm,
                  ),
                ),
              ],
            ),
            if (_isEditingEntry)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _resetForm,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTypeOption({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? iconColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Main app entry for testing
class ClosingEntryApp extends StatelessWidget {
  const ClosingEntryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Accounting Closing Entries',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const ClosingEntryScreen(),
      ),
    );
  }
}

void main() {
  runApp(const ClosingEntryApp());
}
