import 'package:flutter/material.dart';

class KeuanganWidget extends StatelessWidget {
  const KeuanganWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.question_mark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Pendapatan'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Saldo',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Ringkasan',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Terakhir diperbarui: 1 Jan 2023, 08:08',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Pendapatan kotor'),
                trailing: const Text('Rp11.500.000'),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Pembayaran QRIS',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text('Potongan'),
                trailing: const Text('-Rp100.000'),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'MDR',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 8.0),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text('Promo'),
                trailing: const Text('-Rp19.000'),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: const Text('Pendapatan bersih'),
                trailing: const Text('Rp11.381.000'),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Aktivitas terakhir',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Riwayat aktivitas terakhir di toko Anda',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Pencairan - 12abc3'),
                subtitle: const Text('Jumlah'),
                trailing: const Text('23 Mei 2023, 10:00'),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Rp1.079.000',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Sukses',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('QRIS - 456de'),
                subtitle: const Text('Harga'),
                trailing: const Text('23 Mei 2023, 10:00'),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Rp750.000',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text(
                    'Potongan',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Rp732.750',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.home),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.money),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.percent),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}