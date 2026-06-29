
import 'package:flutter/material.dart';

class TransactionHistoryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Transaction history'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Date'),
                ),
                Expanded(
                  child: Text('Services'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                TransactionItem(
                  date: 'Friday, 24 May 2024',
                  service: 'GoPulsa - IM3 5.000 - 085794031941 #481135732-631657-GOPULSA',
                  amount: '-Rp6.500',
                  icon: Icons.payment,
                ),
                TransactionItem(
                  date: 'Saturday, 18 May 2024',
                  service: 'GoPulsa - SIMPATI Paket Internet Harian 10K 1 Hari - 085220570447 #476749624-608459-GOPULSA',
                  amount: '-Rp10.000',
                  icon: Icons.payment,
                ),
                TransactionItem(
                  date: 'Saturday, 11 May 2024',
                  service: 'Google Play Google Storage',
                  amount: '-Rp29.859',
                  icon: Icons.store,
                ),
                TransactionItem(
                  date: 'Friday, 26 Apr 2024',
                  service: 'GoPulsa - IM3 Freedom Internet 3GB / 30 Hari + Bonus Kuota Zona Hingga 2GB - 085794031941',
                  amount: '-Rp23.000',
                  icon: Icons.payment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String date;
  final String service;
  final String amount;
  final IconData icon;

  const TransactionItem({
    Key? key,
    required this.date,
    required this.service,
    required this.amount,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(service),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
