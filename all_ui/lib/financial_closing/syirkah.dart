import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:docx_template/docx_template.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Syirkah Inan',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: const SyirkahReportForm(),
    );
  }
}

class ReportData {
  String periodeWaktu = '';
  String namaUsaha = '';
  String alamatUsaha = '';

  // Ringkasan Akad
  String ringkasanAkad = '';

  // Keuangan
  List<FinancialItem> pendapatanItems = [];
  List<FinancialItem> pengeluaranItems = [];

  // Pembagian Laba
  List<ProfitShare> profitShares = [];

  // Neraca Modal
  String neracaModal = '';

  // Evaluasi
  bool isJalanLancar = true;
  bool isContinued = true;
  String additionalNotes = '';

  // Tanda Tangan
  String namaMitraA = '';
  String namaMitraB = '';
  DateTime? tanggalA;
  DateTime? tanggalB;

  double get totalPendapatan {
    return pendapatanItems.fold(0, (prev, item) => prev + (item.nominal ?? 0));
  }

  double get totalPengeluaran {
    return pengeluaranItems.fold(0, (prev, item) => prev + (item.nominal ?? 0));
  }

  double get labaBersih {
    return totalPendapatan - totalPengeluaran;
  }
}

class FinancialItem {
  String keterangan = '';
  double? nominal;

  FinancialItem({this.keterangan = '', this.nominal});
}

class ProfitShare {
  String namaMitra = '';
  double? persentase;
  double? nominalDapat;

  ProfitShare({this.namaMitra = '', this.persentase, this.nominalDapat});
}

class SyirkahReportForm extends StatefulWidget {
  const SyirkahReportForm({super.key});

  @override
  State<SyirkahReportForm> createState() => _SyirkahReportFormState();
}

