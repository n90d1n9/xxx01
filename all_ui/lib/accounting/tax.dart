import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

// Model untuk data pajak
class TaxData {
  final double amount;
  final double vatRate;
  final double salesTaxRate;
  final double totalTax;
  final double totalAmount;
  final DateTime date;

  TaxData({
    required this.amount,
    required this.vatRate,
    required this.salesTaxRate,
    required this.date,
  }) : totalTax = (amount * vatRate / 100) + (amount * salesTaxRate / 100),
       totalAmount =
           amount + (amount * vatRate / 100) + (amount * salesTaxRate / 100);
}

// Provider untuk menyimpan daftar transaksi pajak
final taxTransactionsProvider =
    StateNotifierProvider<TaxTransactionsNotifier, List<TaxData>>(
      (ref) => TaxTransactionsNotifier(),
    );

class TaxTransactionsNotifier extends StateNotifier<List<TaxData>> {
  TaxTransactionsNotifier() : super([]);

  void addTransaction(TaxData taxData) {
    state = [...state, taxData];
  }

  void clearTransactions() {
    state = [];
  }
}

// Provider untuk formulir perhitungan pajak
final amountProvider = StateProvider<double>((ref) => 0);
final vatRateProvider = StateProvider<double>(
  (ref) => 11,
); // PPN default Indonesia (11%)
final salesTaxProvider = StateProvider<double>(
  (ref) => 0,
); // Pajak penjualan, jika diperlukan

// Provider untuk hasil perhitungan
final calculatedTaxProvider = Provider<double>((ref) {
  final amount = ref.watch(amountProvider);
  final vatRate = ref.watch(vatRateProvider);
  final salesTax = ref.watch(salesTaxProvider);

  return (amount * vatRate / 100) + (amount * salesTax / 100);
});

