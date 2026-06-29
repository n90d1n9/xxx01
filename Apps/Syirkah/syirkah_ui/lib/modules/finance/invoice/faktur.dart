import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakturPage extends ConsumerWidget {
  const FakturPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'FAKTUR PAJAK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kode dan Nomor Seri Faktur Pajak:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Pengusaha Kena Pajak
            const Text(
              'Pengusaha Kena Pajak',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: 'Nama', value: 'Contoh Laporan Zahir Accounting'),
            const _InvoiceField(label: 'Alamat', value: 'Jalan Kemang Selatan 1C No. 20 Mampang Prapatan, Jakarta, Indonesia, 12730'),
            const _InvoiceField(label: 'NPWP', value: ''),
            const SizedBox(height: 16),
            // Pembeli Barang Kena Pajak/Penerima Jasa Kena Pajak
            const Text(
              'Pembeli Barang Kena Pajak/Penerima Jasa Kena Pajak',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: 'Nama', value: 'Adraja'),
            const _InvoiceField(label: 'Alamat', value: ''),
            const _InvoiceField(label: 'NPWP', value: ''),
            const SizedBox(height: 16),
            // Invoice Items
            const Text(
              'Nama Barang Kena Pajak / Jasa Kena Pajak',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceTable(
              items: [
                {'no': 1, 'name': 'Set Komputer', 'price': 5000000.00},
              ],
            ),
            const SizedBox(height: 16),
            // Total
            const Text(
              'Jumlah Harga Jual / Penggantian / Uang Muka / Termijn **)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: '', value: '5.000.000,00'),
            const SizedBox(height: 8),
            const Text(
              'Dikurangi Potongan Harga',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: '', value: '0,00'),
            const SizedBox(height: 8),
            const Text(
              'Dikurangi Uang Muka yang Telah Diterima',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: '', value: '0,00'),
            const SizedBox(height: 8),
            const Text(
              'Dasar Pengenaan Pajak',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: '', value: '5.000.000,00'),
            const SizedBox(height: 8),
            const Text(
              'PPN = 10% x Dasar Pengenaan Pajak',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: '', value: '500.000,00'),
            const SizedBox(height: 16),
            // Pajak Penjualan Atas Barang Mewah
            const Text(
              'Pajak Penjualan Atas Barang Mewah',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _InvoiceTable(
              items: [
                {'tarif': '%', 'dpp': 'Rp.', 'ppn': 'Rp.'},
                {'tarif': '%', 'dpp': 'Rp.', 'ppn': 'Rp.'},
                {'tarif': '%', 'dpp': 'Rp.', 'ppn': 'Rp.'},
                {'tarif': '%', 'dpp': 'Rp.', 'ppn': 'Rp.'},
                {'tarif': '%', 'dpp': 'Rp.', 'ppn': 'Rp.'},
              ],
            ),
            const SizedBox(height: 8),
            const _InvoiceField(label: 'Jumlah', value: 'Rp.'),
            const SizedBox(height: 16),
            // Footer
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Jakarta, 09 January 2014'),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.black,
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

class _InvoiceField extends StatelessWidget {
  const _InvoiceField({Key? key, required this.label, required this.value}) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
          ),
        ),
      ],
    );
  }
}

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable({Key? key, required this.items}) : super(key: key);

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      children: [
        const TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No. Urut',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Nama Barang Kena Pajak / Jasa Kena Pajak',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Harga Jual/Penggantian Uang Muka/Termijn (Rp)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        ...items.map((item) {
          return TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item['no'].toString(),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item['name'],
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item['price'].toString(),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}
