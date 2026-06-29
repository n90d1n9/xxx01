import 'package:flutter/material.dart';

class TransactionWidget extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String type;

  const TransactionWidget({
    Key? key,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Rp $amount',
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akrilik Barokah'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.file_copy),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8.0),
                Text(
                  '30 hari terakhir',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const Spacer(),
                Text(
                  '27 Mei 2021 → 26...',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari transaksi...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                TransactionWidget(
                  title: 'Kulakan akrilik',
                  amount: '180.000',
                  date: '28 Mei 2021',
                  type: 'Pengeluaran',
                ),
                TransactionWidget(
                  title: 'Tutup Buku',
                  amount: '694.700',
                  date: '31 Mei 2021',
                  type: 'Tutup Buku',
                ),
                TransactionWidget(
                  title: '3 stand holder custom Kasir Pintar',
                  amount: '360.000',
                  date: '07 Jun 2021',
                  type: 'Pemasukan',
                ),
                TransactionWidget(
                  title: 'beli 2 stand holder',
                  amount: '180.000',
                  date: '09 Jun 2021',
                  type: 'Pengeluaran',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('TAMBAH TRANSAKSI'),
            ),
          ),
        ],
      ),
    );
  }
}