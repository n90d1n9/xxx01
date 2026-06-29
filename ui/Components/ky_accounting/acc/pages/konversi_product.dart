import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KonversiProduk extends ConsumerWidget {
  const KonversiProduk({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meja',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Quantity'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: '10',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Quantity',
                      suffixText: 'pcs',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Tanggal Konversi'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: '02/11/2018',
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      hintText: 'Tanggal Konversi',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Gudang'),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: 'Toko B',
                    items: const [
                      DropdownMenuItem(
                        value: 'Toko A',
                        child: Text('Toko A'),
                      ),
                      DropdownMenuItem(
                        value: 'Toko B',
                        child: Text('Toko B'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Detail Konversi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Produk')),
                DataColumn(label: Text('Kuantitas per Set (pcs)')),
                DataColumn(label: Text('Biaya per Unit (pcs)')),
                DataColumn(label: Text('Kuantitas')),
                DataColumn(label: Text('Jumlah Estimasi')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('Kayu')),
                    DataCell(Text('1.0 M3')),
                    DataCell(Text('200000')),
                    DataCell(Text('10 M3')),
                    DataCell(Text('2000000')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Cat')),
                    DataCell(Text('1.0 Kaleng')),
                    DataCell(Text('20000')),
                    DataCell(Text('10 Kaleng')),
                    DataCell(Text('200000')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Biaya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DataTable(
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('Biaya per Unit (pcs)')),
                DataColumn(label: Text('Pengalian')),
                DataColumn(label: Text('Jumlah')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('Biaya Produksi')),
                    DataCell(Text('1500000.0')),
                    DataCell(Text('10')),
                    DataCell(Text('15000000')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Biaya Tetap',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('+ Tambah Biaya'),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('Biaya Total Konversi')),
                    DataCell(Text('17200000')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Biaya per Unit')),
                    DataCell(Text('1720000')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Back'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}