import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductForm extends ConsumerWidget {
  const ProductForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Info Product / Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Gambar'),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nama',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Kode / SKU',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Meja',
                  child: Text('Meja'),
                ),
                DropdownMenuItem(
                  value: 'Kursi',
                  child: Text('Kursi'),
                ),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Unit',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Buah',
                  child: Text('Buah'),
                ),
                DropdownMenuItem(
                  value: 'Set',
                  child: Text('Set'),
                ),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Harga & Pengaturan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Produk Bundle',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Nama Produk')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Harga')),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(Text('KY-15-001 | Kayu')),
                    DataCell(TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                    )),
                    DataCell(TextFormField(
                      initialValue: '0',
                      keyboardType: TextInputType.number,
                    )),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('CA-18-001 | Cat')),
                    DataCell(TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                    )),
                    DataCell(TextFormField(
                      initialValue: '0',
                      keyboardType: TextInputType.number,
                    )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Tambah Produk'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Akun (Centang Monitor Persediaan Barang untuk mengaktifkan)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('(5-50500) - Biaya Produksi (Cost of Sales)'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: '1500000',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Tambah Akun'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Total Harga',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '1500000',
                    keyboardType: TextInputType.number,
                    enabled: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Buat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}