import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductHarga extends ConsumerWidget {
  const ProductHarga({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga & Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Produk Bundle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Saya Produk Ini
            Row(
              children: [
                Checkbox(
                  value: ref.watch(productProvider).isProduct,
                  onChanged: (value) {
                    ref.read(productProvider).isProduct = value!;
                  },
                ),
                const Text('Saya Produk Ini'),
              ],
            ),
            const SizedBox(height: 16),
            // Harga Beli Satuan
            TextField(
              decoration: const InputDecoration(
                labelText: 'Harga Beli Satuan',
                prefixText: 'Rp. ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref.read(productProvider).buyPrice = double.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            // Akun Pembelian
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Akun Pembelian',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Pilih akun',
                  child: Text('Pilih akun'),
                ),
                DropdownMenuItem(
                  value: 'Akun 1',
                  child: Text('Akun 1'),
                ),
                DropdownMenuItem(
                  value: 'Akun 2',
                  child: Text('Akun 2'),
                ),
              ],
              onChanged: (value) {
                ref.read(productProvider).buyAccount = value!;
              },
            ),
            const SizedBox(height: 16),
            // Pajak Beli
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pajak Beli',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Pilih pajak',
                  child: Text('Pilih pajak'),
                ),
                DropdownMenuItem(
                  value: 'Pajak 1',
                  child: Text('Pajak 1'),
                ),
                DropdownMenuItem(
                  value: 'Pajak 2',
                  child: Text('Pajak 2'),
                ),
              ],
              onChanged: (value) {
                ref.read(productProvider).buyTax = value!;
              },
            ),
            const SizedBox(height: 32),
            // Saya Produk Ini
            Row(
              children: [
                Checkbox(
                  value: ref.watch(productProvider).isProduct,
                  onChanged: (value) {
                    ref.read(productProvider).isProduct = value!;
                  },
                ),
                const Text('Saya Jual Produk Ini'),
              ],
            ),
            const SizedBox(height: 16),
            // Harga Jual Satuan
            TextField(
              decoration: const InputDecoration(
                labelText: 'Harga Jual Satuan',
                prefixText: 'Rp. ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref.read(productProvider).sellPrice = double.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            // Akun Penjualan
            TextField(
              decoration: const InputDecoration(
                labelText: 'Akun Penjualan',
              ),
              controller: TextEditingController(
                text: '(4-40000) - Pendapatan (Income)',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            // Pajak Jual
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pajak Jual',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Pilih pajak',
                  child: Text('Pilih pajak'),
                ),
                DropdownMenuItem(
                  value: 'Pajak 1',
                  child: Text('Pajak 1'),
                ),
                DropdownMenuItem(
                  value: 'Pajak 2',
                  child: Text('Pajak 2'),
                ),
              ],
              onChanged: (value) {
                ref.read(productProvider).sellTax = value!;
              },
            ),
            const SizedBox(height: 32),
            // Monitor Persediaan Barang
            Row(
              children: [
                Checkbox(
                  value: ref.watch(productProvider).isStock,
                  onChanged: (value) {
                    ref.read(productProvider).isStock = value!;
                  },
                ),
                const Text('Monitor Persediaan Barang'),
              ],
            ),
            const SizedBox(height: 16),
            // Batas Stok Minimum
            TextField(
              decoration: const InputDecoration(
                labelText: 'Batas Stok Minimum',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref.read(productProvider).stockMinimum = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            // Akun Persediaan Barang Default
            TextField(
              decoration: const InputDecoration(
                labelText: 'Akun Persediaan Barang Default',
              ),
              controller: TextEditingController(
                text: '(1-10200) - Persediaan Barang (Inventory)',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 32),
            // *kuantitas awal dapat dicatat melalui stok opname
            const Text(
              '*kuantitas awal dapat dicatat melalui stok opname',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    
                  },
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    
                  },
                  child: const Text('Buat Produk'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  bool isProduct;
  double buyPrice;
  String buyAccount;
  String buyTax;
  bool isStock;
  double sellPrice;
  String sellTax;
  int stockMinimum;

  Product({
    required this.isProduct,
    required this.buyPrice,
    required this.buyAccount,
    required this.buyTax,
    required this.isStock,
    required this.sellPrice,
    required this.sellTax,
    required this.stockMinimum,
  });
}

final productProvider = StateNotifierProvider<ProductNotifier, Product>(
  (ref) => ProductNotifier(),
);

class ProductNotifier extends StateNotifier<Product> {
  ProductNotifier() : super(Product(
    isProduct: false,
    buyPrice: 0,
    buyAccount: 'Pilih akun',
    buyTax: 'Pilih pajak',
    isStock: false,
    sellPrice: 0,
    sellTax: 'Pilih pajak',
    stockMinimum: 0,
  ));
}