import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qr01 extends StatelessWidget {
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
        title: Text('Checkout'),
        backgroundColor: Colors.lightBlue,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Batalkan transaksi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jumlah',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '450.000',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            QrImageView(
              data: 'your_qr_code_data',
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text(
              'Scan untuk Bayar',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}