final totalAmountProvider = Provider<double>((ref) {
  final amount = ref.watch(amountProvider);
  final calculatedTax = ref.watch(calculatedTaxProvider);

  return amount + calculatedTax;
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Pajak Indonesia',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Pajak Indonesia'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TaxCalculatorCard(),
            const SizedBox(height: 16),
            const Expanded(child: TransactionHistoryCard()),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaxReportScreen(),
                  ),
                );
              },
              child: const Text('Lihat Laporan Pajak'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaxCalculatorCard extends ConsumerStatefulWidget {
  const TaxCalculatorCard({Key? key}) : super(key: key);

  @override
  ConsumerState<TaxCalculatorCard> createState() => _TaxCalculatorCardState();
}

class _TaxCalculatorCardState extends ConsumerState<TaxCalculatorCard> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTax = ref.watch(calculatedTaxProvider);
    final totalAmount = ref.watch(totalAmountProvider);

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kalkulator Pajak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty && double.tryParse(value) != null) {
                    ref.read(amountProvider.notifier).state = double.parse(
                      value,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final vatRate = ref.watch(vatRateProvider);

                  return Row(
                    children: [
                      const Text('PPN (%): '),
                      Expanded(
                        child: Slider(
                          value: vatRate,
                          min: 0,
                          max: 20,
                          divisions: 20,
                          label: vatRate.toStringAsFixed(1),
                          onChanged: (value) {
                            ref.read(vatRateProvider.notifier).state = value;
                          },
                        ),
                      ),
                      Text('${vatRate.toStringAsFixed(1)}%'),
                    ],
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final salesTax = ref.watch(salesTaxProvider);

                  return Row(
                    children: [
                      const Text('Pajak Penjualan (%): '),
                      Expanded(
                        child: Slider(
                          value: salesTax,
                          min: 0,
                          max: 10,
                          divisions: 10,
                          label: salesTax.toStringAsFixed(1),
                          onChanged: (value) {
                            ref.read(salesTaxProvider.notifier).state = value;
                          },
                        ),
                      ),
                      Text('${salesTax.toStringAsFixed(1)}%'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pajak:'),
                  Text(
                    formatter.format(calculatedTax),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total dengan Pajak:'),
                  Text(
                    formatter.format(totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final amount = ref.read(amountProvider);
                      final vatRate = ref.read(vatRateProvider);
                      final salesTax = ref.read(salesTaxProvider);

                      final taxData = TaxData(
                        amount: amount,
                        vatRate: vatRate,
                        salesTaxRate: salesTax,
                        date: DateTime.now(),
                      );

                      ref
                          .read(taxTransactionsProvider.notifier)
                          .addTransaction(taxData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaksi disimpan')),
                      );

                      _amountController.clear();
                      ref.read(amountProvider.notifier).state = 0;
                    }
                  },
                  child: const Text('Simpan Transaksi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionHistoryCard extends ConsumerWidget {
  const TransactionHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(taxTransactionsProvider);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (transactions.isEmpty) {
      return const Card(
        elevation: 4,
        child: Center(child: Text('Belum ada transaksi')),
      );
    }

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(taxTransactionsProvider.notifier)
                        .clearTransactions();
                  },
                  child: const Text('Hapus Semua'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction =
                    transactions[transactions.length - 1 - index];
                return ListTile(
                  title: Text(
                    '${formatter.format(transaction.amount)} + ${formatter.format(transaction.totalTax)}',
                  ),
                  subtitle: Text(
                    'PPN: ${transaction.vatRate}% | Pajak Penjualan: ${transaction.salesTaxRate}%\n'
                    '${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)}',
                  ),
                  trailing: Text(
                    formatter.format(transaction.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaxReportScreen extends ConsumerWidget {
  const TaxReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(taxTransactionsProvider);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Menghitung total untuk laporan
    double totalAmount = 0;
    double totalVAT = 0;
    double totalSalesTax = 0;

    for (var transaction in transactions) {
      totalAmount += transaction.amount;
      totalVAT += transaction.amount * transaction.vatRate / 100;
      totalSalesTax += transaction.amount * transaction.salesTaxRate / 100;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pajak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () async {
              await _generatePdfReport(transactions, context);
            },
            tooltip: 'Simpan PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Pajak',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Periode', 'Bulan Ini'),
                    _buildSummaryRow(
                      'Total Transaksi',
                      transactions.length.toString(),
                    ),
                    _buildSummaryRow(
                      'Total Nilai Transaksi',
                      formatter.format(totalAmount),
                    ),
                    _buildSummaryRow('Total PPN', formatter.format(totalVAT)),
                    _buildSummaryRow(
                      'Total Pajak Penjualan',
                      formatter.format(totalSalesTax),
                    ),
                    _buildSummaryRow(
                      'Total Pajak',
                      formatter.format(totalVAT + totalSalesTax),
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Total Keseluruhan',
                      formatter.format(totalAmount + totalVAT + totalSalesTax),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Daftar Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  transactions.isEmpty
                      ? const Center(child: Text('Belum ada transaksi'))
                      : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                '${formatter.format(transaction.amount)} + ${formatter.format(transaction.totalTax)}',
                              ),
                              subtitle: Text(
                                'Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)}\n'
                                'PPN: ${transaction.vatRate}% | Pajak Penjualan: ${transaction.salesTaxRate}%',
                              ),
                              trailing: Text(
                                formatter.format(transaction.totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              isThreeLine: true,
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdfReport(
    List<TaxData> transactions,
    BuildContext context,
  ) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Menghitung total untuk laporan
    double totalAmount = 0;
    double totalVAT = 0;
    double totalSalesTax = 0;

    for (var transaction in transactions) {
      totalAmount += transaction.amount;
      totalVAT += transaction.amount * transaction.vatRate / 100;
      totalSalesTax += transaction.amount * transaction.salesTaxRate / 100;
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Laporan Pajak',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Ringkasan Pajak',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfSummaryRow('Periode', 'Bulan Ini'),
              _buildPdfSummaryRow(
                'Total Transaksi',
                transactions.length.toString(),
              ),
              _buildPdfSummaryRow(
                'Total Nilai Transaksi',
                formatter.format(totalAmount),
              ),
              _buildPdfSummaryRow('Total PPN', formatter.format(totalVAT)),
              _buildPdfSummaryRow(
                'Total Pajak Penjualan',
                formatter.format(totalSalesTax),
              ),
              _buildPdfSummaryRow(
                'Total Pajak',
                formatter.format(totalVAT + totalSalesTax),
              ),
              pw.Divider(),
              _buildPdfSummaryRow(
                'Total Keseluruhan',
                formatter.format(totalAmount + totalVAT + totalSalesTax),
                isTotal: true,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Daftar Transaksi',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfTransactionsTable(transactions, formatter),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text(
                  'Dokumen ini dibuat otomatis oleh aplikasi Kalkulator Pajak Indonesia.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Dicetak pada: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Menyimpan PDF
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/laporan_pajak_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    // Berbagi file
    await Share.shareXFiles([XFile(file.path)], text: 'Laporan Pajak');
  }

  pw.Widget _buildPdfSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTransactionsTable(
    List<TaxData> transactions,
    NumberFormat formatter,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Table header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildPdfTableCell('No.', isHeader: true),
            _buildPdfTableCell('Tanggal', isHeader: true),
            _buildPdfTableCell('Nilai', isHeader: true),
            _buildPdfTableCell('Pajak', isHeader: true),
            _buildPdfTableCell('Total', isHeader: true),
          ],
        ),
        // Table data
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          return pw.TableRow(
            children: [
              _buildPdfTableCell('${index + 1}'),
              _buildPdfTableCell(
                DateFormat('dd/MM/yyyy\nHH:mm').format(transaction.date),
              ),
              _buildPdfTableCell(formatter.format(transaction.amount)),
              _buildPdfTableCell(formatter.format(transaction.totalTax)),
              _buildPdfTableCell(formatter.format(transaction.totalAmount)),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}

// Provider untuk laporan pajak
class TaxReportService {
  static Future<void> generateMonthlyReport(List<TaxData> transactions) async {
    // Implementasi laporan pajak bulanan untuk kepatuhan pajak Indonesia
    // Sesuai format laporan SPT PPN
  }

  static Future<void> generateQuarterlyReport(
    List<TaxData> transactions,
  ) async {
    // Implementasi laporan pajak kuartal
  }

  static Future<void> generateAnnualReport(List<TaxData> transactions) async {
    // Implementasi laporan pajak tahunan
  }
}

// Class untuk menghitung jenis pajak khusus di Indonesia
class IndonesianTaxCalculator {
  // Pajak Penghasilan (PPh)
  static double calculateIncomeTax(double income, int taxBracket) {
    // Implementasi PPh sesuai dengan tarif pajak Indonesia
    switch (taxBracket) {
      case 1: // 0-60 juta per tahun
        return income * 0.05;
      case 2: // 60-250 juta per tahun
        return income * 0.15;
      case 3: // 250-500 juta per tahun
        return income * 0.25;
      case 4: // 500-5 miliar per tahun
        return income * 0.3;
      case 5: // > 5 miliar per tahun
        return income * 0.35;
      default:
        return income * 0.05;
    }
  }

  // Pajak Pertambahan Nilai (PPN)
  static double calculateVAT(double amount) {
    // PPN standar Indonesia (11% per 2022)
    return amount * 0.11;
  }

  // Pajak Penjualan Barang Mewah (PPnBM)
  static double calculateLuxuryTax(double amount, int category) {
    // Implementasi PPnBM sesuai kategori barang (10%-200%)
    switch (category) {
      case 1: // 10%
        return amount * 0.1;
      case 2: // 20%
        return amount * 0.2;
      case 3: // 30%
        return amount * 0.3;
      case 4: // 40%
        return amount * 0.4;
      case 5: // 50%
        return amount * 0.5;
      // Kategori lainnya bisa ditambahkan sesuai kebutuhan
      default:
        return amount * 0.1;
    }
  }
}
