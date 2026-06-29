import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QrisWidget extends StatefulWidget {
  const QrisWidget({Key? key}) : super(key: key);

  @override
  State<QrisWidget> createState() => _QrisWidgetState();
}

class _QrisWidgetState extends State<QrisWidget> {
  String? qrCodeData;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<void> _generateQrCode() async {
    // Replace with your actual QRIS API endpoint and parameters
    final response = await http.get(Uri.parse('https://your-qris-api.com/generate'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        qrCodeData = data['qr_code'];
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRIS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (qrCodeData != null)
              QrImageView(
                data: qrCodeData!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            const SizedBox(height: 20),
            Text(
              'TOKO AKU KAMU DAN MEREKA',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'NMID: ID1020000069200',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text('A01'),
            const SizedBox(height: 20),
            const Text(
              'Diotak Oleh: SPEEDCASH',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              'Versi Cetak: 1.0.2021.03.08',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}