class _SyirkahReportFormState extends State<SyirkahReportForm> {
  final ReportData _reportData = ReportData();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Initialize with some default values
    _reportData.pendapatanItems.add(FinancialItem());
    _reportData.pengeluaranItems.add(FinancialItem());
    _reportData.profitShares.add(ProfitShare());
    _reportData.profitShares.add(ProfitShare());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Tutup Buku Syirkah \'Inan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _showExportOptions,
            tooltip: 'Export Laporan',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildHeader(),
              const Divider(height: 32),
              _buildRingkasanAkad(),
              const Divider(height: 32),
              _buildFinancialSection(),
              const Divider(height: 32),
              _buildProfitSharingSection(),
              const Divider(height: 32),
              _buildNeracaModal(),
              const Divider(height: 32),
              _buildEvaluationSection(),
              const Divider(height: 32),
              _buildSignatureSection(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        icon: const Icon(Icons.save),
        label: const Text('Simpan & Preview'),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'LAPORAN TUTUP BUKU SYIRKAH \'INAN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Periode',
                  hintText: 'Januari-Desember 202X',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Periode tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _reportData.periodeWaktu = value ?? '';
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Usaha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama usaha tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _reportData.namaUsaha = value ?? '';
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Alamat Usaha',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat usaha tidak boleh kosong';
            }
            return null;
          },
          onSaved: (value) {
            _reportData.alamatUsaha = value ?? '';
          },
        ),
      ],
    );
  }

  Widget _buildRingkasanAkad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Ringkasan Akad Syirkah',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Tulis ringkasan akad syirkah di sini...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          onSaved: (value) {
            _reportData.ringkasanAkad = value ?? '';
          },
        ),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Rekap Keuangan Usaha',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          '2.1. Pendapatan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildFinancialItemsList(
          _reportData.pendapatanItems,
          'pendapatan',
          onAdd: () {
            setState(() {
              _reportData.pendapatanItems.add(FinancialItem());
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '2.2. Pengeluaran & Biaya Operasional',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildFinancialItemsList(
          _reportData.pengeluaranItems,
          'pengeluaran',
          onAdd: () {
            setState(() {
              _reportData.pengeluaranItems.add(FinancialItem());
            });
          },
        ),
        const SizedBox(height: 16),
        _buildLabaBersihSection(),
      ],
    );
  }

  Widget _buildFinancialItemsList(
    List<FinancialItem> items,
    String type, {
    required VoidCallback onAdd,
  }) {
    return Column(
      children: [
        ...List.generate(
          items.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Keterangan ${type}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      items[index].keterangan = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nominal (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        items[index].nominal =
                            value.isEmpty ? 0 : double.parse(value);
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed:
                      items.length > 1
                          ? () {
                            setState(() {
                              items.removeAt(index);
                            });
                          }
                          : null,
                ),
              ],
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('Tambah ${type}'),
        ),
      ],
    );
  }

  Widget _buildLabaBersihSection() {
    final totalPendapatan = _reportData.totalPendapatan;
    final totalPengeluaran = _reportData.totalPengeluaran;
    final labaBersih = _reportData.labaBersih;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2.3. Laba Bersih',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pendapatan:'),
              Text(
                currencyFormatter.format(totalPendapatan),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pengeluaran:'),
              Text(
                currencyFormatter.format(totalPengeluaran),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Laba Bersih:'),
              Text(
                currencyFormatter.format(labaBersih),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: labaBersih >= 0 ? Colors.green.shade700 : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitSharingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Pembagian Laba',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _reportData.profitShares.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nama Mitra ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _reportData.profitShares[index].namaMitra = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Persentase (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        _reportData.profitShares[index].persentase =
                            value.isEmpty ? 0 : double.parse(value);
                        _updateProfitShares();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nominal (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text:
                          _reportData.profitShares[index].nominalDapat != null
                              ? currencyFormatter.format(
                                _reportData.profitShares[index].nominalDapat,
                              )
                              : '',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed:
                      _reportData.profitShares.length > 1
                          ? () {
                            setState(() {
                              _reportData.profitShares.removeAt(index);
                              _updateProfitShares();
                            });
                          }
                          : null,
                ),
              ],
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _reportData.profitShares.add(ProfitShare());
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Mitra'),
        ),
      ],
    );
  }

  void _updateProfitShares() {
    final labaBersih = _reportData.labaBersih;

    for (var share in _reportData.profitShares) {
      if (share.persentase != null) {
        share.nominalDapat = labaBersih * (share.persentase! / 100);
      } else {
        share.nominalDapat = 0;
      }
    }
  }

  Widget _buildNeracaModal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Neraca Modal (Opsional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Tulis neraca modal di sini (opsional)...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          onSaved: (value) {
            _reportData.neracaModal = value ?? '';
          },
        ),
      ],
    );
  }

  Widget _buildEvaluationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. Evaluasi & Keputusan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Kegiatan usaha berjalan dengan'),
            const SizedBox(width: 8),
            DropdownButton<bool>(
              value: _reportData.isJalanLancar,
              items: const [
                DropdownMenuItem(value: true, child: Text('lancar')),
                DropdownMenuItem(value: false, child: Text('ada kendala')),
              ],
              onChanged: (value) {
                setState(() {
                  _reportData.isJalanLancar = value ?? true;
                });
              },
            ),
            const Text(' selama periode ini.'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Disepakati bahwa syirkah akan:'),
            const SizedBox(width: 8),
            DropdownButton<bool>(
              value: _reportData.isContinued,
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text('Dilanjutkan untuk periode berikutnya'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Dibubarkan dan dilakukan likuidasi sesuai akad'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _reportData.isContinued = value ?? true;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Catatan Tambahan (opsional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onSaved: (value) {
            _reportData.additionalNotes = value ?? '';
          },
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6. Pernyataan & Tanda Tangan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kami menyatakan bahwa laporan ini telah disusun secara benar, jujur, dan sesuai prinsip syariah:',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pihak A (Mitra):'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _reportData.namaMitraA = value ?? '';
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _reportData.tanggalA = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _reportData.tanggalA != null
                            ? DateFormat(
                              'dd/MM/yyyy',
                            ).format(_reportData.tanggalA!)
                            : 'Pilih Tanggal',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pihak B (Mitra):'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _reportData.namaMitraB = value ?? '';
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _reportData.tanggalB = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _reportData.tanggalB != null
                            ? DateFormat(
                              'dd/MM/yyyy',
                            ).format(_reportData.tanggalB!)
                            : 'Pilih Tanggal',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _updateProfitShares();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReportPreviewScreen(reportData: _reportData),
        ),
      );
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export sebagai PDF'),
                onTap: () {
                  Navigator.pop(context);
                  if (_formKey.currentState?.validate() == true) {
                    _formKey.currentState?.save();
                    _updateProfitShares();
                    _exportToPdf(_reportData);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon lengkapi form terlebih dahulu'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Export sebagai DOCX'),
                onTap: () {
                  Navigator.pop(context);
                  if (_formKey.currentState?.validate() == true) {
                    _formKey.currentState?.save();
                    _updateProfitShares();
                    _exportToDocx(_reportData);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon lengkapi form terlebih dahulu'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text('Cetak Laporan'),
                onTap: () {
                  Navigator.pop(context);
                  if (_formKey.currentState?.validate() == true) {
                    _formKey.currentState?.save();
                    _updateProfitShares();
                    _printReport(_reportData);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon lengkapi form terlebih dahulu'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportToPdf(ReportData data) async {
    final pdf = await _generatePdf(data);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/laporan_syirkah_${data.namaUsaha.replaceAll(' ', '_')}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Laporan Tutup Buku Syirkah \'Inan');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF disimpan di ${file.path}')));
  }

  Future<pw.Document> _generatePdf(ReportData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'LAPORAN TUTUP BUKU SYIRKAH \'INAN',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Periode: ${data.periodeWaktu}')),
                pw.Expanded(child: pw.Text('Nama Usaha: ${data.namaUsaha}')),
              ],
            ),
            pw.Text('Alamat: ${data.alamatUsaha}'),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '1. Ringkasan Akad Syirkah'),
            pw.Text(data.ringkasanAkad),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '2. Rekap Keuangan Usaha'),
            pw.Header(level: 2, text: '2.1. Pendapatan'),
            _buildPdfTable(
              ['Keterangan', 'Nominal (Rp)'],
              data.pendapatanItems
                  .map(
                    (item) => [
                      item.keterangan,
                      currencyFormatter.format(item.nominal ?? 0),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 8),

            pw.Header(level: 2, text: '2.2. Pengeluaran & Biaya Operasional'),
            _buildPdfTable(
              ['Keterangan', 'Nominal (Rp)'],
              data.pengeluaranItems
                  .map(
                    (item) => [
                      item.keterangan,
                      currencyFormatter.format(item.nominal ?? 0),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 8),

            pw.Header(level: 2, text: '2.3. Laba Bersih'),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pendapatan:'),
                      pw.Text(currencyFormatter.format(data.totalPendapatan)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pengeluaran:'),
                      pw.Text(currencyFormatter.format(data.totalPengeluaran)),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Laba Bersih:'),
                      pw.Text(currencyFormatter.format(data.labaBersih)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '3. Pembagian Laba'),
            _buildPdfTable(
              ['Nama Mitra', 'Persentase (%)', 'Nominal (Rp)'],
              data.profitShares
                  .map(
                    (item) => [
                      item.namaMitra,
                      '${item.persentase ?? 0}%',
                      currencyFormatter.format(item.nominalDapat ?? 0),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '4. Neraca Modal (Opsional)'),
            pw.Text(data.neracaModal),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '5. Evaluasi & Keputusan'),
            pw.Text(
              'Kegiatan usaha berjalan dengan ${data.isJalanLancar ? "lancar" : "ada kendala"} selama periode ini.',
            ),
            pw.Text(
              'Disepakati bahwa syirkah akan: ${data.isContinued ? "Dilanjutkan untuk periode berikutnya" : "Dibubarkan dan dilakukan likuidasi sesuai akad"}',
            ),
            pw.Text(data.additionalNotes),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '6. Pernyataan & Tanda Tangan'),
            pw.Text(
              'Kami menyatakan bahwa laporan ini telah disusun secara benar, jujur, dan sesuai prinsip syariah:',
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Pihak A (Mitra)'),
                      pw.SizedBox(height: 40),
                      pw.Text('Nama: ${data.namaMitraA}'),
                      pw.Text(
                        'Tanggal: ${data.tanggalA != null ? DateFormat('dd/MM/yyyy').format(data.tanggalA!) : ""}',
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Pihak B (Mitra)'),
                      pw.SizedBox(height: 40),
                      pw.Text('Nama: ${data.namaMitraB}'),
                      pw.Text(
                        'Tanggal: ${data.tanggalB != null ? DateFormat('dd/MM/yyyy').format(data.tanggalB!) : ""}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfTable(List<String> headers, List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children:
              headers
                  .map(
                    (header) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
        ),
        ...data.map(
          (row) => pw.TableRow(
            children:
                row
                    .map(
                      (cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(cell),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _exportToDocx(ReportData data) async {
    try {
      // Load template from assets
      final templateBytes = await rootBundle.load(
        'assets/templates/syirkah_template.docx',
      );
      final docx = await DocxTemplate.fromBytes(
        templateBytes.buffer.asUint8List(),
      );

      // Prepare content data
      /* final content = Content('', 
        Content('periode', Content(data.periodeWaktu)),
        Content('namaUsaha', Content(data.namaUsaha)),
        Content('alamatUsaha', Content(data.alamatUsaha)),
        Content('ringkasanAkad', Content(data.ringkasanAkad),
        Content('totalPendapatan', Content(currencyFormatter.format(data.totalPendapatan))),
        Content('totalPengeluaran', Content(currencyFormatter.format(data.totalPengeluaran))),
        Content('labaBersih', Content(currencyFormatter.format(data.labaBersih))),
        Content('neracaModal', Content(data.neracaModal),
        Content('jalanLancar', Content(data.isJalanLancar ? 'lancar' : 'ada kendala')),
        Content('statusSyirkah',
            Content(data.isContinued
                ? 'Dilanjutkan untuk periode berikutnya'
                : 'Dibubarkan dan dilakukan likuidasi sesuai akad')),
        Content('additionalNotes', Content(data.additionalNotes)),
        Content('namaMitraA', Content(data.namaMitraA)),
        Content('namaMitraB', Content(data.namaMitraB)),
        Content('tanggalA',Content(
            data.tanggalA != null
                ? DateFormat('dd/MM/yyyy').format(data.tanggalA!)
                : "")),
        Content('tanggalB',Content(
            data.tanggalB != null
                ? DateFormat('dd/MM/yyyy').format(data.tanggalB!)
                : "")));
 */
      // Tables
      /*  Content('pendapatanItems',Content(
            data.pendapatanItems
                .map(
                  (item) => {
                    Content('keterangan', Content(item.keterangan,
                    Content('nominal', Content(currencyFormatter.format(item.nominal ?? 0),
                  },
                )
                .toList(),

        Content('pengeluaranItems',Content(
            data.pengeluaranItems
                .map(
                  (item) => {
                    Content('keterangan', Content(item.keterangan,
                    Content('nominal', Content(currencyFormatter.format(item.nominal ?? 0),
                  },
                )
                .toList(),

        Content('profitShares':
            data.profitShares
                .map(
                  (item) => {
                    Content('namaMitra', Content(item.namaMitra,
                    Content('persentase', Content('${item.persentase ?? 0}%',
                    Content('nominal', Content(currencyFormatter.format(item.nominalDapat ?? 0),
                  },
                )
                .toList(),
      ) */
      //);

      // Generate report from template
      // final generatedDocx = await docx.generate(Content('content', content));

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/laporan_syirkah_${data.namaUsaha.replaceAll(' ', '_')}.docx',
      );
      // await file.writeAsBytes(generatedDocx!);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Laporan Tutup Buku Syirkah \'Inan');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('DOCX disimpan di ${file.path}')));
    } catch (e) {
      // If template is not available, generate a basic docx
      _generateBasicDocx(data);
    }
  }

  Future<void> _generateBasicDocx(ReportData data) async {
    // As a fallback, we'll use a simple text-based output since docx template might not be available
    final content = """
    LAPORAN TUTUP BUKU SYIRKAH 'INAN
    
    Periode: ${data.periodeWaktu}
    Nama Usaha: ${data.namaUsaha}
    Alamat: ${data.alamatUsaha}
    
    1. Ringkasan Akad Syirkah
    ${data.ringkasanAkad}
    
    2. Rekap Keuangan Usaha
    2.1. Pendapatan
    ${data.pendapatanItems.map((item) => "- ${item.keterangan}: ${currencyFormatter.format(item.nominal ?? 0)}").join('\n')}
    
    2.2. Pengeluaran & Biaya Operasional
    ${data.pengeluaranItems.map((item) => "- ${item.keterangan}: ${currencyFormatter.format(item.nominal ?? 0)}").join('\n')}
    
    2.3. Laba Bersih
    Total Pendapatan: ${currencyFormatter.format(data.totalPendapatan)}
    Total Pengeluaran: ${currencyFormatter.format(data.totalPengeluaran)}
    Laba Bersih: ${currencyFormatter.format(data.labaBersih)}
    
    3. Pembagian Laba
    ${data.profitShares.map((item) => "- ${item.namaMitra}: ${item.persentase}% (${currencyFormatter.format(item.nominalDapat ?? 0)})").join('\n')}
    
    4. Neraca Modal (Opsional)
    ${data.neracaModal}
    
    5. Evaluasi & Keputusan
    Kegiatan usaha berjalan dengan ${data.isJalanLancar ? "lancar" : "ada kendala"} selama periode ini.
    Disepakati bahwa syirkah akan: ${data.isContinued ? "Dilanjutkan untuk periode berikutnya" : "Dibubarkan dan dilakukan likuidasi sesuai akad"}
    ${data.additionalNotes}
    
    6. Pernyataan & Tanda Tangan
    Kami menyatakan bahwa laporan ini telah disusun secara benar, jujur, dan sesuai prinsip syariah:
    
    Pihak A (Mitra)                       Pihak B (Mitra)
    
    
    
    Nama: ${data.namaMitraA}              Nama: ${data.namaMitraB}
    Tanggal: ${data.tanggalA != null ? DateFormat('dd/MM/yyyy').format(data.tanggalA!) : ""}              Tanggal: ${data.tanggalB != null ? DateFormat('dd/MM/yyyy').format(data.tanggalB!) : ""}
    """;

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/laporan_syirkah_${data.namaUsaha.replaceAll(' ', '_')}.txt',
    );
    await file.writeAsString(content);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Laporan Tutup Buku Syirkah \'Inan');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File teks disimpan karena template DOCX tidak tersedia'),
      ),
    );
  }

  Future<void> _printReport(ReportData data) async {
    final pdf = await _generatePdf(data);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan Syirkah ${data.namaUsaha}',
    );
  }
}

class ReportPreviewScreen extends StatelessWidget {
  final ReportData reportData;

  const ReportPreviewScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _exportToPdf(context, reportData);
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _printReport(context, reportData);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'LAPORAN TUTUP BUKU SYIRKAH \'INAN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('Periode: ${reportData.periodeWaktu}')),
                Expanded(child: Text('Nama Usaha: ${reportData.namaUsaha}')),
              ],
            ),
            Text('Alamat: ${reportData.alamatUsaha}'),
            const SizedBox(height: 24),

            // Ringkasan Akad
            _buildSectionTitle(context, '1. Ringkasan Akad Syirkah'),
            Text(reportData.ringkasanAkad),
            const SizedBox(height: 24),

            // Rekap Keuangan
            _buildSectionTitle(context, '2. Rekap Keuangan Usaha'),
            _buildSubSectionTitle(context, '2.1. Pendapatan'),
            _buildFinancialTable(
              context,
              ['Keterangan', 'Nominal (Rp)'],
              reportData.pendapatanItems
                  .map(
                    (item) => [
                      item.keterangan,
                      currencyFormatter.format(item.nominal ?? 0),
                    ],
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            _buildSubSectionTitle(
              context,
              '2.2. Pengeluaran & Biaya Operasional',
            ),
            _buildFinancialTable(
              context,
              ['Keterangan', 'Nominal (Rp)'],
              reportData.pengeluaranItems
                  .map(
                    (item) => [
                      item.keterangan,
                      currencyFormatter.format(item.nominal ?? 0),
                    ],
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            _buildSubSectionTitle(context, '2.3. Laba Bersih'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pendapatan:'),
                      Text(
                        currencyFormatter.format(reportData.totalPendapatan),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pengeluaran:'),
                      Text(
                        currencyFormatter.format(reportData.totalPengeluaran),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Laba Bersih:'),
                      Text(
                        currencyFormatter.format(reportData.labaBersih),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              reportData.labaBersih >= 0
                                  ? Colors.green.shade700
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pembagian Laba
            _buildSectionTitle(context, '3. Pembagian Laba'),
            _buildFinancialTable(
              context,
              ['Nama Mitra', 'Persentase (%)', 'Nominal (Rp)'],
              reportData.profitShares
                  .map(
                    (item) => [
                      item.namaMitra,
                      '${item.persentase ?? 0}%',
                      currencyFormatter.format(item.nominalDapat ?? 0),
                    ],
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Neraca Modal
            _buildSectionTitle(context, '4. Neraca Modal (Opsional)'),
            Text(reportData.neracaModal),
            const SizedBox(height: 24),

            // Evaluasi & Keputusan
            _buildSectionTitle(context, '5. Evaluasi & Keputusan'),
            Text(
              'Kegiatan usaha berjalan dengan ${reportData.isJalanLancar ? "lancar" : "ada kendala"} selama periode ini.',
            ),
            const SizedBox(height: 8),
            Text(
              'Disepakati bahwa syirkah akan: ${reportData.isContinued ? "Dilanjutkan untuk periode berikutnya" : "Dibubarkan dan dilakukan likuidasi sesuai akad"}',
            ),
            if (reportData.additionalNotes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Catatan Tambahan: ${reportData.additionalNotes}'),
                ],
              ),
            const SizedBox(height: 24),

            // Tanda Tangan
            _buildSectionTitle(context, '6. Pernyataan & Tanda Tangan'),
            const Text(
              'Kami menyatakan bahwa laporan ini telah disusun secara benar, jujur, dan sesuai prinsip syariah:',
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pihak A (Mitra)'),
                      const SizedBox(height: 40),
                      Text('Nama: ${reportData.namaMitraA}'),
                      Text(
                        'Tanggal: ${reportData.tanggalA != null ? DateFormat('dd/MM/yyyy').format(reportData.tanggalA!) : ""}',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pihak B (Mitra)'),
                      const SizedBox(height: 40),
                      Text('Nama: ${reportData.namaMitraB}'),
                      Text(
                        'Tanggal: ${reportData.tanggalB != null ? DateFormat('dd/MM/yyyy').format(reportData.tanggalB!) : ""}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSubSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFinancialTable(
    BuildContext context,
    List<String> headers,
    List<List<String>> data,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children:
                  headers
                      .map(
                        (header) => Expanded(
                          child: Text(
                            header,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          ...data.map(
            (row) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children:
                    row.map((cell) => Expanded(child: Text(cell))).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf(BuildContext context, ReportData data) async {
    final pdf = await _generatePdf(data);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/laporan_syirkah_${data.namaUsaha.replaceAll(' ', '_')}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Laporan Tutup Buku Syirkah \'Inan');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF disimpan di ${file.path}')));
  }

  Future<pw.Document> _generatePdf(ReportData data) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'LAPORAN TUTUP BUKU SYIRKAH \'INAN',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Periode: ${data.periodeWaktu}')),
                pw.Expanded(child: pw.Text('Nama Usaha: ${data.namaUsaha}')),
              ],
            ),
            pw.Text('Alamat: ${data.alamatUsaha}'),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '1. Ringkasan Akad Syirkah'),
            pw.Text(data.ringkasanAkad),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '2. Rekap Keuangan Usaha'),
            pw.Header(level: 2, text: '2.1. Pendapatan'),
            _buildPdfTable(
              ['Keterangan', 'Nominal (Rp)'],
              data.pendapatanItems
                  .map(
                    (item) => [
                      item.keterangan,
                      currencyFormatter.format(item.nominal ?? 0),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 8),

            pw.Header(level: 2, text: '2.2. Pengeluaran & Biaya Operasional'),
            _buildPdfTable(
              ['Keterangan', 'Nominal (Rp)'],
              data.pengeluaranItems
                  .map(
                    (item) => [
                      item.keterangan,
                      currencyFormatter.format(item.nominal ?? 0),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 8),

            pw.Header(level: 2, text: '2.3. Laba Bersih'),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pendapatan:'),
                      pw.Text(currencyFormatter.format(data.totalPendapatan)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Pengeluaran:'),
                      pw.Text(currencyFormatter.format(data.totalPengeluaran)),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Laba Bersih:'),
                      pw.Text(currencyFormatter.format(data.labaBersih)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '3. Pembagian Laba'),
            _buildPdfTable(
              ['Nama Mitra', 'Persentase (%)', 'Nominal (Rp)'],
              data.profitShares
                  .map(
                    (item) => [
                      item.namaMitra,
                      '${item.persentase ?? 0}%',
                      currencyFormatter.format(item.nominalDapat ?? 0),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '4. Neraca Modal (Opsional)'),
            pw.Text(data.neracaModal),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '5. Evaluasi & Keputusan'),
            pw.Text(
              'Kegiatan usaha berjalan dengan ${data.isJalanLancar ? "lancar" : "ada kendala"} selama periode ini.',
            ),
            pw.Text(
              'Disepakati bahwa syirkah akan: ${data.isContinued ? "Dilanjutkan untuk periode berikutnya" : "Dibubarkan dan dilakukan likuidasi sesuai akad"}',
            ),
            pw.Text(data.additionalNotes),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, text: '6. Pernyataan & Tanda Tangan'),
            pw.Text(
              'Kami menyatakan bahwa laporan ini telah disusun secara benar, jujur, dan sesuai prinsip syariah:',
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Pihak A (Mitra)'),
                      pw.SizedBox(height: 40),
                      pw.Text('Nama: ${data.namaMitraA}'),
                      pw.Text(
                        'Tanggal: ${data.tanggalA != null ? DateFormat('dd/MM/yyyy').format(data.tanggalA!) : ""}',
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Pihak B (Mitra)'),
                      pw.SizedBox(height: 40),
                      pw.Text('Nama: ${data.namaMitraB}'),
                      pw.Text(
                        'Tanggal: ${data.tanggalB != null ? DateFormat('dd/MM/yyyy').format(data.tanggalB!) : ""}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfTable(List<String> headers, List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children:
              headers
                  .map(
                    (header) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
        ),
        ...data.map(
          (row) => pw.TableRow(
            children:
                row
                    .map(
                      (cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(cell),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _printReport(BuildContext context, ReportData data) async {
    final pdf = await _generatePdf(data);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan Syirkah ${data.namaUsaha}',
    );
  }
}
