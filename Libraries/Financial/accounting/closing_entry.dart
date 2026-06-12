// closing_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
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

final filteredEntriesProvider = Provider<List<ClosingEntry>>((ref) {
  final entries = ref.watch(closingEntriesProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return entries.where((entry) {
    return entry.date.year == selectedDate.year &&
        entry.date.month == selectedDate.month;
  }).toList();
});

final totalDebitsProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  return entries.where((e) => e.isDebit).fold(0, (sum, e) => sum + e.amount);
});

final totalCreditsProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  return entries.where((e) => !e.isDebit).fold(0, (sum, e) => sum + e.amount);
});

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
          date: DateTime.now(),
          description: 'Close expense accounts',
        ),
        ClosingEntry(
          id: '4',
          account: 'Expenses',
          amount: 35000.00,
          isDebit: false,
          date: DateTime.now(),
          description: 'Close expense accounts',
        ),
      ]);

  void addEntry(ClosingEntry entry) {
    state = [...state, entry];
  }

  void removeEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
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

      _accountController.clear();
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _isAddingEntry = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Closing entry added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(filteredEntriesProvider);
    final totalDebits = ref.watch(totalDebitsProvider);
    final totalCredits = ref.watch(totalCreditsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Closing Entries',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
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
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(totalDebits, totalCredits),
          _buildDateSelector(selectedDate),
          Expanded(
            child: _isAddingEntry
                ? _buildEntryForm()
                : _buildEntriesList(entries),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () {
          setState(() {
            _isAddingEntry = !_isAddingEntry;
          });
        },
        child: Icon(
          _isAddingEntry ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalDebits, double totalCredits) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text(
            'Closing Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: title == 'Difference'
                  ? (isBalanced ? Colors.green : Colors.red)
                  : Colors.white,
            ),
            const SizedBox(width: 4),
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
    );
  }

  Widget _buildDateSelector(DateTime selectedDate) {
    final formatter = DateFormat('MMMM yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildEntriesList(List<ClosingEntry> entries) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(ClosingEntry entry) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                    color: entry.isDebit
                        ? const Color(0xFFEBF4FF)
                        : const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.isDebit ? 'Debit' : 'Credit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: entry.isDebit
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(entry.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Closing Entry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: 'Account',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.account_balance),
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.attach_money),
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
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Entry Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Debit'),
                    value: true,
                    groupValue: _isDebit,
                    onChanged: (value) {
                      setState(() {
                        _isDebit = value!;
                      });
                    },
                    activeColor: const Color(0xFF6366F1),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Credit'),
                    value: false,
                    groupValue: _isDebit,
                    onChanged: (value) {
                      setState(() {
                        _isDebit = value!;
                      });
                    },
                    activeColor: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  runApp(ProviderScope(child: const MaterialApp(home: ClosingEntryScreen())));
}
