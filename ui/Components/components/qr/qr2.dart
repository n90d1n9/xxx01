import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGenerator extends StatelessWidget {
  final String data;

  const QrCodeGenerator({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: const Center(
        child: Text('kosong') /* QrImage(
          data: data,
          version: QrVersions.auto,
          size: 200.0,
          gapless: true,
        ) */
      ),
    );
  }
}