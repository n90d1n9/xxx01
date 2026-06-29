import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Models
class AccountEntry {
  final String id;
  final String accountCode;
  final String accountName;
  final double debitAmount;
  final double creditAmount;

  AccountEntry({
    required this.id,
    required this.accountCode,
    required this.accountName,
    this.debitAmount = 0.0,
    this.creditAmount = 0.0,
  });

  AccountEntry copyWith({
    String? id,
    String? accountCode,
    String? accountName,
    double? debitAmount,
    double? creditAmount,
  }) {
    return AccountEntry(
      id: id ?? this.id,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      debitAmount: debitAmount ?? this.debitAmount,
      creditAmount: creditAmount ?? this.creditAmount,
    );
  }
}

// Providers
final accountEntriesProvider =
    StateNotifierProvider<AccountEntriesNotifier, List<AccountEntry>>((ref) {
      return AccountEntriesNotifier();
    });

final balanceVerificationProvider = Provider<BalanceVerification>((ref) {
  final entries = ref.watch(accountEntriesProvider);

  double totalDebit = 0.0;
  double totalCredit = 0.0;

  for (var entry in entries) {
    totalDebit += entry.debitAmount;
    totalCredit += entry.creditAmount;
  }

  bool isBalanced = totalDebit == totalCredit;

  return BalanceVerification(
    totalDebit: totalDebit,
    totalCredit: totalCredit,
    isBalanced: isBalanced,
    difference: (totalDebit - totalCredit).abs(),
  );
});

// State Notifier
class AccountEntriesNotifier extends StateNotifier<List<AccountEntry>> {
  AccountEntriesNotifier()
    : super([
        // Sample data - replace with actual data from your backend
        AccountEntry(
          id: '1',
          accountCode: '1110',
          accountName: 'Kas',
          debitAmount: 15000000,
          creditAmount: 0,
        ),
        AccountEntry(
          id: '2',
          accountCode: '1120',
          accountName: 'Piutang Usaha',
          debitAmount: 8500000,
          creditAmount: 0,
        ),
        AccountEntry(
          id: '3',
          accountCode: '1210',
          accountName: 'Peralatan',
          debitAmount: 12000000,
          creditAmount: 0,
        ),
        AccountEntry(
          id: '4',
          accountCode: '2110',
          accountName: 'Utang Usaha',
          debitAmount: 0,
          creditAmount: 5500000,
        ),
        AccountEntry(
          id: '5',
          accountCode: '3110',
          accountName: 'Modal',
          debitAmount: 0,
          creditAmount: 25000000,
        ),
        AccountEntry(
          id: '6',
          accountCode: '4110',
          accountName: 'Pendapatan Jasa',
          debitAmount: 0,
          creditAmount: 7500000,
        ),
        AccountEntry(
          id: '7',
          accountCode: '5110',
          accountName: 'Beban Gaji',
          debitAmount: 2500000,
          creditAmount: 0,
        ),
      ]);

  void updateEntry(AccountEntry entry) {
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
  }

  void addEntry(AccountEntry entry) {
    state = [...state, entry];
  }

  void removeEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }
}

// Balance Verification Model
class BalanceVerification {
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;
  final double difference;

  BalanceVerification({
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
    required this.difference,
  });
}

// Main Screen
class NeracaSaldoScreen extends ConsumerStatefulWidget {
  const NeracaSaldoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NeracaSaldoScreen> createState() => _NeracaSaldoScreenState();
}

class _NeracaSaldoScreenState extends ConsumerState<NeracaSaldoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountCodeController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _debitController = TextEditingController();
  final _creditController = TextEditingController();

  @override
  void dispose() {
    _accountCodeController.dispose();
    _accountNameController.dispose();
    _debitController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  void _addNewEntry() {
    if (_formKey.currentState!.validate()) {
      final newEntry = AccountEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        accountCode: _accountCodeController.text,
        accountName: _accountNameController.text,
        debitAmount: double.tryParse(_debitController.text) ?? 0.0,
        creditAmount: double.tryParse(_creditController.text) ?? 0.0,
      );

      ref.read(accountEntriesProvider.notifier).addEntry(newEntry);

      // Clear form
      _accountCodeController.clear();
      _accountNameController.clear();
      _debitController.clear();
      _creditController.clear();

      Navigator.pop(context);
    }
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Akun Baru'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _accountCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Akun',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kode akun tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Akun',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama akun tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _debitController,
                      decoration: const InputDecoration(
                        labelText: 'Debit',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _creditController,
                      decoration: const InputDecoration(
                        labelText: 'Kredit',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: _addNewEntry,
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(accountEntriesProvider);
    final balance = ref.watch(balanceVerificationProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neraca Saldo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              // TODO: Implement save functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Neraca Saldo berhasil disimpan')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              // TODO: Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mencetak Neraca Saldo')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PT. Contoh Perusahaan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Neraca Saldo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Per ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // Balance Status
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  balance.isBalanced
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: balance.isBalanced ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  balance.isBalanced ? Icons.check_circle : Icons.error,
                  color: balance.isBalanced ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    balance.isBalanced
                        ? 'Neraca Saldo seimbang'
                        : 'Neraca Saldo tidak seimbang (selisih ${currencyFormat.format(balance.difference)})',
                    style: TextStyle(
                      color: balance.isBalanced ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const SizedBox(width: 60),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Akun',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Debit',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Kredit',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 48), // Actions column
              ],
            ),
          ),

          // Divider
          const Divider(height: 16, indent: 16, endIndent: 16),

          // Account entries
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            entry.accountCode,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.accountName,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.debitAmount > 0
                                ? currencyFormat.format(entry.debitAmount)
                                : '-',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.creditAmount > 0
                                ? currencyFormat.format(entry.creditAmount)
                                : '-',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              // Show options for this entry
                              showModalBottomSheet(
                                context: context,
                                builder:
                                    (context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text('Edit'),
                                          onTap: () {
                                            // TODO: Implement edit functionality
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          title: const Text(
                                            'Hapus',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            ref
                                                .read(
                                                  accountEntriesProvider
                                                      .notifier,
                                                )
                                                .removeEntry(entry.id);
                                          },
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
              },
            ),
          ),

          // Totals
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currencyFormat.format(balance.totalDebit),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currencyFormat.format(balance.totalCredit),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Main app
class NeracaSaldoApp extends StatelessWidget {
  const NeracaSaldoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Neraca Saldo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const NeracaSaldoScreen(),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // Initialize Indonesian locale
  runApp(const NeracaSaldoApp());
}
