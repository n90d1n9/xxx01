import 'package:flutter/material.dart';

class JournalEntry extends StatelessWidget {
  final String title;
  final String description;
  final String debit;
  final String credit;
  final String date;

  const JournalEntry({
    Key? key,
    required this.title,
    required this.description,
    required this.debit,
    required this.credit,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Debit (D)',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  debit,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit (C)',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  credit,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                date,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalWidget extends StatelessWidget {
  const JournalWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Umum'),
        leading: const BackButton(),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Hari ini',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          JournalEntry(
            title: 'Pengeluaran',
            description: 'Biaya cetak banner untuk depan toko',
            debit: 'Rp 120,000',
            credit: 'Rp 120,000',
            date: '15 Jul 2020',
          ),
          const SizedBox(height: 16),
          JournalEntry(
            title: 'Pengeluaran',
            description: 'Being komisi ke Pak Rudy',
            debit: 'Rp 20,000',
            credit: 'Rp 20,000',
            date: '15 Jul 2020',
          ),
          const SizedBox(height: 16),
          JournalEntry(
            title: 'Pemasukan',
            description: 'Penjualan kipas angin Maspion',
            debit: 'Rp 250,000',
            credit: 'Rp 250,000',
            date: '15 Jul 2020',
          ),
          const SizedBox(height: 16),
          JournalEntry(
            title: 'Pengeluaran',
            description: 'Bayar air PDAM',
            debit: 'Rp 75,000',
            credit: 'Rp 75,000',
            date: '15 Jul 2020',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}