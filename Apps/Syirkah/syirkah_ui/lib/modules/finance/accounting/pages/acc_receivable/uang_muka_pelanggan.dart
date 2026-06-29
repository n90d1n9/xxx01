import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UangMukaPelanggan extends ConsumerWidget {
  const UangMukaPelanggan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Rincian Uang Muka Pelanggan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SAMPLE DATA BUILD 6',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wednesday, February 01, 2017 - Tuesday, February 28, 2017',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'PT. JKL Teknologi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('No. Referensi')),
                DataColumn(label: Text('No Ref. Mutasi')),
                DataColumn(label: Text('Mata Uang')),
                DataColumn(label: Text('Saldo Awal')),
                DataColumn(label: Text('Mutasi')),
                DataColumn(label: Text('Saldo Akhir')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('2/1/2017')),
                    DataCell(Text('SA000004')),
                    DataCell(Text('')),
                    DataCell(Text('IDR')),
                    DataCell(Text('2,000,000.00')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('2/10/2017')),
                    DataCell(Text('')),
                    DataCell(Text('00000021')),
                    DataCell(Text('IDR')),
                    DataCell(Text('')),
                    DataCell(Text('-2,000,000.00')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('')),
                    DataCell(Text('Saldo SA000004')),
                    DataCell(Text('')),
                    DataCell(Text('IDR')),
                    DataCell(Text('2,000,000.00')),
                    DataCell(Text('-2,000,000.00')),
                    DataCell(Text('0.00')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('2/3/2017')),
                    DataCell(Text('SA000005')),
                    DataCell(Text('')),
                    DataCell(Text('IDR')),
                    DataCell(Text('3,000,000.00')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('2/10/2017')),
                    DataCell(Text('')),
                    DataCell(Text('00000021')),
                    DataCell(Text('IDR')),
                    DataCell(Text('')),
                    DataCell(Text('-2,560,000.00')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('')),
                    DataCell(Text('Saldo SA000005')),
                    DataCell(Text('')),
                    DataCell(Text('IDR')),
                    DataCell(Text('3,000,000.00')),
                    DataCell(Text('-2,560,000.00')),
                    DataCell(Text('440,000.00')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('')),
                    DataCell(Text('Saldo PT. JKL Teknologi')),
                    DataCell(Text('')),
                    DataCell(Text('IDR')),
                    DataCell(Text('5,000,000.00')),
                    DataCell(Text('-4,560,000.00')),
                    DataCell(Text('440,000.00')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('')),
                    DataCell(Text('Grand Total')),
                    DataCell(Text('')),
                    DataCell(Text('IDR')),
                    DataCell(Text('5,000,000.00')),
                    DataCell(Text('-4,560,000.00')),
                    DataCell(Text('440,000.00')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
