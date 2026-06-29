import 'package:flutter/material.dart';

class BukuBesarWidget extends StatelessWidget {
  const BukuBesarWidget({Key? key}) : super(key: key);

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
        title: const Text('Buku Besar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '01 Jul 2020 - 31 Jul 2020',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionRow(
                    date: '15 Jul 2020',
                    description: 'Biaya cetak banner untuk depan toko',
                    debit: 0,
                    credit: 120000,
                    balance: 310000,
                  ),
                  _buildTransactionRow(
                    date: '15 Jul 2020',
                    description: 'Being komisi ke Pak Rudy',
                    debit: 0,
                    credit: 20000,
                    balance: 290000,
                  ),
                  _buildTransactionRow(
                    date: '15 Jul 2020',
                    description: 'Penjualan kipas angin Maspion',
                    debit: 250000,
                    credit: 0,
                    balance: 540000,
                  ),
                  _buildTransactionRow(
                    date: '15 Jul 2020',
                    description: 'Bayar air PDAM',
                    debit: 0,
                    credit: 75000,
                    balance: 465000,
                  ),
                  _buildTransactionRow(
                    date: '15 Jul 2020',
                    description: 'Hutang ke Pak Eko beli perabotan',
                    debit: 230000,
                    credit: 0,
                    balance: 695000,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saldo Akhir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 695,000',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Piutang Usaha',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTransactionRow(
                    date: '30 Jun 2020',
                    description: 'Saldo awal',
                    debit: 556500,
                    credit: 0,
                    balance: 556500,
                  ),
                  _buildTransactionRow(
                    date: '01 Jul 2020',
                    description: 'ok',
                    debit: 0,
                    credit: 1000,
                    balance: 555500,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saldo Akhir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 555,500',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Persediaan Barang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow({
    required String date,
    required String description,
    required int debit,
    required int credit,
    required int balance,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              debit.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              credit.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              balance.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}