import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductBundle extends ConsumerWidget {
  const ProductBundle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga & Pengaturan'),
        actions: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('Produk Bundle'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama Produk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: 'MP-17-006 | Benang Merah Muda',
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8.0),
                DropdownButton<String>(
                  value: '10',
                  items: const [
                    DropdownMenuItem(
                      value: '10',
                      child: Text('10'),
                    ),
                    DropdownMenuItem(
                      value: '20',
                      child: Text('20'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Akun (Centang Monitor Persedian Barang untuk mengaktifkan)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: 'Pilih akun',
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text('Rp. 0'),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Total Harga',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Rp. 200.000',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Buat produk'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}