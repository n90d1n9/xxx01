
import 'package:flutter/material.dart';

class Promo03 extends StatefulWidget {
  const Promo03({Key? key}) : super(key: key);

  @override
  State<Promo03> createState() => _Promo03State();
}

class _Promo03State extends State<Promo03> {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipe Promo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Gratis Ongkir button press
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pilih tipe promo untuk kuponmu'),
                          content: const Text(
                              'Tentukan mau kasih promo berupa potongan ongkir, cashback, atau potongan harga langsung saat checkout, ke pembeli yang pakai kuponmu.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Lanjut'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.delivery_dining),
                      SizedBox(width: 8),
                      Text('Gratis Ongkir'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Cashback button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.percent),
                      SizedBox(width: 8),
                      Text('Cashback'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Minimum Pembelian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Rp Contoh Rp20.000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nominal harus lebih tinggi dari potongan harga.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Text('Kuota'),
                SizedBox(width: 8),
                Icon(Icons.info_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}