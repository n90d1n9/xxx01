
import 'package:flutter/material.dart';

class Promo02 extends StatefulWidget {
  const Promo02({Key? key}) : super(key: key);

  @override
  State<Promo02> createState() => _Promo02State();
}

class _Promo02State extends State<Promo02> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Pengaturan Kupon'),
      ),
      body: SingleChildScrollView(child: 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipe Promo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.delivery_dining),
                        SizedBox(width: 8),
                        Text('Gratis Ongkir'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.percent),
                        SizedBox(width: 8),
                        Text('Cashback'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.discount),
                  SizedBox(width: 8),
                  Text('Diskon'),
                  SizedBox(width: 8),
                  Text('BARU', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nominal Gratis Ongkir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Rp Min. Rp5.000',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Minimum Pembelian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Rp Contoh Rp20.000',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nominal harus lebih tinggi dari potongan harga.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kuota',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Contoh 100',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Target Pembeli',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Radio(
                  value: 'Semua Pembeli',
                  groupValue: 'Target Pembeli',
                  onChanged: (value) {},
                ),
                const Text('Semua Pembeli'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 'Follower Baru',
                  groupValue: 'Target Pembeli',
                  onChanged: (value) {},
                ),
                const Text('Follower Baru'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Estimasi Maks. Pengeluaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Lanjut'),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}